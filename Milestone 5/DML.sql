
--  TABLE OF CONTENTS
--  -----------------
--  SECTION 1 — Database Setup
--  SECTION 2 — Load Data (LOAD DATA INFILE)
--  SECTION 3 — UPDATE Operations
--  SECTION 4 — DELETE Operations
--  SECTION 5 — Validation Queries
--             5.1  COUNT(*) per table
--             5.2  NULL checks on key columns
--             5.3  JOIN-based FK integrity checks
-- ============================================================


-- ============================================================
--  SECTION 1 — DATABASE SETUP
-- ============================================================

-- Select the database (change name if yours differs)
USE nasa_exoplanet_explorer;

-- Allow LOAD DATA INFILE from any path during this session
SET GLOBAL local_infile = 1;

-- Disable FK checks during bulk load so order doesn't matter
-- (We re-enable them immediately after loading)
SET FOREIGN_KEY_CHECKS = 0;


-- ============================================================
--  SECTION 2 — LOAD DATA INFILE
--  One statement per table, loaded in correct FK order:
--  Galaxy → HostStar → DiscoveryMethod → BlackHole
--                     → Exoplanet → UserNotes
--
--  NOTE: Replace the file paths below with the absolute path
--        to your CSV files on your machine.
--        Example (Windows): C:/Users/YourName/Desktop/csvs/
--        Example (Linux/Mac): /home/yourname/project/csvs/
-- ============================================================

-- ── 1. Galaxy (73 rows, no FK dependencies) ──────────────────
LOAD DATA LOCAL INFILE 'galaxy.csv'
INTO TABLE Galaxy
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(galaxy_id, galaxy_name, galaxy_type, dist_mly, stars, diameter_ly, bhs, exoplanets);

-- ── 2. HostStar (4,708 rows, no FK dependencies) ─────────────
LOAD DATA LOCAL INFILE 'hoststar.csv'
INTO TABLE HostStar
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(star_id, hostname, st_teff, st_rad, st_mass, st_dist, star_type);

-- ── 3. DiscoveryMethod (11 rows, no FK dependencies) ─────────
LOAD DATA LOCAL INFILE 'discoverymethod.csv'
INTO TABLE DiscoveryMethod
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(method_id, method_name, description);

-- ── 4. BlackHole (70 rows, FK: galaxy_id → Galaxy) ───────────
--  Note: 12 rows have NULL galaxy_id (host galaxy unconfirmed)
--  The @gal_id variable handles empty strings → NULL correctly
LOAD DATA LOCAL INFILE 'blackhole.csv'
INTO TABLE BlackHole
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(bh_id, bh_name, bh_type, mass_solar, @gal_id, dist_ly, discovered)
SET galaxy_id = NULLIF(@gal_id, '');

-- ── 5. Exoplanet (6,286 rows, FK: star_id, method_id) ────────
--  Note: 340 rows have NULL pl_orbper (orbital period not measured)
--  Variable trick handles empty strings → NULL for nullable cols
LOAD DATA LOCAL INFILE 'exoplanet.csv'
INTO TABLE Exoplanet
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(planet_id, pl_name, star_id, method_id, disc_year,
 @orbper, @radj, @bmassj, @eqt)
SET
  pl_orbper  = NULLIF(@orbper,  ''),
  pl_radj    = NULLIF(@radj,    ''),
  pl_bmassj  = NULLIF(@bmassj,  ''),
  pl_eqt     = NULLIF(@eqt,     '');

-- ── 6. UserNotes (100 rows, FK: planet_id / bh_id / galaxy_id) ───────
--  Uses three separate FK columns matching the Milestone 4 DDL.
--  Only ONE FK column is filled per row; the other two remain NULL.
--  The @variable trick converts empty CSV strings → NULL correctly.
--  CSV column order: note_id, planet_id, bh_id, galaxy_id,
--                    note_text, is_favorite, created_at
LOAD DATA LOCAL INFILE 'usernotes.csv'
INTO TABLE UserNotes
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(note_id, @planet_id, @bh_id, @galaxy_id, note_text, is_favorite, created_at)
SET
  planet_id  = NULLIF(@planet_id,  ''),
  bh_id      = NULLIF(@bh_id,      ''),
  galaxy_id  = NULLIF(@galaxy_id,  '');

-- Re-enable FK checks now that all tables are loaded
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
--  SECTION 3 — UPDATE OPERATIONS (minimum 1 required)
--  Using real rows from the dataset with meaningful changes
-- ============================================================

-- ── UPDATE 1 ─────────────────────────────────────────────────
-- Mark note_id = 1 as a favourite.
-- Row currently: planet note, is_favorite = 1
-- We update the note text to be more descriptive.
UPDATE UserNotes
SET note_text = 'Confirmed favourite — classic Transit detection case, excellent for classroom reference.'
WHERE note_id = 1;

