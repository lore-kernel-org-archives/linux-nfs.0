Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54630 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab1AES2c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 13:28:32 -0500
Date: Wed, 5 Jan 2011 18:27:54 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110105182753.GG8638@n2100.arm.linux.org.uk>
References: <20110105110517.GQ25121@pengutronix.de> <20110105112701.GA8638@n2100.arm.linux.org.uk> <20110105134045.GS25121@pengutronix.de> <1294239193.3014.9.camel@heimdal.trondhjem.org> <4D2487CA.5040501@pengutronix.de> <1294240457.3014.13.camel@heimdal.trondhjem.org> <20110105155230.GC8638@n2100.arm.linux.org.uk> <1294247847.2998.23.camel@heimdal.trondhjem.org> <20110105172641.GF8638@n2100.arm.linux.org.uk> <1294251145.3574.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294251145.3574.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 01:12:25PM -0500, Trond Myklebust wrote:
> On Wed, 2011-01-05 at 17:26 +0000, Russell King - ARM Linux wrote: 
> > On Wed, Jan 05, 2011 at 12:17:27PM -0500, Trond Myklebust wrote:
> > > We should already be flushing the kernel direct mapping after writing by
> > > means of the calls to flush_dcache_page() in xdr_partial_copy_from_skb()
> > > and all the helpers in net/sunrpc/xdr.c.
> > 
> > Hmm, we're getting into the realms of what flush_dcache_page() is supposed
> > to do and what it's not supposed to do.
> > 
> > Is this page an associated with a mapping (iow, page_mapping(page) is non-
> > NULL)?  If not, flush_dcache_page() won't do anything, and from my
> > understanding, its flush_anon_page() which you want to be using there
> > instead.
> 
> Actually, none of these pages are ever mapped into userspace, nor are
> they mapped into the page cache.
> 
> They are allocated directly using alloc_page() by the thread that called
> the readdir() syscall, so afaics there should be no incoherent mappings
> other than the kernel direct mapping and the one created by
> vm_map_ram().
> 
> So, yes, you are right that we don't need the flush_dcache_page() here.

I do still think you need _something_ there, otherwise data can remain
in the direct map alias and not be visible via the vmap alias.  I don't
see that we have anything in place to handle this at present though.

jejb mentioned something about making kunmap_atomic() always flush the
cache, even for lowmem pages, but I think that's going to be exceedingly
painful, to the extent that I believe it will prevent our PIO-only MMC
drivers working - or we need a scatterlist API that will let drivers
iterate over the scatterlist without needing to continually kmap_atomic
and kunmap_atomic each page.
