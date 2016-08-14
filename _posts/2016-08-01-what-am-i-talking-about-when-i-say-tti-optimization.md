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

<img src="/assets/images/20160801/001.jpg" alt="" style="width: 100%; height: auto;" />

At that time, they defined the most important area as marked in red-line, and **the time between clicking the link button and user can interact with the key area content** named **TTI**. 

## Loading and runtime

We have mainly two types of performance issues, when **loading resources** and when code **running on client**. Also we have mainly two platform need to focus on, PC and mobile. As the mobile market occupation increase rapidly and data of PC still steadily, we will focus on mobile this time.

## All have been mentioned

Many articles mentioned the methods, include icon-font, srcset, lazyLoad, load on demand, inlining images, localStorage cache solution and so on. All technologies we used based on the implementation of Browsers Manufactures.      