USE silibrary;

DELIMITER $$

CREATE TRIGGER before_insert_peminjaman
BEFORE INSERT ON peminjaman
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM denda d
        JOIN pengembalian pg ON pg.id_pengembalian = d.id_pengembalian
        JOIN peminjaman p ON p.id_peminjaman = pg.id_peminjaman
        WHERE p.id_anggota = NEW.id_anggota
          AND d.status_bayar = 'belum_bayar'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Anggota masih memiliki denda belum dibayar.';
    END IF;
END$$

CREATE TRIGGER after_update_denda
AFTER UPDATE ON denda
FOR EACH ROW
BEGIN
    IF OLD.status_bayar = 'belum_bayar'
       AND NEW.status_bayar = 'sudah_bayar' THEN
        INSERT INTO log_denda (id_denda, pesan)
        VALUES (
            NEW.id_denda,
            CONCAT('Denda Rp', FORMAT(NEW.total_denda, 2), ' telah dibayar.')
        );
    END IF;
END$$

CREATE PROCEDURE sp_pinjam_buku(
    IN p_id_anggota INT UNSIGNED,
    IN p_id_buku INT UNSIGNED,
    IN p_id_petugas INT UNSIGNED,
    IN p_durasi_hari INT UNSIGNED
)
BEGIN
    DECLARE v_status_anggota VARCHAR(10);
    DECLARE v_stok INT;

    IF p_durasi_hari < 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Durasi pinjam minimal satu hari.';
    END IF;

    SELECT status INTO v_status_anggota
    FROM anggota
    WHERE id_anggota = p_id_anggota;

    IF v_status_anggota IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Anggota tidak ditemukan.';
    END IF;

    IF v_status_anggota <> 'aktif' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Anggota tidak aktif.';
    END IF;

    SELECT stok INTO v_stok
    FROM buku
    WHERE id_buku = p_id_buku
    FOR UPDATE;

    IF v_stok IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Buku tidak ditemukan.';
    END IF;

    IF v_stok < 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stok buku habis.';
    END IF;

    INSERT INTO peminjaman (
        id_anggota, id_buku, id_petugas, tanggal_pinjam, tanggal_kembali, status
    ) VALUES (
        p_id_anggota, p_id_buku, p_id_petugas, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_durasi_hari DAY), 'dipinjam'
    );

    UPDATE buku
    SET stok = stok - 1
    WHERE id_buku = p_id_buku;
END$$

CREATE PROCEDURE sp_kembalikan_buku(
    IN p_id_peminjaman INT UNSIGNED,
    IN p_id_petugas INT UNSIGNED,
    IN p_kondisi_buku VARCHAR(20)
)
BEGIN
    DECLARE v_id_buku INT UNSIGNED;
    DECLARE v_tanggal_jatuh_tempo DATE;
    DECLARE v_status VARCHAR(20);
    DECLARE v_nama_anggota VARCHAR(150);
    DECLARE v_jumlah_hari INT DEFAULT 0;
    DECLARE v_id_pengembalian INT UNSIGNED;

    -- JOIN with anggota as required by the course brief.
    SELECT p.id_buku, p.tanggal_kembali, p.status, a.nama
    INTO v_id_buku, v_tanggal_jatuh_tempo, v_status, v_nama_anggota
    FROM peminjaman p
    JOIN anggota a ON a.id_anggota = p.id_anggota
    WHERE p.id_peminjaman = p_id_peminjaman;

    IF v_id_buku IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaksi peminjaman tidak ditemukan.';
    END IF;

    IF v_status <> 'dipinjam' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Buku sudah dikembalikan sebelumnya.';
    END IF;

    IF p_kondisi_buku NOT IN ('baik', 'rusak_ringan', 'rusak_berat') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Kondisi buku tidak valid.';
    END IF;

    SET v_jumlah_hari = GREATEST(DATEDIFF(CURDATE(), v_tanggal_jatuh_tempo), 0);

    INSERT INTO pengembalian (
        id_peminjaman, id_petugas, tanggal_kembali_aktual, kondisi_buku
    ) VALUES (
        p_id_peminjaman, p_id_petugas, CURDATE(), p_kondisi_buku
    );

    SET v_id_pengembalian = LAST_INSERT_ID();

    UPDATE peminjaman
    SET status = 'dikembalikan'
    WHERE id_peminjaman = p_id_peminjaman;

    UPDATE buku
    SET stok = stok + 1
    WHERE id_buku = v_id_buku;

    IF v_jumlah_hari > 0 THEN
        INSERT INTO denda (
            id_pengembalian, jumlah_hari, tarif_per_hari, total_denda, status_bayar
        ) VALUES (
            v_id_pengembalian, v_jumlah_hari, 3000.00, v_jumlah_hari * 3000.00, 'belum_bayar'
        );
    END IF;

    SELECT CONCAT('Pengembalian untuk ', v_nama_anggota, ' berhasil diproses.') AS pesan;
END$$

CREATE PROCEDURE sp_laporan_peminjaman_anggota(
    IN p_id_anggota INT UNSIGNED
)
BEGIN
    SELECT
        a.id_anggota,
        a.nama,
        a.nim,
        p.id_peminjaman,
        b.judul,
        p.tanggal_pinjam,
        p.tanggal_kembali AS tanggal_jatuh_tempo,
        p.status,
        (
            SELECT COUNT(*)
            FROM peminjaman riwayat
            WHERE riwayat.id_anggota = a.id_anggota
        ) AS total_buku_pernah_dipinjam
    FROM anggota a
    LEFT JOIN peminjaman p ON p.id_anggota = a.id_anggota
    LEFT JOIN buku b ON b.id_buku = p.id_buku
    WHERE a.id_anggota = p_id_anggota
    ORDER BY p.tanggal_pinjam DESC;
END$$

DELIMITER ;
