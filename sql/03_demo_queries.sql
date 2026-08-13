USE silibrary;

-- 1. Borrow one book for an active member with no unpaid penalty.
CALL sp_pinjam_buku(1, 1, 1, 7);

-- 2. View the member's borrowing history. This procedure uses a nested query.
CALL sp_laporan_peminjaman_anggota(1);

-- 3. The seed creates an unpaid penalty for member 4. Paying it writes an audit log.
UPDATE denda
SET status_bayar = 'sudah_bayar'
WHERE id_denda = 1;

SELECT *
FROM log_denda
ORDER BY dibuat_pada DESC;

-- 4. After the penalty is paid, the member is allowed to borrow again.
CALL sp_pinjam_buku(4, 2, 1, 7);

-- 5. Return the first new loan. It uses a JOIN between peminjaman and anggota.
CALL sp_kembalikan_buku(2, 1, 'baik');

SELECT id_buku, judul, stok
FROM buku
ORDER BY id_buku;
