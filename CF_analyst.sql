
create table temp as
select b.noi_dung, replace(b.so_tien,',','') as so_tien from `CF.2024.06.30` b;

update temp
set `so_tien` = CASE 
	WHEN `so_tien` = '' THEN NULL
	WHEN `so_tien` = ' ' THEN NULL 
	WHEN `so_tien` = '-' THEN NULL 
	ELSE  `so_tien`
END;

alter table temp modify column so_tien DOUBLE NULL;

drop table `CF.2024.06.30`;

alter table temp rename to `CF.2024.06.30`;

CREATE TABLE CF AS
SELECT 
c.noi_dung,
c.so_tien AS `2023.03.31`, 
c1.so_tien AS `2023.06.30`,
c2.so_tien AS `2023.09.30`,
c3.so_tien AS `2023.12.31`,
c4.so_tien AS `2024.03.31`, 
c5.so_tien AS `2024.06.30`
FROM 
    `CF.2023.03.31` c
JOIN 
    `CF.2023.06.30` c1 ON c.noi_dung = c1.noi_dung
JOIN 
    `CF.2023.09.30` c2 ON c.noi_dung = c2.noi_dung
JOIN 
    `CF.2023.12.31` c3 ON c.noi_dung = c3.noi_dung
JOIN 
    `CF.2024.03.31` c4 ON c.noi_dung = c4.noi_dung
JOIN 
    `CF.2024.06.30` c5 ON c.noi_dung = c5.noi_dung;
   
-- lấy dữ liệu EBITDA, Netchange in cash, số dư cuối kỳ
-- EBITDA = lợi nhuận trước thuế + chi phí lãi vay + khấu hao 
-- thay đổi dòng tiền ròng = dòng tiền từ hoạt động kinh doanh + dòng tiền từ hoạt động đầu tư + dòng tiền từ hoạt động tài chính
-- số dư cuối kỳ ( tiền và tương đương tiền cuối kỳ)
CREATE TABLE NIC AS
SELECT "EBITDACF" as noi_dung,
	c1.`2023.03.31` + c2.`2023.03.31`+ c3.`2023.03.31` as `2023.03.31`,
	c1.`2023.06.30` + c2.`2023.06.30` + c3.`2023.06.30` as `2023.06.30`,
	c1.`2023.09.30` + c2.`2023.09.30` + c3.`2023.09.30` as `2023.09.30`,
	c1.`2023.12.31` + c2.`2023.12.31` + c3.`2023.12.31` as `2023.12.31`,
	c1.`2024.03.31` + c2.`2024.03.31` + c3.`2024.03.31` as `2024.03.31`,
	c1.`2024.06.30` + c2.`2024.06.30` + c3.`2024.06.30` as `2024.06.30`
FROM CF c1, CF c2, CF c3 
WHERE 
	c1.noi_dung in ("1. Lợi nhuận trước thuế")
	and 
	c2.noi_dung in ("- Chi phí lãi vay")
	and 
	c3.noi_dung in ("- Khấu hao và hao mòn tài sản cố định (bao gồm phân bổ lợi thế thương mại)")
UNION ALL 
SELECT "thay doi dong tien rong" as noi_dung,
	c4.`2023.03.31` + c5.`2023.03.31` + c6.`2023.03.31` as `2023.03.31`,
	c4.`2023.06.30` + c5.`2023.06.30` + c6.`2023.06.30` as `2023.06.30`,
	c4.`2023.09.30` + c5.`2023.09.30` + c6.`2023.09.30` as `2023.09.30`,
	c4.`2023.12.31` + c5.`2023.12.31` + c6.`2023.12.31` as `2023.12.31`,
	c4.`2024.03.31` + c5.`2024.03.31` + c6.`2024.03.31` as `2024.03.31`,
	c4.`2024.06.30` + c5.`2024.06.30` + c6.`2024.06.30` as `2024.06.30`
FROM CF c4, CF c5, CF c6
WHERE 
	c4.noi_dung in ("Lưu chuyển tiền thuần từ hoạt động kinh doanh")
	and 
	c5.noi_dung in ("Lưu chuyển tiền thuần từ hoạt động đầu tư")
	and 
	c6.noi_dung in ("Lưu chuyển tiền thuần từ hoạt động tài chính")
UNION ALL 
SELECT "so du cuoi ky" as noi_dung,
		c.`2023.03.31`, c.`2023.06.30`, c.`2023.09.30`,
		c.`2023.12.31`, c.`2024.03.31`, c.`2024.06.30`
FROM CF c
WHERE noi_dung in ("Tiền và tương đương tiền cuối kỳ (70 = 50+60+61)");



-- Cash inflow breakdown
-- tỷ lệ phần trăm hoạt động vận hành ròng/ dòng tiền đến từ hoạt động đầu tư/ dòng tiền đến từ hoạt động tài chính 
-- tỷ lệ phần trăm hoạt động vận hành = 
SELECT *
FROM CF
WHERE noi_dung IN ("Lưu chuyển tiền thuần từ hoạt động kinh doanh","Lưu chuyển tiền thuần từ hoạt động đầu tư", "Lưu chuyển tiền thuần từ hoạt động tài chính",
					"Lưu chuyển tiền thuần trong kỳ (50 = 20+30+40)")