-- ============================================================
--  NASA Exoplanet Explorer Database System
--  Milestone 4 — DDL Scripts (Final Version)
--  Members  : Areeba Ali & Shandana Shah
--  Program  : BS Artificial Intelligence  |  Semester 4th (B)
--  Instructor: Sir Ali Hasan
--  Commit msg: M4: DDL scripts added, EER diagram verified
-- ============================================================

-- ── 0. create database  ────────────────

CREATE DATABASE nasa_exoplanet_explorer
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nasa_exoplanet_explorer;

-- ── 1. Galaxy ────────────────────────────────────────────────
CREATE TABLE Galaxy (
    galaxy_id    INT           NOT NULL AUTO_INCREMENT,
    galaxy_name  VARCHAR(150)  NOT NULL,
    galaxy_type  VARCHAR(50)   NULL     COMMENT 'Spiral, Elliptical, or Irregular',
    dist_mly     FLOAT         NULL     COMMENT 'Distance from Earth (million light-years)',
    stars        VARCHAR(50)   NULL     COMMENT 'Estimated star count e.g. 200-400B',
    diameter_ly  BIGINT        NULL     COMMENT 'Diameter in light-years',
    bhs          INT           NOT NULL DEFAULT 0 COMMENT 'Number of known black holes',
    exoplanets   INT           NOT NULL DEFAULT 0 COMMENT 'Number of known exoplanets',

    CONSTRAINT pk_galaxy      PRIMARY KEY (galaxy_id),
    CONSTRAINT uq_galaxy_name UNIQUE      (galaxy_name)
) ENGINE = InnoDB
  COMMENT = 'Host galaxies for black holes and other objects';

CREATE INDEX idx_galaxy_type ON Galaxy (galaxy_type);


-- ── 2. HostStar ──────────────────────────────────────────────
CREATE TABLE HostStar (
    star_id    INT           NOT NULL AUTO_INCREMENT,
    hostname   VARCHAR(100)  NOT NULL,
    st_teff    FLOAT         NULL     COMMENT 'Effective temperature (Kelvin)',
    st_rad     FLOAT         NULL     COMMENT 'Star radius (solar radii)',
    st_mass    FLOAT         NULL     COMMENT 'Star mass (solar masses)',
    st_dist    FLOAT         NULL     COMMENT 'Distance from Earth (parsecs)',
    star_type  VARCHAR(50)   NULL     COMMENT 'Spectral type e.g. G2V, M-dwarf',

    CONSTRAINT pk_hoststar      PRIMARY KEY (star_id),
    CONSTRAINT uq_hoststar_name UNIQUE      (hostname)
) ENGINE = InnoDB
  COMMENT = 'Stars that host one or more exoplanets';


-- ── 3. DiscoveryMethod ───────────────────────────────────────
CREATE TABLE DiscoveryMethod (
    method_id    INT           NOT NULL AUTO_INCREMENT,
    method_name  VARCHAR(100)  NOT NULL,
    description  TEXT          NULL     COMMENT 'Brief description of the method',

    CONSTRAINT pk_discovery_method PRIMARY KEY (method_id),
    CONSTRAINT uq_method_name      UNIQUE      (method_name)
) ENGINE = InnoDB
  COMMENT = 'Lookup table of exoplanet discovery techniques';


