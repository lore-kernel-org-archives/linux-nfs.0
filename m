Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42123 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754933Ab0L3SYY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Dec 2010 13:24:24 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Chuck Lever <chuck.lever@oracle.com>, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTikvZF6Q1k0rETLHUffkUT3grxAh3FoB_0vs96B8@mail.gmail.com>
References: <AANLkTi=-dNeeDjcSoznKtwcaNyw1mMXSqepFY89R2i+2@mail.gmail.com>
	 <20101230171453.GA5787@pengutronix.de>
	 <AANLkTikvZF6Q1k0rETLHUffkUT3grxAh3FoB_0vs96B8@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Dec 2010 13:24:20 -0500
Message-ID: <1293733460.4919.21.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-30 at 09:57 -0800, Linus Torvalds wrote: 
> Please cc the poor hapless NFS people too, who probably otherwise
> wouldn't see it. And Arnd just in case it might be locking-related.
> 
> Trond, any ideas? The sysrq thing does imply that it's stuck in some
> busy-loop in fs/nfs/dir.c, and line 647 is get_cache_page(), which in
> turn implies that the endless loop is either the loop in
> readdir_search_pagecache() _or_ in a caller. In particular, the
> EBADCOOKIE case in the caller (nfs_readdir) looks suspicious. What
> protects us from endless streams of EBADCOOKIE and a successful
> uncached_readdir?

There is nothing we can do to protect ourselves against an infinite loop
if the server (or underlying filesystem) is breaking the rules w.r.t.
cookie generation. It should be possible to recover from all other
situations.
IOW: if the server generates non-unique cookies, then we're screwed.
Fixing that particular problem is impossible since it is basically a
variant of the halting problem.
That was why I asked which filesystem is being exported in my previous
reply.

The point of 'uncached_readdir' is to resolve a cookie that was
previously valid, but has since been invalidated; usually that is due to
the file having been unlinked. If it succeeds, it should result in a new
set of valid entries being posted to the 'filldir' callback, and a new
cookie being set in the filp->private (i.e. we should have made
progress). If it fails, we exit, as you can see.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

