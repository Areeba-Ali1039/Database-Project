# 🌌 **NASA Exoplanet Explorer — Milestone 2**

---

## 📘 **Project Overview**

This project is a **Relational Database System** for the **NASA Exoplanet Explorer**, built as part of a university Database course.
Milestone 2 covers the formal **Normalization** of the database schema, structured in sequence from **1NF → 2NF → 3NF**, alongside a duplicate data review and an updated **ERD Diagram (v2.0)**.

| | |
|---|---|
| 👩‍💻 **Members** | Areeba Ali & Syeda Shandana Shah |
| 🎓 **Program** | BS Artificial Intelligence |
| 📅 **Semester** | 4th (B) |
| 👨‍🏫 **Instructor** |  Ali Hassan |

---

## 📋 **Version History**

| Milestone | Date | Version | Remarks |
|---|---|:---:|---|
| 🗂️ ERD Diagram & Schema | April 25, 2026 | `v1.0` | Flowchart |
| ✅ Normalization (M2) | May 2026 | `v2.0` | 3NF applied to all 6 tables; ERD updated |

---

## 📁 **Repository Structure**

```
📦 nasa-exoplanet-explorer
 ┣ 📄 README.md                 ← Project overview and Milestone 2 documentation
 ┣ 📄 NORMALIZATION.md          ← Full Step 1 & Step 2 normalization analysis
 ┣ 🖼️  ERD_v2.png               ← Updated ERD Diagram (v2.0)
 ┗ 📄 Milestone_2_Final.docx    ← Complete submission document
```

---

## 🗄️ **Database Schema — 6 Tables**

### 🪐 Table 1: Exoplanet

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `planet_id` | INT | PK, AUTO_INCREMENT | Surrogate primary key |
| `pl_name` | VARCHAR(100) | NOT NULL, UNIQUE | Planet name (e.g. TRAPPIST-1 e) |
| `star_id` | INT | FK → HostStar | Host star reference |
| `method_id` | INT | FK → DiscoveryMethod | Discovery method reference |
| `disc_year` | INT | NOT NULL | Year of confirmed discovery |
| `pl_orbper` | FLOAT | NULL | Orbital period (days) |
| `pl_radj` | FLOAT | NULL | Planet radius (Jupiter radii) |
| `pl_bmassj` | FLOAT | NULL | Planet mass (Jupiter masses) |
| `pl_eqt` | FLOAT | NULL | Equilibrium temperature (Kelvin) |

---

### ⭐ Table 2: HostStar

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `star_id` | INT | PK, AUTO_INCREMENT | Surrogate primary key |
| `hostname` | VARCHAR(100) | NOT NULL, UNIQUE | Star name (e.g. TRAPPIST-1) |
| `st_teff` | FLOAT | NULL | Stellar effective temperature (Kelvin) |
| `st_rad` | FLOAT | NULL | Stellar radius (solar radii) |
| `st_mass` | FLOAT | NULL | Stellar mass (solar masses) |
| `st_dist` | FLOAT | NULL | Distance from Earth (parsecs) |
| `star_type` | VARCHAR(50) | NULL | Spectral type (e.g. M-dwarf) |

---

### 🔭 Table 3: DiscoveryMethod

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `method_id` | INT | PK, AUTO_INCREMENT | Surrogate primary key |
| `method_name` | VARCHAR(100) | NOT NULL, UNIQUE | Method name (e.g. Transit) |
| `description` | TEXT | NULL | Description of the discovery method |

---

### 🕳️ Table 4: BlackHole *(New)*

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `bh_id` | INT | PK, AUTO_INCREMENT | Surrogate primary key |
| `bh_name` | VARCHAR(150) | NOT NULL, UNIQUE | Black hole name (e.g. Cygnus X-1) |
| `bh_type` | VARCHAR(50) | NOT NULL | Stellar or Supermassive |
| `mass_solar` | DOUBLE | NULL | Mass in solar masses |
| `galaxy_id` | INT | FK → Galaxy, NULL | Host galaxy reference |
| `dist_ly` | DOUBLE | NULL | Distance from Earth (light-years) |
| `discovered` | INT | NULL | Year of discovery |

---

### 🌌 Table 5: Galaxy *(New)*

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `galaxy_id` | INT | PK, AUTO_INCREMENT | Surrogate primary key |
| `galaxy_name` | VARCHAR(150) | NOT NULL, UNIQUE | Galaxy name (e.g. Milky Way) |
| `galaxy_type` | VARCHAR(50) | NULL | Spiral, Elliptical, or Irregular |
| `dist_mly` | FLOAT | NULL | Distance from Earth (million light-years) |
| `stars` | VARCHAR(50) | NULL | Estimated star count (e.g. 200-400B) |
| `diameter_ly` | BIGINT | NULL | Diameter in light-years |
| `bhs` | INT | DEFAULT 0 | Number of known black holes |
| `exoplanets` | INT | DEFAULT 0 | Number of known exoplanets |

