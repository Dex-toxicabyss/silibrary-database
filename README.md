# SiLibrary — Digital Library Database

SiLibrary is an academic MySQL database implementation for a digital library information system. It models catalog data, members, staff, borrowing, returns, late-payment penalties, and database access roles.

## Snapshot

| Item | Detail |
| --- | --- |
| Project type | Academic team project — Database Systems |
| Database | MySQL 8.0+ |
| Data model | 8 primary entities plus the `buku_penulis` M:N junction table and `log_denda` audit table |
| SQL features | DDL, DML, stored procedures, triggers, nested query, `JOIN`, and DCL examples |
| Status | Importable SQL source included |

## Database model

The primary entities are `kategori`, `penulis`, `buku`, `anggota`, `petugas`, `peminjaman`, `pengembalian`, and `denda`. The book-to-author relationship is handled by `buku_penulis`. A `peminjaman` has zero or one `pengembalian`, and a `pengembalian` can have zero or one `denda`.

| Relationship | Cardinality | Implementation |
| --- | --- | --- |
| Kategori → Buku | 1:N | `buku.id_kategori` foreign key |
| Buku ↔ Penulis | M:N | `buku_penulis` junction table |
| Anggota → Peminjaman | 1:N | `peminjaman.id_anggota` foreign key |
| Petugas → Peminjaman | 1:N | `peminjaman.id_petugas` foreign key |
| Peminjaman → Pengembalian | 1:0..1 | `pengembalian.id_peminjaman` unique foreign key |

## Repository structure

```text
sql/
├── 01_schema_and_seed.sql          # Database, tables, relationships, and sample data
├── 02_procedures_and_triggers.sql  # 3 procedures and 2 triggers
├── 03_demo_queries.sql             # Safe learning/demo flow on the seeded database
└── 04_dcl_examples.sql             # Role examples; edit credentials before use
```

## Import and run

> `01_schema_and_seed.sql` starts with `DROP DATABASE IF EXISTS silibrary`. Run it only in a local or disposable academic environment.

Import the schema and programmable objects in this order:

```bash
mysql -u root -p < sql/01_schema_and_seed.sql
mysql -u root -p silibrary < sql/02_procedures_and_triggers.sql
mysql -u root -p silibrary < sql/03_demo_queries.sql
```

The last command is an optional demonstration. It creates a loan for member 1, marks the seed penalty as paid to trigger an audit entry, borrows a book for member 4 after the penalty is paid, and returns that loan.

## Stored procedures and triggers

| Object | Purpose |
| --- | --- |
| `sp_pinjam_buku` | Validates an active member and available stock, creates a loan, and reduces stock. |
| `sp_kembalikan_buku` | Uses a `JOIN` to process a return, restores stock, and creates a late fee when needed. |
| `sp_laporan_peminjaman_anggota` | Lists a member's borrowing history and uses a nested query to count total loans. |
| `before_insert_peminjaman` | Blocks a new loan when the member still has an unpaid penalty. |
| `after_update_denda` | Writes a row to `log_denda` when a fee changes from unpaid to paid. |

## Access-control examples

`04_dcl_examples.sql` documents two course-aligned roles: `petugas_full` can read and write across the database; `petugas_baca` can only read `buku` and `kategori`. The script contains intentional password placeholders, so change them before executing and do not use the sample credentials in a shared environment.

## Scope and provenance

Raffata's documented contribution to the original team project was the ERD, relational model, and Chapters 1–2 documentation. The original Workbench model and SQL export were unavailable when this repository was published. The current scripts are a clean, importable reconstruction from the supplied report's stated entity attributes, relationships, procedure requirements, trigger rules, and DCL goals. They are therefore presented as a course-aligned implementation rather than the exact original team export.
