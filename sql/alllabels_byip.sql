-- This sql is to show the count of  IPs matching  a label over a period of 7 days. If a request has no label attached, then it would be recorded against NOLABEL
SELECT count(*) AS count,httprequest.clientip,
label_item.name
FROM "waf_logs", UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE ARRAY[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) AS t(label_item)
WHERE 
 date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
GROUP BY httprequest.clientip,label_item.name
ORDER BY  clientip