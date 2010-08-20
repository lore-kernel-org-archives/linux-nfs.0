Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab0HTMSH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2010 08:18:07 -0400
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ram Pai <ram.n.pai@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <20100820054533.GB11847@localhost>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
	 <AANLkTi=WkoxjwZbt6Vd0VhbuA7_k2WM-NUXZnrmzOOPy@mail.gmail.com>
	 <1282159872.8540.96.camel@heimdal.trondhjem.org>
	 <20100820054533.GB11847@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 20 Aug 2010 08:17:08 -0400
Message-ID: <1282306628.3927.0.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-08-20 at 13:45 +0800, Wu Fengguang wrote:
> > Hi Ram,
> > 
> > I was seeing it on NFS until I put in the following kswapd-specific hack
> > into nfs_release_page():
> > 
> > 	/* Only do I/O if gfp is a superset of GFP_KERNEL */
> > 	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
> > 		int how = FLUSH_SYNC;
> > 
> > 		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> > 		if (current_is_kswapd())
> > 			how = 0;
> 
> So the patch can remove the above workaround together, and add comment
> that NFS exploits the gfp mask to avoid complex operations involving
> recursive memory allocation and hence deadlock?

I thought I'd send that as a separate patch, but yes, that is my
intention next.

Cheers
  Trond
