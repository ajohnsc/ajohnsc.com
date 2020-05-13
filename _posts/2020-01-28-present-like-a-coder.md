---
layout: post
categories: jekyll update
title: Present like a coder
---
# It took a long a looong time
This and last month was very busy and didn't post anything for a long time due to Christmas , New year holidays and the Holiday grinds we have.

To be honest, I really don't have anything to talk to also since it was a season of celebration and making things good.

But today I stumbled upon a gem on making presentations, ussualy I use Google Slides or Powerpoint to present in my talks, however I find it very boring since it is really static and flaky (if flaky is a real word), I use Prezi before but the problem with Prezi it is a paid service to use.

Then I search for an alternative and I found Impress.js it is a java script that if you embeded to your web page, it will look like Prezi, I converted my Cloud presentation to a Impress.js based presentation and it was a huge success.

For me to able to share it freely to people I made it containerize and can run on docker.

For you to have a copy do the following:

Assuming you have docker installed.

## clone the repo

First clone the repository of my Cloud presentation:

```
[root@localhost] git clone https://github.com/ajohnsc/CloudSlide.git
```

## Build your docker image

Build the docker image of the presentation

```
[root@localhost] docker build -t cloud:present CloudSlide/
```

## Run the container with exposed port

Run the presentation image detached with exposing port 80 to 8080

```
[root@localhost] docker run -d -p 8080:80 --name cloud cloud:present
```

Then check your browser in `http://localhost:8080` to check my presentation.
