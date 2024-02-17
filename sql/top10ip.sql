select httprequest.clientip, count(httprequest.clientip) as requests
from waf_logs
where date >= date_format(current_date - interval '2' day, '%Y/%m/%d')
group by httprequest.clientip
order by requests desc
limit 10 