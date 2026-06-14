-- =============================================================================
-- System rezerwacji sal i sprzętu w uczelni
-- 02_seed.sql — dane przykładowe (min. 2 wiersze w każdej tabeli)
-- PostgreSQL 14+
-- =============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Wydziały
-- ---------------------------------------------------------------------------
INSERT INTO faculties (name, code) VALUES
    ('Wydział Informatyki', 'WI'),
    ('Wydział Elektroniki', 'WE'),
    ('Wydział Zarządzania', 'WZ');

-- ---------------------------------------------------------------------------
-- Użytkownicy
-- ---------------------------------------------------------------------------
INSERT INTO users (email, first_name, last_name, role, faculty_id) VALUES
    ('jan.kowalski@uczelnia.pl',      'Jan',  'Kowalski',   'lecturer', 1),
    ('anna.nowak@student.uczelnia.pl', 'Anna', 'Nowak',      'student',  1),
    ('piotr.wisniewski@uczelnia.pl',   'Piotr','Wiśniewski', 'lecturer', 2),
    ('admin@uczelnia.pl',              'Ewa',  'Zielińska',  'admin',    NULL);

-- ---------------------------------------------------------------------------
-- Budynki
-- ---------------------------------------------------------------------------
INSERT INTO buildings (name, address, campus) VALUES
    ('Budynek A — Wydział Informatyki', 'ul. Akademicka 1',  'Kampus Główny'),
    ('Budynek B — Biblioteka',          'ul. Akademicka 5',  'Kampus Główny'),
    ('Budynek C — Wydział Elektroniki', 'ul. Politechniczna 3', 'Kampus Północny');

-- ---------------------------------------------------------------------------
-- Sale
-- ---------------------------------------------------------------------------
INSERT INTO rooms (building_id, room_number, name, capacity, has_builtin_projector, is_active) VALUES
    (1, 'A-101', 'Sala wykładowa 101',       120, TRUE,  TRUE),
    (1, 'A-205', 'Sala komputerowa 205',      30, FALSE, TRUE),
    (2, 'B-010', 'Sala konferencyjna',        50, TRUE,  TRUE),
    (3, 'C-301', 'Laboratorium elektroniki',  24, FALSE, TRUE),
    (1, 'A-099', 'Sala w remoncie',           40, FALSE, FALSE);

-- ---------------------------------------------------------------------------
-- Sprzęt
-- ---------------------------------------------------------------------------
INSERT INTO equipment (name, inventory_number, equipment_type, is_portable, quantity_available) VALUES
    ('Projektor Epson EB-X06',           'INV-1001', 'projector',   TRUE,  5),
    ('Mikrofon bezprzewodowy Shure BLX', 'INV-2003', 'microphone',  TRUE,  3),
    ('Kamera PTZ do wideokonferencji',   'INV-3007', 'camera',      TRUE,  2),
    ('Głośnik przenośny JBL',            'INV-4012', 'speaker',     TRUE,  4),
    ('Tablica interaktywna Smart Board', 'INV-5001', 'whiteboard',  FALSE, 1);

-- ---------------------------------------------------------------------------
-- Rezerwacje
-- ---------------------------------------------------------------------------
INSERT INTO reservations (room_id, user_id, title, purpose, starts_at, ends_at, status) VALUES
    (
        2, 2,
        'Spotkanie koła naukowego AI',
        'Prezentacja projektów studenckich z zakresu sztucznej inteligencji.',
        TIMESTAMPTZ '2026-06-15 16:00:00+02',
        TIMESTAMPTZ '2026-06-15 18:00:00+02',
        'confirmed'
    ),
    (
        1, 1,
        'Konsultacje przed egzaminem',
        'Konsultacje z przedmiotu Bazy Danych — sesja letnia.',
        TIMESTAMPTZ '2026-06-16 10:00:00+02',
        TIMESTAMPTZ '2026-06-16 12:00:00+02',
        'confirmed'
    ),
    (
        3, 3,
        'Seminarium dyplomowe',
        'Prezentacje prac inżynierskich wydziału elektroniki.',
        TIMESTAMPTZ '2026-06-18 09:00:00+02',
        TIMESTAMPTZ '2026-06-18 13:00:00+02',
        'pending'
    ),
    (
        3, 1,
        'Obrona pracy inżynierskiej (anulowana)',
        'Termin przeniesiony do innej sali z powodu prac konserwacyjnych.',
        TIMESTAMPTZ '2026-06-20 14:00:00+02',
        TIMESTAMPTZ '2026-06-20 16:00:00+02',
        'cancelled'
    ),
    (
        4, 3,
        'Zajęcia laboratoryjne — układy scalone',
        'Ćwiczenia laboratoryjne dla grupy 15-osobowej.',
        TIMESTAMPTZ '2026-06-22 08:00:00+02',
        TIMESTAMPTZ '2026-06-22 11:30:00+02',
        'confirmed'
    );

-- ---------------------------------------------------------------------------
-- Sprzęt przypisany do rezerwacji
-- ---------------------------------------------------------------------------
INSERT INTO reservation_equipment (reservation_id, equipment_id, quantity) VALUES
    (1, 1, 1),  -- Spotkanie koła AI: projektor
    (1, 2, 1),  -- Spotkanie koła AI: mikrofon
    (2, 1, 1),  -- Konsultacje BD: projektor
    (3, 1, 1),  -- Seminarium: projektor
    (3, 3, 1),  -- Seminarium: kamera PTZ
    (3, 4, 2),  -- Seminarium: 2 głośniki
    (5, 2, 1);  -- Zajęcia lab.: mikrofon

-- ---------------------------------------------------------------------------
-- Log anulowań
-- ---------------------------------------------------------------------------
INSERT INTO cancellation_log (reservation_id, cancelled_by, reason) VALUES
    (
        4,
        1,
        'Sala B-010 niedostępna z powodu prac konserwacyjnych — termin przeniesiony na 2026-06-21.'
    );

COMMIT;

-- ---------------------------------------------------------------------------
-- Weryfikacja liczby wierszy (opcjonalnie — do zrzutu ekranu w pgAdmin)
-- ---------------------------------------------------------------------------
SELECT 'faculties'              AS tabela, COUNT(*) AS wiersze FROM faculties
UNION ALL SELECT 'users',                    COUNT(*) FROM users
UNION ALL SELECT 'buildings',                COUNT(*) FROM buildings
UNION ALL SELECT 'rooms',                    COUNT(*) FROM rooms
UNION ALL SELECT 'equipment',                COUNT(*) FROM equipment
UNION ALL SELECT 'reservations',             COUNT(*) FROM reservations
UNION ALL SELECT 'reservation_equipment',    COUNT(*) FROM reservation_equipment
UNION ALL SELECT 'cancellation_log',         COUNT(*) FROM cancellation_log
ORDER BY tabela;
