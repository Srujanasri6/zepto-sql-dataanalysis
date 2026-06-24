--ZEPTO DATASET FROM KAGGLE - 3600+ ROWS (PRODUCTS)--
USE zepto_analysis;

--IMPORTING ZEPTO_V2 CSV DATA--
TRUNCATE TABLE zepto;
LOAD DATA INFILE 'zepto_v2.csv'
INTO TABLE zepto
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, @outOfStock, quantity)
SET outOfStock = (CASE WHEN @outOfStock = 'TRUE' THEN 1 ELSE 0 END);

--CHECKING DATA--
SELECT COUNT(*) FROM zepto;
select * from zepto limit 10;

--Checking for null values--
select * from zepto where category is null or
name is null or mrp is null or discountPercent is null or
availableQuantity is null or
discountedSellingPrice is null or
weightInGms is null or outOfStock is null or quantity is null;
select distinct category from zepto order by category;

--Getting unique categories--
select outOfStock, COUNT(Sku_id) from zepto group by OutOfStock;

--Finding duplicate product names--
select name, count(sku_id) as "number of items"
from zepto group by name having count(sku_id) > 1 order by count(sku_id);

--DELETING INVALID RECORDS WITH '0' PRICE--
select * from zepto where mrp=0 or discountedSellingPrice=0;
select sku_id from zepto where mrp=0 or discountedSellingPrice=0;
delete from zepto where sku_id=3607;
SELECT COUNT(*) FROM zepto;
SET SQL_SAFE_UPDATES=0;

--CONVERTING PAISE TO RUPEES--
UPDATE zepto SET mrp=mrp/100.0, discountedSellingPrice=discountedSellingPrice/100.0;
SET SQL_SAFE_UPDATES=1;
SELECT name, mrp, discountedSellingPrice FROM zepto;

--Finding top 10 highest discounted products--
SELECT DISTINCT name, mrp, discountPercent 
FROM zepto 
ORDER BY discountPercent DESC 
LIMIT 10;

--Identifying out-of-stock and high-value products--
select distinct name,mrp from zepto
where outOfStock = true 
order by mrp desc;

--Calculating REVENUE by category--
select category, sum(discountedSellingPrice * availableQuantity) as Revenue
from zepto group by category order by revenue;

--Filtering EXPENSIVE products with LOW discount--
select name, mrp, discountPercent from zepto
where mrp > 500 and discountPercent < 10;
select name, category , round(avg(discountPercent),2) as avg_discount
from zepto group by name, category order by avg_discount desc  limit 10;

--Calculating price per gram--
select distinct name, weightInGms, discountedSellingPrice, round(discountedSellingPrice/weightInGms,2)
as price_per_gram from zepto where weightInGms >=100 order by price_per_gram;

select distinct name, weightInGms,
case when weightInGms < 1000 then 'less'
when weightInGms < 5000 then 'medium'
else 'heavy' end as weight_category from zepto;

--Calculating inventory weight by category--    
select category, sum(weightInGms * availableQuantity) as total_wt
from zepto group by category order by total_wt;
