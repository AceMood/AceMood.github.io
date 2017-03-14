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

Google Chrome在2008年的下半年第一次发布, 是Windows平台的一个试用版本. 这个Google主导的项目在BSD许可协议下是可以参与的, 也就是我们常说的Chromium项目. 对很对人来讲, 他们会感到新奇: 浏览器大战又要开始了么? Google能做的更好吗?

> It was so good that it essentially forced me to change my mind..." 
> --- Eric Schmidt, on his [initial reluctance](http://blogs.wsj.com/digits/2009/07/09/sun-valley-schmidt-didnt-want-to-build-chrome-initially-he-says/) to the idea of developing Google Chrome.

事实证明他们可以做到. 时至今日Chrome已经是Web上使用最广泛的浏览器之一 (据StatCounter统计, 已经超过[35%+](http://gs.statcounter.com/?PHPSESSID=oc1i9oue7por39rmhqq2eouoh0)的市场份额) 并且现在Windows, Linux, OS X, Chrome OS, Android和iOS平台都可以见到它的身影. 很显然, 使用者对其提供的特性和功能产生了共鸣, Chrome很多的创新也被其他流行的浏览器所采纳.

<table border="0">
<tr>
<td style="width: 30%"><img src="/assets/images/20161126/chrome.webp" alt="" /></td>
<td>
最初的[设计蓝本(38-page comic book)](http://www.google.com/googlebooks/chrome/) 对于Google Chrome的设计和创新做了一个高屋建瓴的解释说明. 当然这是最开始的时候. 但最开始核心的设计准则仍旧对Chrome不断的迭代开发过程起着指导作用:
</td>
</tr>
</table>

__速度__: 目前是成为最快的浏览器

__安全性__: 对用户提供最安全的环境

__稳定性__: 提供一个既有弹性又有稳定性的平台

__易用性__: 简易便捷的用户体验, 哪怕底层是很复杂的技术实现

## 性能的方方面面

现代浏览器都可视为一个平台, 像操作系统一样, Google Chrome也以此目标进行设计. 在Google Chrome之前, 所有的主流浏览器都设计为单进程的单体应用程序. 所有浏览的页面都共享地址空间和相同的资源(注: 就是以单进程多线程的方式存在). 任何一个页面发生问题, 或者浏览器本身出了bug都会影响到整体的体验, 比如程序直接崩溃而所有页面变成全部不可用的状态.


