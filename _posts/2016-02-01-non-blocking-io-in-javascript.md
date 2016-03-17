---
layout: post
title: Non-blocking IO in JavaScript
tagline: by AceMood
categories: JavaScript
sc: js
description: Non-blocking IO in JavaScript
keywords: Node, non-blocking io, javascript, setTimeout, nextTick, setImmediate
---

> There are only two kinds of languages: the ones people complain about and the ones nobody uses.     --- <a class="authorOrTitle" href="https://www.goodreads.com/author/show/64947.Bjarne_Stroustrup">Bjarne Stroustrup</a>

This can be a long article, even more tedious. It's caused by <a title="problem" href="https://gist.github.com/mmalecki/1257394" target="_blank">a topic of process.nextTick</a>. Javascript developer or front-end engineer can face to setTimeout, setImmediate, nextTick everyday, but what the difference between them? Some seniors can tell:

1. setImmediate is lack of implementations on browser side, only high-versioned Internet Explorer do this job.
2. nextTick can be triggered first，setImmediate sometime come last.
3. Node environment has implememted all of the APIs.

At the very beginning, I tried to search for some answers such as <a href="https://nodejs.org/dist/latest-v4.x/docs/api/process.html#process_process_nexttick_callback_arg" target="_blank">Node official docs</a>，<a href="http://howtonode.org/understanding-process-next-tick" target="_blank">and</a> <a href="http://prkr.me/words/2014/understanding-the-javascript-event-loop/" target="_blank">other</a> <a href="https://www.nczonline.net/blog/2013/07/09/the-case-for-setimmediate/" target="_blank">articles</a>. But unfortunately, I couldn't access the truth. Other explaination can be found in reddit blackboard, <a href="https://www.reddit.com/r/node/comments/2la8zb/setimmediate_vs_processnexttick_vs_settimeout/" target="_blank">1</a>, <a href="https://www.reddit.com/r/node/comments/323ojd/what_is_the_difference_between/" target="_blank">2</a> and the author of Node wrote an <a href="https://nodesource.com/blog/understanding-the-nodejs-event-loop/" target="_blank">article</a> try to explain the logic underline. 

I can not tell how many people know the truth and want to explore it, if you know more information, please <a href="mailto:zmike86@gmail.com">contact me</a>, I'm waiting for more useful information.

The first thing I want to say is about I/O.

## I/O Models

Operating System's I/O Models can be classified into five categories: Blocking I/O, Non-blocking I/O, I/O Multiplexing, Signal-driven I/O and Asynchronous I/O. I will take Network IO case for example, though there still have File IO and other types, such as DNS relative and user code in Node. Take Network scenario as example is for convenience.

#### Blocking I/O
Most common model but with huge limitation, obviously it can only deal with one stream per time (stream can be file, socket or pipe). Its flows demonstrated below:
<img src="/assets/images/20160201/git.001.jpg" alt="" width="640" height="450" />

#### Non-Blocking I/O
AKA busy looping, it can deal with multi streams. The application process repeatedly call system to get the status of data, once a stream becomes data ready, process blocking for data copy and then process deal with the data available. But it has a big disadvantage for wasting CPU time. Its flows demonstrated below:
<img src="/assets/images/20160201/git.002.jpg" alt="" width="640" height="450" />

#### I/O Multiplexing
Select and poll are based on this type, see more about <a href="http://man7.org/linux/man-pages/man2/select.2.html" target="_blank">select</a> and <a href="http://man7.org/linux/man-pages/man2/poll.2.html" target="_blank">poll</a>. I/O Multiplexing retains the advantage of Non-Blocking I/O, it can also deal with multi streams at one time, but it's also a blocking type. Call select(or poll) will block application process until one streams becomes data ready. And even more worse, it introduce another system call(recvfrom). 

Notes: Another closely related I/O model is to use multithreading with blocking I/O. That model very closely resembles the model described above, except that instead of using select to block on multiple file descriptors, the program uses multiple threads (one per file descriptor), and each thread is then free to call blocking system calls like recvfrom. 

Its flows demonstrated below:
<img src="/assets/images/20160201/git.003.jpg" alt="" width="640" height="450" />

#### Signal-driven I/O
In this model, application process system call sigaction and install a signal handler, the kernel will return immediately and the main process can do other works without blocking. When the data is ready to be read, the SIGIO signal is generated for our process. We can either read the data from the signal handler by calling recvfrom and then notify the main loop that the data is ready to be processed, or we can notify the main loop and let it read the data. Its flows demonstrated below:
<img src="/assets/images/20160201/git.004.jpg" alt="" width="640" height="450" />

#### Asynchronous I/O
Asynchronous I/O is defined by the POSIX specification, it's an ideal model. In general, system call like aio_*  functions work by telling the kernel to start the operation and to notify us when the entire operation (including the copy of the data from the kernel to our buffer) is complete. The main difference between this model and the signal-driven I/O model in the previous section is that with signal-driven I/O, the kernel tells us when an I/O operation can be initiated, but with asynchronous I/O, the kernel tells us when an I/O operation is complete. Its flows demonstrated below:
<img src="/assets/images/20160201/git.005.jpg" alt="" width="640" height="450" />

