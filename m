Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33866 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab1AER04 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 12:26:56 -0500
Date: Wed, 5 Jan 2011 17:26:41 +0000
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
Message-ID: <20110105172641.GF8638@n2100.arm.linux.org.uk>
References: <1294100558.25100.8.camel@heimdal.trondhjem.org> <20110105084014.GN25121@pengutronix.de> <20110105110517.GQ25121@pengutronix.de> <20110105112701.GA8638@n2100.arm.linux.org.uk> <20110105134045.GS25121@pengutronix.de> <1294239193.3014.9.camel@heimdal.trondhjem.org> <4D2487CA.5040501@pengutronix.de> <1294240457.3014.13.camel@heimdal.trondhjem.org> <20110105155230.GC8638@n2100.arm.linux.org.uk> <1294247847.2998.23.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294247847.2998.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 12:17:27PM -0500, Trond Myklebust wrote:
> We should already be flushing the kernel direct mapping after writing by
> means of the calls to flush_dcache_page() in xdr_partial_copy_from_skb()
> and all the helpers in net/sunrpc/xdr.c.

Hmm, we're getting into the realms of what flush_dcache_page() is supposed
to do and what it's not supposed to do.

Is this page an associated with a mapping (iow, page_mapping(page) is non-
NULL)?  If not, flush_dcache_page() won't do anything, and from my
understanding, its flush_anon_page() which you want to be using there
instead.

> The only new thing is the read access through the virtual address
> mapping. That mapping is created outside the loop in
> nfs_readdir_xdr_to_array(), which is why I'm thinking we do need the
> invalidate_kernel_vmap_range(): we're essentially doing a series of
> writes through the kernel direct mapping (i.e. readdir RPC calls), then
> reading the results through the virtual mapping.
> 
> i.e. we're doing
> 
> ptr = vm_map_ram(lowmem_pages);
> while (need_more_data) {
> 
> for (i = 0; i < npages; i++) {
> addr = kmap_atomic(lowmem_page[i]);
> *addr = rpc_stuff;
> flush_dcache_page(lowmem_page[i]);
> kunmap_atomic(lowmem_page[i]);
> }
> 
> invalidate_kernel_vmap_range(ptr); // Needed here?

Yes, you're going to need some cache maintainence in there to make it work,
because accessing 'ptr' will load that data into the cache, and that won't
be updated by the writes via kmap_atomic().

Provided you don't write to ptr, then using invalidate_kernel_vmap_range()
will be safe.
