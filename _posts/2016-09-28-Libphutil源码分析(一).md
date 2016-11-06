---
layout: post
title: Libphutil源码分析
auth: self
tagline: by AceMood
categories: PHP
sc: php
description: Libphutil源码分析
keywords: Libphutil
---

# Libphutil源码分析(一)

## 综述

Libphutil是Evan Priestley所写的一个php基础库, 提供了丰富的函数集. 虽然不是一个MVC框架,
但是很多对php编程的初学者而言还是有些学习价值. 近期正接触一些php所写的项目, 所以编写边学.
选择这个库作为一个入口点来看源码, 一是作者本人是个非常聪明并且能力很强的人, 之前一直在Facebook
工作, 积累了大量经验. 另一个原因是作为php写后端的世界级互联网公司, Facebook前期的很多功能
都是基于这样的库建立起来的, 而这里面势必有一些Facebook曾经投入到生产环境的代码. 

## 总体架构

项目地址[在这里](https://github.com/phacility/), 目前虽然开源但是作者所在的公司一般不接受cr, 
所以下来看看就好. 
