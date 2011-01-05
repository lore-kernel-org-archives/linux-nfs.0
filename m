Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:45582 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab1AETHs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 14:07:48 -0500
Date: Wed, 5 Jan 2011 19:07:34 +0000
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
Message-ID: <20110105190734.GI8638@n2100.arm.linux.org.uk>
References: <20110105134045.GS25121@pengutronix.de> <1294239193.3014.9.camel@heimdal.trondhjem.org> <4D2487CA.5040501@pengutronix.de> <1294240457.3014.13.camel@heimdal.trondhjem.org> <20110105155230.GC8638@n2100.arm.linux.org.uk> <1294247847.2998.23.camel@heimdal.trondhjem.org> <20110105172641.GF8638@n2100.arm.linux.org.uk> <1294251145.3574.16.camel@heimdal.trondhjem.org> <20110105182753.GG8638@n2100.arm.linux.org.uk> <1294253705.3574.21.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294253705.3574.21.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 01:55:05PM -0500, Trond Myklebust wrote:
> On Wed, 2011-01-05 at 18:27 +0000, Russell King - ARM Linux wrote: 
> > I do still think you need _something_ there, otherwise data can remain
> > in the direct map alias and not be visible via the vmap alias.  I don't
> > see that we have anything in place to handle this at present though.
> 
> Is that perhaps what flush_kernel_dcache_page() is supposed to do?

Well, given how we have things currently setup on ARM, this ends up
being a no-op - as new page cache pages are marked dirty and their
flushing done at the point when they're mapped into userspace.

I guess we could do the flushing there and mark the page clean, but
it'd need some careful examination of various code paths to confirm
that it's safe - we may be avoiding this because some ARM arch
versions need to manually IPI cache flushes to other cores (which
can only be done with IRQs enabled.)

So, I don't think it'll do at the present time.
