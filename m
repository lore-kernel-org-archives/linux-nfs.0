From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: replace large table of slots with mempool
Date: Fri, 30 Oct 2009 15:53:17 -0400
Message-ID: <1256932398.15679.0.camel@heimdal.trondhjem.org>
References: <19178.32618.958277.726234@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin Wilck <martin.wilck@ts.fujitsu.com>,
	linux-nfs@vger.kernel.org, Chuck Lever <Chuck.Lever@oracle.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757130AbZJ3TxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Oct 2009 15:53:15 -0400
In-Reply-To: <19178.32618.958277.726234-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-10-30 at 16:53 +1100, Neil Brown wrote:
> From: Martin Wilck <martin.wilck@ts.fujitsu.com>
> Date: Fri, 30 Oct 2009 16:35:19 +1100
> 
> If {udp,tcp}_slot_table_entries exceeds 111 (on x86-64),
> the allocated slot table exceeds 32K and so requires an
> order-4 allocation.
> As 4 exceeds PAGE_ALLOC_COSTLY_ORDER (==3), these are more
> likely to fail, so the chance of a mount failing due to low or
> fragmented memory goes up significantly.
> 
> This is particularly a problem for autofs which can try a mount
> at any time and does not retry in the face of failure.
> 
> There is no really need for the slots to be allocated in a single
> slab of memory.  Using a kmemcache, particularly when fronted by
> a mempool to allow allocation to usually succeed in atomic context,
> avoid the need for a large allocation, and also reduces memory waste
> in cases where not all of the slots are required.
> 
> This patch replaces the single  kmalloc per client with a mempool
> shared among all clients.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
> The only thing that I'm not completely confident about in this patch
> is 
>    #define RPC_RQST_POOLSIZE	(128)
> simply because it is an arbitrary number.  This allocations will only
> come from this pool when a GFP_ATOMIC alloc fails, so memory has to 
> be tight.  Allowing a further 128 requests which might serve to
> free up memory is probably enough.
> 
> If/when the swap-over-nfs gets upstream it will need to handle this
> memory pool as well ofcourse.

How about getting rid of the memory pool, then doing a mixture of what
we have now supplemented with dynamic allocation?

IOW: preallocate, say, 4 slots per xprt_sock and then the rest via
kmalloc().
We might also consider freeing up the preallocated slots too when the
socket gets closed due to the inactivity timer kicking in...

Once we have dynamically allocated slots, we might also want to get rid
of the 128 slot limit on /proc/sys/sunrpc/tcp_slot_table_entries. I've
been hearing complaints from people with large memory + 10GigE
systems...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