-- ── UPDATE 2 ─────────────────────────────────────────────────
-- Cygnus X-1 (bh_id = 1) distance was recently refined.
-- Original value in CSV: 4,582,136,682.4 light-years
-- Updated to NASA 2021 revised estimate: 7,200 light-years
-- (The CSV stored ly incorrectly as a very large number;
--  this UPDATE corrects it to the known 7,200 ly value)
UPDATE BlackHole
SET dist_ly = 7200.0
WHERE bh_id = 1
  AND bh_name = 'Cygnus X-1';

-- ── UPDATE 3 ─────────────────────────────────────────────────
-- Mark all UserNotes for black holes as favourite = 1
-- where is_favorite was previously 0, for demo bulk update.
-- Uses bh_id IS NOT NULL to identify black hole notes —
-- consistent with the three-FK design in the DDL.
UPDATE UserNotes
SET is_favorite = 1
WHERE bh_id IS NOT NULL
  AND is_favorite = 0;


-- ============================================================
--  SECTION 4 — DELETE OPERATIONS (minimum 1 required)
-- ============================================================

-- ── DELETE 1 ─────────────────────────────────────────────────
-- Remove note_id = 100 (last seed row — demo cleanup).
-- Safe to delete: UserNotes has no table referencing it.
DELETE FROM UserNotes
WHERE note_id = 100;

-- ── DELETE 2 ─────────────────────────────────────────────────
-- Remove any UserNotes where note_text is an empty string.
-- These are incomplete annotation rows with no useful content.
DELETE FROM UserNotes
WHERE note_text = ''
   OR note_text IS NULL;


-- ============================================================
--  SECTION 5 — VALIDATION QUERIES
-- ============================================================

-- ────────────────────────────────────────────────────────────
--  5.1  COUNT(*) FOR EACH TABLE
--  Expected after loading:
--    Galaxy          73 rows
--    HostStar     4,708 rows
--    DiscoveryMethod 11 rows
--    BlackHole       70 rows
--    Exoplanet    6,286 rows
--    UserNotes      ~99 rows (100 loaded, 1 deleted above)
-- ────────────────────────────────────────────────────────────

SELECT 'Galaxy'          AS table_name, COUNT(*) AS row_count FROM Galaxy
UNION ALL
SELECT 'HostStar',                       COUNT(*)             FROM HostStar
UNION ALL
SELECT 'DiscoveryMethod',                COUNT(*)             FROM DiscoveryMethod
UNION ALL
SELECT 'BlackHole',                      COUNT(*)             FROM BlackHole
UNION ALL
SELECT 'Exoplanet',                      COUNT(*)             FROM Exoplanet
UNION ALL
SELECT 'UserNotes',                      COUNT(*)             FROM UserNotes;

/*  EXPECTED OUTPUT:
    +-----------------+-----------+
    | table_name      | row_count |
    +-----------------+-----------+
    | Galaxy          |        73 |
    | HostStar        |      4708 |
    | DiscoveryMethod |        11 |
    | BlackHole       |        70 |
    | Exoplanet       |      6286 |
    | UserNotes       |        99 |
    +-----------------+-----------+
    6 rows in set
*/


-- ────────────────────────────────────────────────────────────
--  5.2  NULL CHECKS ON KEY COLUMNS
--  These queries confirm that NULLs exist only where expected
--  (nullable columns) and NOT in NOT NULL columns.
-- ────────────────────────────────────────────────────────────

-- Exoplanet: pl_orbper is nullable — 340 NULLs expected
SELECT 'Exoplanet.pl_orbper NULLs'  AS check_name,
       COUNT(*)                      AS null_count
FROM Exoplanet
WHERE pl_orbper IS NULL;
/*  EXPECTED OUTPUT:
    +---------------------------+------------+
    | check_name                | null_count |
    +---------------------------+------------+
    | Exoplanet.pl_orbper NULLs |        340 |
    +---------------------------+------------+
*/

-- Exoplanet: pl_name must never be NULL (NOT NULL constraint)
SELECT 'Exoplanet.pl_name NULLs (expect 0)' AS check_name,
       COUNT(*)                               AS null_count
FROM Exoplanet
WHERE pl_name IS NULL;
/*  EXPECTED OUTPUT:
    +-------------------------------------+------------+
    | check_name                          | null_count |
    +-------------------------------------+------------+
    | Exoplanet.pl_name NULLs (expect 0)  |          0 |
    +-------------------------------------+------------+
*/

-- Exoplanet: star_id must never be NULL (FK, NOT NULL)
SELECT 'Exoplanet.star_id NULLs (expect 0)' AS check_name,
       COUNT(*)                               AS null_count
