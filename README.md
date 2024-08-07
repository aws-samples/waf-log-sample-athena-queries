# WAF-Logs-Sample-Athena-queries
Analyzing AWS WAF logs using Amazon Athena queries provides visibility needed for threat detection.

Web application security is an ongoing process. [AWS Web Application Firewall(WAF)](https://aws.amazon.com/waf/) enables real-time monitoring and blocking of potentially harmful web requests. Bot Control and Fraud Control leverage machine learning to detect and prevent sophisticated threats. To guarantee optimal security, it's crucial to regularly assess and improve your WAF configuration by leveraging traffic insights. By doing so, you can enhance the security posture of your application and efficiently mitigate malicious traffic.

This post will provide information on how to use [Amazon Athena](https://aws.amazon.com/athena/) to analyze WAF logs published to Amazon Simple Storage Service (Amazon S3) bucket and gather insights into potential attacks. If you are publishing AWS WAF logs to [Amazon CloudWatch Logs](https://aws.amazon.com/cloudwatch/), please refer to [this post](https://aws.amazon.com/blogs/mt/analyzing-aws-waf-logs-in-amazon-cloudwatch-logs/). Using Athena, it’s easy to perform ongoing analysis of your WAF by surfacing outliers such as top 10 IP addresses accessing your application, top 10 URI accessed, top IP addresses with token rejections, tracking of a client session and many more use cases.  

### AWS WAF Dashboards

AWS WAF provides [per web ACL traffic overview dashboards](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-dashboards.html) to provide an overview into web traffic. The dashboards are divided into 4 different categories: All traffic, Bot Control, Account takeover protection, Account creation fraud prevention. To explore dimensions such requests per top 10 countries, token status or client session thresholds, you can use default dashboards. For deeper web traffic analysis and generating data for your custom use case, you need to analyze WAF logs. Athena provides you a useful integration to run queries. 

### AWS WAF logging

With [WAF logging](https://docs.aws.amazon.com/waf/latest/developerguide/logging.html), you can view metadata in JSON formatcan  about the traffic accessing your protected resources, including client IP addresses, requested resources, and more. See [Log Fields](https://docs.aws.amazon.com/waf/latest/developerguide/logging-fields.html) for a full list of available data. This information allows you to analyze traffic across various dimensions, such as client IPs, URIs, hosts, client IP country, headers, and WAF rules, providing valuable insights into your web application's security. WAF generates a unique JSON log entry for each HTTP request it handles, which can be stored and analyzed. You can send WAF logs to various destinations, including S3 buckets, CloudWatch, or using [Amazon Kinesis Data Firehose](https://aws.amazon.com/kinesis/firehose/) to send logs to third party solutions like Datadog, Splunk etc. Once a Kinesis Data Firehose is created you can associate it with a WAF webACL via CLI or console which enables WAF to send real-time logs to a required destination. 

### Prerequisites

1.	Turn on WAF logging: Follow [this post](https://repost.aws/knowledge-center/waf-turn-on-logging) and publish logs to S3 bucket directly from WAF or via Kinesis Data Firehose. Preferred method is to use Kinesis Data Fire Hose for better control of log delivery.
2.	Configure Athena: WAF has a known structure to specify a partition scheme in advance. Follow [this post](https://docs.aws.amazon.com/athena/latest/ug/waf-logs.html) to create a table in Athena referencing the WAF schema. Points to note when creating Athena tables

    a)	We recommend to create Athena table using the [partitioned schema](https://docs.aws.amazon.com/athena/latest/ug/waf-logs.html#create-waf-table-partition-projection) by date. If you use direct S3 log delivery instead of using Kinesis, consider partitioning by region too.

    b)	Be sure to specify the correct Amazon S3 bucket location for storing WAF logs, as configured in the previous step. 

    c)	WAF regularly updates log fields when new features are launched, so you'll need to update your query schema to get the latest data using Athena.

### Examples of threat detection analysis using WAF logs and Athena

As mentioned earlier in this post, AWS WAF logs contain metadata required to analyze the details of the user request. AWS considers terminating and non-terminating rule actions to halt or continue processing the request down the configured rule priority order. When analyzing bot traffic, it is important to understand the WAF token characteristics and [labels](https://docs.aws.amazon.com/waf/latest/developerguide/waf-tokens-labeling.html) generated by WAF intelligent threat detection. The WAF token is saved as a cookie named aws-waf-token. For CAPTCHA and Challenge requests, AWS WAF inspects WAF token status. If the request has a valid token, its treated as a non-terminating match whereas if the token is invalid [absent, expired, rejected] AWS WAF presents CAPTCHA or Challenge interstitial to clients.

#### Example 1: Top talkers by different criteria 

Top talkers refers to the devices, bots or users that generate the most network traffic or pose greatest potential threat to your applications. For example, you start with looking at your CloudWatch metrics and identify a spike in the number of requests hitting your application in the last few days. Then you would like to dive-deep into the requests to understand the source of the requests by IP address, URI, HTTP headers etc. [This  query](sql/top10ip.sql) helps you to get the top 10 IP sources using Athena queries.  [This  query](sql/top10uri.sql) helps you to get the top 10 URI accessed. You can use additional filters like httprequest.uri, httprequest.httpmethod to get top talkers with respect each HTTP attribute. More examples can be found [here](https://docs.aws.amazon.com/athena/latest/ug/waf-logs.html#query-examples-waf-logs).

Sometimes, you want to see all the traffic from a client before a token was acquired and after the token acqusition. [This query](sql/alltraffic_byip_including_token.sql) gives you information about all  traffic from a given client IP including the traffic before the token was acquired, traffic which caused the token to be acquired and traffic after the token acquisition.

#### Example 2: Get counts of various bot traffic for a given set of days

You have configured bot rule group. You would like to get statistics on the requests that are matched with the rules in the Bot Control rule group. [This query](sql/bot.sql) provides you output with the count of requests against different categories of  bot label matched over a specific date. 


#### Example 3: Get counts of labels per IP address

You have configured multiple AWS WAF rulesets per web ACL. You would like to get statistics on the requests that are matched with each and every rule and build a chart from the csv output. [This query](sql/alllabels_byip.sql) provides you output with the count of each label match per IP address or over a specific date. As of today, AWS WAF provides around 400+ labels and you can customize the query to add or remove the labels per your use case.


#### Example 4: Top talker with additional details 

You have configured multiple AWS WAF rulesets per web ACL. You would like to get statistics on which IP is generating most requests and details of  every rule that they match. [This query](sql/toptraffic.sql) provides the count of traffic by an IP over a range of  dates and which was the terminatingruleid. 

#### Example 5: Website Scraping and attacks

Website scraping is the process of extracting data from websites which involves software and algorithms to navigate a website trying to extract specific data. An attack is an access to a website with an intention to degrade the website performance and breach security. From the previous example, you get the output with IP address and total requests in descending order. To understand if the particular IP address is attacking your website, use the httprequest.clientip as a filter and perform [the query](sql/alltraffic_byip.sql) to identify the URLs the IP is trying to access. Make sure to replace the XXX.XXX by valid IP values in the query. 

#### Example 6: AWS WAF tokens analysis (activity by IP and token misuse)

AWS WAF provides unique token based on the immunity time configured (with minimum of 60 seconds to a maximum of 3 days). AWS WAF presents the user with CAPTCHA or challenge after the immunity time expires. A malicious user can generate a token and reuse it via their scripts to generate high load of requests or spread the requests across multiple IP addresses. As the token is unique per client IP, this query provides output on token ID and number of IP’s which sent the same token. The expectation is to have no more than a small number of IPs per WAF token.  Use [this query](sql/waftoken_byip.sql) to find if you have token misuse. The exception to the 1 IP per WAF token is when the user is travelling and acquires a different IP and the token immunity period hasnot expired. 

If you have enabled Challenge/CAPTCHA/Bot Control , it helps to understand if the IPs generating  the most traffic are having a valid WAF token. [This query](sql/waftoken_analysis.sql) will clarify if the WAF token is missing or expired or the domain is invalid.

#### Example 7: Session tracking – Lifecycle of a client request (Client session activity by token)
With the query in Example 6 , you  have a list of tokens utilized by different IPs.  Once a WAF token is issued, use [this query](sql/alltraffic_bywaftoken.sql) to find out which all requests were made with that token. Before running the query replace the text "INSERT_THE_TOKEN_ID_HERE" with the WAF token into the query. 

#### Example 8: Calculating thresholds for Rate Based Rules
[This query](sql/rbrheaderthreshold.sql)  gives the thresholds for your Rate Based Rules such as how many requests were received with a specific header in a 5 minute window over the past 7 days . You get min, max, avg, p95, p99 values of the requests  coming in with unique values of the header. If you dont need the unique values of the header, then you can  comment out all references to headervalue. This allows you to calculate the thresholds for traffic which has the specific header.

[This query](sql/rbrclientipurithreshold.sql)  gives the thresholds for your Rate Based Rules such as how many requests were received with from a specific IP / for a URI  in a 5 minute window over the past 7 days . You get min, max, avg, p95, p99 values of the requests  coming in with unique values of the IP/ URI combination.  This allows to calculate what thresholds you want to setup for your rate based rules based on IP/URI combination

#### Example 9: Calculating traffic blocked by Rate Based Rules
[This query](sql/traffic_byrbrheader.sql)  gives the details about the  traffic being blocked by your Rate Based Rules using a  specific header as an AGGREGATION KEY. It calculates the traffic  blocked  in  5 minute intervals during the specified time slot. You can add/change additional  AGGREGATION KEYS  per your WAF rules to validate that rules are working as per your requirements. 

[This query](sql/traffic_byrbruri.sql)  gives the details about the  traffic being blocked by your Rate Based Rules using a URI as an AGGREGATION KEY. It calculates the traffic  blocked  in  5 minute intervals during the specified time slot . You can add/change additional  AGGREGATION KEYS  per your WAF rules to validate that rules are working as per your requirements. 

### Tips to make Athena queries faster
To improve query performance refer to [Athena performance tuning post](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning.html). It is important to reduce the data being queried. Here are some additional tips to help improve your Athena queries. 

1.	Use DATE in the Athena partition criteria for WAF logs. 
2.	Use DATE in WHERE clause and restrict to few days by using this where clause "date >= date_format(current_date - interval '7' day, '%Y/%m/%d')". You can decrease/increase the # of days being queried to meet your performance SLA.
3.	Avoid using more than 1 UNNEST clause in a single query. 
4.	Avoid join with the entire dataset without a "DATE" based where clause.
5.  If you a single bucket for logging across WebACLs from multiple AWS account Ids, try to partition the log data with the account id as partition key. This would let you use account Id in the where clause whereby reducing the data queried.  
    If you are sending logs from multiple accounts into 1 single Kinesis Data Firehose, you can also do dynamic partitioning based on the account id. This would allow you to use the account id in the partition and reduce the number of files being queried at any given time. Check [this link](https://docs.aws.amazon.com/firehose/latest/dev/dynamic-partitioning.html) for Additional information on dynamic partitioning.
6.  If multiple Web ACL log to the same bucket, then filter by webACL	webaclid = 'arn of webACL'
7.  If a webACL is attached to multiple AWS resources, then filter by httpsourceId  using this where clause 	httpsourceid = ‘id of the resource’. 
8.  Remember all times are recorded in Coordinated Universal Time (UTC). Factor that in when doing conversion to local timezones. You can  query based on certain absolute dates such as date = '2024/03/22' when querying historical data for better performance.


### Conclusion

This post discusses how to use WAF logs and Athena service to gain insights into your application traffic. You can also build Amazon QuickSight dashboards using specific Athena queries by following this post. The example queries will help you to get started with querying WAF logs via Athena. For queries related to other use cases, refer to this GitHub repository. Our team will keep adding new queries to this repository and please use discussions forum to provide any feedback or request queries for additional specific use cases. Also, note that you will be charged for publishing WAF logs, querying via Athena and for information on cost effective ways of configuring WAF, please refer to this post.

Moreover, to keep up to date with AWS WAF, refer to AWS WAF Security Blog and what’s new with AWS Security, Identity, & Compliance. If you have feedback about this post, submit comments in the Comments section. If you have questions about this post, start a new thread on AWS WAF re:Post or contact AWS Support.


## Authors and acknowledgment
 Jess Izen, Kaustubh Phatak, Kartik Bheemisetty, Vishal Lakhotia

## License
This sample code is made available under the MIT-0 license. See the LICENSE file.

## Project status
This project is continously being updated.
