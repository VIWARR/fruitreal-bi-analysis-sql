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
        
        -- сумма продаж за неделю
        coalesce(sum(total_sales_kg), 0) as total_sales,
        
        -- сумма продаж по сетям
        coalesce(sum(case when warehouse_type_name = 'Склад №2 РЦ' then total_sales_kg end), 0) as retail_sales,
        
        -- средневзвешенная себестоимость
        round(coalesce(sum(total_sales_kg * cost_kg_usd) / sum(total_sales_kg), 0), 2) as weighted_avg_cost,
        
        -- недельный план продаж
        coalesce(max(sales_plan), 0) as sales_plan,
        
        -- % выполнения
        coalesce(max(execition_of_plan), 0) as execition_of_plan,
        
        -- итоговое отклонение от плана
        toInt32((total_sales / sales_plan - execition_of_plan) * 100) as diff_plan

    from vp
    where year = 2024
    group by product_name

    union all

    -- итоговая строка для суммы максимальных значений по каждому продукту
    select
        'Итого' as product_name,
        
        -- итоговая сумма продаж по дням
        coalesce(sum(case when day_of_week = 'понедельник' then total_sales_kg end), 0) as monday,
        coalesce(sum(case when day_of_week = 'вторник' then total_sales_kg end), 0) as tuesday,
        coalesce(sum(case when day_of_week = 'среда' then total_sales_kg end), 0) as wednesday,
        coalesce(sum(case when day_of_week = 'четверг' then total_sales_kg end), 0) as thursday,
        coalesce(sum(case when day_of_week = 'пятница' then total_sales_kg end), 0) as friday,
        coalesce(sum(case when day_of_week = 'суббота' then total_sales_kg end), 0) as saturday,
        coalesce(sum(case when day_of_week = 'воскресенье' then total_sales_kg end), 0) as sunday,
        
        -- итоговая сумма продаж за неделю
        coalesce(sum(total_sales_kg), 0) as total_sales,
        
        -- итоговая сумма продаж за неделю по сетям
        coalesce(sum(case when warehouse_type_name = 'Склад №2 РЦ' then total_sales_kg end), 0) as retail_sales,
        
        -- итоговая средневзвешенная себестоимость
        round(coalesce(sum(total_sales_kg * cost_kg_usd) / sum(total_sales_kg), 0), 2) as weighted_avg_cost,
        
        -- итоговая сумма плана продаж за неделю
        (select sum(max_sales_plan) from max_sales_plan) as sales_plan,
        
        -- итоговый % выполнения за неделю
        coalesce(max(execition_of_plan) as total_execition_of_plan),
        
        -- итоговое отклонение от плана
        toInt32((total_sales / sales_plan - total_execition_of_plan) * 100) as diff_plan
    from vp
    where year = 2024

    group by product_name
) 
order by case when product_name = 'Итого' then 1 else 0 end, product_name;