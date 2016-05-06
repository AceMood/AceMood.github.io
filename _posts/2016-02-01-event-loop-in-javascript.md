---
layout: post
title: Event loop in JavaScript
tagline: by AceMood
categories: JavaScript
sc: js
description: Event loop in JavaScript
keywords: Node, non-blocking, event loop, javascript, setTimeout, nextTick, setImmediate
---

> There are only two kinds of languages: the ones people complain about and the ones nobody uses.     --- <a class="authorOrTitle" href="https://www.goodreads.com/author/show/64947.Bjarne_Stroustrup">Bjarne Stroustrup</a>

# preface

This can be a long article, even tedious. It's caused by <a title="problem" href="https://gist.github.com/mmalecki/1257394" target="_blank">a topic of process.nextTick</a>. Javascript developer or front-end engineer can face to setTimeout, setImmediate, nextTick everyday, but what the difference between them? Some seniors can tell:

1. setImmediate is lack of implementations on browser side, only high-versioned Internet Explorer do this job.
2. nextTick can be triggered first，setImmediate sometime come last.
3. Node environment has implememted all of the APIs.

At the very beginning, I tried to search for some answers such as <a href="https://nodejs.org/dist/latest-v4.x/docs/api/process.html#process_process_nexttick_callback_arg" target="_blank">Node official docs</a>，<a href="http://howtonode.org/understanding-process-next-tick" target="_blank">and</a> <a href="http://prkr.me/words/2014/understanding-the-javascript-event-loop/" target="_blank">other</a> <a href="https://www.nczonline.net/blog/2013/07/09/the-case-for-setimmediate/" target="_blank">articles</a>. But unfortunately, I couldn't access the truth. Other explaination can be found in reddit blackboard, <a href="https://www.reddit.com/r/node/comments/2la8zb/setimmediate_vs_processnexttick_vs_settimeout/" target="_blank">1</a>, <a href="https://www.reddit.com/r/node/comments/323ojd/what_is_the_difference_between/" target="_blank">2</a> and the author of Node wrote an <a href="https://nodesource.com/blog/understanding-the-nodejs-event-loop/" target="_blank">article</a> try to explain the logics. 

I can not tell how many people know the truth and want to explore it, if you know more information, please <a href="mailto:zmike86@gmail.com">contact me</a>, I'm waiting for more useful information.

This article is not only about event loop, but also something like Non-blocking I/O. The first thing I want to say is about I/O Models.

# I/O Models

Operating System's I/O Models can be divided into five categories: Blocking I/O, Non-blocking I/O, I/O Multiplexing, Signal-driven I/O and Asynchronous I/O. I will take Network I/O case for example, though there still have File I/O and other types, such as DNS relative and user code in Node. Take Network scenario as an example is just for convenience.

### Blocking I/O
Blocking I/O is the most common model but with huge limitation, obviously it can only deal with one stream (stream can be file, socket or pipe). Its flows diagram demonstrated below:
<img src="/assets/images/20160201/git.001.jpg" alt="" width="640" height="450" />

### Non-Blocking I/O
Non-Blocking I/O, AKA busy looping, it can deal with multiple streams. The application process repeatedly call system to get the status of data, once any stream's data becomes ready, the application process block for data copy and then deal with the data available. But it has a big disadvantage for wasting CPU time. Its flows diagram sdemonstrated below:
<img src="/assets/images/20160201/git.002.jpg" alt="" width="640" height="450" />

### I/O Multiplexing
Select and poll are based on this type, see more about <a href="http://man7.org/linux/man-pages/man2/select.2.html" target="_blank">select</a> and <a href="http://man7.org/linux/man-pages/man2/poll.2.html" target="_blank">poll</a>. I/O Multiplexing retains the advantage of Non-Blocking I/O, it can also deal with multiple streams, but it's also one of the blocking types. Call select (or poll) will block application process until any stream becomes ready. And even worse, it introduce another system call (recvfrom). 

Notes: Another closely related I/O model is to use multi-threading with blocking I/O. That model very closely resembles the model described above, except that instead of using select to block on multiple file descriptors, the program uses multiple threads (one per file descriptor), and each thread is then free to call blocking system calls like recvfrom. 

Its flows diagram demonstrated below:
<img src="/assets/images/20160201/git.003.jpg" alt="" width="640" height="450" />

