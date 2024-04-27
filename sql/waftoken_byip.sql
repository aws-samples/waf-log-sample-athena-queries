-- This sql identified for each waf token how many unique IPs were associated. Ideally this should be 1 or 2. 
-- If the token has values > 2, the IPs associated with that token should be further analysed for possible fraud.
SELECT   label_item.name,count( distinct httprequest.clientip ) as numberOfRequests
FROM "waf_logs" ,
UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) AS t(label_item)
WHERE 
 date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
 AND label_item.name LIKE 'awswaf:managed:token:id:%'
 GROUP BY label_item.name 
ORDER BY label_item.name