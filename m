Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50174 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751597AbeCNUun (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Mar 2018 16:50:43 -0400
Date: Wed, 14 Mar 2018 16:50:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 09/15] sunrpc: Report per-RPC execution stats
Message-ID: <20180314205042.GB7241@fieldses.org>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154427.21531.85993.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180313154427.21531.85993.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2018 at 11:44:27AM -0400, Chuck Lever wrote:
> Introduce a mechanism to report the server-side execution latency of
> each RPC. The goal is to enable user space to filter the trace
> record for latency outliers, build histograms, etc.

Neato.

To be useful I'd think you'd want more information about each RPC.
(E.g. you'd like to know that the latency outliers all did reads).  I
guess you could use the address and xid to cross-reference with
information collected from somewhere else?

What's our commitment to backwards compatibility?  Trace points seem to
be the wild west compared to the rest of the kernel interface, but if
we want to encourage tooling on top of this then I guess we'll need to
be strict.

Looking at the tcp case, I think it's measuring from the time
tcp_recvfrom receives the last fragment making up an rpc request till
the last sendpage() of the reply returns.  Did you consider other spots?
(E.g. why after the send instead of before?)

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/svc.h               |    1 +
>  include/linux/sunrpc/svc_rdma.h          |    1 +
>  include/trace/events/sunrpc.h            |   20 ++++++++++++++++++++
>  net/sunrpc/svc_xprt.c                    |    2 +-
>  net/sunrpc/svcsock.c                     |    2 ++
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>  7 files changed, 27 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 786ae22..1939709 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -245,6 +245,7 @@ struct svc_rqst {
>  	void *			rq_xprt_ctxt;	/* transport specific context ptr */
>  	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
>  
> +	ktime_t			rq_rtime;	/* receive time */
>  	size_t			rq_xprt_hlen;	/* xprt header len */
>  	struct xdr_buf		rq_arg;
>  	struct xdr_buf		rq_res;
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 4b731b0..8045981 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -79,6 +79,7 @@ struct svc_rdma_op_ctxt {
>  	struct list_head list;
>  	struct xdr_buf arg;
>  	struct ib_cqe cqe;
> +	ktime_t rtime;
>  	u32 byte_len;
>  	struct svcxprt_rdma *xprt;
>  	enum dma_data_direction direction;
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index 5a8157c..50de512 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -705,6 +705,26 @@
>  		__entry->len, show_svc_xprt_flags(__entry->flags))
>  );
>  
> +TRACE_EVENT(svc_stats_latency,
> +	TP_PROTO(const struct svc_rqst *rqst, ktime_t end),
> +
> +	TP_ARGS(rqst, end),
> +
> +	TP_STRUCT__entry(
> +		__field(u32, xid)
> +		__field(unsigned long, execute)
> +		__string(addr, rqst->rq_xprt->xpt_remotebuf)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->xid = be32_to_cpu(rqst->rq_xid);
> +		__entry->execute = ktime_to_us(ktime_sub(end, rqst->rq_rtime));
> +		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
> +	),
> +
> +	TP_printk("addr=%s xid=0x%08x execute=%lu",
> +		__get_str(addr), __entry->xid, __entry->execute)
> +);
>  
>  DECLARE_EVENT_CLASS(svc_deferred_event,
>  	TP_PROTO(struct svc_deferred_req *dr),
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index f745754..2556e6e 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -782,7 +782,6 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  			len = svc_deferred_recv(rqstp);
>  		else
>  			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
> -		dprintk("svc: got len=%d\n", len);
>  		rqstp->rq_reserved = serv->sv_max_mesg;
>  		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  	}
> @@ -893,6 +892,7 @@ int svc_send(struct svc_rqst *rqstp)
>  		len = -ENOTCONN;
>  	else
>  		len = xprt->xpt_ops->xpo_sendto(rqstp);
> +	trace_svc_stats_latency(rqstp, ktime_get_real());
>  	mutex_unlock(&xprt->xpt_mutex);
>  	rpc_wake_up(&xprt->xpt_bc_pending);
>  	trace_svc_send(rqstp, len);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 4ca1d92..f616962 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -574,6 +574,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>  		/* Don't enable netstamp, sunrpc doesn't
>  		   need that much accuracy */
>  	}
> +	rqstp->rq_rtime = skb->tstamp;
>  	svsk->sk_sk->sk_stamp = skb->tstamp;
>  	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
>  
> @@ -1143,6 +1144,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	if (len < 0)
>  		goto error;
>  
> +	rqstp->rq_rtime = ktime_get_real();
>  	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpcnt++;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 19e9c6b..446b9d6 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -558,6 +558,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>  		goto out_readchunk;
>  
>  complete:
> +	rqstp->rq_rtime = ctxt->rtime;
>  	svc_rdma_put_context(ctxt, 0);
>  	dprintk("svcrdma: recvfrom: xprt=%p, rqstp=%p, rq_arg.len=%u\n",
>  		rdma_xprt, rqstp, rqstp->rq_arg.len);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index ca211dc..08fa7de 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -316,6 +316,7 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
>  		goto flushed;
>  
>  	/* All wc fields are now known to be valid */
> +	ctxt->rtime = ktime_get_real();
>  	ctxt->byte_len = wc->byte_len;
>  	spin_lock(&xprt->sc_rq_dto_lock);
>  	list_add_tail(&ctxt->list, &xprt->sc_rq_dto_q);