---

### 📝 Table 6: UserNotes *(New)*

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `note_id` | INT | PK, AUTO_INCREMENT | Surrogate primary key |
| `object_type` | ENUM | NOT NULL ('exoplanet','blackhole','galaxy') | Type of object being annotated |
| `object_id` | INT | NOT NULL | PK of the referenced object |
| `note_text` | TEXT | NULL | User annotation text |
| `is_favorite` | BOOLEAN | DEFAULT FALSE | Marks object as favourite |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | When the note was saved |

---

## 🔗 **Relationships**

| Relationship | Cardinality | Description |
|---|:---:|---|
| HostStar → Exoplanet | **1 : M** | One star can host many exoplanets |
| DiscoveryMethod → Exoplanet | **1 : M** | One method can apply to many exoplanets |
| Galaxy → BlackHole | **1 : M** | One galaxy can contain many black holes |
| Exoplanet → UserNotes | **1 : M** | One exoplanet can have many user notes |
| BlackHole → UserNotes | **1 : M** | One black hole can have many user notes |
| Galaxy → UserNotes | **1 : M** | One galaxy can have many user notes |

---

## ✅ **Step 1 — Normalization Summary**

All 6 tables were reviewed in sequence for **1NF**, **2NF**, and **3NF**.
For each normal form, the issue found and action taken are documented.
Full justifications are in [`NORMALIZATION.md`](./NORMALIZATION.md).

| Table | 1NF | 2NF | 3NF | Changes Made |
|---|:---:|:---:|:---:|---|
| 🪐 Exoplanet | ✅ PASS | ✅ PASS | ✅ PASS | None |
| ⭐ HostStar | ✅ PASS | ✅ PASS | ✅ PASS | Restored 5 missing columns from original ERD |
| 🔭 DiscoveryMethod | ✅ PASS | ✅ PASS | ✅ PASS | Restored missing `description` column |
| 🕳️ BlackHole | ✅ PASS | ✅ PASS | ✅ PASS | None |
| 🌌 Galaxy | ✅ PASS | ✅ PASS | ✅ PASS | None |
| 📝 UserNotes | ✅ PASS | ✅ PASS | ✅ PASS | None |

**Why all tables pass:**
- Every table uses a **single surrogate primary key** — making partial dependency (2NF violation) impossible.
- Repeating data (star names, method names, galaxy info) was already separated into **dedicated lookup tables**.
- **Foreign keys** are used throughout — no non-key column determines another non-key column.

---

## 🔍 **Step 2 — Duplicate Check**

All tables were checked for redundant columns, repeated data, and overlapping attributes.

| Table | Checked For | Finding | Action Taken |
|---|---|---|---|
| Exoplanet | Star/method names repeated per row | `star_id`, `method_id` are FK references — no raw text repeated | ✅ No change |
| HostStar | Duplicate star records | `hostname` has UNIQUE constraint | ✅ No change |
| DiscoveryMethod | Duplicate method names | `method_name` has UNIQUE constraint | ✅ No change |
| BlackHole | Galaxy name repeated per row | `galaxy_id` FK — galaxy name stored only in Galaxy table | ✅ No change |
| Galaxy | `bhs`, `exoplanets` duplicating other tables | Pre-aggregated NASA archive values, not derived in real-time | ✅ Accepted as direct attributes |
| UserNotes | Separate tables per object type | Single polymorphic ENUM table cleaner than 3 separate tables | ✅ No change |

> **Conclusion:** No columns were removed or restructured. The schema was already well-designed with foreign keys used throughout to prevent redundancy.

---

## 🗺️ **Step 3 — Updated ERD Diagram (v2.0)**

The ERD below reflects all normalization changes. All primary keys, foreign keys, relationships, and cardinalities are shown.

![ERD Diagram v2.0](./ERD_v2.png)

---

## 💾 **Step 4 — Commit History**

```bash
M2: Applied 2NF and 3NF normalization, updated ERD and schema
M2: Added updated ERD diagram v2.0 — all 6 tables and relationships
M2: Added NORMALIZATION.md — 1NF, 2NF, 3NF analysis for all 6 tables
```

---

## 💻 **Technologies Used**

| Component | Description |
|---|---|
| 🗄️ **Database** | MySQL (Relational) |
| 📐 **Design** | ERD — Entity Relationship Diagram |
| 📄 **Documentation** | Markdown, Microsoft Word |
| 🔧 **Version Control** | Git & GitHub |

---

## 📚 **Conclusion**

This milestone formally applies normalization to all 6 tables in the NASA Exoplanet Explorer database.
All tables satisfy **Third Normal Form (3NF)** without requiring structural changes, confirming the schema was well-designed from the start.
The ERD has been updated to **v2.0**, reflecting all corrections and additions made since the original submission.

---

## 👩‍💻 **Authors**

**Members:** *Areeba Ali & Syeda Shandana Shah*

---
