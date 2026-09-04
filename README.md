# Flyway Deployment Pipeline for PostgreSQL

This repository manages database schema changes (DDL/DML) for **`APPLICATION`** using [Flyway](https://flywaydb.org/) and GitHub Actions. Application teams add SQL migration files and merge to `master` — the pipeline takes care of the rest.

---

## 1. Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── flyway.yml          # Single shared workflow — handles all environments
└── environments/
    ├── dev/
    │   ├── dev.conf             # Flyway config for DEV
    │   └── sql/
    │       ├── V1__init.sql
    │       └── V2__add_column.sql
    ├── uat/
    │   ├── uat.conf
    │   └── sql/
    ├── cug/
    │   ├── cug.conf
    │   └── sql/
    ├── pqa/
    │   ├── pqa.conf
    │   └── sql/
    └── prod/
        ├── prod.conf
        └── sql/
```

Each environment folder is **independent** — its own config file and its own `sql/` folder with its own `V1, V2, V3…` versioning. A migration added to `uat/sql/` has no effect on `prod/sql/`, and vice versa.

---

## 2. One-Time Setup (done by DBRE team during onboarding)

The items below are provisioned when the repo is created. App teams don't need to touch these unless adding a new environment.

### 2.1 Environment config (`<env>.conf`)
Each `environments/<env>/<env>.conf` holds the Flyway connection settings for that environment's database (host, port, DB name, schema). Credentials are **not** stored in this file.

### 2.2 Secrets
DB credentials and the Slack webhook are stored as **GitHub repository secrets** (Settings → Secrets and variables → Actions), named per environment, e.g.:

| Secret name | Purpose |
|---|---|
| `PG_USER` / `PG_PASSWORD` | Create such set of secrets for each environmet, with its values |
| `SLACK_WEBHOOK_URL` | Incoming webhook URL for pipeline notifications |

> Only the DBRE team can view/rotate these values once set — they never appear in logs or in this repo's code.

### 2.3 Slack Webhook
A Slack incoming webhook is created for the team channel and stored as the `SLACK_WEBHOOK_URL` secret above. The workflow posts to this webhook after every run — see [Section 5](#5-slack-notifications).

---

## 3. Adding a Migration (what the app team does)

1. **Create a new SQL file** under the correct environment's `sql/` folder, e.g. `environments/uat/sql/V3__add_orders_index.sql`.
2. **Follow Flyway naming convention** so migrations apply in order:
   ```
   V<version>__<description>.sql
   e.g. V3__add_orders_index.sql
   ```
   - Version numbers must be higher than the last applied version in that environment and must not repeat.
   - Use double underscores (`__`) between the version and the description.
3. **Open a Pull Request** into `master` with the new file.
4. **Merge to `master`** once reviewed/approved.

That's it — no manual DB access, no manual Flyway commands.

---

## 4. How the Pipeline Runs

1. A merge to `master` that touches files under `environments/<env>/sql/` triggers the shared workflow (`.github/workflows/flyway.yml`).
2. The workflow runs on a self-hosted GitHub Actions runner (runner target may vary per run — Flyway is installed fresh in the job, not pre-baked on a fixed runner).
3. The workflow:
   - Detects which environment(s) had SQL changes.
   - Loads that environment's `<env>.conf` and its DB secrets.
   - Runs `flyway migrate` against that environment's database, applying only the new/pending versioned scripts.
4. Only environments with new SQL files in that merge are deployed to — other environments are untouched.

---

## 5. Slack Notifications

At the end of each run, the workflow posts a message to the `SLACK_WEBHOOK_URL` channel:

- ✅ **Success** — environment, migration version(s) applied, and who merged the PR.
- ❌ **Failure** — environment, the failing script, and the Flyway error output, so it can be fixed and re-merged.

---

## 6. FAQ

**Q: I need to add a new environment (e.g. a new UAT region). What do I do?**
A: Raise a request with the DBRE team — they'll provision the DB role, add the `<env>.conf`, create the `sql/` folder, and add the required secrets.

**Q: Can I run a migration manually / out of band?**
A: No — all changes must go through a merge to `master` so there's a full audit trail and Slack visibility. Contact DBRE for emergency/hotfix procedures.

**Q: What if my migration fails halfway?**
A: Flyway tracks applied versions in its schema history table. Fix the SQL, do **not** reuse the failed version number — add a new version (e.g. if `V3` failed, submit a corrected `V4`) unless DBRE advises otherwise.

**Q: Where do I see past migration history?**
A: Flyway maintains a `flyway_schema_history` table in each database showing every applied version, checksum, and timestamp.

---

For pipeline issues or DB access requests, reach out to the DBRE team.
