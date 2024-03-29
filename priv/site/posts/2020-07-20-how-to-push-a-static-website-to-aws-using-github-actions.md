---
layout: posts/_post.slime
tag:
  - post
tags: 
  - aws
  - github actions
title: "How to push a static website to AWS using github actions"
description: "A reminder on how to push a static website to AWS using github actions with the minimum of enfort"
permalink: post/how-to-push-a-static-website-to-aws-using-github-actions/index.html
date: 2020-07-20
---


This is my personal default template for npm projects:

```yml
name: Push to AWS [CD]

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-node@v1
      with:
        node-version: 14.x 

    - name: NPM - install
      run: npm i

    - name: NPM - export
      run: npm run export

    - name: AWS - Set PEM
      run: |
        echo "${{ secrets.AWS_PEM }}" > temp.pem
        chmod 400 temp.pem

    - name: AWS - Exclude last files if exists
      run: |
           ssh -q -o "StrictHostKeyChecking no" -i temp.pem ${{ secrets.AWS_SSH }} \\
             rm -r /www/shiryel_blog/*

    - name: AWS - Send new files to server
      if: success() || failure()
      run: |
        scp -o "StrictHostKeyChecking no" -i temp.pem  -r \\
          __sapper__/export/* ${{ secrets.AWS_SSH }}:/www/shiryel_blog/

    - name: AWS - Clear PEM
      if: always()
      run: rm -f temp.pem
```

So lets see what hapens here

## First, the scope

```yml
on:
  push:
    branches: [ master ]
```

This says to run this script when a push is made on the master branch

## Then the machine pre-config

```yml
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-node@v1
      with:
        node-version: 14.x 
```

This says to run a countainer on ubuntu (latest version), get the code with checkout, and setup a node version 14

## NPM need to make the NPM things

```yml
    - name: NPM - install
      run: npm i
    
    - name: NPM - export
      run: npm run export
```

Yes

## AWS time, first the PEM

With the PEM on hands, you add it on your github secrets (keep in mind that this aproach is for very small projects, you may want another aproach)
And create a PEM file on your machine

```yml
    - name: AWS - Set PEM
      run: |
        echo "${{ secrets.AWS_PEM }}" > temp.pem
        chmod 400 temp.pem
```

## Then I delete the current static files on AWS if it exists

In my case I like to put the SSH connection (that who you get for connecting on the AWS with your PEM) as a secret (the AWS_SSH)

```yml
    - name: AWS - Exclude last files if exists
      run: |
           ssh -q -o "StrictHostKeyChecking no" -i temp.pem ${{ secrets.AWS_SSH }} \\
             rm -r /www/shiryel_blog/*
```

And yes, make the path modifications for your own files

## Finally I send the files to the server

```yml
    - name: AWS - Send new files to server
      if: success() || failure()
      run: |
        scp -o "StrictHostKeyChecking no" -i temp.pem  -r \\
          __sapper__/export/* ${{ secrets.AWS_SSH }}:/www/shiryel_blog/
```

Modify the `__sapper__/export` and `/www/shiryel_blog` for your needs :)

## And even if it fails... remove the PEM

```yml
    - name: AWS - Clear PEM
      if: always()
      run: rm -f temp.pem
```

That is all folks, have a grat day :)