FROM Exoplanet
WHERE star_id IS NULL;
/*  EXPECTED OUTPUT:
    +-------------------------------------+------------+
    | check_name                          | null_count |
    +-------------------------------------+------------+
    | Exoplanet.star_id NULLs (expect 0)  |          0 |
    +-------------------------------------+------------+
*/

-- BlackHole: galaxy_id is nullable — 12 NULLs expected
SELECT 'BlackHole.galaxy_id NULLs (expect 12)' AS check_name,
       COUNT(*)                                  AS null_count
FROM BlackHole
WHERE galaxy_id IS NULL;
/*  EXPECTED OUTPUT:
    +----------------------------------------+------------+
    | check_name                             | null_count |
    +----------------------------------------+------------+
    | BlackHole.galaxy_id NULLs (expect 12)  |         12 |
    +----------------------------------------+------------+
*/

-- BlackHole: bh_name must never be NULL
SELECT 'BlackHole.bh_name NULLs (expect 0)' AS check_name,
       COUNT(*)                               AS null_count
FROM BlackHole
WHERE bh_name IS NULL;
/*  EXPECTED OUTPUT:
    +--------------------------------------+------------+
    | check_name                           | null_count |
    +--------------------------------------+------------+
    | BlackHole.bh_name NULLs (expect 0)   |          0 |
    +--------------------------------------+------------+
*/

-- HostStar: st_teff is nullable — 283 NULLs expected
SELECT 'HostStar.st_teff NULLs (expect 283)' AS check_name,
       COUNT(*)                                AS null_count
FROM HostStar
WHERE st_teff IS NULL;
/*  EXPECTED OUTPUT:
    +--------------------------------------+------------+
    | check_name                           | null_count |
    +--------------------------------------+------------+
    | HostStar.st_teff NULLs (expect 283)  |        283 |
    +--------------------------------------+------------+
*/

-- HostStar: hostname must never be NULL
SELECT 'HostStar.hostname NULLs (expect 0)' AS check_name,
       COUNT(*)                               AS null_count
FROM HostStar
WHERE hostname IS NULL;
/*  EXPECTED OUTPUT:
    +-------------------------------------+------------+
    | check_name                          | null_count |
    +-------------------------------------+------------+
    | HostStar.hostname NULLs (expect 0)  |          0 |
    +-------------------------------------+------------+
*/

-- UserNotes: every row must have exactly one FK set
-- (all three NULL means the note is orphaned — expect 0)
SELECT 'UserNotes rows with all FKs NULL (expect 0)' AS check_name,
       COUNT(*)                                        AS null_count
FROM UserNotes
WHERE planet_id IS NULL
  AND bh_id     IS NULL
  AND galaxy_id IS NULL;
/*  EXPECTED OUTPUT:
    +----------------------------------------------+------------+
    | check_name                                   | null_count |
    +----------------------------------------------+------------+
    | UserNotes rows with all FKs NULL (expect 0)  |          0 |
    +----------------------------------------------+------------+
*/


-- ────────────────────────────────────────────────────────────
--  5.3  JOIN-BASED FK INTEGRITY CHECKS
--  These confirm every FK reference resolves to a real parent row.
--  Any result > 0 means an orphan row exists (a problem).
-- ────────────────────────────────────────────────────────────

-- Check 1: Every Exoplanet.star_id exists in HostStar
-- (orphan exoplanets with no matching star — expect 0)
SELECT 'Orphan exoplanets (no matching HostStar)' AS integrity_check,
       COUNT(*)                                    AS orphan_count
FROM Exoplanet e
LEFT JOIN HostStar hs ON e.star_id = hs.star_id
WHERE hs.star_id IS NULL;
/*  EXPECTED OUTPUT:
    +--------------------------------------------+--------------+
    | integrity_check                            | orphan_count |
    +--------------------------------------------+--------------+
    | Orphan exoplanets (no matching HostStar)   |            0 |
    +--------------------------------------------+--------------+
*/

-- Check 2: Every Exoplanet.method_id exists in DiscoveryMethod
-- (expect 0)
SELECT 'Orphan exoplanets (no matching DiscoveryMethod)' AS integrity_check,
       COUNT(*)                                           AS orphan_count
FROM Exoplanet e
LEFT JOIN DiscoveryMethod dm ON e.method_id = dm.method_id
WHERE dm.method_id IS NULL;
/*  EXPECTED OUTPUT:
    +--------------------------------------------------+--------------+
    | integrity_check                                  | orphan_count |
    +--------------------------------------------------+--------------+
    | Orphan exoplanets (no matching DiscoveryMethod)  |            0 |
    +--------------------------------------------------+--------------+
*/

-- Check 3: Every BlackHole.galaxy_id (where NOT NULL) exists in Galaxy
-- (expect 0)
SELECT 'Orphan black holes (galaxy_id set but no matching Galaxy)' AS integrity_check,
       COUNT(*)                                                     AS orphan_count
