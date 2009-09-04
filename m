From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 02/10] nfsd41: sunrpc: Added rpc server-side
 backchannel handling
Date: Fri, 04 Sep 2009 13:00:14 -0400
Message-ID: <1252083614.13204.40.camel@heimdal.trondhjem.org>
References: <4AA13DE3.8020800@panasas.com>
	 <1252081892-19494-1-git-send-email-bhalevy@panasas.com>
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
Received: from mx2.netapp.com ([216.240.18.37]:18954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933478AbZIDRBA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 13:01:00 -0400
In-Reply-To: <1252081892-19494-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-04 at 19:31 +0300, Benny Halevy wrote:
> From: Rahul Iyer <iyer@netapp.com>
> 
> Signed-off-by: Rahul Iyer <iyer@netapp.com>
> Signed-off-by: Mike Sager <sager@netapp.com>
> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> When the call direction is a reply, copy the xid and call direction into the
> req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header returns
> rpc_garbage.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [get rid of CONFIG_NFSD_V4_1]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [sunrpc: refactoring of svc_tcp_recvfrom]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: create common send routine for the fore and the back channels]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: Use free_page() to free server backchannel pages]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

OK... Let's not go overboard with all the 'Signed-off-by's here... I'm
sure this ping-ponging between Alexandros and Ricardo can be
consolidated a bit. Particularly given that they work for the same
company...

> [nfsd41: sunrpc: Document server backchannel locking]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: remove bc_connect_worker()]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: Define xprt_server_backchannel()[
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: remove bc_close and bc_init_auto_disconnect dummy functions]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: eliminate unneeded switch statement in xs_setup_tcp()]
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: Don't auto close the server backchannel connection]
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: sunrpc: Remove unused functions]
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: change bc_sock to bc_xprt]
> [nfsd41: sunrpc: move struct rpc_buffer def into a common header file]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: sunrpc: use rpc_sleep in bc_send_request so not to block on mutex]
> [removed cosmetic changes]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Cc: Trond Myklebust <trond.myklebust@netapp.com>
> ---
>  include/linux/sunrpc/clnt.h     |    1 +
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  include/linux/sunrpc/svcsock.h  |    1 +
>  include/linux/sunrpc/xprt.h     |    7 ++
>  net/sunrpc/clnt.c               |    1 +
>  net/sunrpc/sunrpc.h             |    4 +
>  net/sunrpc/svc_xprt.c           |    2 +
>  net/sunrpc/svcsock.c            |  172 +++++++++++++++++++++++++++-------
>  net/sunrpc/xprt.c               |   13 +++
>  net/sunrpc/xprtsock.c           |  198 +++++++++++++++++++++++++++++++++++++-
>  10 files changed, 359 insertions(+), 41 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 3d02558..8ed9642 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -114,6 +114,7 @@ struct rpc_create_args {
>  	rpc_authflavor_t	authflavor;
>  	unsigned long		flags;
>  	char			*client_name;
> +	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
>  };
>  
>  /* Values for "flags" field */
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
> index 04dba23..4b854e2 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -28,6 +28,7 @@ struct svc_sock {
>  	/* private TCP part */
>  	u32			sk_reclen;	/* length of record */
>  	u32			sk_tcplen;	/* current read length */
> +	struct rpc_xprt	       *sk_bc_xprt;	/* NFSv4.1 backchannel xprt */
>  };
>  
>  /*
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index c090df4..cfad635 100644
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
> @@ -231,6 +232,7 @@ struct xprt_create {
>  	struct sockaddr *	srcaddr;	/* optional local address */
>  	struct sockaddr *	dstaddr;	/* remote peer address */
>  	size_t			addrlen;
> +	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
>  };
>  
>  struct xprt_class {
> @@ -366,6 +368,11 @@ static inline int xprt_test_and_set_binding(struct rpc_xprt *xprt)
>  	return test_and_set_bit(XPRT_BINDING, &xprt->state);
>  }
>  
> +static inline int xprt_server_backchannel(struct rpc_xprt *xprt)
> +{
> +	return xprt->bc_xprt != NULL;
> +}

xprt_is_server_backchannel()? When I see a function with a name like the
above, I tend to assume it will actually return a backchannel object.

> +
>  #endif /* __KERNEL__*/
>  
>  #endif /* _LINUX_SUNRPC_XPRT_H */
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index c1e467e..7389804 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -288,6 +288,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>  		.srcaddr = args->saddress,
>  		.dstaddr = args->address,
>  		.addrlen = args->addrsize,
> +		.bc_xprt = args->bc_xprt,
>  	};
>  	char servername[48];
>  
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
> index f412a85..7b0cf70 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -599,6 +599,9 @@ static void xprt_autoclose(struct work_struct *work)
>  	struct rpc_xprt *xprt =
>  		container_of(work, struct rpc_xprt, task_cleanup);
>  
> +	if (xprt_server_backchannel(xprt))
> +		return;

