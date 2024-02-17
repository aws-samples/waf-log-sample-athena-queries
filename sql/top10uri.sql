select httprequest.uri, count(httprequest.uri) as requests
from waf_logs
where date >= date_format(current_date - interval '2' day, '%Y/%m/%d')
group by httprequest.uri
order by requests desc
limit 10 