After introduced those type of I/O models, we can identify them with the current hot-spots technologies such as epoll in linux and <a title="kqueue" href="https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/kqueue.2.html" target="_blank">kqueue</a> in OSX. They're more like the sugnal-driven model, only the <a title="IOCP" href="https://msdn.microsoft.com/en-us/library/windows/desktop/aa365198(v=vs.85).aspx" target="_blank">IOCP on windows</a> implement the fifth model. See more: <a title="epoll和kqueue的实现原理" href="https://www.zhihu.com/question/20122137http://" target="_blank">from zhihu</a>.

Then I have to have a look at libuv, a cpp writen I/O library.

## libuv

<a title="libuv" href="http://docs.libuv.org/en/v1.x/design.html" target="_blank">libuv</a> is one of the dependencies of Node, another is <a title="v8 reference" href="https://developers.google.com/v8/" target="_blank">well-known v8</a>. libuv take care of different I/O model implementations on different Operating System and abstract them into one API for third-party application. libuv has a brother called libev, which appears earlier than libuv, but libev didn't support windows platform. This becomes more and more important while Node becomes more and more popular so that they must consider of windows compatibility. At last Node development team give up libev and pick up libuv instead.

Before we read more about libuv, I should make a tip, I have read many articles and js guides who introduce the event loop in JavaScript, and they seem no much more difference. I think those authors mean to explain the conception as easy as possible and most of them do not show the source code of <a target="_blank" title="webkit" href="https://webkit.org/">Webkit</a> or Node. Many people forget how the event loop schedule and face to the same problem when they encounter it again.

First I want to differ the conceptions of event loop and event loop iteration. Event loop is a task queue which bind with a thread and mostly they are one-to-one relation. Event loop iteration is the procedure when the runtime check for the executable code or task queued in event loop and execute it. The two conceptions corresponding two important function / object in libuv. One is <a href="http://docs.libuv.org/en/v1.x/loop.html#uv-loop-t-event-loop" target="_blank">uv_loop_t</a>, which represent for one event loop object and <a href="http://docs.libuv.org/en/v1.x/loop.html#c.uv_run" target="_blank">API: uv_run </a>, which can be treated as the entry point of event loop iteration. All functions in libuv named starts with `uv_`, which really make reading the source code easy. The most important API in libuv is uv_run, every time call this function can do a event loop iteration. uv_run code shows below(based on implementation of v1.8.0):

{% highlight cpp %}
int uv_run(uv_loop_t* loop, uv_run_mode mode) {
  int timeout;
  int r;
  int ran_pending;

  r = uv__loop_alive(loop);
  if (!r)
    uv__update_time(loop);

  while (r != 0 && loop->stop_flag == 0) {
    uv__update_time(loop);
    uv__run_timers(loop);
    ran_pending = uv__run_pending(loop);
    uv__run_idle(loop);
    uv__run_prepare(loop);
    
    timeout = 0;
    if ((mode == UV_RUN_ONCE && !ran_pending) || mode == UV_RUN_DEFAULT)
      timeout = uv_backend_timeout(loop);

    uv__io_poll(loop, timeout);
    uv__run_check(loop);
    uv__run_closing_handles(loop);

    if (mode == UV_RUN_ONCE) {
      /** 
       * UV_RUN_ONCE implies forward progress: at least one callback
       * must have been invoked when it returns. uv__io_poll() can return 
       * without doing I/O (meaning: no callbacks) when its timeout 
       * expires - which means we have pending timers that satisfy 
       * the forward progress constraint.
       *
       * UV_RUN_NOWAIT makes no guarantees about progress so it's 
       * omitted from the check.
       */
      uv__update_time(loop);
      uv__run_timers(loop);
    }

    r = uv__loop_alive(loop);
    if (mode == UV_RUN_ONCE || mode == UV_RUN_NOWAIT)
      break;
  }

  /** 
   * The if statement lets gcc compile it to a conditional store. Avoids
   * dirtying a cache line.
   */
  if (loop->stop_flag != 0)
    loop->stop_flag = 0;

  return r;
}
{% endhighlight %}

Every time runtime do an event loop iteration, it executes the ordered code as figure below, and we can know
what kind of callbacks would be called during each event loop iteration. 
<img src="/assets/images/20160201/git.006.jpg" alt="event loop iteration" width="640" height="600" />

As libuv described the <a target="_blank" href="http://docs.libuv.org/en/v1.x/design.html">underline principle</a>, timer relative callbacks will be called in the `uv__run_timers(loop)` step, but it don't mention about `setImmediate` and `process.nextTick`. It's reasonable obviously, libuv isn't just for Node now, so logic in Node will be taken account in Node itself(more flexible). After diving into the source code of Node, we can see what happened when setTimeout/setInterval, setImmediate and process.nextTick.