Why do you need this? For one thing, it means that XPRT_CLOSE_WAIT never
gets cleared...

> +
>  	xprt->ops->close(xprt);
>  	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>  	xprt_release_write(xprt, NULL);
> @@ -669,6 +672,9 @@ xprt_init_autodisconnect(unsigned long data)
>  {
>  	struct rpc_xprt *xprt = (struct rpc_xprt *)data;
>  
> +	if (xprt_server_backchannel(xprt))
> +		return;

Hmm... Do you need this? Why would you want to set up an autodisconnect
timer in the first place?

> +
>  	spin_lock(&xprt->transport_lock);
>  	if (!list_empty(&xprt->recv) || xprt->shutdown)
>  		goto out_abort;
> @@ -1103,6 +1109,13 @@ found:
>  	dprintk("RPC:       created transport %p with %u slots\n", xprt,
>  			xprt->max_reqs);
>  
> +	/*
> +	 * Since we don't want connections for the backchannel, we set
> +	 * the xprt status to connected
> +	 */
> +	if (args->bc_xprt)
> +		xprt_set_connected(xprt);
> +

Why don't you do this in the ->setup() callback?

>  	return xprt;
>  }
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 62438f3..592681c 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -32,6 +32,7 @@
>  #include <linux/tcp.h>
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/sched.h>
> +#include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/xprtsock.h>
>  #include <linux/file.h>
>  #ifdef CONFIG_NFS_V4_1
> @@ -43,6 +44,7 @@
>  #include <net/udp.h>
>  #include <net/tcp.h>
>  
> +#include "sunrpc.h"
>  /*
>   * xprtsock tunables
>   */
> @@ -2098,6 +2100,134 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>  			xprt->stat.bklog_u);
>  }
>  
> +/*
> + * Allocate a bunch of pages for a scratch buffer for the rpc code. The reason
> + * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
> + * to use the server side send routines.
> + */
> +void *bc_malloc(struct rpc_task *task, size_t size)
> +{
> +	struct page *page;
> +	struct rpc_buffer *buf;
> +
> +	BUG_ON(size > PAGE_SIZE - sizeof(struct rpc_buffer));
> +	page = alloc_page(GFP_KERNEL);
> +
> +	if (!page)
> +		return NULL;
> +
> +	buf = page_address(page);
> +	buf->len = PAGE_SIZE;
> +
> +	return buf->data;
> +}
> +
> +/*
> + * Free the space allocated in the bc_alloc routine
> + */
> +void bc_free(void *buffer)
> +{
> +	struct rpc_buffer *buf;
> +
> +	if (!buffer)
> +		return;
> +
> +	buf = container_of(buffer, struct rpc_buffer, data);
> +	free_page((unsigned long)buf);
> +}
> +
> +/*
> + * Use the svc_sock to send the callback. Must be called with svsk->sk_mutex
> + * held. Borrows heavily from svc_tcp_sendto and xs_tcp_send_request.
> + */
> +static int bc_sendto(struct rpc_rqst *req)
> +{
> +	int len;
> +	struct xdr_buf *xbufp = &req->rq_snd_buf;
> +	struct rpc_xprt *xprt = req->rq_xprt;
> +	struct sock_xprt *transport =
> +				container_of(xprt, struct sock_xprt, xprt);
> +	struct socket *sock = transport->sock;
> +	unsigned long headoff;
> +	unsigned long tailoff;
> +
> +	/*
> +	 * Set up the rpc header and record marker stuff
> +	 */
> +	xs_encode_tcp_record_marker(xbufp);
> +
> +	tailoff = (unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK;
> +	headoff = (unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK;
> +	len = svc_send_common(sock, xbufp,
> +			      virt_to_page(xbufp->head[0].iov_base), headoff,
> +			      xbufp->tail[0].iov_base, tailoff);
> +
> +	if (len != xbufp->len) {
> +		printk(KERN_NOTICE "Error sending entire callback!\n");
> +		len = -EAGAIN;
> +	}
> +
> +	return len;
> +}
> +
> +/*
> + * The send routine. Borrows from svc_send
> + */
> +static int bc_send_request(struct rpc_task *task)
> +{
> +	struct rpc_rqst *req = task->tk_rqstp;
> +	struct svc_xprt	*xprt;
> +	struct svc_sock         *svsk;
> +	u32                     len;
> +
> +	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
> +	/*
> +	 * Get the server socket associated with this callback xprt
> +	 */
> +	xprt = req->rq_xprt->bc_xprt;
> +	svsk = container_of(xprt, struct svc_sock, sk_xprt);
> +
> +	/*
> +	 * Grab the mutex to serialize data as the connection is shared
> +	 * with the fore channel
> +	 */
> +	if (!mutex_trylock(&xprt->xpt_mutex)) {
> +		rpc_sleep_on(&xprt->xpt_bc_pending, task, NULL);
> +		if (!mutex_trylock(&xprt->xpt_mutex))
> +			return -EAGAIN;
> +		rpc_wake_up_queued_task(&xprt->xpt_bc_pending, task);
> +	}
> +	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> +		len = -ENOTCONN;
> +	else
> +		len = bc_sendto(req);
> +	mutex_unlock(&xprt->xpt_mutex);
> +
> +	if (len > 0)
> +		len = 0;
> +
> +	return len;
> +}
> +
> +/*
> + * The close routine. Since this is client initiated, we do nothing
> + */
> +
> +static void bc_close(struct rpc_xprt *xprt)
> +{
> +	return;
> +}
> +
> +/*
> + * The xprt destroy routine. Again, because this connection is client
> + * initiated, we do nothing
> + */
> +
> +static void bc_destroy(struct rpc_xprt *xprt)
> +{
> +	return;
> +}
> +
>  static struct rpc_xprt_ops xs_udp_ops = {
>  	.set_buffer_size	= xs_udp_set_buffer_size,
>  	.reserve_xprt		= xprt_reserve_xprt_cong,
> @@ -2134,6 +2264,22 @@ static struct rpc_xprt_ops xs_tcp_ops = {
>  	.print_stats		= xs_tcp_print_stats,
>  };
>  
> +/*
> + * The rpc_xprt_ops for the server backchannel
> + */
> +
> +static struct rpc_xprt_ops bc_tcp_ops = {
> +	.reserve_xprt		= xprt_reserve_xprt,
> +	.release_xprt		= xprt_release_xprt,
> +	.buf_alloc		= bc_malloc,
> +	.buf_free		= bc_free,
> +	.send_request		= bc_send_request,
> +	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
> +	.close			= bc_close,
> +	.destroy		= bc_destroy,
> +	.print_stats		= xs_tcp_print_stats,
> +};
> +
>  static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
>  				      unsigned int slot_table_size)
>  {
> @@ -2272,14 +2418,46 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>  	xprt->prot = IPPROTO_TCP;
>  	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>  	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
> +	xprt->timeout = &xs_tcp_default_timeout;
>  
> -	xprt->bind_timeout = XS_BIND_TO;
> -	xprt->connect_timeout = XS_TCP_CONN_TO;
> -	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> -	xprt->idle_timeout = XS_IDLE_DISC_TO;
> +	if (args->bc_xprt) {
> +		struct svc_sock *bc_sock;

Why are you embedding this inside the forward channel setup code? Just
make a TCP backchannel class with its own ->setup().

> -	xprt->ops = &xs_tcp_ops;
> -	xprt->timeout = &xs_tcp_default_timeout;
> +		/* backchannel */
> +		xprt_set_bound(xprt);
> +		xprt->bind_timeout = 0;
> +		xprt->connect_timeout = 0;
> +		xprt->reestablish_timeout = 0;
> +		xprt->idle_timeout = (~0);
> +
> +		/*
> +		 * The backchannel uses the same socket connection as the
> +		 * forechannel
> +		 */
> +		xprt->bc_xprt = args->bc_xprt;
> +		bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
> +		bc_sock->sk_bc_xprt = xprt;
> +		transport->sock = bc_sock->sk_sock;
> +		transport->inet = bc_sock->sk_sk;
> +
> +		xprt->ops = &bc_tcp_ops;
> +
> +		switch (addr->sa_family) {
> +		case AF_INET:
> +			xs_format_peer_addresses(xprt, "tcp",
> +						 RPCBIND_NETID_TCP);
> +			break;
> +		case AF_INET6:
> +			xs_format_peer_addresses(xprt, "tcp",
> +						 RPCBIND_NETID_TCP6);
> +			break;
> +		default:
> +			kfree(xprt);
> +			return ERR_PTR(-EAFNOSUPPORT);
> +		}
> +
> +		goto out;
> +	}
>  
>  	switch (addr->sa_family) {
>  	case AF_INET:
> @@ -2303,6 +2481,14 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>  		return ERR_PTR(-EAFNOSUPPORT);
>  	}
>  
> +	xprt->bind_timeout = XS_BIND_TO;
> +	xprt->connect_timeout = XS_TCP_CONN_TO;
> +	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> +	xprt->idle_timeout = XS_IDLE_DISC_TO;
> +
> +	xprt->ops = &xs_tcp_ops;
> +
> +out:
>  	if (xprt_bound(xprt))
>  		dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
>  				xprt->address_strings[RPC_DISPLAY_ADDR],

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