-- ── 4. BlackHole ─────────────────────────────────────────────
CREATE TABLE BlackHole (
    bh_id       INT           NOT NULL AUTO_INCREMENT,
    bh_name     VARCHAR(150)  NOT NULL,
    bh_type     VARCHAR(50)   NOT NULL COMMENT 'Stellar or Supermassive',
    mass_solar  DOUBLE        NULL     COMMENT 'Mass in solar masses',
    galaxy_id   INT           NULL     COMMENT 'FK -> Galaxy',
    dist_ly     DOUBLE        NULL     COMMENT 'Distance from Earth (light-years)',
    discovered  INT           NULL     COMMENT 'Year of discovery',

    CONSTRAINT pk_blackhole       PRIMARY KEY (bh_id),
    CONSTRAINT uq_blackhole_name  UNIQUE      (bh_name),
    CONSTRAINT fk_blackhole_galaxy
        FOREIGN KEY (galaxy_id) REFERENCES Galaxy (galaxy_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE = InnoDB
  COMMENT = 'Stellar and supermassive black holes';

CREATE INDEX idx_bh_galaxy     ON BlackHole (galaxy_id);
CREATE INDEX idx_bh_type       ON BlackHole (bh_type);
CREATE INDEX idx_bh_discovered ON BlackHole (discovered);


-- ── 5. Exoplanet ─────────────────────────────────────────────
CREATE TABLE Exoplanet (
    planet_id  INT           NOT NULL AUTO_INCREMENT,
    pl_name    VARCHAR(100)  NOT NULL,
    star_id    INT           NOT NULL COMMENT 'FK -> HostStar',
    method_id  INT           NULL     COMMENT 'FK -> DiscoveryMethod',
    disc_year  INT           NOT NULL COMMENT 'Year of confirmed discovery',
    pl_orbper  FLOAT         NULL     COMMENT 'Orbital period (days)',
    pl_radj    FLOAT         NULL     COMMENT 'Planet radius (Jupiter radii)',
    pl_bmassj  FLOAT         NULL     COMMENT 'Planet mass (Jupiter masses)',
    pl_eqt     FLOAT         NULL     COMMENT 'Equilibrium temperature (Kelvin)',

    CONSTRAINT pk_exoplanet      PRIMARY KEY (planet_id),
    CONSTRAINT uq_exoplanet_name UNIQUE      (pl_name),
    CONSTRAINT fk_exoplanet_star
        FOREIGN KEY (star_id)   REFERENCES HostStar       (star_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exoplanet_method
        FOREIGN KEY (method_id) REFERENCES DiscoveryMethod (method_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB
  COMMENT = 'Confirmed exoplanets and their orbital/physical properties';

CREATE INDEX idx_exoplanet_star   ON Exoplanet (star_id);
CREATE INDEX idx_exoplanet_method ON Exoplanet (method_id);
CREATE INDEX idx_exoplanet_year   ON Exoplanet (disc_year);


-- ── 6. UserNotes ─────────────────────────────────────────────
--  3 separate FK columns so Workbench draws all relationship
--  lines exactly like the ERD diagram.
--  Only ONE of (planet_id, bh_id, galaxy_id) will be filled
--  per row — the others stay NULL.
-- ─────────────────────────────────────────────────────────────
CREATE TABLE UserNotes (
    note_id      INT       NOT NULL AUTO_INCREMENT,
    planet_id    INT       NULL     COMMENT 'FK -> Exoplanet (fill if annotating a planet)',
    bh_id        INT       NULL     COMMENT 'FK -> BlackHole (fill if annotating a black hole)',
    galaxy_id    INT       NULL     COMMENT 'FK -> Galaxy    (fill if annotating a galaxy)',
    note_text    TEXT      NULL     COMMENT 'Free-form user annotation',
    is_favorite  BOOLEAN   NOT NULL DEFAULT FALSE COMMENT 'TRUE if marked as favourite',
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_usernotes PRIMARY KEY (note_id),

    CONSTRAINT fk_notes_exoplanet
        FOREIGN KEY (planet_id)  REFERENCES Exoplanet (planet_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_notes_blackhole
        FOREIGN KEY (bh_id)      REFERENCES BlackHole (bh_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_notes_galaxy
        FOREIGN KEY (galaxy_id)  REFERENCES Galaxy    (galaxy_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB
  COMMENT = 'User annotations and favourites for all astronomical objects';

CREATE INDEX idx_notes_planet   ON UserNotes (planet_id);
CREATE INDEX idx_notes_bh       ON UserNotes (bh_id);
CREATE INDEX idx_notes_galaxy   ON UserNotes (galaxy_id);
CREATE INDEX idx_notes_favorite ON UserNotes (is_favorite);

-- ── Verify all 6 tables created ──────────────────────────────
SHOW TABLES;

-- ── End of DDL ───────────────────────────────────────────────