## Node

Node is a popular and famous runtime for JavaScript, this article don't cover any primary technology about Node which you can find in any other technical books. If you want to, I'm willing to recommend you <a target="_blank" href="http://www.amazon.cn/Node-js%E5%AE%9E%E6%88%98-%E5%9D%8E%E7%89%B9%E4%BC%A6/dp/B00K4RUZHW/ref=sr_1_2?s=books&ie=UTF8&qid=1458129004&sr=1-2&keywords=nodejs">Node.js in Action</a> and <a target="_blank" href="http://www.amazon.cn/Mastering-Node-js-Pasquali-Sandro/dp/B00GX9HM8A/ref=sr_1_1?ie=UTF8&qid=1458129053&sr=8-1&keywords=mastering+node.js">Mastering Node.js</a>.

All Node source code shown in this article based on v4.4.0(LTS). 

#### setTimeout
> Timers are crucial to Node.js. Internally, any TCP I/O connection creates a timer so that we can time out of connections. Additionally, many user user libraries and applications also use timers. As such there may be a significantly large amount of timeouts scheduled at any given time. Therefore, it is very important that the timers implementation is performant and efficient.
  
In Node, definition of setTimeout and setInterval locate at `lib/timer.js`. For performance, timeout objects with their timeout value are stored in a Map structure, key is the timeout value in millisecond. Value is a linked-list contains all the timeout objects share the same timeout value. It used a c++ handle defined in `src/timer_wrap.cc`. When you write the code `setTimeout(callback, timeout)`, Node initialize a linked-list(if not exists) contains the timeout object, which has a _timer field point to an instance of TimerWrap, then call the _timer.start method to delegate the timeout task to Node.
{% highlight javascript %}
  function TimersList(msecs, unrefed) {
    // Create the list with the linkedlist properties to
    this._idleNext = null; 
    // prevent any unnecessary hidden class changes.
    this._idlePrev = null; 
    this._timer = new TimerWrap();
    this._unrefed = unrefed;
    this.msecs = msecs;
  } 
  
  // code ignored
  
  list = new TimersList(msecs, unrefed);

  // code ignored
  
  list._timer.start(msecs, 0);

  lists[msecs] = list;
  list._timer[kOnTimeout] = listOnTimeout;
{% endhighlight %}

During the TimerWrap initialization, it also initialize its handle_ field, a `uv_timer_t` object.
{% highlight cpp %}
  int r = uv_timer_init(env->event_loop(), &handle_);
  
  // code ignored
  
  env->SetProtoMethod(constructor, "start", Start);
{% endhighlight %}

Then the TimerWrap designate the timeout task to its handle_. The work flow is simple enough that Node do not take care of what time exactly the timeout callback get called, it all depends on libuv's API. We can see it in the `Start` method of TimerWrap (called from javascript code).
{% highlight cpp %}
  int64_t timeout = args[0]->IntegerValue();
  int64_t repeat = args[1]->IntegerValue();
  int err = uv_timer_start(&wrap->handle_, OnTimeout, timeout, repeat);
{% endhighlight %}

Back to the figure above in <a href="#libuv">libuv section</a>, you can find in each event loop iteration, event_loop can schedule the timeout task itself, with update the time of event_loop, it can accurately know when to execute the OnTimeout callback of TimerWrap. Which can invoke the bound javascript functions.
{% highlight cpp %}
  static void OnTimeout(uv_timer_t* handle) {
    TimerWrap* wrap = static_cast<TimerWrap*>(handle->data);
    Environment* env = wrap->env();
    HandleScope handle_scope(env->isolate());
    Context::Scope context_scope(env->context());
    wrap->MakeCallback(kOnTimeout, 0, nullptr);
  }
{% endhighlight %}

For deeper into libuv source code, every time `uv_run` invoke `uv__run_timers(loop)`, which defined in `deps/uv/src/unix/timer.c`, it compares the timeout of uv_timer_t and time of event_loop, if they hit each other then execute the callbacks.
 {% highlight cpp %}
   if (handle->timeout > loop->time)
     break;

   uv_timer_stop(handle);
   uv_timer_again(handle);
   handle->timer_cb(handle);
 {% endhighlight %} 
    
Notice about the `uv_timer_again(handle)` code above, it differs the setTimeout and setInterval, but the two APIs invoke the same functions underline.  

#### setImmediate

Node did almost the same job when you write javascript code as `setImmediate(callback)`.

#### process.nextTick



Not yet finished, coming soon...

<div class="note">
<span class="note__caption">Note:</span>
<em class="note__content--normal"> I am very lucky to have a bundle of guys who know C++ very well, they teach me a lot and provide useful information.</em>
</div>

<div class="note">
<span class="note__caption">Note:</span>
<em class="note__content--warning"> I am a Chinese, writing in English is for exercise. If you want to refer my articles, please mark your own as refer from <a title="AceMood's Blog" href="{{ page.url }}" target="_blank">AceMood's Blog.</a></em>
</div>

