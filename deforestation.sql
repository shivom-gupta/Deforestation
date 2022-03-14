CREATE VIEW forestation AS
SELECT f.country_code,f.country_name,f.year,f.forest_area_sqkm,
  	   l.total_area_sq_mi*2.59 AS total_area_sqkm,
      	   r.region, r.income_group,
     	  (f.forest_area_sqkm*100)/(total_area_sq_mi*2.59) AS percent_for
FROM forest_area f
JOIN land_area l
ON f.country_code=l.country_code AND f.year=l.year
JOIN regions r
ON f.country_code=r.country_code;



SELECT country_code, country_name, 
	   lag(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm AS diff,
      	   100*(lag(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm )/(     lag(forest_area_sqkm) OVER (ORDER BY year)) AS per
FROM forestation
WHERE country_name='World' AND year=2016;
                                                                                                   
SELECT country_code, country_name ,
	lag(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm AS  diff,
           100*(lag(forest_area_sqkm) OVER (ORDER BY year)-forest_area_sqkm)/(lag(forest_area_sqkm) OVER (ORDER BY year)) AS per
FROM forestation
WHERE country_name='World' AND year=1990;
                                                                                                   

SELECT country_name,country_code,
   ABS(2.5899*total_area_sq_mi-
(SELECT lag(forest_area_sqkm) 	OVER (ORDER BY year)-forest_area_sqkm AS diff
FROM forestation
WHERE country_name='World' AND (year=2016 or year =1990)
ORDER BY year DESC
LIMIT 1) )
FROM land_area
WHERE year = 2016
ORDER BY abs;

SELECT DISTINCT region, year,SUM(forest_area_sqkm), percent_for
FROM forestation
WHERE year=1990 
GROUP BY 1,2,4
ORDER BY 2,4 DESC;
                                                                                                   
SELECT t1.country_code,t1.country_name, region,f1-f2 AS diff, 100*(f1-f2)/f2 AS per_inc
FROM (
SELECT DISTINCT country_code,country_name, forest_area_sqkm AS f1
FROM forestation
WHERE year=2016) t1
JOIN (
SELECT DISTINCT country_code,country_name, forest_area_sqkm AS f2
FROM forestation
WHERE year=1990) t2
ON  t1.country_code=t2.country_code
JOIN regions r
ON r.country_code = t1.country_code
ORDER BY 5;


SELECT quartile, COUNT(*) AS no_of_cn
FROM
(
   SELECT *,
   CASE WHEN percent_for >=75 THEN '4'
   WHEN percent_for <75 AND percent_for >=50 THEN '3'
   WHEN percent_for <50 AND percent_for >=25 THEN '2'
   WHEN percent_for <25 THEN '1' END AS quartile
   FROM
 	 (SELECT *
  	 FROM forestation
   	WHERE year=2016 AND region NOT LIKE 'World' AND percent_for is NOT NULL 
) temp )temp2
GROUP BY 1
ORDER BY 1 DESC;

SELECT country_name,region, percent_for
FROM forestation
WHERE percent_for > 75 AND year = 2016
ORDER BY 3 DESC
