select 
  a.season as season,
  a.isocode as isocode,
  a.total_sales_kg,
  b.total_sales_by_ficle_retail,
  (a.total_sales_kg - b.total_sales_by_ficle_retail) AS clean_sales,
  c.total_sales_by_clean_retail,
  ((a.total_sales_kg - b.total_sales_by_ficle_retail) - c.total_sales_by_clean_retail) AS cat_b,
  d.total_sales_70
from 
  (select 
    season,
    isocode,
    sum(total_sales_kg) as total_sales_kg
  from sales_orange
  where season != 'Межсезон'
  group by season, isocode
  ) a
left join
  (select 
    season,
    isocode,
    sum(total_sales_kg) as total_sales_by_ficle_retail
  from sales_orange 
  where buyers_name in ('Виталюр Скл 2', 'Фреш Сервис', 'ПРОСТОРМАРКЕТ', 'Юнифуд', 'ГРИНрозница', 'Белкоопвнешторг Белкоопсоюза РЦ', 
                        'БелМаркетКомпани скл 2 РЦ', 'ПРОСТОРИТЕЙЛ', 'БелВиллесден', 'Дилерторг', 'Табак-инвест РЦ', 
                        'Белинтерпродукт СКЛ №2 рц', 'Санта Ритейл', 'Доброном', 'Баниар', 'Еврокэш Групп Скл.2', 
                        'Евроторг', 'Фудлогистик Скл.2', 'ЛенПродуктСервис') and season != 'Межсезон'
  group by season, isocode
  ) b
on a.season = b.season and a.isocode = b.isocode
left join
  (select 
    season,
    isocode,
    sum(total_sales_kg) as total_sales_by_clean_retail
   from sales_orange 
   where buyers_name not in ('Виталюр Скл 2', 'Фреш Сервис', 'ПРОСТОРМАРКЕТ', 'Юнифуд', 'ГРИНрозница', 'Белкоопвнешторг Белкоопсоюза РЦ', 
                             'БелМаркетКомпани скл 2 РЦ', 'ПРОСТОРИТЕЙЛ', 'БелВиллесден', 'Дилерторг', 'Табак-инвест РЦ', 
                             'Белинтерпродукт СКЛ №2 рц', 'Санта Ритейл', 'Доброном', 'Баниар', 'Еврокэш Групп Скл.2', 
                             'Евроторг', 'Фудлогистик Скл.2', 'ЛенПродуктСервис') and season != 'Межсезон' and warehouse_type_name = 'Склад №2 РЦ'
   group by season, isocode
  ) c 
on a.season = c.season and a.isocode = c.isocode
left join
  (select 
    season,
    isocode,
    sum(total_sales_kg) as total_sales_70
  from sales_orange
  where segment_name = '70.0' and season != 'Межсезон'
  group by season, isocode
  ) d
on a.season = d.season and a.isocode = d.isocode
ORDER BY a.season ASC

  