FROM BlackHole bh
LEFT JOIN Galaxy g ON bh.galaxy_id = g.galaxy_id
WHERE bh.galaxy_id IS NOT NULL
  AND g.galaxy_id IS NULL;
/*  EXPECTED OUTPUT:
    +------------------------------------------------------------+--------------+
    | integrity_check                                            | orphan_count |
    +------------------------------------------------------------+--------------+
    | Orphan black holes (galaxy_id set but no matching Galaxy)  |            0 |
    +------------------------------------------------------------+--------------+
*/

-- Check 4: Spot-check JOIN — exoplanets with their host star name
-- (confirms real data flows correctly across the FK)
SELECT e.planet_id,
       e.pl_name,
       hs.hostname      AS host_star,
       dm.method_name   AS discovery_method,
       e.disc_year
FROM Exoplanet e
JOIN HostStar        hs ON e.star_id   = hs.star_id
JOIN DiscoveryMethod dm ON e.method_id = dm.method_id
LIMIT 10;
/*  EXPECTED OUTPUT (sample — actual values depend on CSV data):
    +-----------+-------------------+-------------+------------------+-----------+
    | planet_id | pl_name           | host_star   | discovery_method | disc_year |
    +-----------+-------------------+-------------+------------------+-----------+
    |         1 | Kepler-1b         | Kepler-1    | Transit          |      2009 |
    |         2 | Kepler-2b         | Kepler-2    | Transit          |      2010 |
    |         3 | HD 209458 b       | HD 209458   | Transit          |      2000 |
    |       ...                                                                  |
    +-----------+-------------------+-------------+------------------+-----------+
    10 rows in set
*/

-- Check 5: Spot-check JOIN — black holes with their host galaxy
SELECT bh.bh_id,
       bh.bh_name,
       bh.bh_type,
       bh.mass_solar,
       g.galaxy_name    AS host_galaxy
FROM BlackHole bh
LEFT JOIN Galaxy g ON bh.galaxy_id = g.galaxy_id
ORDER BY bh.bh_id
LIMIT 10;
/*  EXPECTED OUTPUT (sample — actual values depend on CSV data):
    +-------+---------------------+--------------+-------------+------------------+
    | bh_id | bh_name             | bh_type      | mass_solar  | host_galaxy      |
    +-------+---------------------+--------------+-------------+------------------+
    |     1 | Cygnus X-1          | Stellar      |        21.2 | Milky Way        |
    |     2 | V404 Cygni          | Stellar      |         9.0 | Milky Way        |
    |     3 | GRS 1915+105        | Stellar      |        14.0 | Milky Way        |
    |   ...                                                                       |
    +-------+---------------------+--------------+-------------+------------------+
    10 rows in set
*/

-- Check 6: UserNotes — count notes per object type
-- Uses three separate FK columns (matches Milestone 4 DDL design)
SELECT 'planet'    AS object_type,
       COUNT(*)    AS note_count,
       SUM(is_favorite) AS favourite_count
FROM UserNotes WHERE planet_id IS NOT NULL
UNION ALL
SELECT 'blackhole',
       COUNT(*),
       SUM(is_favorite)
FROM UserNotes WHERE bh_id IS NOT NULL
UNION ALL
SELECT 'galaxy',
       COUNT(*),
       SUM(is_favorite)
FROM UserNotes WHERE galaxy_id IS NOT NULL;
/*  EXPECTED OUTPUT (values depend on CSV seed data):
    +-------------+------------+-----------------+
    | object_type | note_count | favourite_count |
    +-------------+------------+-----------------+
    | planet      |         40 |              15 |
    | blackhole   |         35 |              35 |   <- all BH notes set to favourite by UPDATE 3
    | galaxy      |         24 |               8 |
    +-------------+------------+-----------------+
    3 rows in set
*/

-- Check 7: Full summary JOIN — stars hosting the most exoplanets
SELECT hs.hostname,
       hs.star_type,
       COUNT(e.planet_id) AS exoplanet_count
FROM HostStar hs
JOIN Exoplanet e ON hs.star_id = e.star_id
GROUP BY hs.star_id, hs.hostname, hs.star_type
ORDER BY exoplanet_count DESC
LIMIT 10;
/*  EXPECTED OUTPUT (sample — actual values depend on CSV data):
    +-------------+-----------+-----------------+
    | hostname    | star_type | exoplanet_count |
    +-------------+-----------+-----------------+
    | Kepler-90   | G-type    |               8 |
    | TRAPPIST-1  | M-dwarf   |               7 |
    | Kepler-11   | G-type    |               6 |
    | Kepler-20   | G-type    |               5 |
    | HD 10180    | G-type    |               5 |
    |   ...                                     |
    +-------------+-----------+-----------------+
    10 rows in set
*/
