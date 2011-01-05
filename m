Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:37662 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab1AEUBM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 15:01:12 -0500
Date: Wed, 5 Jan 2011 20:00:08 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <20110105200008.GJ8638@n2100.arm.linux.org.uk>
References: <1294254337.16957.13.camel@mulgrave.site> <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com> <1294256169.16957.18.camel@mulgrave.site>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294256169.16957.18.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 01:36:09PM -0600, James Bottomley wrote:
> On Wed, 2011-01-05 at 11:18 -0800, Linus Torvalds wrote:
> > On Wed, Jan 5, 2011 at 11:05 AM, James Bottomley
> > <James.Bottomley@hansenpartnership.com> wrote:
> > >
> > > I think the solution for the kernel direct mapping problem is to take
> > > the expected flushes and invalidates into kmap/kunmap[_atomic].
> > 
> > No, we really can't do that. Most of the time, the kmap() is the only
> > way we access the page anyway, so flushing things would just be
> > stupid. Why waste time and energy on doing something pointless?
> 
> It's hardly pointless.  The kmap sets up an inequivalent alias in the
> cache.

No it doesn't.  For pages which are inaccessible, it sets up a mapping
for those pages.  On aliasing cache architectures, when you tear down
such a mapping, you have to flush the cache before you do so (otherwise
you can end up with cache lines existing in the cache for inaccessible
mappings.)

For lowmem pages, kmap() (should always) bypass the 'setup mapping' stage
because all lowmem pages are already accessible.  So kunmap() doesn't
do anything - just like the !HIGHMEM implementation for these macros.

So, for highmem-enabled systems:

	low_addr = kmap_atomic(lowmem_page);
	high_addr = kmap_atomic(highmem_page);

results in low_addr in the kernel direct-mapped region, and high_addr
in the kmap_atomic region.
