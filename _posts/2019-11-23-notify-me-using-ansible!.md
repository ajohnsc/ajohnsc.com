---
layout: post
categories: jekyll update
title: Notify me using Ansible!
---
# Waiting moment

One of my friend from office took a Red hat examination, all of us in the team are all excited for him to pass.

However it took a while for him to get the results, thus all of us are waiting.

But I don't want to wait in Red hat's verify site if he already passed, therefore I thought on how to automate it and use Ansible for it.

I used a Linux server that sits all runs 24/7 and placed my Ansible playbook there.

To start my Ansible playbook:
```
# I'll create a playbook using vim
[aj@server ~]$ vim cert.yaml
```

It needs the necessary headers, the goal of the playbook is for it to run locally in the machine thus decalring the `hosts` as `localhost` and `connection` as `local` to prevent it to ssh (since ssh is not running).
```
---
- name: check if he succeeded
  hosts:  localhost
  connection: local

  tasks:
```

In the tasks area I need to get info from the Red hat verify website and getting the specific certification id and exam, In this example I used `shell` module to execute my command, then register the result to `result` varaiable.
```
  - name: get data from red hat
    shell: curl -s https://www.redhat.com/rhtapps/services/verify?certId=XXX-XXX-XXX | grep 'YYYYY' | wc -l
    register: results
```
Note: XXX-XXX-XXX is the certification ID, and YYYYY is the exam code.

In the command I used in the `shell` module I expect 2 outputs, it's either "0" if he doesn't have the certification or "1" if he already passed it.

Thus I want to proceed in 2 actions.

1st action is if he didn't have the credentials yet, It will reschedule the same playbook again.
```
  - name: schedule this playbook using ansible
    at:
      command: ansible-playbook /home/aj/cert.yaml >> /home/aj/runlogs
      count: 10
      units: minutes
    when: results.stdout == "0"
```

2nd action is if he has the credentials, It will send me a message using telegram.
```
  - name: notify if he survived
    telegram:
      token: 'AAAAAAAAA:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
      chat_id: -PPPPPPPPP
      msg: "Friend passed YYYYY Exam!"
    when: results.stdout == "1"
```
Note: AAAAAAAAA:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB is the telegram chat bot token and PPPPPPPPP is the chat id of telegram.

So the final playbook.
```
---
- name: check if he succeeded
  hosts:  localhost
  connection: local

  tasks:
  - name: get data from red hat
    shell: curl -s https://www.redhat.com/rhtapps/services/verify?certId=XXX-XXX-XXX | grep 'YYYYY' | wc -l
    register: results

  - name: schedule this playbook using ansible
    at:
      command: ansible-playbook /home/aj/cert.yaml >> /home/aj/runlogs
      count: 10
      units: minutes
    when: results.stdout == "0"

  - name: notify if he survived
    telegram:
      token: 'AAAAAAAAA:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
      chat_id: -PPPPPPPPP
      msg: "Friend passed YYYYY Exam!"
    when: results.stdout == "1"
```
