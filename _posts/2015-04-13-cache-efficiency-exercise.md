---
layout: post
title: Cache efficiency exercise
tagline: by AceMood
categories: Front-end
sc: fe
description: Cache efficiency exercise
keywords: web performance, facebook
---

# preface

It's reprinted from [post of Facebook engineering team](https://code.facebook.com/posts/964122680272229/web-performance-cache-efficiency-exercise/). 
I must say that Facebook web team have an excellent option in a perfect environment to help them improve their web performance. Their solutions in web
architecture inspire me from time to time. I strongly recommend every web developer to read their blogs and dive into their solutions.

# Web performance: Cache efficiency exercise

Speed is a consideration for any website, whether it's for the local barbershop or Wikipedia, with its huge repository of knowledge. 
It's a feature that shouldn't be ignored. This is why caching is important — a great way to make websites faster is to save parts of 
them so they don't have to be calculated or downloaded again on the next visit.

My team was recently having a discussion about the parts of facebook.com that are currently uncached, and the question came up: 
What is the efficiency of the cache since, at Facebook, we release new code twice a day? Are we releasing new code too often to 
benefit from having resources in the browser cache? In searching for an answer, we found a study on[Yahoo's Performance Research blog]
(http://yuiblog.com/blog/2007/01/04/performance-research-part-2/) that looked at the impact of the browser cache on webpage performance.

We were surprised and saddened to see the results: 20% of all page views were coming in with an empty cache. But then again, 
this study was done more than eight years ago. That was before browsers could show traffic in things like the network waterfall 
screengrab you see at the top of this post. We're talking just a few months after IE7 and jQuery were first released. 
Let that sink in for a minute. jQuery 1.0 — yeah, the old-old-old days. With a grain of salt in hand, we decided to run our 
own numbers and see if things have gotten better since that study was published.

# Re-creating the study

In the original study, Yahoo created a new image that was served with a special set of headers. These headers tell the browser that when that same image is requested a second time, instead of doing a normal request do a conditional GET request if the image has changed. This type of GET request passes the Last-Modified header back to the server, and if it hasn't been too long since the image has been modified, the reply can be 304 Not Modified instead of 200 Success. Yahoo then looked at its server logs to do the analysis.

Similar to that, we created a PHP endpoint that could both deliver the image and also log requests to a database.The image was sent with HTTP headers to control the browser cache and any intermediate proxy caches, and we logged all the headers that were sent as part of the request. The headers we sent in our response were:

```
Cache-Control: no-cache, private, max-age=0
ETag: abcde
Expires: Thu, 15 Apr 2014 20:00:00 GMT
Pragma: private
Last-Modified: $now // RFC1123 format
```

But for IE7 and IE8, we tweaked two headers to get around some known bugs and instead sent:

```
Cache-Control: private, max-age=0
Pragma: no-cache
```
