---
layout: post
categories: jekyll update
title: First Blog
---
# Hello World!

I want to embark in a journey of docummenting everything that I do. this might help me how to use this stuff moving forward.

## Today I just tried on how to install Jekyll in a Centos/7

First we need to install the latest Ruby

Install all the requirements

```
[root@localhost] yum install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel sqlite-devel
```

Then install RVM
```
[root@localhost] curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
[root@localhost] curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
[root@localhost] curl -L get.rvm.io | bash -s stable
```

Load RVM environment
```
[root@localhost] source /etc/profile.d/rvm.sh
[root@localhost] rvm reload
```

Install dependencies of rvm
```
[root@localhost] rvm requirements run
```

Install latest Ruby
```
[root@localhost] rvm install 2.6
```

Now install Jekyll and bundler
```
[root@localhost] gem install jekyll bundler
```

Then install github pages using gems
```
[root@localhost] gem install github-pages
```

initialize a blog
```
[root@localhost] jekyll new new-blog
[root@localhost] cd new-blog
```

test the jekyll blog
```
[root@localhost] jekyll serve
```

And now you have a working blog ussualy works on localhost:4000!

