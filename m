Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59467 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671Ab1AEXHD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 18:07:03 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
References: <1294254337.16957.13.camel@mulgrave.site>
	 <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	 <1294256169.16957.18.camel@mulgrave.site>
	 <20110105200008.GJ8638@n2100.arm.linux.org.uk>
	 <1294259637.16957.25.camel@mulgrave.site>
	 <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
	 <20110105210448.GM8638@n2100.arm.linux.org.uk>
	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
	 <1294262208.2952.4.camel@heimdal.trondhjem.org>
	 <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 18:06:48 -0500
Message-ID: <1294268808.2952.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 13:30 -0800, Linus Torvalds wrote: 
> On Wed, Jan 5, 2011 at 1:16 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > So what should be the preferred way to ensure data gets flushed when
> > you've written directly to a page, and then want to read through the
> > vm_map_ram() virtual range? Should we be adding new semantics to
> > flush_kernel_dcache_page()?
> 
> The "preferred way" is actually simple: "don't do that". IOW, if some
> page is accessed through a virtual mapping you've set up, then
> _always_ access it through that virtual mapping.
> 
> Now, when that is impossible (and yes, it sometimes is), then you
> should flush after doing all writes. And if you do the write through
> the regular kernel mapping, you should use flush_dcache_page(). And if
> you did it through the virtual mapping, you should use
> "flush_kernel_vmap_range()" or whatever.
> 
> NOTE! I really didn't look those up very closely, and if the accesses
> can happen concurrently you are basically screwed, so you do need to
> do locking or something else to guarantee that there is some nice
> sequential order.  And maybe I forgot something.  Which is why I do
> suggest "don't do that" as a primary approach to the problem if at all
> possible.
> 
> Oh, and you may need to flush before reading too (and many writes do
> end up being "read-modify-write" cycles) in case it's possible that
> you have stale data from a previous read that was then invalidated by
> a write to the aliasing address. Even if that write was flushed out,
> the stale read data may exist at the virtual address. I forget what
> all we required - in the end the only sane model is "virtual caches
> suck so bad that anybody who does them should be laughed at for being
> a retard".

Yes. The fix I sent out was a call to invalidate_kernel_vmap_range(),
which takes care of invalidating the cache prior to a virtual address
read.

My question was specifically about the write through the regular kernel
mapping: according to Russell and my reading of the cachetlb.txt
documentation, flush_dcache_page() is only guaranteed to have an effect
on page cache pages.
flush_kernel_dcache_page() (not to be confused with flush_dcache_page)
would appear to be the closest fit according to my reading of the
documentation, however the ARM implementation appears to be a no-op...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

