---FLTR year | week
{% set year = filter_values('year')[0] %} ---filter_values('year')[0]
{% set week = filter_values('week')[0] %} ---filter_values('week')[0]

select * from (
    -- основная таблица
    select
        product_name,

        -- сумма продаж по дням недели
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
        round(coalesce(sum(total_sales_kg * cost_kg_usd) / nullif(sum(total_sales_kg), 0), 0), 2) as weighted_avg_cost,

        -- недельный план продаж
        coalesce(max(sales_plan), 0) as sales_plan,

        -- % выполнения плана
        coalesce(max(execition_of_plan), 0) as execition_of_plan,
        
        -- итоговое отклонение от плана
        round((total_sales / sales_plan - execition_of_plan), 3) as diff_plan

    from vp_arch 
    where year = {{ year }} and week = {{ week }}
    group by product_name

    union all

    -- итоговая строка "итого"
    select
        'Итого' as product_name,

        -- итоговые суммы продаж по дням недели
        coalesce(sum(case when day_of_week = 'понедельник' then total_sales_kg end), 0) as monday,
        coalesce(sum(case when day_of_week = 'вторник' then total_sales_kg end), 0) as tuesday,
        coalesce(sum(case when day_of_week = 'среда' then total_sales_kg end), 0) as wednesday,
        coalesce(sum(case when day_of_week = 'четверг' then total_sales_kg end), 0) as thursday,
        coalesce(sum(case when day_of_week = 'пятница' then total_sales_kg end), 0) as friday,
        coalesce(sum(case when day_of_week = 'суббота' then total_sales_kg end), 0) as saturday,
        coalesce(sum(case when day_of_week = 'воскресенье' then total_sales_kg end), 0) as sunday,

        -- итоговые суммы продаж за неделю
        coalesce(sum(total_sales_kg), 0) as total_sales,

        -- итоговые суммы продаж по сетям
        coalesce(sum(case when warehouse_type_name = 'Склад №2 РЦ' then total_sales_kg end), 0) as retail_sales,

        -- итоговая средневзвешенная себестоимость
        round(coalesce(sum(total_sales_kg * cost_kg_usd) / nullif(sum(total_sales_kg), 0), 0), 2) as weighted_avg_cost,

        -- итоговая сумма плана продаж
        (select sum(max_sales_plan) from (
            select max(sales_plan) as max_sales_plan
            from vp_arch
            where year = {{ year }} and week = {{ week }}
            group by product_name
        ) as subquery) as sales_plan,

        -- итоговый % выполнения плана
        coalesce(max(execition_of_plan), 0) as total_execition_of_plan,
        
        -- итоговое отклонение от плана
        round((total_sales / sales_plan - total_execition_of_plan), 3) as diff_plan

    from vp_arch
    where year = {{ year }} and week = {{ week }}
) 
order by case when product_name = 'Итого' then 1 else 0 end, product_name;