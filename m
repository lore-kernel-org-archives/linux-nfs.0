Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:55134 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933887AbcHaPwK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 11:52:10 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux Network Devel Mailing <netdev@vger.kernel.org>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.1: work around -Wmaybe-uninitialized warning
Date: Wed, 31 Aug 2016 17:52:08 +0200
Message-ID: <4865077.USSZu2CAsg@wuerfel>
In-Reply-To: <DC57A918-AB14-483B-87EF-A88469193855@primarydata.com>
References: <20160831123911.3467676-1-arnd@arndb.de> <5024842.0SZmq2hZxe@wuerfel> <DC57A918-AB14-483B-87EF-A88469193855@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, August 31, 2016 3:02:42 PM CEST Trond Myklebust wrote:
> > On Aug 31, 2016, at 09:37, Arnd Bergmann <arnd@arndb.de> wrote:
> > 
> > On Wednesday, August 31, 2016 1:17:48 PM CEST Trond Myklebust wrote:
> >> What version of gcc are you using? I’m unable to reproduce with gcc 6.1.1..
> > 
> > This is also on 6.1.1 for ARM. Note that 6e8d666e9253 ("Disable
> > "maybe-uninitialized" warning globally") turned off those warnings, so
> > unless you explicitly pass -Wmaybe-uninitialized (e.g. by building with
> > "make W=1"), you won't get it.
> > 
> 
> I’m not getting that error on gcc 6.1.1 for x86_64 with either “make W=1” or “make W=2”.
> “make W=3” does gives rise to one warning in nfs4_slot_get_seqid:

Ok, I had not realized that the patch that Linus did disabled the warning
for all levels, I'll try to come up a patch to bring it back at W=1 level.

On my system, I had simply reverted the patch that turned off the
warning, but I have now verified that I get it with
"make EXTRA_CFLAGS=-Wmaybe-uninitialized" on an x86 defconfig with gcc-5 and
gcc-6.

> /home/trondmy/devel/kernel/linux/fs/nfs/nfs4session.c: In function ‘nfs4_slot_get_seqid’:
> /home/trondmy/devel/kernel/linux/fs/nfs/nfs4session.c:184:10: warning: conversion to ‘int’ from ‘long int’ may alter its value [-Wconversion]
>    return PTR_ERR(slot);
>           ^~~~~~~~~~~~~
> 
> (which is another false positive) but that’s all...

sure, W=3 is useless.

> > The reason I'm still sending the patches for this warning is that
> > we do get a number of valid ones (this was the only false positive
> > out of the seven such warnings since last week).
> 
> There is a Zen-like quality to IS_ERR() when it casts a const pointer to an unsigned long, back to a non-const pointer, and then back to an unsigned long before comparing it to another unsigned long cast constant negative integer. However, I’m not sure the C99 standard would agree that a positive test result implies we can assume that a simple cast of the same pointer to a signed long will result in a negative, non-zero valued errno.
> 
> I suspect that if we really want to fix these false negatives, we should probably address that issue.

I've looked into this before, as we've had a couple of these cases (I
think less than 10 in the whole kernel, but they keep coming up every
few releases), and I couldn't find a way to make IS_ERR more transparent.

Using IS_ERR_OR_ZERO() seems like a good enough solution, and will
probably result in slightly better code (I have not checked this
specific case though), as we can also skip the second runtime check.

	Arnd
