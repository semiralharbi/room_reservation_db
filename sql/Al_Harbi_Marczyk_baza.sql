--
-- PostgreSQL database dump
--

\restrict obUJspFjPWfVdQ2cyqd5zgHvj9fYphhAQQXGOfW4qPCbHIDFlWQJ0PpOUrbKqee

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14 (Debian 16.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    address character varying(255) NOT NULL,
    campus character varying(64) NOT NULL
);


--
-- Name: TABLE buildings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.buildings IS 'Budynki uczelni na poszczególnych kampusach.';


--
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.buildings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.buildings_id_seq OWNED BY public.buildings.id;


--
-- Name: cancellation_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cancellation_log (
    id integer NOT NULL,
    reservation_id integer NOT NULL,
    cancelled_by integer NOT NULL,
    cancelled_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text NOT NULL
);


--
-- Name: TABLE cancellation_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cancellation_log IS 'Historia anulowań — audyt operacji.';


--
-- Name: cancellation_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cancellation_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cancellation_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cancellation_log_id_seq OWNED BY public.cancellation_log.id;


--
-- Name: equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    inventory_number character varying(64) NOT NULL,
    equipment_type character varying(32) NOT NULL,
    is_portable boolean DEFAULT true NOT NULL,
    quantity_available integer NOT NULL,
    CONSTRAINT equipment_quantity_available_check CHECK ((quantity_available >= 0))
);


--
-- Name: TABLE equipment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.equipment IS 'Ewidencja sprzętu do wypożyczenia przy rezerwacjach.';


--
-- Name: COLUMN equipment.equipment_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.equipment.equipment_type IS 'Np. projector, microphone, camera.';


--
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.equipment.id;


--
-- Name: faculties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.faculties (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    code character varying(16) NOT NULL
);


--
-- Name: TABLE faculties; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.faculties IS 'Jednostki organizacyjne uczelni (wydziały).';


--
-- Name: COLUMN faculties.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.faculties.code IS 'Skrót wydziału, np. WI, WE.';


--
-- Name: faculties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.faculties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: faculties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.faculties_id_seq OWNED BY public.faculties.id;


--
-- Name: reservation_equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservation_equipment (
    id integer NOT NULL,
    reservation_id integer NOT NULL,
    equipment_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    CONSTRAINT reservation_equipment_quantity_check CHECK ((quantity > 0))
);


--
-- Name: TABLE reservation_equipment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reservation_equipment IS 'Powiązanie rezerwacji z wypożyczonym sprzętem.';


--
-- Name: reservation_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reservation_equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reservation_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reservation_equipment_id_seq OWNED BY public.reservation_equipment.id;


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservations (
    id integer NOT NULL,
    room_id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(255) NOT NULL,
    purpose text,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reservations_check CHECK ((ends_at > starts_at)),
    CONSTRAINT reservations_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'cancelled'::character varying])::text[])))
);


--
-- Name: TABLE reservations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reservations IS 'Rezerwacje terminów sal przez użytkowników.';


--
-- Name: COLUMN reservations.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reservations.status IS 'pending | confirmed | cancelled.';


--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reservations_id_seq OWNED BY public.reservations.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    building_id integer NOT NULL,
    room_number character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    capacity integer NOT NULL,
    has_builtin_projector boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT rooms_capacity_check CHECK ((capacity > 0))
);


--
-- Name: TABLE rooms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rooms IS 'Sale wykładowe i konferencyjne w budynkach.';


--
-- Name: COLUMN rooms.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rooms.is_active IS 'FALSE = sala niedostępna (np. remont), bez nowych rezerwacji.';


--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    role character varying(20) NOT NULL,
    faculty_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['student'::character varying, 'lecturer'::character varying, 'admin'::character varying])::text[])))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users IS 'Użytkownicy systemu: studenci, wykładowcy, administratorzy.';


--
-- Name: COLUMN users.role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.role IS 'Rola: student | lecturer | admin.';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: buildings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings ALTER COLUMN id SET DEFAULT nextval('public.buildings_id_seq'::regclass);


--
-- Name: cancellation_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_log ALTER COLUMN id SET DEFAULT nextval('public.cancellation_log_id_seq'::regclass);


--
-- Name: equipment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- Name: faculties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faculties ALTER COLUMN id SET DEFAULT nextval('public.faculties_id_seq'::regclass);


--
-- Name: reservation_equipment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_equipment ALTER COLUMN id SET DEFAULT nextval('public.reservation_equipment_id_seq'::regclass);


