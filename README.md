# System rezerwacji sal i sprzętu w uczelni — baza danych (PostgreSQL)

Projekt akademicki: model relacyjny bazy danych do rezerwacji sal wykładowych i wypożyczania sprzętu multimedialnego.

## Pliki SQL

| Plik | Opis |
|------|------|
| `sql/01_schema.sql` | Tabele, klucze PK/FK, indeksy, ograniczenia CHECK |
| `sql/02_seed.sql` | Dane przykładowe (min. 2 wiersze w każdej tabeli) |

## Uruchomienie (PostgreSQL lokalnie)

```bash
# Utworzenie bazy (jako użytkownik postgres)
createdb room_reservation

# Załadowanie schematu i danych
psql -d room_reservation -f sql/01_schema.sql
psql -d room_reservation -f sql/02_seed.sql
```

## Uruchomienie (Docker)

```bash
docker compose up -d
```

Skrypty z `sql/` są montowane do `/docker-entrypoint-initdb.d` i wykonują się automatycznie przy pierwszym starcie kontenera.

Połączenie:

- Host: `localhost`
- Port: `5432`
- Baza: `room_reservation`
- Użytkownik: `app_user`
- Hasło: `app_secret`

## Tabele (8)

1. `faculties` — wydziały
2. `users` — użytkownicy (student / lecturer / admin)
3. `buildings` — budynki
4. `rooms` — sale
5. `equipment` — sprzęt multimedialny
6. `reservations` — rezerwacje sal
7. `reservation_equipment` — sprzęt przypisany do rezerwacji (N:M)
8. `cancellation_log` — historia anulowań

## Przykładowe zapytanie (demo)

```sql
SELECT
    r.title,
    r.starts_at,
    rm.room_number,
    b.name AS building,
    u.first_name || ' ' || u.last_name AS reserved_by
FROM reservations r
JOIN rooms rm ON rm.id = r.room_id
JOIN buildings b ON b.id = rm.building_id
JOIN users u ON u.id = r.user_id
WHERE r.status <> 'cancelled'
ORDER BY r.starts_at;
```
