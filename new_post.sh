#!/bin/bash

date=$(date '+%Y-%m-%d')

read -p "Enter Title:" title

titlename=${title// /-}

filename=`echo "$titlename" | tr '[:upper:]' '[:lower:]'`

finalfilename=$date-$filename.md

touch _posts/$finalfilename
mkdir assets/$date-$filename

cat << EOF >> _posts/$finalfilename
---
layout: post
title: $title
categories: jekyll update
---

EOF


code _posts/$finalfilename
