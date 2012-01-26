Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab2AZNJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 08:09:29 -0500
Date: Thu, 26 Jan 2012 15:11:36 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 6/6] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Message-ID: <20120126131136.GA16400@redhat.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
 <1327494434-21566-6-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327494434-21566-6-git-send-email-ian.campbell@citrix.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 12:27:14PM +0000, Ian Campbell wrote:
> This prevents an issue where an ACK is delayed, a retransmit is queued (either
> at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> wire. If this happens to an NFS WRITE RPC then the write() system call
> completes and the userspace process can continue, potentially modifying data
> referenced by the retransmission before the retransmission occurs.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Neil Brown <neilb@suse.de>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> Cc: netdev@vger.kernel.org

This doesn't include either of the two options you proposed to address
the sender blocked forever by receiver issue with bridged septups and
endpoints such a tap device or a socket on the same box,
does it?

I mean this discussion:
http://article.gmane.org/gmane.linux.nfs/44846/match=use+skb+fragment+destructors

It would be nice to have this addressed in some way.

How about patching __skb_queue_tail to do a deep copy?
That would seem to handle both tap and socket cases -
any other ones left?

If we do this, I think it would be beneficial to pass a flag
to the destructor indicating that a deep copy was done:
this would allow senders to detect that and adapt.


> ---
>  include/linux/sunrpc/xdr.h  |    2 ++
>  include/linux/sunrpc/xprt.h |    5 ++++-
>  net/sunrpc/clnt.c           |   27 ++++++++++++++++++++++-----
>  net/sunrpc/svcsock.c        |    3 ++-
>  net/sunrpc/xprt.c           |   12 ++++++++++++
>  net/sunrpc/xprtsock.c       |    3 ++-
>  6 files changed, 44 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index a20970e..172f81e 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -16,6 +16,7 @@
>  #include <asm/byteorder.h>
>  #include <asm/unaligned.h>
>  #include <linux/scatterlist.h>
> +#include <linux/skbuff.h>
>  
>  /*
>   * Buffer adjustment
> @@ -57,6 +58,7 @@ struct xdr_buf {
>  			tail[1];	/* Appended after page data */
>  
>  	struct page **	pages;		/* Array of contiguous pages */
> +	struct skb_frag_destructor *destructor;
>  	unsigned int	page_base,	/* Start of page data */
>  			page_len,	/* Length of page data */
>  			flags;		/* Flags for data disposition */
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 15518a1..75131eb 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -92,7 +92,10 @@ struct rpc_rqst {
>  						/* A cookie used to track the
>  						   state of the transport
>  						   connection */
> -	
> +	struct skb_frag_destructor destructor;	/* SKB paged fragment
> +						 * destructor for
> +						 * transmitted pages*/
> +
>  	/*
>  	 * Partial send handling
>  	 */
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index f0268ea..06f363f 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -61,6 +61,7 @@ static void	call_reserve(struct rpc_task *task);
>  static void	call_reserveresult(struct rpc_task *task);
>  static void	call_allocate(struct rpc_task *task);
>  static void	call_decode(struct rpc_task *task);
> +static void	call_complete(struct rpc_task *task);
>  static void	call_bind(struct rpc_task *task);
>  static void	call_bind_status(struct rpc_task *task);
>  static void	call_transmit(struct rpc_task *task);
> @@ -1115,6 +1116,8 @@ rpc_xdr_encode(struct rpc_task *task)
>  			 (char *)req->rq_buffer + req->rq_callsize,
>  			 req->rq_rcvsize);
>  
> +	req->rq_snd_buf.destructor = &req->destructor;
> +
>  	p = rpc_encode_header(task);
>  	if (p == NULL) {
>  		printk(KERN_INFO "RPC: couldn't encode RPC header, exit EIO\n");
> @@ -1278,6 +1281,7 @@ call_connect_status(struct rpc_task *task)
>  static void
>  call_transmit(struct rpc_task *task)
>  {
> +	struct rpc_rqst *req = task->tk_rqstp;
>  	dprint_status(task);
>  
>  	task->tk_action = call_status;
> @@ -1311,8 +1315,8 @@ call_transmit(struct rpc_task *task)
>  	call_transmit_status(task);
>  	if (rpc_reply_expected(task))
>  		return;
> -	task->tk_action = rpc_exit_task;
> -	rpc_wake_up_queued_task(&task->tk_xprt->pending, task);
> +	task->tk_action = call_complete;
> +	skb_frag_destructor_unref(&req->destructor);
>  }
>  
>  /*
> @@ -1385,7 +1389,8 @@ call_bc_transmit(struct rpc_task *task)
>  		return;
>  	}
>  
> -	task->tk_action = rpc_exit_task;
> +	task->tk_action = call_complete;
> +	skb_frag_destructor_unref(&req->destructor);
>  	if (task->tk_status < 0) {
>  		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
>  			"error: %d\n", task->tk_status);
> @@ -1425,7 +1430,6 @@ call_bc_transmit(struct rpc_task *task)
>  			"error: %d\n", task->tk_status);
>  		break;
>  	}
> -	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
>  }
>  #endif /* CONFIG_SUNRPC_BACKCHANNEL */
>  
> @@ -1591,12 +1595,14 @@ call_decode(struct rpc_task *task)
>  		return;
>  	}
>  
> -	task->tk_action = rpc_exit_task;
> +	task->tk_action = call_complete;
>  
>  	if (decode) {
>  		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
>  						      task->tk_msg.rpc_resp);
>  	}
> +	rpc_sleep_on(&req->rq_xprt->pending, task, NULL);
> +	skb_frag_destructor_unref(&req->destructor);
>  	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
>  			task->tk_status);
>  	return;
> @@ -1611,6 +1617,17 @@ out_retry:
>  	}
>  }
>  
> +/*
> + * 8.	Wait for pages to be released by the network stack.
> + */
> +static void
> +call_complete(struct rpc_task *task)
> +{
> +	dprintk("RPC: %5u call_complete result %d\n",
> +		task->tk_pid, task->tk_status);
> +	task->tk_action = rpc_exit_task;
> +}
> +
>  static __be32 *
>  rpc_encode_header(struct rpc_task *task)
>  {
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 0e6b919..aa7f108 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -198,7 +198,8 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
>  	while (pglen > 0) {
>  		if (slen == size)
>  			flags = 0;
> -		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
> +		result = kernel_sendpage(sock, *ppage, xdr->destructor,
> +					 base, size, flags);
>  		if (result > 0)
>  			len += result;
>  		if (result != size)
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index c64c0ef..2137eb6 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1101,6 +1101,16 @@ static inline void xprt_init_xid(struct rpc_xprt *xprt)
>  	xprt->xid = net_random();
>  }
>  
> +static int xprt_complete_skb_pages(struct skb_frag_destructor *destroy)
> +{
> +	struct rpc_rqst	*req =
> +		container_of(destroy, struct rpc_rqst, destructor);
> +
> +	dprintk("RPC: %5u completing skb pages\n", req->rq_task->tk_pid);
> +	rpc_wake_up_queued_task(&req->rq_xprt->pending, req->rq_task);

It seems that at the sunrpc module can get unloaded
at this point. The code for 'return 0' can then get
overwritten. Right?

Not sure how important making module unloading robust
is - if we wanted to fix this we'd need to move
the callback code into core (hopefully generalizing
it somewhat).

> +	return 0;
> +}
> +
>  static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
>  {
>  	struct rpc_rqst	*req = task->tk_rqstp;
> @@ -1113,6 +1123,8 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
>  	req->rq_xid     = xprt_alloc_xid(xprt);
>  	req->rq_release_snd_buf = NULL;
>  	xprt_reset_majortimeo(req);
> +	atomic_set(&req->destructor.ref, 1);
> +	req->destructor.destroy = &xprt_complete_skb_pages;
>  	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
>  			req, ntohl(req->rq_xid));
>  }
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 38b2fec..5406977 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -408,7 +408,8 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
>  		remainder -= len;
>  		if (remainder != 0 || more)
>  			flags |= MSG_MORE;
> -		err = sock->ops->sendpage(sock, *ppage, NULL, base, len, flags);
> +		err = sock->ops->sendpage(sock, *ppage, xdr->destructor,
> +					  base, len, flags);
>  		if (remainder == 0 || err != len)
>  			break;
>  		sent += err;
> -- 
> 1.7.2.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
