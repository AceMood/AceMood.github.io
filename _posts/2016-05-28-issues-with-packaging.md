---
layout: post
title: Issues with packaging
auth: self
tagline: by AceMood
categories: JavaScript
sc: js
description: Issues with packaging
keywords: javascript, packaging resources, bundle tools, web performance optimize
---

> Release Engineering is the part of the software engineering process that is most akin to herding cats.
> --- <a class="authorOrTitle" href="https://www.facebook.com/chuckr">Chuck Rossi</a>

## Preface

As [YUI Blog 34 golden rules](https://developer.yahoo.com/performance/rules.html) had mentioned that, make minimum requests can improve Front-end performance, we often bundle javascript files into less files, so do css files. It works well when we do not have more requirements on our website. For example, ten years before, we can easily move all javascript file into one big bundle as demonstrated below:

<img src="/assets/images/20160528/pack.001.jpg" class="img--small" /><br/>
<img src="/assets/images/20160528/pack.002.jpg" class="img--small" /><br/>

It can deal with tiny scale website as we do not need to include many js and css external files. As websites (or webapps) grow rapidly recent years (most website is larger than 1 MB), we must review the packaging issue from Front-end engineering aspect. Also modular development of Front-end brings new issues to our packaging process.

## Packaging Strategy

There have some author [introduce the issue](http://jamie-wong.com/2014/11/29/the-js-packaging-problem/) and try to resolve it.
From this article, there is no perfect solution at present. We now just discuss the large scale website such as Facebook.com and Google Map. How you packaging your static resources mostly depend on the engineers in your team, they config the package rules and decide which ones can be merged into one file. For further, we can do the packaging tasks into an automatical system according to the logs of your website. 

As I have reprinted the [browser cache](https://code.facebook.com/posts/964122680272229/web-performance-cache-efficiency-exercise/) article, we should consider the cache strategy and utilize it to do its best work. Also we should consider the whole website pages which shared the common library and images served on your server rather than only minimum the count of requests of one main page. 

## Current Module Loader in Browser

For simple example, we have five js resources (after analyzed) in a HTML file, such as:

```
require_js('lib/base.js');
require_js('base/navbar.js');
require_js('base/head.js');
require_js('mod/qrcode.js');
require_js('page/main.js');
```

And thr pack rule as:

```
{
  pack: [
    '/res/bundle.js': ['lib/base.js', 'mod/qrcode.js']
  ]
}
```

But, be aware of that, how we could do the packaging work if `mod/qrcode.js` depends on `base/head.js` and `base/head.js` depends on `lib/base.js`? Someone may tell if we construct our directory clearly and make a convention to that, we can avoid this situation. Of course, we can make some rules to avoid that, but it's not flexible enough, we can not decide how the engineer build their source code directory and how they write the package rules in configuration file.

So, it is very important that our Module Loader in Browser side support the mess-ordered definition of javascript modules, for example:

Imagine we have `a`, `b`, `c` three modules,
 
``` javascript
define('a', function(require, module, exports) {
  exports.key = 'a';
})
```

``` javascript
define('b', function(require, module, exports) {
  var mod_a = require('a');
  exports.key = mod_a.key + 'b'; 
})
```

``` javascript
define('c', function(require, module, exports) {
  var mod_b = require('b');
  exports.key = mod_b.key + 'c';
})
```

Normally, we can only bundle the three files in `a->b->c` order, but it really depends on how we implement our Module Loader. When `define` a module, we do not fetch its dependencies immediately, we can extract its dpendencies (or from the reource map object) without fetching it (leave it later). Only when the entry point module executed `kernel.exec`, we fetch all dependencies. See more [implementation in kernel.js](https://github.com/AceMood/kerneljs/blob/master/lib/Module.js).

With such implementation, we can output the module in mess order (in case we encounter the packaging issue).

```html
<script src="a.js"></script>
<script src="c.js"></script>
<script src="b.js"></script>
```

## Conclusion

1. JavaScript Module Loader should not prefetch module's dependencies until needed. Not only for performance, but also for packaging strategy.

2. Packaging Strategy is an important issue when we consider the Front-end engineering. Simple enough, we can let developers take over this task through config package rules, but for flexible and less error-proned, we should build an Automated Packaging System (A.P.S) to analyze the access logs of our website and do the packaging automatically.
