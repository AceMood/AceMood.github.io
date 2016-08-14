---
layout: post
title: What am I talking about when I say TTI optimization
tagline: by AceMood
categories: JavaScript
sc: js
description: Performance
keywords: front-end performance, TTI
---
## preface

Standing on date Aug 1st 2016, we talk about **TTI** optimization. Keep in mind that we have lots of methods can do. TTI means time to interact, first mentioned by Facebook when they guys do optimization of HomePage. 

<img src="/assets/images/20160801/001.png" alt="fb" style="width: 100%; height: auto;" />

At that time, they defined the most important area as marked in red-line, and **the time between clicking the link button and user can interact with the key area content** named **TTI**. 

## Loading and runtime

We have mainly two types of performance issues, when **loading resources** and when code **running on client**. Also we have mainly two platform need to focus on, PC and mobile. As the mobile market occupation increase rapidly and data of PC still steadily, we will focus on mobile this time.

Many blog/articles mentioned the workaround, include icon-font, srcset, lazyLoad, load on demand, inlining images data, localStorage cache solution, compress and so on. All technologies we most used are based on the implementation of Browsers Manufactures. 

## Tips on advice

If you do not have sense about what you're going to do, do the data analysis first. I reprinted an [article](https://acemood.github.io/2015/04/13/cache-efficiency-exercise/) from Facebook's Blog to demonstrate that a series of data can give more information if you rethink it from multi-aspects. And what is the key point impacts your website's TTI can be different, for example:

* If you have many images (biggest size) on the first viewport, do your best to reduce the size of images and requests or cache all the unchanged data on client, then analyze it again, compare the results and make other decisions.       
* If the javascript code on your website is the critical point, do some other work to improve it. Also you must consider as time goes on, your website may become bigger and bigger, how to balence it.

If you're willing from another aspect, you can notice what Googlers have done on **Loading** and **Runtime**. To reduce the loading time (connection time) they implement and apply the [QUIC protocol](https://www.chromium.org/quic)

<br>
<img src="/assets/images/20160801/002.png" alt="fb" style="width: 80%; height: auto; posiiton:relative; margin:auto" />
<br>

To improve the runtime performance, they use a new optimize compiler named [TurboFan](http://v8project.blogspot.com/2015/07/digging-into-turbofan-jit.html) in v8 engine.

Before digging into the technology, we notice all things they did can not only bring benefit to Google, also for any other companies and organizations. So, Optimization is not a single task of one company, it relates to the whole social of Internet and Computer Sciense, further for whole human beings. If possible, top-level developers should join them to improve.

Back on our own project, I take the [Baidu.Inc Home page](http://m.baidu.com/) for example, it's not a real improvement, but an imagination.



