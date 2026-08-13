DROP DATABASE IF EXISTS silibrary;
CREATE DATABASE silibrary
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE silibrary;

CREATE TABLE kategori (
    id_kategori INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL UNIQUE,
    deskripsi VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE penulis (
    id_penulis INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_penulis VARCHAR(150) NOT NULL,
    negara_asal VARCHAR(100),
    email VARCHAR(150) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE buku (
    id_buku INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_kategori INT UNSIGNED NOT NULL,
    judul VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    tahun_terbit SMALLINT UNSIGNED NOT NULL,
    penerbit VARCHAR(150) NOT NULL,
    stok INT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_buku_kategori
        FOREIGN KEY (id_kategori) REFERENCES kategori(id_kategori),
    CONSTRAINT chk_buku_tahun CHECK (tahun_terbit BETWEEN 1000 AND 9999)
) ENGINE=InnoDB;

CREATE TABLE buku_penulis (
    id_buku INT UNSIGNED NOT NULL,
    id_penulis INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_buku, id_penulis),
    CONSTRAINT fk_buku_penulis_buku
        FOREIGN KEY (id_buku) REFERENCES buku(id_buku)
        ON DELETE CASCADE,
    CONSTRAINT fk_buku_penulis_penulis
        FOREIGN KEY (id_penulis) REFERENCES penulis(id_penulis)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE anggota (
    id_anggota INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    nim VARCHAR(30) NOT NULL UNIQUE,
    alamat VARCHAR(255),
    no_telepon VARCHAR(25),
    email VARCHAR(150) NOT NULL UNIQUE,
    tanggal_daftar DATE NOT NULL,
    status ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif'
) ENGINE=InnoDB;

CREATE TABLE petugas (
    id_petugas INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    nip VARCHAR(30) NOT NULL UNIQUE,
    jabatan VARCHAR(100) NOT NULL,
    no_telepon VARCHAR(25),
    email VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE peminjaman (
    id_peminjaman INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_anggota INT UNSIGNED NOT NULL,
    id_buku INT UNSIGNED NOT NULL,
    id_petugas INT UNSIGNED NOT NULL,
    tanggal_pinjam DATE NOT NULL,
    tanggal_kembali DATE NOT NULL,
    status ENUM('dipinjam', 'dikembalikan') NOT NULL DEFAULT 'dipinjam',
    CONSTRAINT fk_peminjaman_anggota
        FOREIGN KEY (id_anggota) REFERENCES anggota(id_anggota),
    CONSTRAINT fk_peminjaman_buku
        FOREIGN KEY (id_buku) REFERENCES buku(id_buku),
    CONSTRAINT fk_peminjaman_petugas
        FOREIGN KEY (id_petugas) REFERENCES petugas(id_petugas),
    CONSTRAINT chk_peminjaman_tanggal CHECK (tanggal_kembali >= tanggal_pinjam)
) ENGINE=InnoDB;

CREATE TABLE pengembalian (
    id_pengembalian INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_peminjaman INT UNSIGNED NOT NULL UNIQUE,
    id_petugas INT UNSIGNED NOT NULL,
    tanggal_kembali_aktual DATE NOT NULL,
    kondisi_buku ENUM('baik', 'rusak_ringan', 'rusak_berat') NOT NULL DEFAULT 'baik',
    CONSTRAINT fk_pengembalian_peminjaman
        FOREIGN KEY (id_peminjaman) REFERENCES peminjaman(id_peminjaman),
    CONSTRAINT fk_pengembalian_petugas
        FOREIGN KEY (id_petugas) REFERENCES petugas(id_petugas)
) ENGINE=InnoDB;

CREATE TABLE denda (
    id_denda INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_pengembalian INT UNSIGNED NOT NULL UNIQUE,
    jumlah_hari INT UNSIGNED NOT NULL,
    tarif_per_hari DECIMAL(12, 2) NOT NULL,
    total_denda DECIMAL(12, 2) NOT NULL,
    status_bayar ENUM('belum_bayar', 'sudah_bayar') NOT NULL DEFAULT 'belum_bayar',
    CONSTRAINT fk_denda_pengembalian
        FOREIGN KEY (id_pengembalian) REFERENCES pengembalian(id_pengembalian),
    CONSTRAINT chk_denda_total CHECK (total_denda >= 0)
) ENGINE=InnoDB;

CREATE TABLE log_denda (
    id_log INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_denda INT UNSIGNED NOT NULL,
    pesan VARCHAR(255) NOT NULL,
    dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_denda
        FOREIGN KEY (id_denda) REFERENCES denda(id_denda)
) ENGINE=InnoDB;

INSERT INTO kategori (nama_kategori, deskripsi) VALUES
    ('Teknologi', 'Buku terkait teknologi dan rekayasa perangkat lunak'),
    ('Sains', 'Buku pengetahuan dan sains populer'),
    ('Fiksi', 'Novel dan karya fiksi');

INSERT INTO penulis (nama_penulis, negara_asal, email) VALUES
    ('Roger S. Pressman', 'Amerika Serikat', 'roger.pressman@example.test'),
    ('Robert C. Martin', 'Amerika Serikat', 'unclebob@example.test'),
    ('Andrea Hirata', 'Indonesia', 'andrea.hirata@example.test'),
    ('Yuval Noah Harari', 'Israel', 'yuval.harari@example.test');

INSERT INTO buku (id_kategori, judul, isbn, tahun_terbit, penerbit, stok) VALUES
    (1, 'Software Engineering: A Practitioner''s Approach', '9780078022128', 2014, 'McGraw-Hill', 4),
    (1, 'Clean Code', '9780132350884', 2008, 'Prentice Hall', 3),
    (3, 'Laskar Pelangi', '9789793062792', 2005, 'Bentang Pustaka', 5),
    (2, 'Sapiens', '9780062316097', 2015, 'Harper', 2);

INSERT INTO buku_penulis (id_buku, id_penulis) VALUES
    (1, 1), (2, 2), (3, 3), (4, 4);

INSERT INTO anggota (nama, nim, alamat, no_telepon, email, tanggal_daftar, status) VALUES
    ('Raffata Izacky Yuargya Aletama', '102042500123', 'Tangerang, Banten', '081234567801', 'raffata@example.test', '2025-09-01', 'aktif'),
    ('Alvin Isatoni', '102042500124', 'Bandung, Jawa Barat', '081234567802', 'alvin@example.test', '2025-09-01', 'aktif'),
    ('Raffi Fernandes', '102042530011', 'Bandung, Jawa Barat', '081234567803', 'raffi@example.test', '2025-09-01', 'aktif'),
    ('Muhammad Ikhsan Ibni Ulwan', '102042530005', 'Bandung, Jawa Barat', '081234567804', 'ikhsan@example.test', '2025-09-01', 'aktif');

INSERT INTO petugas (nama, nip, jabatan, no_telepon, email) VALUES
    ('Siti Rahma', '1989001001', 'Pustakawan', '081234567811', 'siti.rahma@example.test'),
    ('Budi Santoso', '1989001002', 'Administrator Perpustakaan', '081234567812', 'budi.santoso@example.test');

-- Historical transaction retained as seed data to demonstrate an outstanding penalty.
INSERT INTO peminjaman (id_anggota, id_buku, id_petugas, tanggal_pinjam, tanggal_kembali, status) VALUES
    (4, 4, 1, '2026-05-01', '2026-05-08', 'dikembalikan');

INSERT INTO pengembalian (id_peminjaman, id_petugas, tanggal_kembali_aktual, kondisi_buku) VALUES
    (1, 1, '2026-05-10', 'baik');

INSERT INTO denda (id_pengembalian, jumlah_hari, tarif_per_hari, total_denda, status_bayar) VALUES
    (1, 2, 3000.00, 6000.00, 'belum_bayar');
