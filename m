Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:33148 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751432Ab1AETFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 14:05:40 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 13:05:36 -0600
Message-ID: <1294254337.16957.13.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[sorry for the unthreaded insertion.  We're seeing this on parisc too]

> On Wed, Jan 05, 2011 at 10:14:17AM -0500, Trond Myklebust wrote:
> > OK. So,the new behaviour in 2.6.37 is that we're writing to a series of
> > pages via the usual kmap_atomic()/kunmap_atomic() and kmap()/kunmap()
> > interfaces, but we can end up reading them via a virtual address range
> > that gets set up via vm_map_ram() (that range gets set up before the
> > write occurs).
> 
> kmap of lowmem pages will always reuses the existing kernel direct
> mapping, so there won't be a problem there.
> 
> > Do we perhaps need an invalidate_kernel_vmap_range() before we can read
> > the data on ARM in this kind of scenario?
> 
> Firstly, vm_map_ram() does no cache maintainence of any sort, nor does
> it take care of page colouring - so any architecture where cache aliasing
> can occur will see this problem.  It should not limited to ARM.
> 
> Secondly, no, invalidate_kernel_vmap_range() probably isn't sufficient.
> There's two problems here:
> 
> 	addr = kmap(lowmem_page);
> 	*addr = stuff;
> 	kunmap(lowmem_page);
> 
> Such lowmem pages are accessed through their kernel direct mapping.
> 
> 	ptr = vm_map_ram(lowmem_page);
> 	read = *ptr;
> 
> This creates a new mapping which can alias with the kernel direct mapping.
> Now, as this is a new mapping, there should be no cache lines associated
> with it.  (Looking at vm_unmap_ram(), it calls free_unmap_vmap_area_addr(),
> free_unmap_vmap_area(), which then calls flush_cache_vunmap() on the
> region.  vb_free() also calls flush_cache_vunmap() too.)
> 
> If the write after kmap() hits an already present cache line, the cache
> line will be updated, but it won't be written back to memory.  So, on
> a subsequent vm_map_ram(), with any kind of aliasing cache, there's
> no guarantee that you'll hit that cache line and read the data just
> written there.
> 
> The kernel direct mapping would need to be flushed.
> 
> I'm really getting to the point of hating the poliferation of RAM
> remapping interfaces - it's going to (and is) causing nothing but lots
> of pain on virtual cache architectures, needing more and more cache
> flushing interfaces to be created.
> 
> Is there any other solution to this?

I think the solution for the kernel direct mapping problem is to take
the expected flushes and invalidates into kmap/kunmap[_atomic].  I think
the original reason for not doing this was efficiency:  the user should
know what they did with the data (i.e. if they're only reading it, it
doesn't need to be flushed on unmap).  However, the difficulty of
getting all this right seems to outweigh the efficiency of only using
the necessary flushing.  At least on some architectures, we can look at
the TLB flags to see if the page was dirtied (and only flush if it was).

James


