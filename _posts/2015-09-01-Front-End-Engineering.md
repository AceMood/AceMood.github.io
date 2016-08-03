---
layout: post
title: Front-End-Engineering
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
one hundred files in one page at any position. 
For example, a developer may write code as below, and he is only one of the team members who take care of each part of the page. It definitely a front-end component which include three elements (style, script and template). Of course we have serveral
ways to combine the three elements (such as web component).

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

Also we can take a look at the directories of the whole project,

``` javascript
-- template
---- index.php
---- list.php
---- detail.php
---- feedback.php
-- third_party
---- lib
------ zepto.js
------ underscore.js
------ backbone.js
---- vi
------ reset.less
------ grid.less
-- static
---- images
---- js
------ index.js
------ list.js
------ detail.js
---- css
-- widget
---- banner
---- navbar
---- footer
---- chatter
---- imageloader
```

# Component based development

# Resource Map Layer

# Packaging

# Do optimizations at runtime

# References

# Postscript

# Conclusion
