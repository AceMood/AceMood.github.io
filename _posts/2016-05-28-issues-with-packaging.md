---
layout: post
title: Issues with packaging
tagline: by AceMood
categories: JavaScript
sc: js
description: Issues with packaging
keywords: javascript, packaging resources, bundle tools, web performance optimize
---

> Release Engineering is the part of the software engineering process that is most akin to herding cats.
> --- <a class="authorOrTitle" href="https://www.facebook.com/chuckr">Chuck Rossi</a>

# Preface

As [YUI Blog 34 golden rules](https://developer.yahoo.com/performance/rules.html) had mentioned that, make minimum requests can improve Front-end performance, we often bundle javascript files into less files, so do css files. It works well when we do not have more requirements on our website. For example, ten years before, we can easily move all javascript file into one big bundle as demonstrated below:

<img src="/assets/images/20160528/pack.001.jpg" alt="" style="width: 100%; height: auto;" /><br/>
<img src="/assets/images/20160528/pack.002.jpg" alt="" style="width: 100%; height: auto;" /><br/>

It can deal with tiny scale website as we do not need to include many js and css external files. As websites (or webapps) grow rapidly recent years (most website is larger than 1 MB), we must review the packaging issue from Front-end engineering aspect. Also modular development of Front-end brings new issues to our packaging process.

# Packaging Strategy

There have someone [introduce the issue](http://jamie-wong.com/2014/11/29/the-js-packaging-problem/) and try to resolve it.
From his article, there is no perfect solution at present. How you packaging your static resources depend on your visitor, the complexity of your website and so on. We now just discuss the large scale website such as Facebook.com and Google Map. 

As I have reprinted the [browser cache](https://code.facebook.com/posts/964122680272229/web-performance-cache-efficiency-exercise/) article, we should consider the cache strategy and utilize it to do its best work. Also we should consider the whole website pages which shared the common library and images served on your server rather than only minimum the count of requests of one main page. 

# Current Module Loader in Browser



# Further Reading