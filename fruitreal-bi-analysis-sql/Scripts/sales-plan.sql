SELECT
    product_name,
    
    -- Сумма продаж по дням
    COALESCE(SUM(CASE WHEN day_of_week = 'понедельник' THEN total_sales_kg END), 0) AS Monday,
    COALESCE(SUM(CASE WHEN day_of_week = 'вторник' THEN total_sales_kg END), 0) AS Tuesday,
    COALESCE(SUM(CASE WHEN day_of_week = 'среда' THEN total_sales_kg END), 0) AS Wednesday,
    COALESCE(SUM(CASE WHEN day_of_week = 'четверг' THEN total_sales_kg END), 0) AS Thursday,
    COALESCE(SUM(CASE WHEN day_of_week = 'пятница' THEN total_sales_kg END), 0) AS Friday,
    COALESCE(SUM(CASE WHEN day_of_week = 'суббота' THEN total_sales_kg END), 0) AS Saturday,
    COALESCE(SUM(CASE WHEN day_of_week = 'воскресенье' THEN total_sales_kg END), 0) AS Sunday,
    
    -- Итоговая сумма продаж за неделю
    COALESCE(SUM(total_sales_kg), 0) AS Total_sales,
    
    -- План продаж за неделю
    COALESCE(MAX(sales_plan), 0) AS Sales_plan
    
FROM vp
WHERE year = 2024
GROUP BY year, product_name
ORDER BY year, product_name;