---
layout: post
title: innerHTML tips
tagline: by AceMood
categories: Front-end
sc: fe
description: innerHTML tips
keywords: innerHTML disable script execution, script load parallel
---

## Script Won't Execute

When you want to insert a fragment of html in javascript, how will you do that? Here is an [article from w3c](https://www.w3.org/TR/2008/WD-html5-20080610/dom.html#innerhtml0) for introduction. But some notes can impact the work we face to in daily development. 

Script tag will not execute whether it is inlined or external linked. Say, you have code fragment:

``` javascript
var str = '<script>alert("well done!")</script>';
element.innerHTML = str;
```
Nothing will happen, the script code won't execute. But style code escape from this rule, you can visit the [jsbin demo](http://jsbin.com/zeyavadeyo/edit?html,js,output) for more information.

## Script Load Parallel

Another issue, if you have more than one script in your page, you get them download and executed one by one, such as [demo](http://jsbin.com/nufinehebi/edit?html,output), I set the blocking.php produce script and sleep 5 seconds, but the second script with simple code:
``` php
sleep(5);

header('Content-type', 'application/javascript');

echo 'alert(\'blocking.php loaded!\');';
```

``` javascrpt
alert('a.js loaded!');
```

As you expected, they loaded in order. But will parallel when you use innerHTML.



## References

1. [https://w3c.github.io/DOM-Parsing/](https://w3c.github.io/DOM-Parsing/)
2. [https://www.w3.org/TR/2011/WD-html5-20110525/apis-in-html-documents.html#innerhtml](https://www.w3.org/TR/2011/WD-html5-20110525/apis-in-html-documents.html#innerhtml)
3. [http://www.quirksmode.org/dom/innerhtml.html](http://www.quirksmode.org/dom/innerhtml.html)