### Signal-driven I/O
In this model, application process system call sigaction and install a signal handler, the kernel will return immediately and the application process can do other works without being blocked. When the data is ready to be read, the SIGIO signal is generated for our process. We can either read the data from the signal handler by calling recvfrom and then notify the main loop that the data is ready to be processed, or we can notify the main loop and let it read the data. Its flows diagram demonstrated below:
<img src="/assets/images/20160201/git.004.jpg" alt="" width="640" height="450" />

### Asynchronous I/O
Asynchronous I/O is defined by the POSIX specification, it's an ideal model. In general, system call like aio_*  functions work by telling the kernel to start the operation and to notify us when the entire operation (including the copy of the data from the kernel to our buffer) is complete. The main difference between this model and the signal-driven I/O model in the previous section is that with signal-driven I/O, the kernel tells us when an I/O operation can be initiated, but with asynchronous I/O, the kernel tells us when an I/O operation is complete. Its flows demonstrated below:
<img src="/assets/images/20160201/git.005.jpg" alt="" width="640" height="450" />

After introduced those type of I/O models, we can identify them with the current hot-spots technologies such as epoll in linux and <a title="kqueue" href="https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/kqueue.2.html" target="_blank">kqueue</a> in OSX. They're more like the I/O multiplexing model, only the <a title="IOCP" href="https://msdn.microsoft.com/en-us/library/windows/desktop/aa365198(v=vs.85).aspx" target="_blank">IOCP on windows</a> implement the fifth model. See more: <a title="epoll和kqueue的实现原理" href="https://www.zhihu.com/question/20122137http://" target="_blank">from zhihu</a>.

Then have a look at libuv, an I/O library written in C++.

# libuv

<a title="libuv" href="http://docs.libuv.org/en/v1.x/design.html" target="_blank">libuv</a> is one of the dependencies of Node, another is <a title="v8 reference" href="https://developers.google.com/v8/" target="_blank">well-known v8</a>. libuv take care of different I/O model implementations on different Operating System and abstract them into one API for third-party application. libuv has a brother called libev, which appears earlier than libuv, but libev didn't support windows platform. This becomes more and more important while Node becomes more and more popular so that they must consider of windows compatibility. At last Node development team give up libev and pick up libuv instead.

Before we read more about libuv, I should make a tip, I have read many articles and guides who introduce the event loop in JavaScript, and they seem no much more difference. I think those authors mean to explain the conception as easy as possible and most of them do not show the source code of <a target="_blank" title="webkit" href="https://webkit.org/">Webkit</a> or Node. Many readers forget how the event loop schedule asynchronous tasks and face to the same problem when they encounter it again.

First I want to differ the conceptions of `event loop` and `event loop iteration`. Event loop is a task queue which bind with a single thread, they are one-to-one relation. Event loop iteration is the procedure when the runtime check for task (piece of code) queued in event loop and execute it. The two conceptions map tp two important function / object in libuv. One is <a href="http://docs.libuv.org/en/v1.x/loop.html#uv-loop-t-event-loop" target="_blank">uv_loop_t</a>, which represent for one event loop object and <a href="http://docs.libuv.org/en/v1.x/loop.html#c.uv_run" target="_blank">API: uv_run </a>, which can be treated as the entry point of event loop iteration. All functions in libuv named starts with `uv_`, which really make reading the source code easy. 

### uv_run

The most important API in libuv is `uv_run`, every time call this function can do an event loop iteration. uv_run code shows below (based on implementation of v1.8.0):

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

Every time runtime do an event loop iteration, it executes the ordered code as figure below, and we can know what kind of callbacks would be called during each event loop iteration. 
<img src="/assets/images/20160201/git.006.jpg" alt="event loop iteration" width="640" height="600" />

As libuv described the <a target="_blank" href="http://docs.libuv.org/en/v1.x/design.html">underline principle</a>, timer relative callbacks will be called in the `uv__run_timers(loop)` step, but it don't mention about `setImmediate` and `process.nextTick`. It's reasonable obviously, libuv is lower layer of Node, so logic in Node will be taken account in itself (more flexible). After diving into the source code of Node project, we can see what happened when setTimeout/setInterval, setImmediate and process.nextTick.

# Node

