Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38731 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbeCLK5B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2018 06:57:01 -0400
Received: by mail-qt0-f194.google.com with SMTP id n12so18227801qtl.5
        for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2018 03:57:00 -0700 (PDT)
Message-ID: <1520852218.4440.2.camel@redhat.com>
Subject: Re: [PATCH v2] SUNRPC: Initialize rpc_rqst outside of
 xprt->reserve_lock
From: Jeff Layton <jlayton@redhat.com>
To: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>,
        anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 12 Mar 2018 06:56:58 -0400
In-Reply-To: <0141adad-602c-70d0-08d6-e33b954cc163@talpey.com>
References: <20180311152620.16974.96109.stgit@manet.1015granger.net>
         <0141adad-602c-70d0-08d6-e33b954cc163@talpey.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is opaque. But, it's helpful to treat it as if it has endianness, if
only to make logfiles, traces and such look consistent when (e.g.) the
client and server are different endianness.

-- Jeff

On Sun, 2018-03-11 at 17:41 -0700, Tom Talpey wrote:
>  > +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
> 
> Why is the type a be32? The XID is opaque, tested only for equality, and
> no byte order is defined by the RPC protocol.
> 
> Methinks it should be u32.
> 
> Tom.
> 
> On 3/11/2018 8:27 AM, Chuck Lever wrote:
> > alloc_slot is a transport-specific op, but initializing an rpc_rqst
> > is common to all transports. In addition, the only part of initial-
> > izing an rpc_rqst that needs serialization is getting a fresh XID.
> > 
> > Move rpc_rqst initialization to common code in preparation for
> > adding a transport-specific alloc_slot to xprtrdma.
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> >   include/linux/sunrpc/xprt.h |    1 +
> >   net/sunrpc/clnt.c           |    1 +
> >   net/sunrpc/xprt.c           |   12 +++++++-----
> >   3 files changed, 9 insertions(+), 5 deletions(-)
> > 
> > Changes since v1:
> > - Partial sends should not bump the XID
> > 
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 5fea0fb..9784e28 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -324,6 +324,7 @@ struct xprt_class {
> >   struct rpc_xprt		*xprt_create_transport(struct xprt_create *args);
> >   void			xprt_connect(struct rpc_task *task);
> >   void			xprt_reserve(struct rpc_task *task);
> > +void			xprt_request_init(struct rpc_task *task);
> >   void			xprt_retry_reserve(struct rpc_task *task);
> >   int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
> >   int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index 6e432ec..226f558 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1546,6 +1546,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
> >   	task->tk_status = 0;
> >   	if (status >= 0) {
> >   		if (task->tk_rqstp) {
> > +			xprt_request_init(task);
> >   			task->tk_action = call_refresh;
> >   			return;
> >   		}
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index 70f0050..2d95926 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -66,7 +66,7 @@
> >    * Local functions
> >    */
> >   static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
> > -static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
> > +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
> >   static void	xprt_connect_status(struct rpc_task *task);
> >   static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
> >   static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
> > @@ -987,6 +987,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
> >   		task->tk_status = -EAGAIN;
> >   		goto out_unlock;
> >   	}
> > +	if (!bc_prealloc(req) && !req->rq_xmit_bytes_sent)
> > +		req->rq_xid = xprt_alloc_xid(xprt);
> >   	ret = true;
> >   out_unlock:
> >   	spin_unlock_bh(&xprt->transport_lock);
> > @@ -1163,10 +1165,10 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
> >   out_init_req:
> >   	xprt->stat.max_slots = max_t(unsigned int, xprt->stat.max_slots,
> >   				     xprt->num_reqs);
> > +	spin_unlock(&xprt->reserve_lock);
> > +
> >   	task->tk_status = 0;
> >   	task->tk_rqstp = req;
> > -	xprt_request_init(task, xprt);
> > -	spin_unlock(&xprt->reserve_lock);
> >   }
> >   EXPORT_SYMBOL_GPL(xprt_alloc_slot);
> >   
> > @@ -1303,8 +1305,9 @@ static inline void xprt_init_xid(struct rpc_xprt *xprt)
> >   	xprt->xid = prandom_u32();
> >   }
> >   
> > -static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
> > +void xprt_request_init(struct rpc_task *task)
> >   {
> > +	struct rpc_xprt *xprt = task->tk_xprt;
> >   	struct rpc_rqst	*req = task->tk_rqstp;
> >   
> >   	INIT_LIST_HEAD(&req->rq_list);
> > @@ -1312,7 +1315,6 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
> >   	req->rq_task	= task;
> >   	req->rq_xprt    = xprt;
> >   	req->rq_buffer  = NULL;
> > -	req->rq_xid     = xprt_alloc_xid(xprt);
> >   	req->rq_connect_cookie = xprt->connect_cookie - 1;
> >   	req->rq_bytes_sent = 0;
> >   	req->rq_snd_buf.len = 0;
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@redhat.com>
