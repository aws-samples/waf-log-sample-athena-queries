SELECT count(*) AS count,httprequest.clientip,
label_item.name
FROM "waf_logs", UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) as t(label_item)
WHERE 
 date >=date_format(current_date - interval '8' day, '%Y/%m/%d')  
GROUP BY httprequest.clientip,label_item.name
order by clientip