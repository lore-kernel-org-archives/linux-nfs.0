Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:44180 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373Ab1AEVQO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 16:16:14 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
References: <1294254337.16957.13.camel@mulgrave.site>
	 <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	 <1294256169.16957.18.camel@mulgrave.site>
	 <20110105200008.GJ8638@n2100.arm.linux.org.uk>
	 <1294259637.16957.25.camel@mulgrave.site>
	 <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 15:16:10 -0600
Message-ID: <1294262170.16957.46.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 12:48 -0800, Linus Torvalds wrote:
> On Wed, Jan 5, 2011 at 12:33 PM, James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> >
> > well, that depends.  For us on parisc, kmap of a user page in !HIGHMEM
> > sets up an inequivalent aliase still ... because the cache colour of the
> > user and kernel virtual addresses are different.  Depending on the
> > return path to userspace, we still usually have to flush to get the user
> > to see the changes the kernel has made.
> 
> Umm. Again, that has nothing to do with kmap().
> 
> This time it's about the user space mapping.
> 
> Repeat after me: even without the kmap(), the kernel access to that
> mapping would have caused cache aliases.
> 
> See? Once more, the kmap() is entirely innocent. You can have a
> non-highmem mapping that you never use kmap for, and that you map into
> user space, and you'd see exactly the same aliases. Notice? Look ma,
> no kmap().

Yes, I understand that (we have no highmem on parisc, so kmap is a nop).
The problem (at least as I see it) is that once something within the
kernel (well, OK, mostly within drivers) touches a user page via its
kernel mapping, the flush often gets forgotten (mainly because it always
works on x86). What I was thinking about is that every time the kernel
touches a user space page, it has to be within a kmap/kunmap pair
(because the page might be highmem) ... so it's possible to make
kmap/kunmap do the flushing for this case so the driver writer can't
ever forget it.

I think the problem case is only really touching scatter/gather elements
outside of the DMA API (i.e. the driver pio case), so this may be
overkill.  Russell also pointed out that a lot of the PIO iterators do
excessive kmap_atomic/kunmap_atomic on the same page, so adding a flush
could damage performance to the point where the flash root devices on
arm might not work.  Plus the pio iterators already contain the
appropriate flush, so perhaps just using them in every case fixes the
problem.

> So clearly kmap() is not the issue. The issue continues to be a
> totally separate virtual mapping. Whether it's a user mapping or
> vm_map_ram() is obviously immaterial - as far as the CPU is concerned,
> there is no difference between the two (apart from the trivial
> differences of virtual location and permissions).
> 
> (You can also force the problem with vmalloc() an then following the
> kernel page tables, but I hope nobody does that any more. I suspect
> I'm wrong, though, there's probably code that mixes vmalloc and
> physical page accesses in various drivers)

Yes, unfortunately, we have seen this quite a bit; mainly to get large
buffers.  Its not just confined to drivers:  xfs used to fail on both
arm and parisc because it used a vmalloc region for its log buffer which
it then had to do I/O on.

James


