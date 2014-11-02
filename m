Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:42005 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaKBSDA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Nov 2014 13:03:00 -0500
Message-ID: <545671D0.2090506@electrozaur.com>
Date: Sun, 02 Nov 2014 20:02:56 +0200
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>
CC: Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs atime semantics, was: Re: [PATCH 3/4] common: skip atime
 related tests on NFS
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>	<1414502171-10319-4-git-send-email-eguan@redhat.com>	<20141030090306.GA23917@infradead.org> <CAHQdGtRFMcJGNZvU_V22Xh-3LadD2bYc=TwrkmBVBK81RkWCvw@mail.gmail.com>
In-Reply-To: <CAHQdGtRFMcJGNZvU_V22Xh-3LadD2bYc=TwrkmBVBK81RkWCvw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/31/2014 01:31 PM, Trond Myklebust wrote:
<>
> If there is no read on the wire, then there is no way to update the
> atime without doing an explicit SETATTR. Courtesy of POSIX filesystem
> semantics on the server, that means we get a bonus change attribute
> and ctime update (no extra charge).
> 
> Unless there are new suggestions for how to solve the atime issue that
> do not involve introducing this or similar regressions, then the
> standing NACK applies.
> 

Say the user asks, realy (realy^3) nicely, can we instead of sending
SETATTR (BAD) send in its place an async READ of say one byte (or one
word)

It will do what we want. Just need to collect the updates and atime vs rel-atime
correctly, and to not hurt performance as well. (Like only send when no real
READS went through)

> Cheers
>   Trond
> 

Cheers
Boaz

