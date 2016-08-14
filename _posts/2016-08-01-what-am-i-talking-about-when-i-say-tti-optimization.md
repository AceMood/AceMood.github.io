---
layout: post
title: What am I talking about when I say TTI optimization
auth: self
tagline: by AceMood
categories: JavaScript
sc: js
description: Performance
keywords: front-end performance, TTI
---

> Unfortunately, though, the workmanlike application of those sound engineering principles isn’t always thrilling — until the software is completed on time and works without surprise.     --- <a class="authorOrTitle" href="https://en.wikipedia.org/wiki/Jon_Bentley_(computer_scientist)">Jon Bentley</a>

## Preface

Standing on date Aug 1st 2016, we talk about **TTI** optimization. Keep in mind that we have lots of methods can do. TTI means time to interact, first mentioned by Facebook when they guys do optimization of HomePage. 

<img src="/assets/images/20160801/001.png" alt="fb" style="width: 100%; height: auto;" />

At that time, they defined the most important area as marked in red-line, and **the time between clicking the link button from previous webpage and user can interact with the key area content on Facebook's homapage** named **TTI**. 

## Loading and runtime

We have mainly two types of performance issues, when **loading resources** and when code **running on client**. Also we have mainly two platform need to focus on, PC and mobile. As the mobile market occupation increase rapidly and data of PC still steadily, we will focus on mobile this time.

Many blog/articles mentioned the workaround, include icon-font, srcset, lazyLoad, load on demand, inlining images data, localStorage cache solution, compress and so on. All technologies we most used are based on the implementation of Browsers Manufactures. 

## Tips on advice

If you do not have sense about what you're going to do, do the data analysis first. I reprinted an [article](https://acemood.github.io/2015/04/13/cache-efficiency-exercise/) from Facebook's Blog to demonstrate that a series of data can give more information if you rethink it from multi-aspects. And what is the key point impacts your website's TTI can be different, for example:

* If you have many images (biggest size) on the first viewport, do your best to reduce the size of images and requests or cache all the unchanged data on client, then analyze it again, compare the results and make other decisions.       
* If the javascript code on your website is the critical point, do some other work to improve it. Also you must consider as time goes on, your website may become bigger and bigger, how to balence it.

If you're willing from another aspect, you can notice what Googlers have done on **Loading** and **Runtime**. To reduce the loading time (connection time) they implement and apply the [QUIC protocol](https://www.chromium.org/quic)

<img src="/assets/images/20160801/002.png" alt="fb" style="width: 80%; height: auto; positon:relative; margin: 20px auto;" />

