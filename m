Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15701 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748Ab0HRUKO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:10:14 -0400
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <20100818193440.GZ5854@think>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
	 <20100818193440.GZ5854@think>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 16:10:10 -0400
Message-ID: <1282162210.8540.100.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-18 at 15:34 -0400, Chris Mason wrote:
> On Wed, Aug 18, 2010 at 03:04:01PM -0400, Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Allowing kswapd to do GFP_KERNEL memory allocations (or any blocking memory
> > allocations) is wrong and can cause deadlocks in try_to_release_page(), as
> > the filesystem believes it is safe to allocate new memory and block,
> > whereas kswapd is there specifically to clear a low-memory situation...
> > 
> > Set the gfp_mask to GFP_IOFS instead.
> 
> I always thought releasepage was supposed to do almost zero work.  It
> could release an instantly freeable page but it wasn't supposed to dive
> in and solve world hunger or anything.
> 
> I thought the VM would be using writepage for that.

writepage isn't sufficient for the NFS case: the page may be in the
'clean but unstable' state, in which case the NFS client needs to send a
COMMIT rpc call before the page can finally be released.

That is why we need the gfp_flag to tell us when it is safe to do this,
and when it is not.
The main case where it is safe and necessary for try_to_release_page()
to initiate a COMMIT call is in the invalidate_inode_pages2(). We might
want to do it in the kswapd case too, but in that case, we definitely
should tell the filesystem that it is unsafe to block.

Trond
