-- =============================================================================
-- System rezerwacji sal i sprzętu w uczelni
-- 01_schema.sql — definicja tabel, kluczy, indeksów i ograniczeń
-- PostgreSQL 14+
-- =============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Wydziały
-- ---------------------------------------------------------------------------
CREATE TABLE faculties (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(128) NOT NULL,
    code        VARCHAR(16)  NOT NULL UNIQUE
);

COMMENT ON TABLE faculties IS 'Jednostki organizacyjne uczelni (wydziały).';
COMMENT ON COLUMN faculties.code IS 'Skrót wydziału, np. WI, WE.';

-- ---------------------------------------------------------------------------
-- Użytkownicy
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    first_name  VARCHAR(64)  NOT NULL,
    last_name   VARCHAR(64)  NOT NULL,
    role        VARCHAR(20)  NOT NULL
                CHECK (role IN ('student', 'lecturer', 'admin')),
    faculty_id  INTEGER REFERENCES faculties(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE users IS 'Użytkownicy systemu: studenci, wykładowcy, administratorzy.';
COMMENT ON COLUMN users.role IS 'Rola: student | lecturer | admin.';

CREATE INDEX idx_users_faculty_id ON users (faculty_id);

-- ---------------------------------------------------------------------------
-- Budynki
-- ---------------------------------------------------------------------------
CREATE TABLE buildings (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(128) NOT NULL,
    address     VARCHAR(255) NOT NULL,
    campus      VARCHAR(64)  NOT NULL
);

COMMENT ON TABLE buildings IS 'Budynki uczelni na poszczególnych kampusach.';

-- ---------------------------------------------------------------------------
-- Sale
-- ---------------------------------------------------------------------------
CREATE TABLE rooms (
    id                    SERIAL PRIMARY KEY,
    building_id           INTEGER NOT NULL REFERENCES buildings(id) ON DELETE RESTRICT,
    room_number           VARCHAR(32)  NOT NULL,
    name                  VARCHAR(128) NOT NULL,
    capacity              INTEGER NOT NULL CHECK (capacity > 0),
    has_builtin_projector BOOLEAN NOT NULL DEFAULT FALSE,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (building_id, room_number)
);

COMMENT ON TABLE rooms IS 'Sale wykładowe i konferencyjne w budynkach.';
COMMENT ON COLUMN rooms.is_active IS 'FALSE = sala niedostępna (np. remont), bez nowych rezerwacji.';

CREATE INDEX idx_rooms_building_id ON rooms (building_id);

-- ---------------------------------------------------------------------------
-- Sprzęt multimedialny
-- ---------------------------------------------------------------------------
CREATE TABLE equipment (
    id                 SERIAL PRIMARY KEY,
    name               VARCHAR(128) NOT NULL,
    inventory_number   VARCHAR(64)  NOT NULL UNIQUE,
    equipment_type     VARCHAR(32)  NOT NULL,
    is_portable        BOOLEAN NOT NULL DEFAULT TRUE,
    quantity_available INTEGER NOT NULL CHECK (quantity_available >= 0)
);

COMMENT ON TABLE equipment IS 'Ewidencja sprzętu do wypożyczenia przy rezerwacjach.';
COMMENT ON COLUMN equipment.equipment_type IS 'Np. projector, microphone, camera.';

-- ---------------------------------------------------------------------------
-- Rezerwacje sal
-- ---------------------------------------------------------------------------
CREATE TABLE reservations (
    id          SERIAL PRIMARY KEY,
    room_id     INTEGER NOT NULL REFERENCES rooms(id) ON DELETE RESTRICT,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title       VARCHAR(255) NOT NULL,
    purpose     TEXT,
    starts_at   TIMESTAMPTZ NOT NULL,
    ends_at     TIMESTAMPTZ NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);

COMMENT ON TABLE reservations IS 'Rezerwacje terminów sal przez użytkowników.';
COMMENT ON COLUMN reservations.status IS 'pending | confirmed | cancelled.';

CREATE INDEX idx_reservations_user_id ON reservations (user_id);
CREATE INDEX idx_reservations_room_time
    ON reservations (room_id, starts_at, ends_at)
    WHERE status <> 'cancelled';

-- ---------------------------------------------------------------------------
-- Sprzęt przypisany do rezerwacji (relacja N:M)
-- ---------------------------------------------------------------------------
CREATE TABLE reservation_equipment (
    id              SERIAL PRIMARY KEY,
    reservation_id  INTEGER NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    equipment_id    INTEGER NOT NULL REFERENCES equipment(id) ON DELETE RESTRICT,
    quantity        INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    UNIQUE (reservation_id, equipment_id)
);

COMMENT ON TABLE reservation_equipment IS 'Powiązanie rezerwacji z wypożyczonym sprzętem.';

CREATE INDEX idx_reservation_equipment_reservation_id
    ON reservation_equipment (reservation_id);
CREATE INDEX idx_reservation_equipment_equipment_id
    ON reservation_equipment (equipment_id);

-- ---------------------------------------------------------------------------
-- Log anulowań rezerwacji
-- ---------------------------------------------------------------------------
CREATE TABLE cancellation_log (
    id              SERIAL PRIMARY KEY,
    reservation_id  INTEGER NOT NULL UNIQUE REFERENCES reservations(id) ON DELETE CASCADE,
    cancelled_by    INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    cancelled_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason          TEXT NOT NULL
);

COMMENT ON TABLE cancellation_log IS 'Historia anulowań — audyt operacji.';

CREATE INDEX idx_cancellation_log_cancelled_by ON cancellation_log (cancelled_by);

COMMIT;
