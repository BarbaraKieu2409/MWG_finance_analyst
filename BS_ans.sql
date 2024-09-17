
create table temp as
select b.noi_dung, replace(b.so_tien,',','') as so_tien from `BS.2024.06.30` b;

update temp
set `so_tien` = CASE 
	WHEN `so_tien` = '' THEN NULL
	WHEN `so_tien` = ' ' THEN NULL 
	WHEN `so_tien` = '-' THEN NULL 
	ELSE  `so_tien`
END;

alter table temp modify column so_tien DOUBLE NULL;

drop table `BS.2024.06.30`;

alter table temp rename to `BS.2024.06.30`;



CREATE TABLE BS AS
SELECT 
	b.noi_dung,
	b.so_tien AS `2023.03.31`, 
	b1.so_tien AS `2023.06.30`,
	b2.so_tien AS `2023.09.30`,
	b3.so_tien AS `2023.12.31`,
	b4.so_tien AS `2024.03.31`, 
	b5.so_tien AS `2024.06.30`
FROM 
    `BS.2023.03.31` b 
JOIN 
    `BS.2023.06.30` b1 ON b.noi_dung = b1.noi_dung
JOIN 
    `BS.2023.09.30` b2 ON b.noi_dung = b2.noi_dung
JOIN 
    `BS.2023.12.31` b3 ON b.noi_dung = b3.noi_dung
JOIN 
    `BS.2024.03.31` b4 ON b.noi_dung = b4.noi_dung
JOIN 
    `BS.2024.06.30` b5 ON b.noi_dung = b5.noi_dung;
   
--  lấy dữ liệu tài sản, nợ phải trả, VCSH 
CREATE TABLE TS AS 
SELECT  *
FROM BS
WHERE noi_dung IN ("1. Tiền", "TỔNG CỘNG TÀI SẢN", "C. NỢ PHẢI TRẢ",  "D.VỐN CHỦ SỞ HỮU");

-- lấy dữ liệu khoản phải thu 
CREATE TABLE KPT AS
SELECT 
	"khoan phai thu" as noi_dung, 
	SUM(`2023.03.31`) as `2023.03.31`, 
	SUM(`2023.06.30`) as `2023.06.30`, 
	SUM(`2023.09.30`) as `2023.09.30`,
	SUM(`2023.12.31`) as `2023.12.31`,
	SUM(`2024.03.31`) as `2024.03.31`,
	SUM(`2024.06.30`) as `2024.06.30`
FROM BS
WHERE noi_dung IN ("III. Các khoản phải thu ngắn hạn", "I. Phải thu dài hạn");

-- lấy dữ liệu hàng tồn kho
	CREATE TABLE HTK AS
	select *
	from BS
	where noi_dung IN ("IV. Hàng tồn kho")

-- lấy dữ liệu khoản phải trả 
CREATE TABLE KPTR AS 
SELECT *
FROM BS 
WHERE noi_dung IN ("C. NỢ PHẢI TRẢ")
 
-- lấy dữ liệu để tính hệ số thanh khoản nhanh 
-- hệ số thanh khoản nhanh = (tài sản ngắn hạn - hàng tồn kho)/ nợ ngắn hạn 
CREATE TABLE HSTK AS 
select 
	"he so thanh khoan nhanh" as noi_dung,
	(b1.`2023.03.31` - b2.`2023.03.31`)/b3.`2023.03.31` as `2023.03.31`,
	(b1.`2023.06.30` - b2.`2023.06.30`)/b3.`2023.06.30` as `2023.06.30`,
	(b1.`2023.09.30` - b2.`2023.09.30`)/b3.`2023.09.30` as `2023.09.30`,
	(b1.`2023.12.31` - b2.`2023.12.31`)/b3.`2023.12.31` as `2023.12.31`,
	(b1.`2024.03.31` - b2.`2024.03.31`)/b3.`2024.03.31` as `2024.03.31`,
	(b1.`2024.06.30` - b2.`2024.06.30`)/b3.`2024.06.30` as `2024.06.30`
from BS b1, BS b2, BS b3
where 
	b1.noi_dung in ("A- TÀI SẢN NGẮN HẠN")
	and
	b2.noi_dung in ("IV. Hàng tồn kho")
	and
	b3.noi_dung in ("I. Nợ ngắn hạn");



-- lấy dữ liệu để tính vốn lưu đông và vốn lưu động ròng 
-- vốn lưu động = tài sản ngắn hạn, vốn lưu động ròng = tài sản ngắn hạn - nợ ngắn hạn 
CREATE TABLE VLD AS 
SELECT "von luu dong" as noi_dung  ,
		d1.`2023.03.31`, d1.`2023.06.30`, d1.`2023.09.30`,
		d1.`2023.12.31`, d1.`2024.03.31`, d1.`2024.06.30`
FROM BS d1
WHERE d1.noi_dung = "A- TÀI SẢN NGẮN HẠN" 
UNION ALL 
SELECT 
	"von luu dong ròng" as noi_dung,
	(b1.`2023.03.31` - b2.`2023.03.31`) as `2023.03.31`,
	(b1.`2023.06.30` - b2.`2023.06.30`) as `2023.06.30`,
	(b1.`2023.09.30` - b2.`2023.09.30`) as `2023.09.30`,
	(b1.`2023.12.31` - b2.`2023.12.31`) as `2023.12.31`,
	(b1.`2024.03.31` - b2.`2024.03.31`) as `2024.03.31`,
	(b1.`2024.06.30` - b2.`2024.06.30`) as `2024.06.30`
FROM BS b1, BS b2
WHERE 
	b1.noi_dung in ("A- TÀI SẢN NGẮN HẠN")
	and
	b2.noi_dung in ("I. Nợ ngắn hạn") ;


-- Merge all table to analyze
create table merge_tb
select distinct *
from (
select * from BCKQKD b 
union all 
select * from TS t
union all
select * from BCTQ b2 
union all
select * from HSTK h
union all
select * from HTK h1
union all 
select * from KPT k
union all 
select * from KPTR k1
union all
select * from RVN r
union all
select * from NIC n
union all
select * from VLD v
) a;