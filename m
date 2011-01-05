Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33565 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab1AFAA3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 19:00:29 -0500
Date: Wed, 5 Jan 2011 23:59:22 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110105235922.GP8638@n2100.arm.linux.org.uk>
References: <1294256169.16957.18.camel@mulgrave.site> <20110105200008.GJ8638@n2100.arm.linux.org.uk> <1294259637.16957.25.camel@mulgrave.site> <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com> <20110105210448.GM8638@n2100.arm.linux.org.uk> <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com> <1294262208.2952.4.camel@heimdal.trondhjem.org> <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com> <1294268808.2952.18.camel@heimdal.trondhjem.org> <AANLkTi=SjMinMp+m726GS1iehj6cQgNy1RqSoUqKhjtv@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTi=SjMinMp+m726GS1iehj6cQgNy1RqSoUqKhjtv@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 03:28:53PM -0800, Linus Torvalds wrote:
> On Wed, Jan 5, 2011 at 3:06 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > Yes. The fix I sent out was a call to invalidate_kernel_vmap_range(),
> > which takes care of invalidating the cache prior to a virtual address
> > read.
> >
> > My question was specifically about the write through the regular kernel
> > mapping: according to Russell and my reading of the cachetlb.txt
> > documentation, flush_dcache_page() is only guaranteed to have an effect
> > on page cache pages.
> 
> I don't think that should ever matter. It's not like the hardware can
> know whether it's a dcache page or not.
> 
> And if the sw implementation cares, it's doing something really odd.

>From the hardware perspective you're correct that it doesn't.  However,
from the efficient implementation perspective it does matter.

Take for example the read-ahead done on block devices.  We don't want to
flush all those pages that were read in when we don't know that they're
ever going to end up in a user mapping.  So what's commonly done (as
suggested by DaveM) is that flush_dcache_page() detects that it's a
dcache page, ensures that there's no user mappings, and sets a 'dirty'
flag.  This flag is guaranteed to be clear when new, clean, unread
pages enter the page cache.

When the page eventually ends up in a user mapping, that dirty flag is
checked and the necessary cache flushing done at that point.

Note that when there are user mappings, flush_dcache_page() has to flush
those mappings too, otherwise mmap() <-> read()/write() coherency breaks.
I believe this was what flush_dcache_page() was created to resolve.

flush_kernel_dcache_page() was to solve the problem of PIO drivers
writing to dcache pages, so that data written into the kernel mapping
would be visible to subsequent user mappings.

We chose a different overall approach - which had already been adopted by
PPC - where we invert the meaning of this 'dirty' bit to mean that it's
clean.  So every new page cache page starts out life as being marked
dirty and so nothing needs to be done at flush_kernel_dcache_page().
We continue to use davem's optimization but with the changed meaning of
the bit, but as we now support SMP we do the flushing at set_pte_at()
time.

This also means that we don't have to rely on the (endlessly) buggy PIO
drivers remembering to add flush_kernel_dcache_page() calls - something
which has been a source of constant never-ending pain for us.

The final piece of the jigsaw is flush_anon_page() which deals with
kernel<->user coherency for anonymous pages by flushing both the user
and kernel sides of the mapping.  This was to solve direct-io coherency
problems.

As the users of flush_anon_page() always do:

	flush_anon_page(vma, page, addr);
	flush_dcache_page(page);

and documentation doesn't appear to imply that this will always be the
case, we restrict flush_dcache_page() to only work on page cache pages,
otherwise we end up flushing the kernel-side mapping multiple time in
succession.

Maybe we should make flush_anon_page() only flush the user mapping,
stipulate that it shall always be followed by flush_dcache_page(),
which shall flush the kernel side mapping even for anonymous pages?
That sounds to me like a recipe for missing flush_dcache_page() calls
causing bugs.
