Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31470 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167Ab1EDApH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 20:45:07 -0400
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
In-Reply-To: <20110503202023.699435f4@corrin.poochiereds.net>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	 <1304386808-2733-2-git-send-email-andros@netapp.com>
	 <20110503202023.699435f4@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 May 2011 20:44:50 -0400
Message-ID: <1304469890.26184.16.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-05-03 at 20:20 -0400, Jeff Layton wrote:
> On Mon,  2 May 2011 21:40:08 -0400
> andros@netapp.com wrote:
> 
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Hookup TCP congestion feedback into rpc_slot allocation so that the RPC layer
> > can fully utilize the negotiated TCP window.
> > 
> > Use a slab cache for rpc_slots. Statically allocate an rpc_xprt rpc_slot slab
> > cache using GFP_KERNEL to the RPC_DEF_SLOT_TABLE number of slots at
> > rpc_xprt allocation.
> > 
> > Add a dynamic rpc slot allocator to rpc_xprt_ops which is set only for TCP.
> > For TCP, trigger a dyamic slot allocation in response to a write_space
> > callback which is in turn called when the TCP layer is waiting for buffer space.
> > 
> > Dynamically add a slot at the beginning of the RPC call_transmit state. The slot
> > allocator uses GFP_NOWAIT and will return without allocating a slot if
> > GFP_NOWAIT allocation fails. This is OK because the write_space callback will
> > be called again, and the dynamic slot allocator can retry.
> > 
> > Signed-off-by: Andy Adamson <andros@netap.com>
> > ---
> >  include/linux/sunrpc/sched.h |    2 +
> >  include/linux/sunrpc/xprt.h  |    6 +++-
> >  net/sunrpc/clnt.c            |    4 ++
> >  net/sunrpc/sched.c           |   39 ++++++++++++++++++++++
> >  net/sunrpc/xprt.c            |   75 +++++++++++++++++++++++++++++++++++++-----
> >  net/sunrpc/xprtsock.c        |    1 +
> >  6 files changed, 117 insertions(+), 10 deletions(-)
> > 
> 
> Nice work, comments inline below...
> 
> 
> [...]
> 
> > +
> > +/*
> > + * Static transport rpc_slot allocation called only at rpc_xprt allocation.
> > + * No need to take the xprt->reserve_lock.
> > + */
> > +int
> > +xprt_alloc_slot_entries(struct rpc_xprt *xprt, int num_req)
> > +{
> > +	struct rpc_rqst *req;
> > +	int i;
> > +
> > +	for (i = 0; i < num_req; i++) {
> > +		req = rpc_alloc_slot(GFP_KERNEL);
> > +		if (!req)
> > +			return -ENOMEM;
> > +		memset(req, 0, sizeof(*req));
> > +		list_add(&req->rq_list, &xprt->free);
> > +	}
> > +	dprintk("<-- %s mempool_alloc %d reqs\n", __func__,
> > +		xprt->max_reqs);
> > +	return 0;
> > +}
> > +
> 
> So, I don't quite get this...
> 
> You declare a global mempool early on, and then allocate from that
> mempool for a list of static entries. Doesn't that sort of rob you of
> any benefit of using a mempool here? IOW, won't the static allocations
> potentially rob the mempool of "guaranteed" entries such that the
> dynamic ones eventually all turn into slab allocations anyway?

The other thing is that we really should _never_ be using GFP_KERNEL
allocations in any paths that might be used for writebacks, since that
might recurse back into the filesystem due to direct memory reclaims. In
fact, since this code path will commonly be used by rpciod, then we
should rather be using GFP_ATOMIC and/or GFP_NOWAIT (see rpc_malloc).

> What I think would make more sense would be to have multiple mempools
> -- one per xprt and simply set the mempool size to the number of
> "static" entries that you want for the mempool. Then you could get rid
> of the free list, and just do allocations out of the mempool directly.
> You'll be guaranteed to be able to allocate up to the number in the
> mempool and everything above that would just becomes a slab allocation.

I'm not sure that we need multiple mempools: all we really require is
that memory reclaims to be able to make some form of progress.
I'd therefore rather advocate a global mempool (which matches our policy
on the rpc buffer pool), but that we allow the allocations to fail if
we're really low on memory.

The problem with multiple mempools is that if there is no activity on
one of those filesystems, then we're basically locking up memory for no
good reason.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