Node is a popular and famous platform for JavaScript, this article don't cover any primary technology about Node which you can find in any other technical books. If you want to, I'm willing to recommend you <a target="_blank" href="http://www.amazon.cn/Node-js%E5%AE%9E%E6%88%98-%E5%9D%8E%E7%89%B9%E4%BC%A6/dp/B00K4RUZHW/ref=sr_1_2?s=books&ie=UTF8&qid=1458129004&sr=1-2&keywords=nodejs">Node.js in Action</a> and <a target="_blank" href="http://www.amazon.cn/Mastering-Node-js-Pasquali-Sandro/dp/B00GX9HM8A/ref=sr_1_1?ie=UTF8&qid=1458129053&sr=8-1&keywords=mastering+node.js">Mastering Node.js</a>.

All Node source code shown in this article based on v4.4.0 (LTS). 

### Setup

When setup a Node process, it also setup an event loop. See the entry method `StartNodeInstance` in `src/node.cc`, if event loop is alive the do-while loop will continue.

{% highlight cpp %}
bool more;
do {
  v8::platform::PumpMessageLoop(default_platform, isolate);
  more = uv_run(env->event_loop(), UV_RUN_ONCE);

  if (more == false) {
    v8::platform::PumpMessageLoop(default_platform, isolate);
    EmitBeforeExit(env);

    // Emit `beforeExit` if the loop became alive either after emitting
    // event, or after running some callbacks.
    more = uv_loop_alive(env->event_loop());
    if (uv_run(env->event_loop(), UV_RUN_NOWAIT) != 0)
      more = true;
  }
} while (more == true);
{% endhighlight %}

### Async user code

##### setTimeout
> Timers are crucial to Node.js. Internally, any TCP I/O connection creates a timer so that we can time out of connections. Additionally, many user user libraries and applications also use timers. As such there may be a significantly large amount of timeouts scheduled at any given time. Therefore, it is very important that the timers implementation is performant and efficient.
  
In Node, definition of setTimeout and setInterval locate at `lib/timer.js`. For performance, timeout objects with their timeout value are stored in a Key-Value structure (object in JavaScript), key is the timeout value in millisecond, value is a linked-list contains all the timeout objects share the same timeout value. It used a C++ handle defined in `src/timer_wrap.cc` as each item in the linked-list. When you write the code `setTimeout(callback, timeout)`, Node initialize a linked-list(if not exists) contains the timeout object. Timeout object has a _timer field point to an instance of TimerWrap (C++ object), then call the _timer.start method to delegate the timeout task to Node. The snippet from `lib/timer.js`, when called setTimeout in JavaScript it new a TimersList() object as a linked-list node and store it in the Key-Value structure.

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

Notice the constructor of TimersList, it initialize a TimerWrap object, which build its handle_ field, a `uv_timer_t` object. The snippet from `src/timer_wrap.cc` show that:

{% highlight cpp %}
static void Initialize(Local<Object> target,
                       Local<Value> unused,
                       Local<Context> context) {  
                       
  // code ignored

  env->SetProtoMethod(constructor, "start", Start);
  env->SetProtoMethod(constructor, "stop", Stop);
}

static void New(const FunctionCallbackInfo<Value>& args) {
  // code ignored
  
  new TimerWrap(env, args.This());
}

TimerWrap(Environment* env, Local<Object> object)
    : HandleWrap(env,
                 object,
                 reinterpret_cast<uv_handle_t*>(&handle_),
                 AsyncWrap::PROVIDER_TIMERWRAP) {
  int r = uv_timer_init(env->event_loop(), &handle_);
  CHECK_EQ(r, 0);
}
{% endhighlight %}

Then the TimerWrap designate the timeout task to its handle_. The workflow is simple enough that Node do not take care of what time exactly the timeout callback get called, it all depends on libuv's timetable. We can see it in the `Start` method of TimerWrap (called from client javascript code), it invoke uv_timer_start to schedule the timeout callback.

{% highlight cpp %}
static void Start(const FunctionCallbackInfo<Value>& args) {
  TimerWrap* wrap = Unwrap<TimerWrap>(args.Holder());

  CHECK(HandleWrap::IsAlive(wrap));

  int64_t timeout = args[0]->IntegerValue();
  int64_t repeat = args[1]->IntegerValue();
  int err = uv_timer_start(&wrap->handle_, OnTimeout, timeout, repeat);
  args.GetReturnValue().Set(err);
}
{% endhighlight %}

Back to the figure above in <a href="#uvrun">libuv section</a>, you can find in each event loop iteration, event_loop can schedule the timeout task itself, with update the time of event_loop, it can accurately know when to execute the OnTimeout callback of TimerWrap. Which can invoke the bound javascript functions.

