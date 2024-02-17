SELECT   label_item.name,count(distinct httprequest.clientip )
FROM "waf_logs" ,
UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) as t(label_item)
WHERE 
 date >=date_format(current_date - interval '8' day, '%Y/%m/%d')  
 and label_item.name like 'awswaf:managed:token:id:%'
 group by label_item.name
order by label_item.name