To improve the runtime performance, they use a new optimize compiler named [TurboFan](http://v8project.blogspot.com/2015/07/digging-into-turbofan-jit.html) in v8 engine.

Before digging into the technology, we notice all things they did can not only bring benefit to Google, also for any other companies and organizations. So, Optimization is not a single task of one company, it relates to the whole social of Internet and Computer Sciense, further for whole human beings. If possible, top-level developers should join them to improve.

## Samples

Back to your own project, I take the [Baidu.Inc Home page](https://m.baidu.com/s?word=%E4%B8%8A%E6%B5%B7) for example, it's not a real improvement, but an imagination. I wrote [some scripts](https://github.com/AceMood/htmlAnalyzer) to get the request(without cookie) result to analyze. On the mobile side, embed javascript, css and html into localStorage is a good idea, reduce request and use cookies to control the versioning resources. Without cookies can get the first view result with no-cache.

As I see, all javascript code in the page is about **345.706kb**, and **112.759kb** after gzip. The whole page is about **165kb** after gzip, which means js code occupies **68.34%**. 

```
{
    "jsTotalByteSize": "345.706kb",
    "cssTotalByteSize": "64.058kb",
    "scripts": [
        {
            "byteSize": 1269,
            "gzip": 634,
            "content": "(function(){window._uid='';var B = window.B || {};B.comm = B.comm || {};B.comm.isAndroid = 0;B.comm.isShwoCallBaiduApp = 0;B.comm.lsConf={lsSuportKey:'lssp',lsVersionKey:'lsv',lsPrefix:'wise_se_'};win"
        },
        {
            "byteSize": 7001,
            "gzip": 2629,
            "content": "!function(t){function n(){return e[i]=e[i]||t.apply(this,arguments),e[i]}window.B=window.B||{};var e=B.search=B.search||{},i=\"eventManager\";n.apply(this,[])}(function(){function t(t,n){try{t.apply(thi"
        },
        {
            "byteSize": 118,
            "gzip": 114,
            "content": "!function(){document.addEventListener(\"touchstart\",function(){B=B||{},B.comm=B.comm||{},B.comm.enableTotop=!1},!1)}();"
        },
        {
            "byteSize": 1938,
            "gzip": 946,
            "content": "window.B=window.B||{},function(t){var a=function(){function a(t,a){m=\"virtual\",b.routeStatus={action:\"push\",type:\"virtual\"};var e=t;if(e)if(\"base\"==t){for(var r in y)l.remove(y[r]);l.set(t,a)}else l.s"
        },
        {
            "byteSize": 3217,
            "gzip": 1410,
            "content": "window.B=window.B||{},function(t){function a(){function a(){var t=location.href.match(/#(.*)$/),a=t?t[0]:\"\";return 0===a.indexOf(\"#%7C\")&&(a=a.replace(/%7C/,\"|\")),a||\"\"}function e(t){t&&t.last&&\"base\""
        },
        {
            "byteSize": 3377,
            "gzip": 1437,
            "content": "A.merge(function(){if (document.querySelector(\"[srcid='91'][order='1']\")){A._setContainer(document.querySelector(\"[srcid='91'][order='1']\"),true);}else{A._setContainer(document.querySelector(\"[srcid='"
        },
        {
            "byteSize": 5542,
            "gzip": 2004,
            "content": "A.merge(function(){if (document.querySelector(\"[srcid='we_image'][order='2']\")){A._setContainer(document.querySelector(\"[srcid='we_image'][order='2']\"),true);}else{A._setContainer(document.querySelect"
        }
        
        ...
        
    ],
    "styles": [
        {
            "byteSize": 20,
            "gzip": 40,
            "content": "#page{display:none;}"
        },
        {
            "byteSize": 29663,
            "gzip": 7454,
            "content": "@font-face{font-family:sicons;src:url(//m.baidu.com/static/search/iconfont/search_iconfont_128e950d.eot);src:url(//m.baidu.com/static/search/iconfont/search_iconfont_128e950d.eot#iefix) format('embedd"
        },
        {
            "byteSize": 62,
            "gzip": 77,
            "content": "#page-hd {visibility: visible;}.result-loading {display:none;}"
        },
        {
            "byteSize": 1657,
            "gzip": 555,
            "content": ".wa-bk-polysemy-hide {display: none;}.wa-bk-polysemy-greeting {height: 38px;border: solid 1px #ddd;border-bottom-width: 0;overflow: hidden;-webkit-user-select: none;user-select: none;}.wa-bk-polysemy-"
        },
        {
            "byteSize": 1135,
            "gzip": 438,
            "content": ".wa-we-image-border .wa-we-image-box{overflow:hidden;}.wa-we-image-border .wa-we-image-abstract{line-height:21px;padding: 6px 10px;}.wa-we-image-border .wa-we-image-imgs{/*width:100%;*//*display:inlin"
        }
        
        ...
    ],
    "images": [],
    "afterGzip": "112.759kb"
}
```

Have no data on exactly TTI time, just from size, we can make an A/B test to compare the result if you launch ggc advanced mode for js code compressing.

<img src="/assets/images/20160801/003.png" alt="fb" style="width: 80%; height: auto; positon:relative; margin: 20px auto;" />

Of course, introduce new tools in the workflow is not an easy topic, and it may change the code have written by developers, gcc's **extern.js** and **goog.exportSymbol** mechanism can provide a useful way to not break the relation between code in first view and other libraries, but it may need more testing before publishing. But how could we do a better job if we lost our imagination. All things depend on developers. AND, you can even fork the tools and make your own if you dive into it and rewrite some compiler code, I think it can give a bigger promotion.
