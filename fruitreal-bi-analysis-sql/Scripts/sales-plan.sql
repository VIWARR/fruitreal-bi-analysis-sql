-- максимальные планы продаж по группе товаров
with max_sales_plan as (
    select 
        product_name, 
        max(sales_plan) as max_sales_plan
    from vp
    where year = 2024
    group by product_name
)
select * from (
    select
        product_name,
        
        -- сумма продаж по дням
        coalesce(sum(case when day_of_week = 'понедельник' then total_sales_kg end), 0) as monday,
        coalesce(sum(case when day_of_week = 'вторник' then total_sales_kg end), 0) as tuesday,
        coalesce(sum(case when day_of_week = 'среда' then total_sales_kg end), 0) as wednesday,
        coalesce(sum(case when day_of_week = 'четверг' then total_sales_kg end), 0) as thursday,
        coalesce(sum(case when day_of_week = 'пятница' then total_sales_kg end), 0) as friday,
        coalesce(sum(case when day_of_week = 'суббота' then total_sales_kg end), 0) as saturday,
        coalesce(sum(case when day_of_week = 'воскресенье' then total_sales_kg end), 0) as sunday,
        
        -- итоговая сумма продаж за неделю
        coalesce(sum(total_sales_kg), 0) as total_sales,
        
        -- план продаж для каждого продукта
        coalesce(max(sales_plan), 0) as sales_plan

    from vp
    where year = 2024
    group by product_name

    union all

    -- итоговая строка для суммы максимальных значений по каждому продукту
    select
        'Итого' as product_name,
        
        -- сумма продаж по дням для итоговой строки
        coalesce(sum(case when day_of_week = 'понедельник' then total_sales_kg end), 0) as monday,
        coalesce(sum(case when day_of_week = 'вторник' then total_sales_kg end), 0) as tuesday,
        coalesce(sum(case when day_of_week = 'среда' then total_sales_kg end), 0) as wednesday,
        coalesce(sum(case when day_of_week = 'четверг' then total_sales_kg end), 0) as thursday,
        coalesce(sum(case when day_of_week = 'пятница' then total_sales_kg end), 0) as friday,
        coalesce(sum(case when day_of_week = 'суббота' then total_sales_kg end), 0) as saturday,
        coalesce(sum(case when day_of_week = 'воскресенье' then total_sales_kg end), 0) as sunday,
        
        -- итоговая сумма продаж за неделю для итоговой строки
        coalesce(sum(total_sales_kg), 0) as total_sales,
        
        -- сумма максимальных значений по sales_plan для каждого продукта
        (select sum(max_sales_plan) from max_sales_plan) as sales_plan

    from vp
    where year = 2024

    group by product_name
) 
order by case when product_name = 'Итого' then 1 else 0 end, product_name;
