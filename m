Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62942 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab1EBU2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 16:28:44 -0400
Received: by iwn34 with SMTP id 34so4955422iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2011 13:28:43 -0700 (PDT)
In-Reply-To: <1304367673.20876.1.camel@lade.trondhjem.org>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	<20110502140750.GA10885@fieldses.org>
	<BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
	<1304347155.7830.7.camel@lade.trondhjem.org>
	<BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
	<1304356699.7830.26.camel@lade.trondhjem.org>
	<BANLkTi=2uYagwN=Xy9FxhXV4wt3tf669JA@mail.gmail.com>
	<1304367673.20876.1.camel@lade.trondhjem.org>
Date: Mon, 2 May 2011 22:28:43 +0200
Message-ID: <BANLkTimB=-QaW8S-H9XNv9TM+gWbB23CjQ@mail.gmail.com>
Subject: Re: How does NFS handle notify?
From: Stef Bon <stefbon@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/5/2 Trond Myklebust <Trond.Myklebust@netapp.com>:

>>
>> So, what's your opinion?
>
> Your proposal requires NFS and CIFS protocol support and I just told you
> that there is none in NFS...

Hi,

yes I've read that. I also have read that there is possibly support
for in newer versions in NFS.

I imagined that you (not only you but I mean all who are working on
NFS) are interested to find a good way to do this.

I want to work on this, but when I'm trying to achieve something in
the VFS, I'm interested in what other developers with simular projects
(most important cifs and nfs) look at it.

Stef
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>
