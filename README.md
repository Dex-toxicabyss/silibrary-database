# SiLibrary — Digital Library Database

SiLibrary is an academic relational database design for a digital library information system. The model covers catalog data, members, staff, lending, returns, and late-payment penalties.

## Snapshot

| Item | Detail |
| --- | --- |
| Project type | Academic team project — Database Systems |
| Tooling | MySQL Workbench / relational database design |
| Scope | ERD, relational model, lending and return relationships |
| Data model | 8 primary entities with 1:1, 1:N, and M:N relationships |
| Status | Documentation-first repository |

## System model

The documented model includes `Kategori`, `Penulis`, `Buku`, `Anggota`, `Petugas`, `Peminjaman`, `Pengembalian`, and `Denda`. The book-to-author relationship is represented through the `Buku_Penulis` junction table. Lending links members and staff to borrowing transactions, while returns and penalties extend the flow.

## Raffata's contribution

Raffata contributed to the Entity Relationship Diagram, the relational model, and the project documentation for Chapters 1 and 2. His documented work includes defining entities and attributes, transforming relationships into relational form, recording cardinality, and clarifying business rules for lending and returns.

## Concepts practiced

- Entity Relationship Diagramming with Chen notation
- Relational model transformation
- Primary keys, foreign keys, and junction tables
- Cardinality: 1:1, 1:N, and M:N
- Database documentation and business-rule communication

## Code availability

This public repository currently documents the database design. The original Workbench model and SQL export are not included in this first publication, so no import command or MySQL version is claimed. When source assets are added, this README will be updated with precise import instructions.

## Scope note

This is an academic database-design project. The contribution section deliberately separates Raffata's ERD/model/documentation work from SQL implementation performed by other team members.
