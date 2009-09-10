From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2 02/12] nfsd41: sunrpc: Added rpc server-side
 backchannel handling
Date: Thu, 10 Sep 2009 07:49:26 -0400
Message-ID: <1252583366.8722.121.camel@heimdal.trondhjem.org>
References: <4AA8C597.8080809@panasas.com>
	 <1252574717-30074-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Rahul Iyer <iyer@netapp.com>,
	Mike Sager <sager@netapp.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9126 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114AbZIJLt5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 07:49:57 -0400
In-Reply-To: <1252574717-30074-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-09-10 at 12:25 +0300, Benny Halevy wrote:
> From: Rahul Iyer <iyer@netapp.com>
> 
> When the call direction is a reply, copy the xid and call direction into the
> req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header returns
> rpc_garbage.
> 
> Signed-off-by: Rahul Iyer <iyer@netapp.com>
> Signed-off-by: Mike Sager <sager@netapp.com>
> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [get rid of CONFIG_NFSD_V4_1]
> [sunrpc: refactoring of svc_tcp_recvfrom]
> [nfsd41: sunrpc: create common send routine for the fore and the back channels]
> [nfsd41: sunrpc: Use free_page() to free server backchannel pages]
> [nfsd41: sunrpc: Document server backchannel locking]
> [nfsd41: sunrpc: remove bc_connect_worker()]
> [nfsd41: sunrpc: Define xprt_server_backchannel()[
> [nfsd41: sunrpc: remove bc_close and bc_init_auto_disconnect dummy functions]
> [nfsd41: sunrpc: eliminate unneeded switch statement in xs_setup_tcp()]
> [nfsd41: sunrpc: Don't auto close the server backchannel connection]
> [nfsd41: sunrpc: Remove unused functions]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: change bc_sock to bc_xprt]
> [nfsd41: sunrpc: move struct rpc_buffer def into a common header file]
> [nfsd41: sunrpc: use rpc_sleep in bc_send_request so not to block on mutex]
> [removed cosmetic changes]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [sunrpc: add new xprt class for nfsv4.1 backchannel]
> [sunrpc: v2.1 change handling of auto_close and init_auto_disconnect operations for the nfsv4.1 backchannel]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> [reverted more cosmetic leftovers]
> [got rid of xprt_server_backchannel]
> [separated "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel"]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Cc: Trond Myklebust <trond.myklebust@netapp.com>
> ---
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  include/linux/sunrpc/svcsock.h  |    1 +
>  include/linux/sunrpc/xprt.h     |    1 +
>  net/sunrpc/sunrpc.h             |    4 +
>  net/sunrpc/svc_xprt.c           |    2 +
>  net/sunrpc/svcsock.c            |  172 +++++++++++++++++++++++++++++++--------
>  net/sunrpc/xprt.c               |   15 +++-
>  net/sunrpc/xprtsock.c           |  146 +++++++++++++++++++++++++++++++++
>  8 files changed, 303 insertions(+), 39 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index 2223ae0..5f4e18b 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -65,6 +65,7 @@ struct svc_xprt {
>  	size_t			xpt_locallen;	/* length of address */
>  	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
>  	size_t			xpt_remotelen;	/* length of address */
> +	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
>  };
>  
>  int	svc_reg_xprt_class(struct svc_xprt_class *);
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 04dba23..1b353a7 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -28,6 +28,7 @@ struct svc_sock {
>  	/* private TCP part */
>  	u32			sk_reclen;	/* length of record */
>  	u32			sk_tcplen;	/* current read length */
> +	struct rpc_xprt		*sk_bc_xprt;	/* NFSv4.1 backchannel xprt */
>  };
>  
>  /*
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index c090df4..228d694 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -179,6 +179,7 @@ struct rpc_xprt {
>  	spinlock_t		reserve_lock;	/* lock slot table */
>  	u32			xid;		/* Next XID value to use */
>  	struct rpc_task *	snd_task;	/* Task blocked in send */
> +	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
>  #if defined(CONFIG_NFS_V4_1)
>  	struct svc_serv		*bc_serv;       /* The RPC service which will */
>  						/* process the callback */
> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
> index 13171e6..90c292e 100644
> --- a/net/sunrpc/sunrpc.h
> +++ b/net/sunrpc/sunrpc.h
> @@ -43,5 +43,9 @@ static inline int rpc_reply_expected(struct rpc_task *task)
>  		(task->tk_msg.rpc_proc->p_decode != NULL);
>  }
>  
> +int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
> +		    struct page *headpage, unsigned long headoffset,
> +		    struct page *tailpage, unsigned long tailoffset);
> +
>  #endif /* _NET_SUNRPC_SUNRPC_H */
>  
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 912dea5..df124f7 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -160,6 +160,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
>  	mutex_init(&xprt->xpt_mutex);
>  	spin_lock_init(&xprt->xpt_lock);
>  	set_bit(XPT_BUSY, &xprt->xpt_flags);
> +	rpc_init_wait_queue(&xprt->xpt_bc_pending, "xpt_bc_pending");
>  }
>  EXPORT_SYMBOL_GPL(svc_xprt_init);
>  
> @@ -810,6 +811,7 @@ int svc_send(struct svc_rqst *rqstp)
>  	else
>  		len = xprt->xpt_ops->xpo_sendto(rqstp);
>  	mutex_unlock(&xprt->xpt_mutex);
> +	rpc_wake_up(&xprt->xpt_bc_pending);
>  	svc_xprt_release(rqstp);
>  
>  	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 76a380d..ccc5e83 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -49,6 +49,7 @@
>  #include <linux/sunrpc/msg_prot.h>
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/stats.h>
> +#include <linux/sunrpc/xprt.h>
>  
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
> @@ -153,49 +154,27 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
>  }
>  
>  /*
> - * Generic sendto routine
> + * send routine intended to be shared by the fore- and back-channel
>   */
> -static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
> +int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
> +		    struct page *headpage, unsigned long headoffset,
> +		    struct page *tailpage, unsigned long tailoffset)
>  {
> -	struct svc_sock	*svsk =
> -		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> -	struct socket	*sock = svsk->sk_sock;
> -	int		slen;
> -	union {
> -		struct cmsghdr	hdr;
> -		long		all[SVC_PKTINFO_SPACE / sizeof(long)];
> -	} buffer;
> -	struct cmsghdr *cmh = &buffer.hdr;
> -	int		len = 0;
>  	int		result;
>  	int		size;
>  	struct page	**ppage = xdr->pages;
>  	size_t		base = xdr->page_base;
>  	unsigned int	pglen = xdr->page_len;
>  	unsigned int	flags = MSG_MORE;
> -	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> +	int		slen;
> +	int		len = 0;
>  
>  	slen = xdr->len;
>  
> -	if (rqstp->rq_prot == IPPROTO_UDP) {
> -		struct msghdr msg = {
> -			.msg_name	= &rqstp->rq_addr,
> -			.msg_namelen	= rqstp->rq_addrlen,
> -			.msg_control	= cmh,
> -			.msg_controllen	= sizeof(buffer),
> -			.msg_flags	= MSG_MORE,
> -		};
> -
> -		svc_set_cmsg_data(rqstp, cmh);
> -
> -		if (sock_sendmsg(sock, &msg, 0) < 0)
> -			goto out;
> -	}
> -
>  	/* send head */
>  	if (slen == xdr->head[0].iov_len)
>  		flags = 0;
> -	len = kernel_sendpage(sock, rqstp->rq_respages[0], 0,
> +	len = kernel_sendpage(sock, headpage, headoffset,
>  				  xdr->head[0].iov_len, flags);
>  	if (len != xdr->head[0].iov_len)
>  		goto out;
> @@ -219,16 +198,58 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
>  		base = 0;
>  		ppage++;
>  	}
> +
>  	/* send tail */
>  	if (xdr->tail[0].iov_len) {
> -		result = kernel_sendpage(sock, rqstp->rq_respages[0],
> -					     ((unsigned long)xdr->tail[0].iov_base)
> -						& (PAGE_SIZE-1),
> -					     xdr->tail[0].iov_len, 0);
> -
> +		result = kernel_sendpage(sock, tailpage, tailoffset,
> +				   xdr->tail[0].iov_len, 0);
>  		if (result > 0)
>  			len += result;
>  	}
> +
> +out:
> +	return len;
> +}
> +
> +
> +/*
> + * Generic sendto routine
> + */
> +static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
> +{
> +	struct svc_sock	*svsk =
> +		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> +	struct socket	*sock = svsk->sk_sock;
> +	union {
> +		struct cmsghdr	hdr;
> +		long		all[SVC_PKTINFO_SPACE / sizeof(long)];
> +	} buffer;
> +	struct cmsghdr *cmh = &buffer.hdr;
> +	int		len = 0;
> +	unsigned long tailoff;
> +	unsigned long headoff;
> +	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> +
> +	if (rqstp->rq_prot == IPPROTO_UDP) {
> +		struct msghdr msg = {
> +			.msg_name	= &rqstp->rq_addr,
> +			.msg_namelen	= rqstp->rq_addrlen,
> +			.msg_control	= cmh,
> +			.msg_controllen	= sizeof(buffer),
> +			.msg_flags	= MSG_MORE,
> +		};
> +
> +		svc_set_cmsg_data(rqstp, cmh);
> +
> +		if (sock_sendmsg(sock, &msg, 0) < 0)
> +			goto out;
> +	}
> +
> +	tailoff = ((unsigned long)xdr->tail[0].iov_base) & (PAGE_SIZE-1);
> +	headoff = 0;
> +	len = svc_send_common(sock, xdr, rqstp->rq_respages[0], headoff,
> +			       rqstp->rq_respages[0], tailoff);
> +
>  out:
>  	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
>  		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
> @@ -951,6 +972,57 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
>  	return -EAGAIN;
>  }
>  
> +static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
> +			       struct rpc_rqst **reqpp, struct kvec *vec)
> +{
> +	struct rpc_rqst *req = NULL;
> +	u32 *p;
> +	u32 xid;
> +	u32 calldir;
> +	int len;
> +
> +	len = svc_recvfrom(rqstp, vec, 1, 8);
> +	if (len < 0)
> +		goto error;
> +
> +	p = (u32 *)rqstp->rq_arg.head[0].iov_base;
> +	xid = *p++;
> +	calldir = *p;
> +
> +	if (calldir == 0) {
> +		/* REQUEST is the most common case */
> +		vec[0] = rqstp->rq_arg.head[0];
> +	} else {
> +		/* REPLY */
> +		if (svsk->sk_bc_xprt)
> +			req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
> +
> +		if (!req) {
> +			printk(KERN_NOTICE
> +				"%s: Got unrecognized reply: "
> +				"calldir 0x%x sk_bc_xprt %p xid %08x\n",
> +				__func__, ntohl(calldir),
> +				svsk->sk_bc_xprt, xid);
> +			vec[0] = rqstp->rq_arg.head[0];
> +			goto out;
> +		}
> +
> +		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
> +		       sizeof(struct xdr_buf));
> +		/* copy the xid and call direction */
> +		memcpy(req->rq_private_buf.head[0].iov_base,
> +		       rqstp->rq_arg.head[0].iov_base, 8);
> +		vec[0] = req->rq_private_buf.head[0];
> +	}
> + out:
> +	vec[0].iov_base += 8;
> +	vec[0].iov_len -= 8;
> +	len = svsk->sk_reclen - 8;
> + error:
> +	*reqpp = req;
> +	return len;
> +}
> +
>  /*
>   * Receive data from a TCP socket.
>   */
> @@ -962,6 +1034,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	int		len;
>  	struct kvec *vec;
>  	int pnum, vlen;
> +	struct rpc_rqst *req = NULL;
>  
>  	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
>  		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
> @@ -975,9 +1048,27 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	vec = rqstp->rq_vec;
>  	vec[0] = rqstp->rq_arg.head[0];
>  	vlen = PAGE_SIZE;
> +
> +	/*
> +	 * We have enough data for the whole tcp record. Let's try and read the
> +	 * first 8 bytes to get the xid and the call direction. We can use this
> +	 * to figure out if this is a call or a reply to a callback. If
> +	 * sk_reclen is < 8 (xid and calldir), then this is a malformed packet.
> +	 * In that case, don't bother with the calldir and just read the data.
> +	 * It will be rejected in svc_process.
> +	 */
> +	if (len >= 8) {
> +		len = svc_process_calldir(svsk, rqstp, &req, vec);
> +		if (len < 0)
> +			goto err_again;
> +		vlen -= 8;
> +	}
> +
>  	pnum = 1;
>  	while (vlen < len) {
> -		vec[pnum].iov_base = page_address(rqstp->rq_pages[pnum]);
> +		vec[pnum].iov_base = (req) ?
> +			page_address(req->rq_private_buf.pages[pnum - 1]) :
> +			page_address(rqstp->rq_pages[pnum]);
>  		vec[pnum].iov_len = PAGE_SIZE;
>  		pnum++;
>  		vlen += PAGE_SIZE;
> @@ -989,6 +1080,16 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	if (len < 0)
>  		goto err_again;
>  
> +	/*
> +	 * Account for the 8 bytes we read earlier
> +	 */
> +	len += 8;
> +
> +	if (req) {
> +		xprt_complete_rqst(req->rq_task, len);
> +		len = 0;
> +		goto out;
> +	}
>  	dprintk("svc: TCP complete record (%d bytes)\n", len);
>  	rqstp->rq_arg.len = len;
>  	rqstp->rq_arg.page_base = 0;
> @@ -1002,6 +1103,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	rqstp->rq_xprt_ctxt   = NULL;
>  	rqstp->rq_prot	      = IPPROTO_TCP;
>  
> +out:
>  	/* Reset TCP read info */
>  	svsk->sk_reclen = 0;
>  	svsk->sk_tcplen = 0;
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index f412a85..f577e5a 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -832,6 +832,11 @@ static void xprt_timer(struct rpc_task *task)
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
>  
> +static inline int xprt_has_timer(struct rpc_xprt *xprt)
> +{
> +	return xprt->idle_timeout != (~0);
> +}

Why did this change again?

It's a disconnect timer, and the idle_timeout sets the timeout period. A
test for whether or not that period is 0 therefore makes sense (a zero
timeout being a nonsense value for a timer).

Testing for arbitrary non-zero values is more dubious, and forces the
backchannel to explicitly set a non-zero value. What value does that
add?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
