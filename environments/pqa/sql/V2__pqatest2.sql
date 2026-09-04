-- ============================================================
-- Set 2 / V2: Add email verification tracking
-- Tests: multiple ADD COLUMN in one statement, conditional UPDATE
-- ============================================================

-- DDL
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;

-- DML
UPDATE users
SET is_verified = true,
    verified_at = now()
WHERE username IN ('sarath.k', 'priya.n');
