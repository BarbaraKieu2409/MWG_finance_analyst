
create table temp as
select b.noi_dung, replace(b.so_tien,',','') as so_tien from `PL.2024.06.30` b;

update temp
set `so_tien` = CASE 
	WHEN `so_tien` = '' THEN NULL
	WHEN `so_tien` = ' ' THEN NULL 
	WHEN `so_tien` = '-' THEN NULL 
	ELSE  `so_tien`
END;

alter table temp modify column so_tien DOUBLE NULL;

drop table `PL.2024.06.30`;

alter table temp rename to `PL.2024.06.30`;

CREATE TABLE PL AS
SELECT 
P.noi_dung,
P.so_tien AS `2023.03.31`, 
P1.so_tien AS `2023.06.30`,
P2.so_tien AS `2023.09.30`,
P3.so_tien AS `2023.12.31`,
P4.so_tien AS `2024.03.31`, 
P5.so_tien AS `2024.06.30`
FROM 
    `PL.2023.03.31` P
JOIN 
    `PL.2023.06.30` P1 ON P.noi_dung = P1.noi_dung
JOIN 
    `PL.2023.09.30` P2 ON P.noi_dung = P2.noi_dung
JOIN 
    `PL.2023.12.31` P3 ON P.noi_dung = P3.noi_dung
JOIN 
    `PL.2024.03.31` P4 ON P.noi_dung = P4.noi_dung
JOIN 
    `PL.2024.06.30` P5 ON P.noi_dung = P5.noi_dung;
 
-- tính EBITDA và revenue 
-- EBITDA = doanh thu - giá vốn bán hàng - chi phí bán hàng - chi phí quản lý doanh nghiệp
CREATE TABLE RVN AS 
SELECT "doanh thu" as noi_dung,
	p.`2023.03.31`, p.`2023.06.30`, p.`2023.09.30`,
	p.`2023.12.31`, p.`2024.03.31`, p.`2024.06.30`
FROM PL p
WHERE p.noi_dung = "doanh thu"
UNION ALL 
SELECT 
	"EBITDA" as noi_dung,
	(p.`2023.03.31` - p1.`2023.03.31` - p2.`2023.03.31`- p3.`2023.03.31`) as `2023.03.31`,
	(p.`2023.06.30` - p1.`2023.06.30` - p2.`2023.06.30`- p3.`2023.06.30`) as `2023.06.30`,
	(p.`2023.09.30` - p1.`2023.09.30` - p2.`2023.09.30`- p3.`2023.09.30`) as `2023.09.30`,
	(p.`2023.12.31` - p1.`2023.12.31`- p2.`2023.12.31`- p3.`2023.12.31`) as `2023.12.31`,
	(p.`2024.03.31` - p1.`2024.03.31` - p2.`2024.03.31`- p3.`2024.03.31`) as `2024.03.31`,
	(p.`2024.06.30` - p1.`2024.06.30` - p2.`2024.06.30`- p3.`2024.06.30`) as `2024.06.30`
FROM PL p, PL p1, PL p2, PL p3
WHERE 
	p.noi_dung in ("doanh thu")
	and 
	p1.noi_dung in ("giá vốn hàng bán")
	and 
	p2.noi_dung in ("9. Chi phí bán hàng")
	and
 	p3.noi_dung in ("10. Chi phí quản lý doanh nghiệp");

SELECT *
FROM PL
ROLLBACK;

-- tổng quan báo cáo kết quả kinh doanh 
--  + doanh thu
--  + giá vốn hàng bán
--  + lợi nhuận gộp 
--  + chi phí hoạt động 
--  + lợi nhuận hoạt động 
--  + lợi nhuận trước thuế
--  + lợi nhuận ròng
update PL
SET noi_dung = 'doanh thu'
where noi_dung = '1. Doanh thu bán hàng và cung cấp dịch vụ';

update PL 
SET noi_dung = 'giá vốn hàng bán'
WHERE noi_dung = '4. Giá vốn hàng bán và dịch vụ cung cấp';

update PL 
SET noi_dung = 'lợi nhuận gộp'
WHERE noi_dung = "5. Lợi nhuận gộp về bán hàng và cung cấp dịch vụ(20=10-11)";

update PL
SET noi_dung = "lợi nhuận hoạt động"
WHERE noi_dung IN ("11. Lợi nhuận thuần từ hoạt động kinh doanh{30=20+(21-22) + 24 - (25+26)}");

update PL 
SET noi_dung = "lợi nhuận trước thuế"
WHERE noi_dung IN ("15. Tổng lợi nhuận trước thuế(50=30+40)");

update PL 
SET noi_dung = "lợi nhuận ròng"
WHERE noi_dung IN("18. Lợi nhuận sau thuế thu nhập doanh nghiệp(60=50-51-52)");

CREATE TABLE BCKQKD AS 
SELECT *
FROM PL 
WHERE noi_dung IN ('doanh thu', 'giá vốn hàng bán',
					'lợi nhuận gộp',"lợi nhuận hoạt động","lợi nhuận ròng","lợi nhuận trước thuế")
UNION ALL
SELECT 
	"chi phí hoạt động " as noi_dung,
	(p5.`2023.03.31` + p6.`2023.03.31`+ p7.`2023.03.31`) as `2023.03.31`,
	(p5.`2023.06.30` + p6.`2023.06.30`+ p7.`2023.06.30`) as `2023.06.30`,
	(p5.`2023.09.30` + p6.`2023.09.30`+ p7.`2023.09.30`) as `2023.09.30`,
	(p5.`2023.12.31` + p6.`2023.12.31`+ p7.`2023.12.31`) as `2023.12.31`,
	(p5.`2024.03.31` + p6.`2024.03.31`+ p7.`2024.03.31`) as `2024.03.31`,
	(p5.`2024.06.30` + p6.`2024.06.30`+ p7.`2024.06.30`) as `2024.06.30`
FROM  PL p5, PL p6, PL p7
WHERE 
	p5.noi_dung in ("7. Chi phí tài chính")
	and 
	p6.noi_dung in ("9. Chi phí bán hàng")
	and
 	p7.noi_dung in ("10. Chi phí quản lý doanh nghiệp");
					
-- báo cáo theo quý
-- +giá vốn hàng bán
-- +doanh thu
-- +lợi nhuận gộp 
CREATE TABLE BCTQ AS
SELECT *
FROM PL 
WHERE noi_dung IN ("giá vốn hàng bán", "doanh thu","lợi nhuận gộp" )