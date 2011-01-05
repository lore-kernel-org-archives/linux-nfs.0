Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:40144 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751774Ab1AEUeA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 15:34:00 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <20110105200008.GJ8638@n2100.arm.linux.org.uk>
References: <1294254337.16957.13.camel@mulgrave.site>
	 <AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	 <1294256169.16957.18.camel@mulgrave.site>
	 <20110105200008.GJ8638@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 14:33:57 -0600
Message-ID: <1294259637.16957.25.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 20:00 +0000, Russell King - ARM Linux wrote:
> On Wed, Jan 05, 2011 at 01:36:09PM -0600, James Bottomley wrote:
> > On Wed, 2011-01-05 at 11:18 -0800, Linus Torvalds wrote:
> > > On Wed, Jan 5, 2011 at 11:05 AM, James Bottomley
> > > <James.Bottomley@hansenpartnership.com> wrote:
> > > >
> > > > I think the solution for the kernel direct mapping problem is to take
> > > > the expected flushes and invalidates into kmap/kunmap[_atomic].
> > > 
> > > No, we really can't do that. Most of the time, the kmap() is the only
> > > way we access the page anyway, so flushing things would just be
> > > stupid. Why waste time and energy on doing something pointless?
> > 
> > It's hardly pointless.  The kmap sets up an inequivalent alias in the
> > cache.
> 
> No it doesn't.  For pages which are inaccessible, it sets up a mapping
> for those pages.  On aliasing cache architectures, when you tear down
> such a mapping, you have to flush the cache before you do so (otherwise
> you can end up with cache lines existing in the cache for inaccessible
> mappings.)
> 
> For lowmem pages, kmap() (should always) bypass the 'setup mapping' stage
> because all lowmem pages are already accessible.  So kunmap() doesn't
> do anything - just like the !HIGHMEM implementation for these macros.

well, that depends.  For us on parisc, kmap of a user page in !HIGHMEM
sets up an inequivalent aliase still ... because the cache colour of the
user and kernel virtual addresses are different.  Depending on the
return path to userspace, we still usually have to flush to get the user
to see the changes the kernel has made.

James

> So, for highmem-enabled systems:
> 
> 	low_addr = kmap_atomic(lowmem_page);
> 	high_addr = kmap_atomic(highmem_page);
> 
> results in low_addr in the kernel direct-mapped region, and high_addr
> in the kmap_atomic region.


