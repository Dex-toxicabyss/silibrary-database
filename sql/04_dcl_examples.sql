-- DCL examples for MySQL 8.0.
-- Do not run unchanged in production. Replace the placeholder passwords and
-- restrict the host value to match the intended deployment environment.

CREATE USER IF NOT EXISTS 'petugas_full'@'localhost'
    IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT';
GRANT SELECT, INSERT, UPDATE, DELETE ON silibrary.* TO 'petugas_full'@'localhost';

CREATE USER IF NOT EXISTS 'petugas_baca'@'localhost'
    IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT';
GRANT SELECT ON silibrary.buku TO 'petugas_baca'@'localhost';
GRANT SELECT ON silibrary.kategori TO 'petugas_baca'@'localhost';

FLUSH PRIVILEGES;

-- Verification commands:
-- SHOW GRANTS FOR 'petugas_full'@'localhost';
-- SHOW GRANTS FOR 'petugas_baca'@'localhost';
