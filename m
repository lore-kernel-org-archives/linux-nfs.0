From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcrdma: Fix race between svc_rdma_recvfrom thread and
	the dto_tasklet
Date: Mon, 27 Jul 2009 17:35:40 -0400
Message-ID: <20090727213540.GB4718@fieldses.org>
References: <1218579184-46881-1-git-send-email-tom@opengridcomputing.com> <20090727213355.GA4718@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39376 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755092AbZG0Vfk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jul 2009 17:35:40 -0400
In-Reply-To: <20090727213355.GA4718@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 27, 2009 at 05:33:55PM -0400, bfields wrote:
> On Tue, Aug 12, 2008 at 05:13:04PM -0500, Tom Tucker wrote:
> > RDMA_READ completions are kept on a separate queue from the general
> > I/O request queue. Since a separate lock is used to protect the RDMA_READ
> > completion queue, a race exists between the dto_tasklet and the
> > svc_rdma_recvfrom thread where the dto_tasklet sets the XPT_DATA
> > bit and adds I/O to the read-completion queue. Concurrently, the
> > recvfrom thread checks the generic queue, finds it empty and resets
> > the XPT_DATA bit. A subsequent svc_xprt_enqueue will fail to enqueue
> > the transport for I/O and cause the transport to "stall".
> > 
> > The fix is to protect both lists with the same lock and set the XPT_DATA
> > bit with this lock held.
> 
> Thanks.  Assuming this race has existed from the start (so it's not a
> recent regression), and the consequences are no worse than a stall, I'm
> inclined to queue this up for 2.6.32--but if I'm wrong about either of
> those, we could try for 2.6.31 and/or stable.

Erp, cripes, sorry--only just noticed all this mail seems to have been
delayed a year!  OK....--b.

> 
> --b.
> 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > 
> > ---
> >  include/linux/sunrpc/svc_rdma.h          |    1 -
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    8 ++++----
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 ++---
> >  3 files changed, 6 insertions(+), 8 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> > index ef2e3a2..dc05b54 100644
> > --- a/include/linux/sunrpc/svc_rdma.h
> > +++ b/include/linux/sunrpc/svc_rdma.h
> > @@ -143,7 +143,6 @@ struct svcxprt_rdma {
> >  	unsigned long	     sc_flags;
> >  	struct list_head     sc_dto_q;		/* DTO tasklet I/O pending Q */
> >  	struct list_head     sc_read_complete_q;
> > -	spinlock_t           sc_read_complete_lock;
> >  	struct work_struct   sc_work;
> >  };
> >  /* sc_flags */
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > index b4b17f4..74de31a 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > @@ -443,18 +443,18 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
> >  
> >  	dprintk("svcrdma: rqstp=%p\n", rqstp);
> >  
> > -	spin_lock_bh(&rdma_xprt->sc_read_complete_lock);
> > +	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
> >  	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
> >  		ctxt = list_entry(rdma_xprt->sc_read_complete_q.next,
> >  				  struct svc_rdma_op_ctxt,
> >  				  dto_q);
> >  		list_del_init(&ctxt->dto_q);
> >  	}
> > -	spin_unlock_bh(&rdma_xprt->sc_read_complete_lock);
> > -	if (ctxt)
> > +	if (ctxt) {
> > +		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
> >  		return rdma_read_complete(rqstp, ctxt);
> > +	}
> >  
> > -	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
> >  	if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
> >  		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
> >  				  struct svc_rdma_op_ctxt,
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > index 19ddc38..900cb69 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > @@ -359,11 +359,11 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
> >  			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
> >  				struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
> >  				BUG_ON(!read_hdr);
> > +				spin_lock_bh(&xprt->sc_rq_dto_lock);
> >  				set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
> > -				spin_lock_bh(&xprt->sc_read_complete_lock);
> >  				list_add_tail(&read_hdr->dto_q,
> >  					      &xprt->sc_read_complete_q);
> > -				spin_unlock_bh(&xprt->sc_read_complete_lock);
> > +				spin_unlock_bh(&xprt->sc_rq_dto_lock);
> >  				svc_xprt_enqueue(&xprt->sc_xprt);
> >  			}
> >  			svc_rdma_put_context(ctxt, 0);
> > @@ -428,7 +428,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
> >  	init_waitqueue_head(&cma_xprt->sc_send_wait);
> >  
> >  	spin_lock_init(&cma_xprt->sc_lock);
> > -	spin_lock_init(&cma_xprt->sc_read_complete_lock);
> >  	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
> >  
> >  	cma_xprt->sc_ord = svcrdma_ord;
