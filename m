From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Fri, 18 May 2007 17:17:59 -0400
Message-ID: <1179523079.6488.156.camel@heimdal.trondhjem.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<1179515255.6488.136.camel@heimdal.trondhjem.org>
	<1179518863.23385.195.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp9pt-0005xU-GP
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 14:18:05 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/RVSujf6bDVWFin6nI2Q25SHVWDI9gwKQ=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp9pv-0000q6-I9
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 14:18:08 -0700
In-Reply-To: <1179518863.23385.195.camel@trinity.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 15:07 -0500, Tom Tucker wrote:
> On Fri, 2007-05-18 at 15:07 -0400, Trond Myklebust wrote:
> [...snip...]
> > +		     xprt->sc_ctxt_max);
> > > +
> > > +	spin_lock_irqsave(&xprt->sc_ctxt_lock, flags);
> > 
> > Why do you need an irqsafe spinlock to protect this list?
> > 
> 
> The svc_rdma_put_context function is called from interrupt context. This
> function adds free contexts back to this list.

Why not move the calls to rq_cq_reap() and sq_cq_reap() into the
tasklet? That way you can get away with only a bh-safe lock instead of
having to shut down interrupts again.

> > > +	while (xprt->sc_ctxt_cnt < target) {
> > > +		xprt->sc_ctxt_cnt ++;
> > > +		spin_unlock_irqrestore(&xprt->sc_ctxt_lock, flags);
> > > +
> > > +		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
> > > +
> > > +		spin_lock_irqsave(&xprt->sc_ctxt_lock, flags);
> > 
> > You've now dropped the spinlock. How can you know that the condition
> > xprt->sc_ctxt_cnt <= target is still valid?
> > 
> 
> I increment the sc_ctxt_cnt with the lock held. If I'm at the limit, the
> competing thread will find it equal -- correct? 

Fair enough.

> > > +		if (ctxt) {
> > > +			at_least_one = 1;
> > > +			ctxt->next = xprt->sc_ctxt_head;
> > > +			xprt->sc_ctxt_head = ctxt;
> > > +		} else {
> > > +			/* kmalloc failed...give up for now */
> > > +			xprt->sc_ctxt_cnt --;
> > > +			break;
> > > +		}
> > > +	}
> > > +	spin_unlock_irqrestore(&xprt->sc_ctxt_lock, flags);
> > > +
> > > +	return at_least_one;
> > > +}
> > > +
> > > +struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
> > > +{
> > > +	struct svc_rdma_op_ctxt *ctxt;
> > > +	unsigned long flags;
> > > +
> > > +	while (1) {
> > > +		spin_lock_irqsave(&xprt->sc_ctxt_lock, flags);
> > > +		if (unlikely(xprt->sc_ctxt_head == NULL)) {
> > > +			/* Try to bump my cache. */
> > > +			spin_unlock_irqrestore(&xprt->sc_ctxt_lock, flags);
> > > +
> > > +			if (rdma_bump_context_cache(xprt))
> > > +				continue;
> > > +
> > > +			printk(KERN_INFO "svcrdma: sleeping waiting for context "
> > > +			       "memory on xprt=%p\n",
> > > +			       xprt);
> > > +			schedule_timeout_uninterruptible(msecs_to_jiffies(500));
> > 
> > 							   (HZ >> 1)
> > However this is rather naughty: you are tying up an nfsd thread that
> > could be put to doing useful work elsewhere.
> > 
> 
> True, it could be processing requests for another client.
> 
> Here was my dilemma. I can actually predict what the worst case number
> is so that I'm guaranteed not to fail. The problem is that this is a
> very big number and I wanted to have a footprint driven by load as
> opposed to worst-case. This led to the code above. 
> 
> As an intermediate approach, I believe that I need about 4 contexts to
> be guaranteed I can process a request. I could attempt to acquire them
> all (at the top of svc_rdma_recvfrom) and cache them in the rqstp
> structure. If I couldn't get them, I would just return 0 (EAGAIN). This
> would be marginally wasteful on a given request, but would avoid ever
> sleeping for a context.
> 
> Comments?

How about just keeping a fixed size pool, and deferring handling more
RDMA requests until you have enough free contexts in your pool to
guarantee that you can complete the request? That would be analogous to
the way the existing RPC server socket code handles the issue of socket
send buffers.

> > > +			continue;
> > > +		}
> > > +		ctxt = xprt->sc_ctxt_head;
> > > +		xprt->sc_ctxt_head = ctxt->next;
> > > +		spin_unlock_irqrestore(&xprt->sc_ctxt_lock, flags);
> > > +		ctxt->xprt = xprt;
> > > +		INIT_LIST_HEAD(&ctxt->dto_q);
> > > +		break;
> > > +	}
> > > +	ctxt->count = 0;
> > > +	return ctxt;
> > > +}

<snip>

> > > +
> > > +struct page *svc_rdma_get_page(void)
> > > +{
> > > +	struct page *page;
> > > +
> > > +	while ((page = alloc_page(GFP_KERNEL))==NULL) {
> > > +		/* If we can't get memory, wait a bit and try again */
> > > +		printk(KERN_INFO "svcrdma: out of memory...retrying in 1000 jiffies.\n");
> > > +		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
> > 							HZ
> > See comment above about tying up threads. Also note that you are
> > probably better off using __GFP_NOFAIL instead of the loop.
> > 
> 
> I thought that the __GFP_NOFAIL pool was a precious resource and that a
> memory out condition was one of the places you'd actually want to sleep.
> I basically copied this approach from the svc_recv implementation in
> svcsock.c

AFAIK, __GFP_NOFAIL just means keep retrying until the allocation
succeeds. It is not tied to a specific resource.




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
