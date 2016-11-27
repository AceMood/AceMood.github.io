---
layout: post
title: 高性能Google Chrome
auth: self
tagline: by AceMood
categories: Front-end
sc: fe
description: 高性能Google Chrome
keywords: 性能优化, Chrome, 架构
---

> Chrome's network stack from 10,000 feet.
> --- <a class="authorOrTitle" href="https://www.igvita.com/">Ilya Grigorik</a>

# 高性能Google Chrome【译】

## 前言

几年前有一篇[《How Browsers Work》](http://taligarsiel.com/Projects/howbrowserswork1.htm)是讲浏览器渲染的一篇经典文章. 随着介绍浏览器各个组件的技术博文越来越多, 以及渲染引擎开源项目的不断提升, 很多途径都可以获取浏览器实现原理的知识. 今天译的这篇入选了[《The Architecture of Open Source Applications》](http://www.aosabook.org/en/index.html)项目, 是近年少见的比较全面且权威的介绍浏览器性能的好文.

在浏览器的性能方面, 资源加载、渲染和脚本的执行一直是重中之重. Chrome浏览器从协议方面, 编译器方面入手提高了加载和运行时的性能, 还引入了很多经典的架构模式和技巧, 可以说Chrome从性能优化的高度、深度上都处于领先地位. 另外对于开发者和使用者来说, 这些提升是普惠性质的, 带动了技术的发展, 授益于整个技术界.

## Google Chrome的历史和设计准则

Google Chrome在2008年的下半年第一次发布, 是Windows平台的一个试用版本. The Google-authored code powering Chrome was also made available under a permissive BSD license - aka, the Chromium项目. 对很对人来讲, 他们会感到新奇: 浏览器大战又要开始了么? Google能做的更好吗?

> It was so good that it essentially forced me to change my mind..." 
> --- Eric Schmidt, on his [initial reluctance](http://blogs.wsj.com/digits/2009/07/09/sun-valley-schmidt-didnt-want-to-build-chrome-initially-he-says/) to the idea of developing Google Chrome.

Turns out, they could. Today Chrome is one of the most widely used browsers on the web (35%+ of the market share according to StatCounter) and is now available on Windows, Linux, OS X, Chrome OS, as well as Android and iOS platforms. Clearly, the features and the functionality resonated with the users, and many innovations of Chrome have also found their way into other popular browsers.

<table>
<tr>
<td style="width: 30%"><img src="/assets/images/20161126/chrome.webp" alt="" /></td>
<td>
The original 38-page comic book explanation of the ideas and innovations of Google Chrome offers a great overview of the thinking and design process behind the popular browser. However, this was only the beginning. The core principles that motivated the original development of the browser continue to be the guiding principles for ongoing improvements in Chrome:
</td>
</tr>
</table>

Speed: the objective is to make the fastest browser
Security: provide the most secure environment to the user
Stability: provide a resilient and stable web application platform
Simplicity: sophisticated technology, wrapped in a simple user experience

## 性能的方方面面

现代浏览器都可视为一个平台, 像操作系统一样, Google Chrome也以此目标进行设计. 在Google Chrome之前, 所有的主流浏览器都设计为单进程的单体应用程序. 所有浏览的页面都共享地址空间和相同的资源(注: 就是以单进程多线程的方式存在). 任何一个页面发生问题, 或者浏览器本身出了bug都会影响到整体的体验, 比如程序直接崩溃而所有页面变成全部不可用的状态.