--
-- Name: reservations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations ALTER COLUMN id SET DEFAULT nextval('public.reservations_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: buildings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.buildings (id, name, address, campus) FROM stdin;
1	Budynek A — Wydział Informatyki	ul. Akademicka 1	Kampus Główny
2	Budynek B — Biblioteka	ul. Akademicka 5	Kampus Główny
3	Budynek C — Wydział Elektroniki	ul. Politechniczna 3	Kampus Północny
\.


--
-- Data for Name: cancellation_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cancellation_log (id, reservation_id, cancelled_by, cancelled_at, reason) FROM stdin;
1	4	1	2026-06-13 12:58:27.316352+00	Sala B-010 niedostępna z powodu prac konserwacyjnych — termin przeniesiony na 2026-06-21.
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment (id, name, inventory_number, equipment_type, is_portable, quantity_available) FROM stdin;
1	Projektor Epson EB-X06	INV-1001	projector	t	5
2	Mikrofon bezprzewodowy Shure BLX	INV-2003	microphone	t	3
3	Kamera PTZ do wideokonferencji	INV-3007	camera	t	2
4	Głośnik przenośny JBL	INV-4012	speaker	t	4
5	Tablica interaktywna Smart Board	INV-5001	whiteboard	f	1
\.


--
-- Data for Name: faculties; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.faculties (id, name, code) FROM stdin;
1	Wydział Informatyki	WI
2	Wydział Elektroniki	WE
3	Wydział Zarządzania	WZ
\.


--
-- Data for Name: reservation_equipment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reservation_equipment (id, reservation_id, equipment_id, quantity) FROM stdin;
1	1	1	1
2	1	2	1
3	2	1	1
4	3	1	1
5	3	3	1
6	3	4	2
7	5	2	1
\.


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reservations (id, room_id, user_id, title, purpose, starts_at, ends_at, status, created_at) FROM stdin;
1	2	2	Spotkanie koła naukowego AI	Prezentacja projektów studenckich z zakresu sztucznej inteligencji.	2026-06-15 14:00:00+00	2026-06-15 16:00:00+00	confirmed	2026-06-13 12:58:27.316352+00
2	1	1	Konsultacje przed egzaminem	Konsultacje z przedmiotu Bazy Danych — sesja letnia.	2026-06-16 08:00:00+00	2026-06-16 10:00:00+00	confirmed	2026-06-13 12:58:27.316352+00
3	3	3	Seminarium dyplomowe	Prezentacje prac inżynierskich wydziału elektroniki.	2026-06-18 07:00:00+00	2026-06-18 11:00:00+00	pending	2026-06-13 12:58:27.316352+00
4	3	1	Obrona pracy inżynierskiej (anulowana)	Termin przeniesiony do innej sali z powodu prac konserwacyjnych.	2026-06-20 12:00:00+00	2026-06-20 14:00:00+00	cancelled	2026-06-13 12:58:27.316352+00
5	4	3	Zajęcia laboratoryjne — układy scalone	Ćwiczenia laboratoryjne dla grupy 15-osobowej.	2026-06-22 06:00:00+00	2026-06-22 09:30:00+00	confirmed	2026-06-13 12:58:27.316352+00
6	2	2	Spotkanie koła naukowego AI	Prezentacja projektów studenckich z zakresu sztucznej inteligencji.	2026-06-15 14:00:00+00	2026-06-15 16:00:00+00	confirmed	2026-06-13 14:35:01.011535+00
7	1	1	Konsultacje przed egzaminem	Konsultacje z przedmiotu Bazy Danych — sesja letnia.	2026-06-16 08:00:00+00	2026-06-16 10:00:00+00	confirmed	2026-06-13 14:35:01.011535+00
8	3	3	Seminarium dyplomowe	Prezentacje prac inżynierskich wydziału elektroniki.	2026-06-18 07:00:00+00	2026-06-18 11:00:00+00	pending	2026-06-13 14:35:01.011535+00
9	3	1	Obrona pracy inżynierskiej (anulowana)	Termin przeniesiony do innej sali z powodu prac konserwacyjnych.	2026-06-20 12:00:00+00	2026-06-20 14:00:00+00	cancelled	2026-06-13 14:35:01.011535+00
10	4	3	Zajęcia laboratoryjne — układy scalone	Ćwiczenia laboratoryjne dla grupy 15-osobowej.	2026-06-22 06:00:00+00	2026-06-22 09:30:00+00	confirmed	2026-06-13 14:35:01.011535+00
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rooms (id, building_id, room_number, name, capacity, has_builtin_projector, is_active) FROM stdin;
1	1	A-101	Sala wykładowa 101	120	t	t
2	1	A-205	Sala komputerowa 205	30	f	t
3	2	B-010	Sala konferencyjna	50	t	t
4	3	C-301	Laboratorium elektroniki	24	f	t
5	1	A-099	Sala w remoncie	40	f	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, first_name, last_name, role, faculty_id, created_at) FROM stdin;
1	jan.kowalski@uczelnia.pl	Jan	Kowalski	lecturer	1	2026-06-13 12:58:27.316352+00
2	anna.nowak@student.uczelnia.pl	Anna	Nowak	student	1	2026-06-13 12:58:27.316352+00
3	piotr.wisniewski@uczelnia.pl	Piotr	Wiśniewski	lecturer	2	2026-06-13 12:58:27.316352+00
4	admin@uczelnia.pl	Ewa	Zielińska	admin	\N	2026-06-13 12:58:27.316352+00
\.


