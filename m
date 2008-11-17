From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 28/51] FIXME: nfsd41: sunrpc: Added rpc server-side
 backchannel handling
Date: Mon, 17 Nov 2008 16:11:27 +0200
Message-ID: <49217B8F.8060104@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350216-11150-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:15664 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751745AbYKQOLa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:11:30 -0500
In-Reply-To: <1226350216-11150-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:50 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> FIXME: bhalevy: write up commit message
> 
> Signed-off-by: Mike Sager <sager@netapp.com>
> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-13: look into using a similar design to the rdma xprt.
we're essentially adding a new transport type which will eventually
be multi-xprt and will work over multiple connections of different
xprts.

> ---
>  include/linux/sunrpc/clnt.h    |    1 +
>  include/linux/sunrpc/svcsock.h |    1 +
>  include/linux/sunrpc/xprt.h    |    4 +
>  net/sunrpc/clnt.c              |    1 +
>  net/sunrpc/svcsock.c           |   76 +++++++++++
>  net/sunrpc/xprt.c              |   41 ++++++-
>  net/sunrpc/xprtsock.c          |  284 +++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 398 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index c6a1179..fe6a699 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -118,6 +118,7 @@ struct rpc_create_args {
>  	unsigned char		minorversion;
>  	rpc_authflavor_t	authflavor;
>  	unsigned long		flags;
> +	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
>  };
>  
>  /* Values for "flags" field */
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 6bb1ec4..e01a1c6 100644
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
> index 45a92e2..982dbbc 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -180,6 +180,9 @@ struct rpc_xprt {
>  	spinlock_t		reserve_lock;	/* lock slot table */
>  	u32			xid;		/* Next XID value to use */
>  	struct rpc_task *	snd_task;	/* Task blocked in send */
> +#if defined(CONFIG_NFSD_V4_1)

review 11-13: get rid of #ifdef?
straighten out the naming convention!!!!!!!
(bc_svc_* on the client/rpc receiver and bc_* on the server, rpc sender)

> +	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
> +#endif /* CONFIG_NFSD_V4_1 */
>  #if defined(CONFIG_NFS_V4_1)
>  	struct svc_serv		*bc_serv;	/* The RPC service which will */
>  						/* process the callback */
> @@ -232,6 +235,7 @@ struct xprt_create {
>  	struct sockaddr *	srcaddr;	/* optional local address */
>  	struct sockaddr *	dstaddr;	/* remote peer address */
>  	size_t			addrlen;
> +	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
>  };
>  
>  struct xprt_class {
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index fcadd8e..5e8fba0 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -262,6 +262,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>  		.srcaddr = args->saddress,
>  		.dstaddr = args->address,
>  		.addrlen = args->addrsize,
> +		.bc_sock = args->bc_sock,
>  	};
>  	char servername[48];
>  
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index c2b6fa4..0cc826d 100644
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
> @@ -795,6 +796,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	int		len;
>  	struct kvec *vec;
>  	int pnum, vlen;
> +#if defined(CONFIG_NFSD_V4_1)
> +	struct rpc_rqst *req = NULL;
> +#endif
>  
>  	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
>  		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
> @@ -878,12 +882,71 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	len = svsk->sk_reclen;
>  	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  
> +	/*
> +	 * We have enough data for the whole tcp record. Let's try and read the
> +	 * first 8 bytes to get the xid and the call direction. We can use this
> +	 * to figure out if this is a call or a reply to a callback. If
> +	 * sk_reclen is < 8 (xid and calldir), then this is a malformed packet.
> +	 * In that case, don't bother with the calldir and just read the data.
> +	 * It will be rejected in svc_process.
> +	 */
> +
>  	vec = rqstp->rq_vec;
>  	vec[0] = rqstp->rq_arg.head[0];
>  	vlen = PAGE_SIZE;
> +
> +	if (len >= 8) {
> +		u32 *p;
> +		u32 xid;
> +		u32 calldir;
> +
> +		len = svc_recvfrom(rqstp, vec, 1, 8);
> +		if (len < 0)
> +			goto error;
> +
> +		p = (u32 *)vec[0].iov_base;
> +		p = (u32 *)rqstp->rq_arg.head[0].iov_base;
> +		xid = *p++;
> +		calldir = *p;
> +
> +#if defined(CONFIG_NFSD_V4_1)
> +		if (calldir) {
> +			/* REPLY */
> +			if (svsk->sk_bc_xprt)
> +				req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
> +			if (req) {
> +				memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
> +					sizeof(struct xdr_buf));
> +				vec[0] = req->rq_private_buf.head[0];
> +			} else
> +				printk(KERN_NOTICE
> +					"%s: Got unrecognized reply: "
> +					"calldir 0x%x sk_bc_xprt %p xid %08x\n",
> +					__func__, ntohl(calldir),
> +					svsk->sk_bc_xprt, xid);
> +		}
> +
> +		if (!calldir || !req)
> +			vec[0] = rqstp->rq_arg.head[0];
> +
> +#else /* CONFIG_NFSD_V4_1 */
> +		vec[0] = rqstp->rq_arg.head[0];
> +#endif /* CONFIG_NFSD_V4_1 */
> +		vec[0].iov_base += 8;
> +		vec[0].iov_len -= 8;
> +		len = svsk->sk_reclen - 8;
> +		vlen -= 8;
> +	}
> +
>  	pnum = 1;
>  	while (vlen < len) {
> +#if defined(CONFIG_NFSD_V4_1)
> +		vec[pnum].iov_base = (req) ?
> +			page_address(req->rq_private_buf.pages[pnum - 1]):
> +			page_address(rqstp->rq_pages[pnum]);
> +#else /* CONFIG_NFSD_V4_1 */
>  		vec[pnum].iov_base = page_address(rqstp->rq_pages[pnum]);
> +#endif /* CONFIG_NFSD_V4_1 */
>  		vec[pnum].iov_len = PAGE_SIZE;
>  		pnum++;
>  		vlen += PAGE_SIZE;
> @@ -895,6 +958,18 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	if (len < 0)
>  		goto error;
>  
> +	/*
> +	 * Account for the 8 bytes we read earlier
> +	 */
> +	len += 8;
> +
> +#if defined(CONFIG_NFSD_V4_1)
> +	if (req) {
> +		xprt_complete_rqst(req->rq_task, len);
> +		len = 0;
> +		goto out;
> +	}
> +#endif /* CONFIG_NFSD_V4_1 */
>  	dprintk("svc: TCP complete record (%d bytes)\n", len);
>  	rqstp->rq_arg.len = len;
>  	rqstp->rq_arg.page_base = 0;
> @@ -908,6 +983,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	rqstp->rq_xprt_ctxt   = NULL;
>  	rqstp->rq_prot	      = IPPROTO_TCP;
>  
> +out:
>  	/* Reset TCP read info */
>  	svsk->sk_reclen = 0;
>  	svsk->sk_tcplen = 0;
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index e71f1be..5eeb660 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1022,6 +1022,27 @@ void xprt_release(struct rpc_task *task)
>  	spin_unlock(&xprt->reserve_lock);
>  }
>  
> +/*
> + * The autoclose function for the back channel
> + *
> + * The callback channel should never close the channel,
> + * let the forechannel do that.
> + */
> +static void bc_autoclose(struct work_struct *work)
> +{
> +	return;
> +}
> +
> +
> +/*
> + * The autodisconnect routine for the back channel. We never disconnect
> + */
> +static void
> +bc_init_autodisconnect(unsigned long data)

