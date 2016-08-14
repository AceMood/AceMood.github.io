---
layout: post
title: Front-End-Engineering
auth: self
tagline: by AceMood
categories: Front-end
sc: fe
description: Build Tools
keywords: engineering, front-end, static resource management, soi, neo-core
---

> These tools were less negatively received than the older versions. By December 2010 I started open sourcing them; Haste became Celerity and Alite became Aphront. I wrote Maniphest to track open issues with the project in January or February and we open sourced Phabricator in late April, shortly after I left Facebook.
> --- <a class="authorOrTitle" href="https://www.facebook.com/epriestley">Evan Priestley</a>

# Preface

__It can be a really big topic, I confirm that it not only contains issue like development, debugging, testing, feedback, performance, also build workflow, static resource management, security and so on. We now will have a glance at Build Tools and Performance.__

# Fragmented code

Nowadays, we write more and more Front-end code in the page. We may include external javascript and stylesheet more than 
one hundred files in one page at any position. For example, a developer may write code as below, and he is only one of the team members who take care of each part of the page. It definitely a front-end component which include three elements (style, script and template). Of course we have serveral ways to combine the three elements (such as web component). 

``` html
<link rel="stylesheet" type="text/css" href="reset.css" />
<style>
.navbar {
  width: 95%;
  height: auto;
  display: inline-block;
  overflow: hidden;
}
</style>
<div class="navbar">
    <div class="navbar__title"></div>
    <div class="navbar__list">
        <ul>
        <ul>
    </div>
</div>
<script src="zepto.js"></script>
<script src="navbar.js"></script>
<script>
  NavBar.init('.navbar');
</script>
```

But notice that, we have at least three problems here until now:

* the `reset.css` may be already included at any other place, it can cause duplicated resource loaded and waste Browser time. so dose `zepto.js`.
* we want all the style at the top of the page and all the js at the bottom of the page
* `navbar.js` may depend on `zepto.js`, we have to declare the script tag in right order manually

Also we can take a look at the directories of the whole project,

```
- template
--- index.php
--- list.php
--- detail.php
- third_party
--- lib
----- zepto.js
----- underscore.js
----- backbone.js
--- vi
----- reset.less
----- grid.less
- static
--- images
----- logo.png
----- bg.png
--- js
----- index.js
----- list.js
----- detail.js
--- css
- widget
--- navbar
----- navbar.js
----- navbar.less
----- navbar.tmpl
--- footer
----- footer.js
----- footer.less
----- footer.tmpl
--- chatter
----- chatter.js
----- chatter.less
--- imageloader
----- imageloader.js
```

Now we know that the code in `widget/navbar.tmpl` will something like

``` html
<link rel="stylesheet" type="text/css" href="navbar.css" />
<div class="navbar">
    <div class="navbar__title"></div>
    <div class="navbar__list">
        <ul>
        <ul>
    </div>
</div>
<script src="navbar.js"></script>
```

# Component based development

# Resource Map Layer

# Packaging

# Do optimizations at runtime

## BigPipe

## BigRender

## Quickling


# Postscript

# Conclusion
