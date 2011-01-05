Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19326 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752817Ab1AEVQ7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 16:16:59 -0500
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
In-Reply-To: <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
References: <1294254337.16957.13.camel@mulgrave.site>
	 <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	 <1294256169.16957.18.camel@mulgrave.site>
	 <20110105200008.GJ8638@n2100.arm.linux.org.uk>
	 <1294259637.16957.25.camel@mulgrave.site>
	 <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
	 <20110105210448.GM8638@n2100.arm.linux.org.uk>
	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 16:16:48 -0500
Message-ID: <1294262208.2952.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 13:08 -0800, Linus Torvalds wrote: 
> On Wed, Jan 5, 2011 at 1:04 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Wed, Jan 05, 2011 at 12:48:32PM -0800, Linus Torvalds wrote:
> >> (You can also force the problem with vmalloc() an then following the
> >> kernel page tables, but I hope nobody does that any more. I suspect
> >> I'm wrong, though, there's probably code that mixes vmalloc and
> >> physical page accesses in various drivers)
> >
> > Should vmalloc_to_page() (84 users)/vmalloc_to_pfn() (17 users) be
> > deprecated then? ;)
> 
> I do think that the "modern" way of doing it is
> "vmap()"/"vm_map_ram()" and friends, and it should be preferred over
> using vmalloc() and then looking up the pages.
> 
> But in the end, the two approaches really are equivalent, so it's not
> like it really matters. So I don't think we need to deprecate things
> officially, but obviously we should make people more aware of the
> whole virtual alias thing that crops up whenever you use any of these
> approaches.

So what should be the preferred way to ensure data gets flushed when
you've written directly to a page, and then want to read through the
vm_map_ram() virtual range? Should we be adding new semantics to
flush_kernel_dcache_page()?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

