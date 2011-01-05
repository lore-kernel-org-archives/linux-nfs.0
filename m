Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5844 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231Ab1AEP3r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 10:29:47 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
In-Reply-To: <1294240457.3014.13.camel@heimdal.trondhjem.org>
References: <20101230171453.GA5787@pengutronix.de>
	 <1293731992.4919.5.camel@heimdal.trondhjem.org>
	 <20101230191846.GB14221@pengutronix.de>
	 <20110103213850.GC25121@pengutronix.de>
	 <1294100558.25100.8.camel@heimdal.trondhjem.org>
	 <20110105084014.GN25121@pengutronix.de>
	 <20110105110517.GQ25121@pengutronix.de>
	 <20110105112701.GA8638@n2100.arm.linux.org.uk>
	 <20110105134045.GS25121@pengutronix.de>
	 <1294239193.3014.9.camel@heimdal.trondhjem.org>
	 <4D2487CA.5040501@pengutronix.de>
	 <1294240457.3014.13.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 10:29:29 -0500
Message-ID: <1294241369.3014.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 10:14 -0500, Trond Myklebust wrote: 
> OK. So,the new behaviour in 2.6.37 is that we're writing to a series of
> pages via the usual kmap_atomic()/kunmap_atomic() and kmap()/kunmap()
> interfaces, but we can end up reading them via a virtual address range
> that gets set up via vm_map_ram() (that range gets set up before the
> write occurs).
> 
> Do we perhaps need an invalidate_kernel_vmap_range() before we can read
> the data on ARM in this kind of scenario?

IOW: Does something like the following patch fix the problem?

------------------------------------------------------------------------------- 
From: Trond Myklebust <Trond.Myklebust@netapp.com>
NFS: Ensure we clean the TLB cache in nfs_readdir_xdr_to_array
    
After calling nfs_readdir_xdr_filler(), we need a call to
invalidate_kernel_vmap_range() before we can proceed to read
the data back through the virtual address range.
    
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 996dd89..4640470 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -587,6 +587,9 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		if (status < 0)
 			break;
 		pglen = status;
+
+		invalidate_kernel_vmap_range(pages_ptr, pglen);
+
 		status = nfs_readdir_page_filler(desc, &entry, pages_ptr, page, pglen);
 		if (status < 0) {
 			if (status == -ENOSPC)


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