{% highlight cpp %}
static void OnTimeout(uv_timer_t* handle) {
  TimerWrap* wrap = static_cast<TimerWrap*>(handle->data);
  Environment* env = wrap->env();
  HandleScope handle_scope(env->isolate());
  Context::Scope context_scope(env->context());
  wrap->MakeCallback(kOnTimeout, 0, nullptr);
}
{% endhighlight %}

Dive into libuv source code, every time `uv_run` invoke `uv__run_timers(loop)`, which defined in `deps/uv/src/unix/timer.c`, it compares the timeout of uv_timer_t and time of event_loop, if they hit each other then execute the callbacks.

{% highlight cpp %}
void uv__run_timers(uv_loop_t* loop) {
  struct heap_node* heap_node;
  uv_timer_t* handle;

  for (;;) {
    heap_node = heap_min((struct heap*) &loop->timer_heap);
    if (heap_node == NULL)
      break;

    handle = container_of(heap_node, uv_timer_t, heap_node);
    if (handle->timeout > loop->time)
      break;

    uv_timer_stop(handle);
    uv_timer_again(handle);
    handle->timer_cb(handle);
  }
}
{% endhighlight %} 
    
Notice about the `uv_timer_again(handle)` code above, it differs the setTimeout and setInterval, but the two APIs invoke the same functions underline.  

##### setImmediate

Node did most of the same job with `setTimeout` when you write javascript code as `setImmediate(callback)`. Definition of setImmediate is also in `lib/timer.js`, when call this method it will add private property `_immediateCallback` to process object so that C++ bindings can identify the callbacks' proxy registered, and finally return an immediate object (you can think it as another timeout object but without timeout property). Internally, `timer.js` maintain an array named immediateQueue, which contains all callbacks installed in current event loop iteration.

{% highlight javascript %}
exports.setImmediate = function(callback, arg1, arg2, arg3) {
  // code ignored
  
  var immediate = new Immediate();

  L.init(immediate);

  // code ignored

  if (!process._needImmediateCallback) {
    process._needImmediateCallback = true;
    process._immediateCallback = processImmediate;
  }

  if (process.domain)
    immediate.domain = process.domain;

  L.append(immediateQueue, immediate);

  return immediate;
};
{% endhighlight %}

Before Node <a href="#setup">setup an event loop</a>, it build an Environment object (Environment class definition locates in `src/env.h`) which shared by all current process code. See the method `CreateEnvironment` in `src/node.cc`. CreateEnvironment setup an `uv_check_t` used by its event loop. Snippet showed that.

{% highlight cpp %}
Environment* CreateEnvironment(Isolate* isolate,
                               uv_loop_t* loop,
                               Local<Context> context,
                               int argc,
                               const char* const* argv,
                               int exec_argc,
                               const char* const* exec_argv) {
                               
  // code ignored
  
  uv_check_init(env->event_loop(), env->immediate_check_handle());
  uv_unref(
      reinterpret_cast<uv_handle_t*>(env->immediate_check_handle()));
      
  // code ignored
  
  SetupProcessObject(env, argc, argv, exec_argc, exec_argv);
  LoadAsyncWrapperInfo(env);
  
  return env;
}  
{% endhighlight %}
  
Method `SetupProcessObject` defined in `src/node.cc`, this can make global process object have necessary bindings. From code below we can find that it assign an set accessor by calling need_imm_cb_string() to the `NeedImmediateCallbackSetter` method. If we had a look at `src/env.h`, we know that need_imm_cb_string() return the string: "_needImmediateCallback". This means every time javascript code set an "_needImmediateCallback" property on process object, NeedImmediateCallbackSetter will get called.

{% highlight cpp %}
void SetupProcessObject(Environment* env,
                        int argc,
                        const char* const* argv,
                        int exec_argc,
                        const char* const* exec_argv) {
  
  // code ignored
  
  maybe = process->SetAccessor(env->context(),
                               env->need_imm_cb_string(),
                               NeedImmediateCallbackGetter,
                               NeedImmediateCallbackSetter,
                               env->as_external());
                               
  // code ignored

}  
{% endhighlight %}

In method `NeedImmediateCallbackSetter` it start the `uv_check_t` handle if process._needImmediateCallback is set to true, which managed by libuv's event loop (env->event_loop()), and initialized in CreateEnvironment method.

