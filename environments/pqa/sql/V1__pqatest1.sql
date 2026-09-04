-- ============================================================
-- Set 2 / V1: Create users table + seed rows
-- Tests: UNIQUE constraint, basic seed DML
-- ============================================================

-- DDL
CREATE TABLE IF NOT EXISTS users (
    user_id    BIGSERIAL PRIMARY KEY,
    username   TEXT NOT NULL UNIQUE,
    email      TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- DML
INSERT INTO users (username, email) VALUES
    ('sarath.k',    'sarath.k@example.com'),
    ('priya.n',     'priya.n@example.com'),
    ('rohan.d',     'rohan.d@example.com');
