---
layout: posts/_post.slime
tag:
  - post
tags:
  - elixir
  - phoenix
title: "Testing Phoenix Channels on Browser console"
description: "In this blog post I show how you can test your phoenix channels manually on the browser console"
permalink: post/testing-phoenix-channels-on-browser-console/index.html
date: 2020-08-02
---

So... I was building a backend using only the channels, and I wanted to test it on the console... so after many search, here is how you can make it:

## 1 - Connect to a socket

```js
  ws = new WebSocket("ws://localhost:4000/socket/websocket"); 
```

## 2 - Show the messages that arrive from the server

```js
  ws.onmessage = function (e) {
        console.log("From Server:"+ e.data);
          };
```

## 3 - Join to a topic

```js
ws.send(JSON.stringify({
    "topic": "chat:lobby",
      "event": "phx_join",
        "payload": { "hello": "world" },
          "ref": 0
}));
```

## 4 - Send a event with a payload to the topic

```js
ws.send(JSON.stringify({
    "topic": "chat:lobby",
      "event": "echo",
        "payload": { "hello": "world" },
          "ref": 0
}));
```

Keep in mind that the phoenix uses the `event` "heartbeat" to keep the conection alive, so if you dont want to lose the conection, send it each 30 seconds hehe


So... I was building a backend using only the channels, and I wanted to test it on the console... so after many search, here is how you can make it:

## 1 - Connect to a socket

```js
  ws = new WebSocket("ws://localhost:4000/socket/websocket"); 
```

## 2 - Show the messages that arrive from the server

```js
  ws.onmessage = function (e) {
    console.log("From Server:"+ e.data);
  };
```

## 3 - Join to a topic

```js
ws.send(JSON.stringify({
  "topic": "chat:lobby",
  "event": "phx_join",
  "payload": { "hello": "world" },
  "ref": 0
}));
```

## 4 - Send a event with a payload to the topic

```js
ws.send(JSON.stringify({
  "topic": "chat:lobby",
  "event": "echo",
  "payload": { "hello": "world" },
  "ref": 0
}));
```

Keep in mind that the phoenix uses the `event` "heartbeat" to keep the conection alive, so if you dont want to lose the conection, send it each 30 seconds hehe