{% highlight cpp %}
static void NeedImmediateCallbackSetter(
    Local<Name> property,
    Local<Value> value,
    const PropertyCallbackInfo<void>& info) {
  Environment* env = Environment::GetCurrent(info);

  uv_check_t* immediate_check_handle = env->immediate_check_handle();
  bool active = uv_is_active(
      reinterpret_cast<const uv_handle_t*>(immediate_check_handle));

  if (active == value->BooleanValue())
    return;

  uv_idle_t* immediate_idle_handle = env->immediate_idle_handle();

  if (active) {
    uv_check_stop(immediate_check_handle);
    uv_idle_stop(immediate_idle_handle);
  } else {
    uv_check_start(immediate_check_handle, CheckImmediate);
    // Idle handle is needed only to stop the event loop from blocking in poll.
    uv_idle_start(immediate_idle_handle, IdleImmediateDummy);
  }
}
{% endhighlight %}

At last, we dive into `CheckImmediate`, notice the immediate_callback_string method will return string: "_immediateCallback", that we have seen in timer.js.

{% highlight cpp %}
static void CheckImmediate(uv_check_t* handle) {
  Environment* env = Environment::from_immediate_check_handle(handle);
  HandleScope scope(env->isolate());
  Context::Scope context_scope(env->context());
  MakeCallback(env, env->process_object(), env->immediate_callback_string());
}
{% endhighlight %}

So we knew that, in every event loop iteration, setImmediate callbacks would be executed in the `uv__run_check(loop);` step followed `uv__io_poll(loop, timeout);`. If get a little confused, you can back to the diagram in <a href="#libuv">event loop iteration execute order.</a>

##### process.nextTick

process.nextTick might have the ability to hide its implementation **^_^**. I have <a target="_blank" href="https://github.com/nodejs/node/issues/5584">issued that</a> for node project to get more information. At last I closed it myself because I thought the author got a little confused about my question. Debug into the source code also make sense, I add logs in the source code and recompiled the whole project to see what happened.

The entry point is in `src/node.js`, there is a `processNextTick` method that build the process.nextTick API. `process._tickCallback` is the callback function must be executed properly by C++ code (or if you use `require('domain')` it would be override by process._tickDomainCallback). Every time you called process.nextTick(callback) from your javascript code, it maintains nextTickQueue and tickInfo objects for recording necessary tick information.

`process._setupNextTick` is another important method in `src/node.js`, it map to a C++ binding Function named `SetupNextTick` in `src/node.cc`. In this method, it take the first argument and set it the `tick_callback_function` as a Persistent<Function> stored on Environment object. The tick_callback_function is what exactly executed the bound callbacks as in javascript code. You can see the snippet from node.js. Notice that `_combinedTickCallback` invoke the bound callbacks.

{% highlight javascript %}
// This tickInfo thing is used so that the C++ code in src/node.cc
// can have easy access to our nextTick state, and avoid unnecessary
// calls into JS land.
const tickInfo = process._setupNextTick(_tickCallback, _runMicrotasks);

function _tickCallback() {
  var callback, args, tock;

  do {
    while (tickInfo[kIndex] < tickInfo[kLength]) {
      tock = nextTickQueue[tickInfo[kIndex]++];
      callback = tock.callback;
      args = tock.args;
      // Using separate callback execution functions allows direct
      // callback invocation with small numbers of arguments to avoid the
      // performance hit associated with using `fn.apply()`
      _combinedTickCallback(args, callback);
      if (1e4 < tickInfo[kIndex])
        tickDone();
    }
    tickDone();
    _runMicrotasks();
    emitPendingUnhandledRejections();
  } while (tickInfo[kLength] !== 0);
}
{% endhighlight %}

And snippet in `SetupNextTick` method from `node.cc` showed that env object will get a tick_callback_function passed from arguments to be the callback when current tick transmitting to next phrase. 

{% highlight cpp %}
env->SetMethod(process, "_setupNextTick", SetupNextTick);

void SetupNextTick(const FunctionCallbackInfo<Value>& args) {
  Environment* env = Environment::GetCurrent(args);

  CHECK(args[0]->IsFunction());
  CHECK(args[1]->IsObject());

  env->set_tick_callback_function(args[0].As<Function>());
  env->SetMethod(args[1].As<Object>(), "runMicrotasks", RunMicrotasks);

  // Do a little housekeeping.
  env->process_object()->Delete(
      env->context(),
      FIXED_ONE_BYTE_STRING(args.GetIsolate(), "_setupNextTick")).FromJust();

  // code ignored

  args.GetReturnValue().Set(Uint32Array::New(array_buffer, 0, fields_count));
}
{% endhighlight %}

