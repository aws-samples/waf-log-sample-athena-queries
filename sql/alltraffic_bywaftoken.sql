-- This sql retrieves all requests that were passed a specific waf token
-- This analysis is useful to determine if a token is being used to attack the site
SELECT   * 
FROM "waf_logs" ,
UNNEST( CASE WHEN cardinality(labels) >= 1
               THEN labels
               ELSE array[ cast( row('NOLABEL') as row(name varchar)) ]
              END
       ) AS t(label_item)
WHERE 
 date >=date_format(current_date - interval '7' day, '%Y/%m/%d')  
 AND label_item.name = 'INSERT_THE_TOKEN_ID_HERE'
 ORDER BY timestamp 