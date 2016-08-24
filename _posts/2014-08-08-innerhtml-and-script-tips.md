---
layout: post
title: innerHTML and script tips
tagline: by AceMood
categories: Front-end
sc: fe
description: innerHTML and script tips
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
```
sleep(5);

header('Content-type', 'application/javascript');

echo 'alert(\'blocking.php loaded!\');';
```

``` javascrpt
alert('a.js loaded!');
```

As you expected, they loaded parallel(in Chrome and Firefox 3.0 after) and execute in order. But they will execute parallel when you use innerHTML.

``` javascript
  var frag = document.createDocumentFragment();
  var blockjs = document.createElement('script');
  blockjs.src = 'http://localhost/jsbin/innerhtml/blocking.php';
  var ajs = document.createElement('script');
  ajs.src = 'http://localhost/jsbin/innerhtml/a.js';

  frag.appendChild(blockjs);
  frag.appendChild(ajs);
  container.appendChild(frag);
```

Visit [demo](http://jsbin.com/vorumopogo/edit?html,js,output)

## Conclusion

1. The result will impact how we implement the js loader in client-side, we must take care of the order of script execution when use dynamic insertion. 
2. Need more test in other browsers.

## References

1. [https://w3c.github.io/DOM-Parsing/](https://w3c.github.io/DOM-Parsing/)
2. [https://www.w3.org/TR/2011/WD-html5-20110525/apis-in-html-documents.html#innerhtml](https://www.w3.org/TR/2011/WD-html5-20110525/apis-in-html-documents.html#innerhtml)
3. [http://www.quirksmode.org/dom/innerhtml.html](http://www.quirksmode.org/dom/innerhtml.html)