So we just need to search when the tick_callback_function() get called. After a while I find that `env()->tick_callback_function()` can be called from two places. First is the `Environment::KickNextTick` defined in `src/env.cc`. It called by `node::MakeCallback` in `src/node.cc`, which is only called by API internally. Second is `AsyncWrap::MakeCallback` defined in `src/async_wrap.cc`. It's also the same as the author <a target="_blank" href="https://github.com/nodejs/node/issues/5584">mentioned that</a>, only the AsyncWrap::MakeCallback can be called by public.

I have added some logs to see what happened internally. Only know the callbacks run at the end  phase of each event loop is not enough for me. At last I find that every AsyncWrap is a wrapper for async operations, the TimerWrap inherited from AsyncWrap. When timeout handler execute the callback `OnTimeout`, it actually execute the `AsyncWrap::MakeCallback`. You can see the same code showed before in the setTimeout section:

{% highlight cpp %}
  static void OnTimeout(uv_timer_t* handle) {
    TimerWrap* wrap = static_cast<TimerWrap*>(handle->data);
    Environment* env = wrap->env();
    HandleScope handle_scope(env->isolate());
    Context::Scope context_scope(env->context());
    wrap->MakeCallback(kOnTimeout, 0, nullptr);
  }
{% endhighlight %}

A dark day seems bright now, every stage in `uv_run` can be the last stage of event loop iteration, such like timeout, it check and execute the `env()->tick_callback_function()`. Another API setImmediate ended in the internal called `node::MakeCallback`, node does the same work. And the last part of StartNodeInstance, `EmitBeforeExit(env)` and `EmitExit(env)` will also call the `node::MakeCallback` to ensure the tick_callback_function can be called before process exit.

### File I/O

Not yet finished, coming soon...

### Network I/O

Not yet finished, coming soon...

# Quiz

You can now take a quiz to test whether you have already understand the event loop in Node.js totally. It mainly contains user asynchronous code. <a target="_blank" href="https://gist.github.com/a0viedo/0de050bb2249757c5def">Have a try.</a>

# Conclusion
When called setTimeout and setImmediate, it schedules the callback function as a task to be executed in next event loop iteration. But nextTick won't. It will get called before current event loop iteration ended. Also we can foresee that if we called the nextTick recursively the timeout task have no chance to execute during such procedure.

# References
[1] <a target="_blank" href="https://nodesource.com/blog/understanding-the-nodejs-event-loop/">https://nodesource.com/blog/understanding-the-nodejs-event-loop/</a><br/>
[2] <a target="_blank" href="http://khan.io/2015/02/25/the-event-loop-and-non-blocking-io-in-node-js/">http://khan.io/2015/02/25/the-event-loop-and-non-blocking-io-in-node-js/</a><br/>
[3] <a target="_blank" href="http://hueniverse.com/2011/06/29/the-style-of-non-blocking/">http://hueniverse.com/2011/06/29/the-style-of-non-blocking/</a><br/>
[4] <a target="_blank" href="http://blog.mixu.net/2011/02/01/understanding-the-node-js-event-loop/">http://blog.mixu.net/2011/02/01/understanding-the-node-js-event-loop/</a><br/>
[5] <a target="_blank" href="http://stackoverflow.com/questions/1050222/concurrency-vs-parallelism-what-is-the-difference">http://stackoverflow.com/questions/1050222/concurrency-vs-parallelism-what-is-the-difference</a><br/>
[6] <a target="_blank" href="http://blog.libtorrent.org/2012/10/asynchronous-disk-io/">http://blog.libtorrent.org/2012/10/asynchronous-disk-io/</a><br/>
[7] <a target="_blank" href="http://prkr.me/words/2014/understanding-the-javascript-event-loop/">http://prkr.me/words/2014/understanding-the-javascript-event-loop/</a><br/>
[8] <a target="_blank" href="http://www.xmailserver.org/linux-patches/nio-improve.html">http://www.xmailserver.org/linux-patches/nio-improve.html</a><br/>

<div class="note">
<span class="note__caption">Note:</span>
<em class="note__content--normal"> I am very lucky to have a bundle of guys as friends who know C++ very well, they teach me a lot and provide useful information.</em>
</div>

<div class="note">
<span class="note__caption">Note:</span>
<em class="note__content--warning"> I am a Chinese, writing in English is for exercise. If you want to refer my articles, please mark your own as refer from <a title="AceMood's Blog" href="{{ page.url }}" target="_blank">AceMood's Blog.</a></em>
</div>