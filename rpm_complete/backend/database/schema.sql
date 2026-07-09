-- ════════════════════════════════════════════════════════════════
--  Rajapalayam Municipality · Family Survey System
--  PostgreSQL schema  (database: rajapalayam_survey)
--
--  Run with:
--    psql -U <user> -d rajapalayam_survey -f schema.sql
-- ════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────
--  Extensions
-- ────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ────────────────────────────────────────────────────────────────
--  WARDS  — Rajapalayam Municipality, 42 wards (with LGD codes)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wards (
  id        SERIAL PRIMARY KEY,
  ward_no   INTEGER NOT NULL UNIQUE CHECK (ward_no BETWEEN 1 AND 42),
  ward_name TEXT    NOT NULL UNIQUE,         -- e.g. "Ward 1 (LGD: 43107)"
  lgd_code  INTEGER NOT NULL UNIQUE
);

-- ────────────────────────────────────────────────────────────────
--  COLLECTORS — survey collectors (one record per name + ward pair)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS collectors (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  ward       TEXT NOT NULL,                  -- matches surveys.ward / wards.ward_name
  ward_id    INTEGER REFERENCES wards(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login TIMESTAMPTZ,
  UNIQUE (name, ward)
);

-- ────────────────────────────────────────────────────────────────
--  ADMINS — administrator credentials (password hashed with bcrypt)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admins (
  id            SERIAL PRIMARY KEY,
  username      TEXT NOT NULL UNIQUE DEFAULT 'admin',
  password_hash TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────────────
--  Sequence used to generate human-friendly survey codes
--  e.g. RPM-000001, RPM-000002, ...
-- ────────────────────────────────────────────────────────────────
CREATE SEQUENCE IF NOT EXISTS survey_code_seq START WITH 1 INCREMENT BY 1;

-- ────────────────────────────────────────────────────────────────
--  FAMILIES / SURVEYS — one row per family survey
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS surveys (
  id              SERIAL PRIMARY KEY,
  survey_id       TEXT NOT NULL UNIQUE
                    DEFAULT ('RPM-' || LPAD(nextval('survey_code_seq')::TEXT, 6, '0')),

  -- Location / identification
  ward            TEXT NOT NULL,             -- e.g. "Ward 1 (LGD: 43107)"
  ward_id         INTEGER REFERENCES wards(id) ON DELETE SET NULL,
  door            TEXT NOT NULL,
  street          TEXT NOT NULL,

  -- Family identity
  famno           TEXT,                      -- Family Register No.
  head            TEXT NOT NULL,             -- Family Head Name
  ration          TEXT,                      -- Ration Card No.
  abha            TEXT,                      -- ABHA ID
  pmja            TEXT,                      -- PMJA No.
  phr             TEXT,                      -- PHR No.
  smartcard       TEXT,                      -- Smart Card ID
  phone           TEXT NOT NULL CHECK (phone ~ '^[6-9][0-9]{9}$'),

  -- Household details
  bpl             TEXT,                      -- BPL / APL
  caste           TEXT,                      -- Community (Caste)
  insurance       TEXT,                      -- Govt / Private Health Insurance (Yes/No)
  housing         TEXT,                      -- Type of House
  water           TEXT,                      -- Water Source
  toilet          TEXT,                      -- Toilet Facility
  status          TEXT NOT NULL DEFAULT 'Submitted',

  -- Collection metadata
  collector       TEXT NOT NULL,
  collector_ward  TEXT NOT NULL,
  survey_date     TEXT NOT NULL,             -- stored as displayed (en-IN format, dd/mm/yyyy)

  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Speeds up the duplicate-family check (Ward + Street + Door)
CREATE INDEX IF NOT EXISTS idx_surveys_dup_lookup
  ON surveys (ward, street, door);

CREATE INDEX IF NOT EXISTS idx_surveys_ward       ON surveys (ward);
CREATE INDEX IF NOT EXISTS idx_surveys_collector  ON surveys (collector);
CREATE INDEX IF NOT EXISTS idx_surveys_ward_id    ON surveys (ward_id);
CREATE INDEX IF NOT EXISTS idx_surveys_date       ON surveys (survey_date);

-- ────────────────────────────────────────────────────────────────
--  FAMILY MEMBERS — one row per person within a family
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS family_members (
  id                    SERIAL PRIMARY KEY,
  survey_id             INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,

  memno                 TEXT,
  name                  TEXT NOT NULL,
  rel                   TEXT,                -- Relationship to Head
  dob                   DATE NOT NULL,
  age                   INTEGER,
  gender                TEXT,

  aadhar                TEXT CHECK (aadhar = '' OR aadhar ~ '^[0-9 ]{12,14}$'),
  mobile                TEXT CHECK (mobile = '' OR mobile ~ '^[6-9][0-9]{9}$'),
  blood                 TEXT,
  marital               TEXT,

  edu                   TEXT,
  occ                   TEXT,
  income                TEXT,
  religion              TEXT,

  death_date            DATE,
  death_reason          TEXT,
  new_mem_date          DATE,
  new_mem_reason        TEXT,

  disability            TEXT,
  has_chronic_disease   TEXT,
  chronic_ncd           TEXT,
  chronic_cd            TEXT,
  treatment_place       TEXT,

  schemes               TEXT,
  vaccination           TEXT,
  remarks               TEXT,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_members_survey   ON family_members (survey_id);
CREATE INDEX IF NOT EXISTS idx_members_aadhar   ON family_members (aadhar) WHERE aadhar <> '';
CREATE INDEX IF NOT EXISTS idx_members_gender   ON family_members (gender);

-- ────────────────────────────────────────────────────────────────
--  ELIGIBLE COUPLES — one row per eligible couple within a family
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS eligible_couples (
  id                       SERIAL PRIMARY KEY,
  survey_id                INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,

  frno                     TEXT,             -- Family Register No.
  ecno                     TEXT,             -- EC No.
  rchid                    TEXT,             -- RCH ID (woman)

  husband_name             TEXT,
  wife_name                TEXT,
  reg_date                 DATE,

  bank_ac                  TEXT,
  bank_branch              TEXT,

  husband_age_at_marriage  TEXT,
  wife_age_at_marriage     TEXT,
  mother_current_age       TEXT,

  total_pregnancies        TEXT,
  living_sons              TEXT,
  living_daughters         TEXT,
  abortions                TEXT,

  youngest_child_dob       DATE,
  last_delivery_date       DATE,
  child_born_this_year     TEXT,

  last_delivery_place      TEXT,
  delivery_type            TEXT,
  post_delivery_health     TEXT,

  contraceptive_method     TEXT,
  stopping_or_spacing      TEXT,
  no_contra_reason         TEXT,

  sterilisation_date       DATE,
  sterilisation_place      TEXT,

  pregnancy_test           TEXT,
  an_number                TEXT,
  anc_done                 TEXT,
  anc_date                 DATE,
  next_visit                DATE,

  planned_delivery_place   TEXT,
  current_health_status    TEXT,
  remarks                  TEXT,

  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_couples_survey ON eligible_couples (survey_id);

-- ────────────────────────────────────────────────────────────────
--  AUDIT LOGS — track create / update / delete operations
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_logs (
  id          SERIAL PRIMARY KEY,
  actor_role  TEXT NOT NULL,        -- 'collector' | 'admin'
  actor_name  TEXT NOT NULL,
  action      TEXT NOT NULL,        -- 'CREATE' | 'UPDATE' | 'DELETE' | 'DELETE_ALL' | 'LOGIN' | 'EXPORT'
  entity      TEXT,                 -- 'survey', etc.
  entity_id   TEXT,
  details     JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs (created_at);
CREATE INDEX IF NOT EXISTS idx_audit_actor   ON audit_logs (actor_name);

-- ────────────────────────────────────────────────────────────────
--  updated_at trigger for surveys
-- ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_surveys_updated_at ON surveys;
CREATE TRIGGER trg_surveys_updated_at
  BEFORE UPDATE ON surveys
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ────────────────────────────────────────────────────────────────
--  SEED DATA — 42 wards of Rajapalayam Municipality
--  ward_name format matches the frontend WARDS[] array exactly:
--  "Ward <n> (LGD: <43107 + n - 1>)"
-- ────────────────────────────────────────────────────────────────
INSERT INTO wards (ward_no, ward_name, lgd_code)
SELECT n, 'Ward ' || n || ' (LGD: ' || (43106 + n) || ')', (43106 + n)
FROM generate_series(1, 42) AS n
ON CONFLICT (ward_no) DO NOTHING;

-- ────────────────────────────────────────────────────────────────
--  SEED DATA — Default admin account
--  Default password: admin123  (CHANGE THIS IMMEDIATELY IN PRODUCTION)
--  Hash generated with bcrypt, 10 rounds.
--  To generate your own hash:
--    node -e "console.log(require('bcryptjs').hashSync('yourpassword', 10))"
-- ────────────────────────────────────────────────────────────────
INSERT INTO admins (username, password_hash)
VALUES ('admin', '$2b$10$kM8BAS9DfRldKPVOLVbqFeyPOPB4Qu5FL023rYsEjmLTC7rrtbvhC')
ON CONFLICT (username) DO NOTHING;

-- ────────────────────────────────────────────────────────────────
--  CITIZEN MODULE — Complaints and Correction Requests
-- ────────────────────────────────────────────────────────────────

-- 1. Complaints Table
CREATE TABLE IF NOT EXISTS complaints (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    citizen_mobile TEXT NOT NULL CHECK (citizen_mobile ~ '^[6-9][0-9]{9}$'),
    issue_type TEXT NOT NULL,
    description TEXT,
    street TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Received',
    evidence_photos TEXT[],
    citizen_feedback TEXT,
    citizen_rating INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Correction Requests Table
CREATE TABLE IF NOT EXISTS correction_requests (
    id SERIAL PRIMARY KEY,
    survey_id INTEGER NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    field_name TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    status TEXT NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Prevent duplicate active complaints for the same issue on the same street
CREATE UNIQUE INDEX IF NOT EXISTS idx_dedupe_complaints
ON complaints (street, issue_type)
WHERE status NOT IN ('Resolved', 'Closed');