--
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.buildings_id_seq', 3, true);


--
-- Name: cancellation_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cancellation_log_id_seq', 1, true);


--
-- Name: equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.equipment_id_seq', 5, true);


--
-- Name: faculties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.faculties_id_seq', 3, true);


--
-- Name: reservation_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reservation_equipment_id_seq', 7, true);


--
-- Name: reservations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reservations_id_seq', 10, true);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rooms_id_seq', 5, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: cancellation_log cancellation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_log
    ADD CONSTRAINT cancellation_log_pkey PRIMARY KEY (id);


--
-- Name: cancellation_log cancellation_log_reservation_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_log
    ADD CONSTRAINT cancellation_log_reservation_id_key UNIQUE (reservation_id);


--
-- Name: equipment equipment_inventory_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_inventory_number_key UNIQUE (inventory_number);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: faculties faculties_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faculties
    ADD CONSTRAINT faculties_code_key UNIQUE (code);


--
-- Name: faculties faculties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faculties
    ADD CONSTRAINT faculties_pkey PRIMARY KEY (id);


--
-- Name: reservation_equipment reservation_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_equipment
    ADD CONSTRAINT reservation_equipment_pkey PRIMARY KEY (id);


--
-- Name: reservation_equipment reservation_equipment_reservation_id_equipment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_equipment
    ADD CONSTRAINT reservation_equipment_reservation_id_equipment_id_key UNIQUE (reservation_id, equipment_id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_building_id_room_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_building_id_room_number_key UNIQUE (building_id, room_number);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_cancellation_log_cancelled_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cancellation_log_cancelled_by ON public.cancellation_log USING btree (cancelled_by);


--
-- Name: idx_reservation_equipment_equipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reservation_equipment_equipment_id ON public.reservation_equipment USING btree (equipment_id);


--
-- Name: idx_reservation_equipment_reservation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reservation_equipment_reservation_id ON public.reservation_equipment USING btree (reservation_id);


--
-- Name: idx_reservations_room_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reservations_room_time ON public.reservations USING btree (room_id, starts_at, ends_at) WHERE ((status)::text <> 'cancelled'::text);


--
-- Name: idx_reservations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reservations_user_id ON public.reservations USING btree (user_id);


--
-- Name: idx_rooms_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rooms_building_id ON public.rooms USING btree (building_id);


--
-- Name: idx_users_faculty_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_faculty_id ON public.users USING btree (faculty_id);


--
-- Name: cancellation_log cancellation_log_cancelled_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_log
    ADD CONSTRAINT cancellation_log_cancelled_by_fkey FOREIGN KEY (cancelled_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: cancellation_log cancellation_log_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancellation_log
    ADD CONSTRAINT cancellation_log_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.reservations(id) ON DELETE CASCADE;


--
-- Name: reservation_equipment reservation_equipment_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_equipment
    ADD CONSTRAINT reservation_equipment_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(id) ON DELETE RESTRICT;


--
-- Name: reservation_equipment reservation_equipment_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_equipment
    ADD CONSTRAINT reservation_equipment_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.reservations(id) ON DELETE CASCADE;


--
-- Name: reservations reservations_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE RESTRICT;


--
-- Name: reservations reservations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: rooms rooms_building_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_building_id_fkey FOREIGN KEY (building_id) REFERENCES public.buildings(id) ON DELETE RESTRICT;


--
-- Name: users users_faculty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_faculty_id_fkey FOREIGN KEY (faculty_id) REFERENCES public.faculties(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict obUJspFjPWfVdQ2cyqd5zgHvj9fYphhAQQXGOfW4qPCbHIDFlWQJ0PpOUrbKqee

