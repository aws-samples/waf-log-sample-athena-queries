-- This sql calculates for each client ip the total number of requests, the number of challenge requests, the number of captcha requests,
-- the number of challenge requests with token invalid, the number of captcha requests with token invalid,
-- the number of challenge requests with token domain mismatch, the number of captcha requests with token domain mismatch,
SELECT  httprequest.clientip AS clientip, COUNT(*) AS "Total_Requests",
SUM(CASE WHEN action = 'CHALLENGE' THEN 1 ELSE 0 END ) CHALLENGE,
SUM(CASE WHEN action = 'CAPTCHA' THEN 1 ELSE 0 END ) CAPTCHA,
SUM(CASE WHEN challengeresponse.failurereason = 'TOKEN_INVALID' THEN 1 ELSE 0 END ) CHALLENGE_TOKEN_INVALID,
SUM(CASE WHEN captcharesponse.failurereason = 'TOKEN_INVALID' THEN 1 ELSE 0 END ) CAPTCHA_TOKEN_INVALID,
SUM(CASE WHEN challengeresponse.failurereason = 'TOKEN_DOMAIN_MISMATCH' THEN 1 ELSE 0 END ) CHALLENGE_TOKEN_DOMAIN_MISMATCH,
SUM(CASE WHEN captcharesponse.failurereason = 'TOKEN_DOMAIN_MISMATCH' THEN 1 ELSE 0 END ) CAPTCHA_TOKEN_DOMAIN_MISMATCH,
SUM(CASE WHEN challengeresponse.failurereason = 'TOKEN_EXPIRED' THEN 1 ELSE 0 END ) CHALLENGE_TOKEN_EXPIRED,
SUM(CASE WHEN captcharesponse.failurereason = 'TOKEN_EXPIRED' THEN 1 ELSE 0 END ) CAPTCHA_TOKEN_EXPIRED,
SUM(CASE WHEN challengeresponse.failurereason = 'TOKEN_MISSING' THEN 1 ELSE 0 END ) CHALLENGE_TOKEN_MISSING,
SUM(CASE WHEN captcharesponse.failurereason = 'TOKEN_MISSING' THEN 1 ELSE 0 END ) CAPTCHA_TOKEN_MISSING
FROM  waf_logs
 WHERE date >= date_format(current_date - interval '7' day, '%Y/%m/%d')
GROUP BY httprequest.clientip
ORDER BY Total_Requests DESC