review 11-13: rename to noop_init_autodisconnect and noop_autoclose.
> +{
> +	return;
> +}
> +
>  /**
>   * xprt_create_transport - create an RPC transport
>   * @args: rpc transport creation arguments
> @@ -1063,9 +1084,16 @@ found:
>  	INIT_LIST_HEAD(&xprt->bc_pa_list);
>  #endif /* CONFIG_NFS_V4_1 */
>  
> -	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
> -	setup_timer(&xprt->timer, xprt_init_autodisconnect,
> -			(unsigned long)xprt);
> +	if (args->bc_sock) {
> +		INIT_WORK(&xprt->task_cleanup, bc_autoclose);
> +		setup_timer(&xprt->timer, bc_init_autodisconnect,
> +			    (unsigned long)xprt);
> +	} else {
> +		INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
> +		setup_timer(&xprt->timer, xprt_init_autodisconnect,
> +			    (unsigned long)xprt);
> +	}
> +
>  	xprt->last_used = jiffies;
>  	xprt->cwnd = RPC_INITCWND;
>  	xprt->bind_index = 0;
> @@ -1085,6 +1113,13 @@ found:
>  	dprintk("RPC:       created transport %p with %u slots\n", xprt,
>  			xprt->max_reqs);
>  
> +	/*
> +	 * Since we don't want connections for the backchannel, we set
> +	 * the xprt status to connected
> +	 */
> +	if (args->bc_sock)
> +		xprt_set_connected(xprt);
> +
>  	return xprt;
>  }
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8513d50..5531e50 100644
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
> @@ -2018,6 +2019,221 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>  			xprt->stat.bklog_u);
>  }
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +/*
> + * The connect worker for the backchannel
> + * This should never be called as we should never need to connect
> + */
> +static void bc_connect_worker(struct work_struct *work)
> +{
> +	BUG();
> +}
> +
> +/*
> + * The set_port routine of the rpc_xprt_ops. This is related to the portmapper
> + * and should never be called
> + */
> +
> +static void bc_set_port(struct rpc_xprt *xprt, unsigned short port)
> +{
> +	BUG();
> +}
> +
> +/*
> + * The connect routine for the backchannel rpc_xprt ops
> + * Again, should never be called!
> + */
> +
> +static void bc_connect(struct rpc_task *task)
> +{
> +	BUG();
> +}
> +
> +struct rpc_buffer {
> +	size_t	len;
> +	char	data[];
> +};
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
> +	free_pages((unsigned long)buf, get_order(buf->len));
> +}
> +
> +/*
> + * Use the svc_sock to send the callback. Must be called with svsk->sk_mutex

review 11-13: revise comment. s/svsk->sk_mutex/svc_xprt.xpt_mutex/

> + * held. Borrows heavily from svc_tcp_sendto and xs_tcp_semd_request.

ask Ricardo / Mike Sager if svc_send can be refactored so we'd reuse
the common code.

> + */
> +static int bc_sendto(struct rpc_rqst *req)
> +{
> +	int total_len;
> +	int len;
> +	int size;
> +	int result;
> +	struct xdr_buf *xbufp = &req->rq_snd_buf;
> +	struct page **pages = xbufp->pages;
> +	unsigned int flags = MSG_MORE;
> +	unsigned int pglen = xbufp->page_len;
> +	size_t base = xbufp->page_base;
> +	struct rpc_xprt *xprt = req->rq_xprt;
> +	struct sock_xprt *transport =
> +				container_of(xprt, struct sock_xprt, xprt);
> +	struct socket *sock = transport->sock;
> +
> +	total_len = xbufp->len;
> +
> +	/*
> +	 * Set up the rpc header and record marker stuff
> +	 */
> +	xs_encode_tcp_record_marker(xbufp);
> +
> +	/*
> +	 * The RPC message is divided into 3 pieces:
> +	 * - The header: This is what most of the smaller RPC messages consist
> +	 *   of. Often the whole message is in this.
> +	 *
> +	 *   - xdr->pages: This is a list of pages that contain data, for
> +	 *   example in a write request or while using rpcsec gss
> +	 *
> +	 *   - The tail: This is the rest of the rpc message
> +	 *
> +	 *  First we send the header, then the pages and then finally the tail.
> +	 *  The code borrows heavily from svc_sendto.
> +	 */
> +
> +	/*
> +	 * Send the head
> +	 */
> +	if (total_len == xbufp->head[0].iov_len)
> +		flags = 0;
> +
> +	len = sock->ops->sendpage(sock, virt_to_page(xbufp->head[0].iov_base),
> +			(unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK,
> +			xbufp->head[0].iov_len, flags);
> +
> +	if (len != xbufp->head[0].iov_len)
> +		goto out;
> +
> +	/*
> +	 * send page data
> +	 *
> +	 * Check the amount of data to be sent. If it is less than the
> +	 * remaining page, then send it else send the current page
> +	 */
> +
> +	size = PAGE_SIZE - base < pglen ? PAGE_SIZE - base : pglen;
> +	while (pglen > 0) {
> +		if (total_len == size)
> +			flags = 0;
> +		result = sock->ops->sendpage(sock, *pages, base, size, flags);
> +		if (result > 0)
> +			len += result;
> +		if (result != size)
> +			goto out;
> +		total_len -= size;
> +		pglen -= size;
> +		size = PAGE_SIZE < pglen ? PAGE_SIZE : pglen;
> +		base = 0;
> +		pages++;
> +	}
> +	/*
> +	 * send tail
> +	 */
> +	if (xbufp->tail[0].iov_len) {
> +		result = sock->ops->sendpage(sock,
> +			xbufp->tail[0].iov_base,
> +			(unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK,
> +			xbufp->tail[0].iov_len,
> +			0);
> +
> +		if (result > 0)
> +			len += result;
> +	}
> +out:
> +	if (len != xbufp->len)
> +		printk(KERN_NOTICE "Error sending entire callback!\n");
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
> +	struct rpc_xprt *bc_xprt = req->rq_xprt;
> +	struct svc_xprt	*xprt;
> +	struct svc_sock         *svsk;
> +	u32                     len;
> +
> +	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
> +	/*
> +	 * Get the server socket associated with this callback xprt
> +	 */
> +	svsk = bc_xprt->bc_sock;
> +	xprt = &svsk->sk_xprt;
> +
> +	mutex_lock(&xprt->xpt_mutex);
> +	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> +		len = -ENOTCONN;
> +	else
> +		len = bc_sendto(req);
> +	mutex_unlock(&xprt->xpt_mutex);
> +
> +	return 0;
> +
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
> +#endif /* CONFIG_NFSD_V4_1 */
> +
>  static struct rpc_xprt_ops xs_udp_ops = {
>  	.set_buffer_size	= xs_udp_set_buffer_size,
>  	.reserve_xprt		= xprt_reserve_xprt_cong,
> @@ -2054,6 +2270,26 @@ static struct rpc_xprt_ops xs_tcp_ops = {
>  	.print_stats		= xs_tcp_print_stats,
>  };
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +/*
> + * The rpc_xprt_ops for the server backchannel
> + */
> +
> +static struct rpc_xprt_ops bc_tcp_ops = {
> +	.reserve_xprt		= xprt_reserve_xprt,
> +	.release_xprt		= xprt_release_xprt,
> +	.set_port		= bc_set_port,
> +	.connect		= bc_connect,
> +	.buf_alloc		= bc_malloc,
> +	.buf_free		= bc_free,
> +	.send_request		= bc_send_request,
> +	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
> +	.close			= bc_close,
> +	.destroy		= bc_destroy,
> +	.print_stats		= xs_tcp_print_stats,
> +};
> +#endif /* CONFIG_NFSD_V4_1 */
> +
>  static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
>  				      unsigned int slot_table_size)
>  {
> @@ -2186,13 +2422,31 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
>  	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>  	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
>  
> -	xprt->bind_timeout = XS_BIND_TO;
> -	xprt->connect_timeout = XS_TCP_CONN_TO;
> -	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> -	xprt->idle_timeout = XS_IDLE_DISC_TO;
> +#if defined(CONFIG_NFSD_V4_1)
> +	if (args->bc_sock) {

review 11-13: get rid if the #ifdef and next: label
(which is just the "else" lag.

> +		/* backchannel */
> +		xprt_set_bound(xprt);
> +		INIT_DELAYED_WORK(&transport->connect_worker,
> +				  bc_connect_worker);
> +		xprt->bind_timeout = 0;
> +		xprt->connect_timeout = 0;
> +		xprt->reestablish_timeout = 0;
> +		xprt->idle_timeout = (~0);
>  
> -	xprt->ops = &xs_tcp_ops;
> -	xprt->timeout = &xs_tcp_default_timeout;
> +		/*
> +		 * The backchannel uses the same socket connection as the
> +		 * forechannel
> +		 */
> +		xprt->bc_sock = args->bc_sock;
> +		xprt->bc_sock->sk_bc_xprt = xprt;
> +		transport->sock = xprt->bc_sock->sk_sock;
> +		transport->inet = xprt->bc_sock->sk_sk;
> +
> +		xprt->ops = &bc_tcp_ops;
> +
> +		goto next;
> +	}
> +#endif /* CONFIG_NFSD_V4_1 */
>  
>  	switch (addr->sa_family) {
>  	case AF_INET:
> @@ -2200,13 +2454,29 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
>  			xprt_set_bound(xprt);
>  
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
+		break;
+	}
+	xprt->bind_timeout = XS_BIND_TO;
+	xprt->connect_timeout = XS_TCP_CONN_TO;
+	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	xprt->idle_timeout = XS_IDLE_DISC_TO;
+
+	xprt->ops = &xs_tcp_ops;
+
+next:
+	xprt->timeout = &xs_tcp_default_timeout;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
+		break;
+	case AF_INET6:
 		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
-- 
1.6.0.1

>  		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
> -		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
>  		break;
>  	case AF_INET6:
>  		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
>  			xprt_set_bound(xprt);
>  
>  		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
> +		break;
> +	}
> +	xprt->bind_timeout = XS_BIND_TO;
> +	xprt->connect_timeout = XS_TCP_CONN_TO;
> +	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> +	xprt->idle_timeout = XS_IDLE_DISC_TO;
> +
> +	xprt->ops = &xs_tcp_ops;
> +
> +next:
> +	xprt->timeout = &xs_tcp_default_timeout;
> +
> +	switch (addr->sa_family) {
> +	case AF_INET:
> +		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
> +		break;
> +	case AF_INET6:
>  		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
>  		break;
>  	default:
