Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754941Ab0L3TZe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Dec 2010 14:25:34 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Chuck Lever <chuck.lever@oracle.com>, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=sO9M8m1Fpntu_YscVU4SrppKfxBf2eRZ2Dr+L@mail.gmail.com>
References: <AANLkTi=-dNeeDjcSoznKtwcaNyw1mMXSqepFY89R2i+2@mail.gmail.com>
	 <20101230171453.GA5787@pengutronix.de>
	 <AANLkTikvZF6Q1k0rETLHUffkUT3grxAh3FoB_0vs96B8@mail.gmail.com>
	 <1293733460.4919.21.camel@heimdal.trondhjem.org>
	 <AANLkTi=sO9M8m1Fpntu_YscVU4SrppKfxBf2eRZ2Dr+L@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Dec 2010 14:25:15 -0500
Message-ID: <1293737115.4919.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-30 at 10:50 -0800, Linus Torvalds wrote: 
> On Thu, Dec 30, 2010 at 10:24 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > There is nothing we can do to protect ourselves against an infinite loop
> > if the server (or underlying filesystem) is breaking the rules w.r.t.
> > cookie generation. It should be possible to recover from all other
> > situations.
> 
> Umm. Sure there is. Just make sure that you return the uncached entry
> to user space, rather than loop forever.
> 
> Looping forever in kernel space is a bad idea. How about just changing
> the "continue" into a "break" for the "uncached readdir returned
> success".

uncached_readdir is not really a problem. The real problem is
filesystems that generate "infinite directories" by producing looping
combinations of cookies.

IOW: I've seen servers that generate cookies in a sequence of a form
vaguely resembling

1 2 3 4 5 6 7 8 9 10 11 12 3...

(with possibly a thousand or so entries between the first and second
copy of '3')

The kernel won't loop forever with something like that (because
eventually filldir() will declare it is out of buffer space), but
userland has a halting problem: it needs to detect that every
sys_getdents() call it is making is generating another copy of the
sequence associated with '4 5 6 7 8 9 10 11 12 3'...

> No halting problems, no excuses. There is absolutely _no_ excuse for
> an endless loop in kernel mode. Certainly not "the other end is
> incompetent".

We should never get an endless loop in _kernel mode_ with the current
scheme, and I can't see that anyone has demonstrated that yet.

> EVERYBODY is incompetent sometimes. That just means that you must
> never trust the other end too much. You can't say "we require the
> server to be sane in order not to lock up".

Unfortunately we must. Call it an NFS protocol failure, but it really
boils down to the fact that POSIX readdir() generates a data stream with
no well-defined concept of an offset. As a result, each and every
filesystem has their own interesting ways of generating cookies to
represent that 'offset'.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

