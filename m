From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 35/40] svc: Move the xprt independent code to the
	svc_xprt.c file
Date: Mon, 31 Dec 2007 17:14:45 -0500
Message-ID: <20071231221445.GB26470@fieldses.org>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int> <20071231030827.8430.76850.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327AbXLaWOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Dec 2007 17:14:47 -0500
In-Reply-To: <20071231030827.8430.76850.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 30, 2007 at 09:08:27PM -0600, Tom Tucker wrote:
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 4d03e87..fbbeeae 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -48,66 +48,24 @@
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/stats.h>
>  
> -/* SMP locking strategy:
> - *
> - *	svc_pool->sp_lock protects most of the fields of that pool.
> - * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
> - *	when both need to be taken (rare), svc_serv->sv_lock is first.
> - *	BKL protects svc_serv->sv_nrthread.
> - *	svc_sock->sk_lock protects the svc_sock->sk_deferred list
> - *             and the ->sk_info_authunix cache.
> - *	svc_sock->sk_xprt.xpt_flags.XPT_BUSY prevents a svc_sock being
> - *	enqueued multiply.
> - *
> - *	Some flags can be set to certain values at any time
> - *	providing that certain rules are followed:
> - *
> - *	XPT_CONN, XPT_DATA, can be set or cleared at any time.
> - *		after a set, svc_xprt_enqueue must be called.
> - *		after a clear, the socket must be read/accepted
> - *		 if this succeeds, it must be set again.
> - *	XPT_CLOSE can set at any time. It is never cleared.
> - *      xpt_ref contains a bias of '1' until XPT_DEAD is set.
> - *             so when xprt_ref hits zero, we know the transport is dead
> - *             and no-one is using it.
> - *      XPT_DEAD can only be set while XPT_BUSY is held which ensures
> - *             no other thread will be using the socket or will try to
> - *	       set XPT_DEAD.
> - *
> - */
> -
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
>  
>  static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
>  					 int *errp, int flags);
> -static void		svc_delete_xprt(struct svc_xprt *xprt);
>  static void		svc_udp_data_ready(struct sock *, int);
>  static int		svc_udp_recvfrom(struct svc_rqst *);
>  static int		svc_udp_sendto(struct svc_rqst *);
> -static void		svc_close_xprt(struct svc_xprt *xprt);
>  static void		svc_sock_detach(struct svc_xprt *);
>  static void		svc_sock_free(struct svc_xprt *);
>  
> -static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
> -static int svc_deferred_recv(struct svc_rqst *rqstp);
> -static struct cache_deferred_req *svc_defer(struct cache_req *req);
>  static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
>  					  struct sockaddr *, int, int);
> -static void svc_age_temp_xprts(unsigned long closure);
> -
> -/* apparently the "standard" is that clients close
> - * idle connections after 5 minutes, servers after
> - * 6 minutes
> - *   http://www.connectathon.org/talks96/nfstcp.pdf
> - */
> -static int svc_conn_age_period = 6*60;
> -
>  #ifdef CONFIG_DEBUG_LOCK_ALLOC
>  static struct lock_class_key svc_key[2];
>  static struct lock_class_key svc_slock_key[2];
>  
> -static inline void svc_reclassify_socket(struct socket *sock)
> +static void svc_reclassify_socket(struct socket *sock)
>  {
>  	struct sock *sk = sock->sk;
>  	BUG_ON(sock_owned_by_user(sk));
> @@ -131,67 +89,11 @@ static inline void svc_reclassify_socket(struct socket *sock)
>  	}
>  }
>  #else
> -static inline void svc_reclassify_socket(struct socket *sock)
> +static void svc_reclassify_socket(struct socket *sock)
>  {
>  }
>  #endif
>  
> -static char *__svc_print_addr(struct sockaddr *addr, char *buf, size_t len)
> -{
> -	switch (addr->sa_family) {
> -	case AF_INET:
> -		snprintf(buf, len, "%u.%u.%u.%u, port=%u",
> -			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
> -			ntohs(((struct sockaddr_in *) addr)->sin_port));
> -		break;
> -
> -	case AF_INET6:
> -		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
> -			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
> -			ntohs(((struct sockaddr_in6 *) addr)->sin6_port));
> -		break;
> -
> -	default:
> -		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
> -		break;
> -	}
> -	return buf;
> -}
> -
> -/**
> - * svc_print_addr - Format rq_addr field for printing
> - * @rqstp: svc_rqst struct containing address to print
> - * @buf: target buffer for formatted address
> - * @len: length of target buffer
> - *
> - */
> -char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
> -{
> -	return __svc_print_addr(svc_addr(rqstp), buf, len);
> -}
> -EXPORT_SYMBOL_GPL(svc_print_addr);
> -
> -/*
> - * Queue up an idle server thread.  Must have pool->sp_lock held.
> - * Note: this is really a stack rather than a queue, so that we only
> - * use as many different threads as we need, and the rest don't pollute
> - * the cache.
> - */
> -static inline void
> -svc_thread_enqueue(struct svc_pool *pool, struct svc_rqst *rqstp)
> -{
> -	list_add(&rqstp->rq_list, &pool->sp_threads);
> -}
> -
> -/*
> - * Dequeue an nfsd thread.  Must have pool->sp_lock held.
> - */
> -static inline void
> -svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
> -{
> -	list_del(&rqstp->rq_list);
> -}
> -
>  /*
>   * Release an skbuff after use
>   */
> @@ -214,220 +116,6 @@ static void svc_release_skb(struct svc_rqst *rqstp)
>  	}
>  }
>  
> -/*
> - * Queue up a socket with data pending. If there are idle nfsd
> - * processes, wake 'em up.
> - *
> - */
> -void svc_xprt_enqueue(struct svc_xprt *xprt)
> -{
> -	struct svc_serv	*serv = xprt->xpt_server;
> -	struct svc_pool *pool;
> -	struct svc_rqst	*rqstp;
> -	int cpu;
> -
> -	if (!(xprt->xpt_flags &
> -	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
> -		return;
> -	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> -		return;
> -
> -	cpu = get_cpu();
> -	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
> -	put_cpu();
> -
> -	spin_lock_bh(&pool->sp_lock);
> -
> -	if (!list_empty(&pool->sp_threads) &&
> -	    !list_empty(&pool->sp_sockets))
> -		printk(KERN_ERR
> -		       "svc_xprt_enqueue: "
> -		       "threads and transports both waiting??\n");
> -
> -	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
> -		/* Don't enqueue dead sockets */
> -		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
> -		goto out_unlock;
> -	}
> -
> -	/* Mark socket as busy. It will remain in this state until the
> -	 * server has processed all pending data and put the socket back
> -	 * on the idle list.  We update XPT_BUSY atomically because
> -	 * it also guards against trying to enqueue the svc_sock twice.
> -	 */
> -	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
> -		/* Don't enqueue socket while already enqueued */
> -		dprintk("svc: transport %p busy, not enqueued\n", xprt);
> -		goto out_unlock;
> -	}
> -	BUG_ON(xprt->xpt_pool != NULL);
> -	xprt->xpt_pool = pool;
> -
> -	/* Handle pending connection */
> -	if (test_bit(XPT_CONN, &xprt->xpt_flags))
> -		goto process;
> -
> -	/* Handle close in-progress */
> -	if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
> -		goto process;
> -
> -	/* Check if we have space to reply to a request */
> -	if (!xprt->xpt_ops->xpo_has_wspace(xprt)) {
> -		/* Don't enqueue while not enough space for reply */
> -		dprintk("svc: no write space, transport %p  not enqueued\n",
> -			xprt);
> -		xprt->xpt_pool = NULL;
> -		clear_bit(XPT_BUSY, &xprt->xpt_flags);
> -		goto out_unlock;
> -	}
> -
> - process:
> -	if (!list_empty(&pool->sp_threads)) {
> -		rqstp = list_entry(pool->sp_threads.next,
> -				   struct svc_rqst,
> -				   rq_list);
> -		dprintk("svc: transport %p served by daemon %p\n",
> -			xprt, rqstp);
> -		svc_thread_dequeue(pool, rqstp);
> -		if (rqstp->rq_xprt)
> -			printk(KERN_ERR
> -				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
> -				rqstp, rqstp->rq_xprt);
> -		rqstp->rq_xprt = xprt;
> -		svc_xprt_get(xprt);
> -		rqstp->rq_reserved = serv->sv_max_mesg;
> -		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
> -		BUG_ON(xprt->xpt_pool != pool);
> -		wake_up(&rqstp->rq_wait);
> -	} else {
> -		dprintk("svc: transport %p put into queue\n", xprt);
> -		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
> -		BUG_ON(xprt->xpt_pool != pool);
> -	}
> -
> -out_unlock:
> -	spin_unlock_bh(&pool->sp_lock);
> -}
> -EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
> -
> -/*
> - * Dequeue the first socket.  Must be called with the pool->sp_lock held.
> - */
> -static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
> -{
> -	struct svc_xprt	*xprt;
> -
> -	if (list_empty(&pool->sp_sockets))
> -		return NULL;
> -
> -	xprt = list_entry(pool->sp_sockets.next,
> -			  struct svc_xprt, xpt_ready);
> -	list_del_init(&xprt->xpt_ready);
> -
> -	dprintk("svc: transport %p dequeued, inuse=%d\n",
> -		xprt, atomic_read(&xprt->xpt_ref.refcount));
> -
> -	return xprt;
> -}
> -
> -/*
> - * svc_xprt_received conditionally queues the transport for processing
> - * by another thread. The caller must hold the XPT_BUSY bit and must
> - * not thereafter touch transport data.
> - *
> - * Note: XPT_DATA only gets cleared when a read-attempt finds no (or
> - * insufficient) data.
> - */
> -void svc_xprt_received(struct svc_xprt *xprt)
> -{
> -	BUG_ON(!test_bit(XPT_BUSY, &xprt->xpt_flags));
> -	xprt->xpt_pool = NULL;
> -	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> -	svc_xprt_enqueue(xprt);
> -}
> -EXPORT_SYMBOL_GPL(svc_xprt_received);
> -
> -/**
> - * svc_reserve - change the space reserved for the reply to a request.
> - * @rqstp:  The request in question
> - * @space: new max space to reserve
> - *
> - * Each request reserves some space on the output queue of the socket
> - * to make sure the reply fits.  This function reduces that reserved
> - * space to be the amount of space used already, plus @space.
> - *
> - */
> -void svc_reserve(struct svc_rqst *rqstp, int space)
> -{
> -	space += rqstp->rq_res.head[0].iov_len;
> -
> -	if (space < rqstp->rq_reserved) {
> -		struct svc_xprt *xprt = rqstp->rq_xprt;
> -		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
> -		rqstp->rq_reserved = space;
> -
> -		svc_xprt_enqueue(xprt);
> -	}
> -}
> -
> -static void svc_xprt_release(struct svc_rqst *rqstp)
> -{
> -	struct svc_xprt	*xprt = rqstp->rq_xprt;
> -
> -	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
> -
> -	svc_free_res_pages(rqstp);
> -	rqstp->rq_res.page_len = 0;
> -	rqstp->rq_res.page_base = 0;
> -
> -	/* Reset response buffer and release
> -	 * the reservation.
> -	 * But first, check that enough space was reserved
> -	 * for the reply, otherwise we have a bug!
> -	 */
> -	if ((rqstp->rq_res.len) >  rqstp->rq_reserved)
> -		printk(KERN_ERR "RPC request reserved %d but used %d\n",
> -		       rqstp->rq_reserved,
> -		       rqstp->rq_res.len);
> -
> -	rqstp->rq_res.head[0].iov_len = 0;
> -	svc_reserve(rqstp, 0);
> -	rqstp->rq_xprt = NULL;
> -
> -	svc_xprt_put(xprt);
> -}
> -
> -/*
> - * External function to wake up a server waiting for data
> - * This really only makes sense for services like lockd
> - * which have exactly one thread anyway.
> - */
> -void
> -svc_wake_up(struct svc_serv *serv)
> -{
> -	struct svc_rqst	*rqstp;
> -	unsigned int i;
> -	struct svc_pool *pool;
> -
> -	for (i = 0; i < serv->sv_nrpools; i++) {
> -		pool = &serv->sv_pools[i];
> -
> -		spin_lock_bh(&pool->sp_lock);
> -		if (!list_empty(&pool->sp_threads)) {
> -			rqstp = list_entry(pool->sp_threads.next,
> -					   struct svc_rqst,
> -					   rq_list);
> -			dprintk("svc: daemon %p woken up.\n", rqstp);
> -			/*
> -			svc_thread_dequeue(pool, rqstp);
> -			rqstp->rq_xprt = NULL;
> -			 */
> -			wake_up(&rqstp->rq_wait);
> -		}
> -		spin_unlock_bh(&pool->sp_lock);
> -	}
> -}
> -
>  union svc_pktinfo_u {
>  	struct in_pktinfo pkti;
>  	struct in6_pktinfo pkti6;
> @@ -469,8 +157,7 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
>  /*
>   * Generic sendto routine
>   */
> -static int
> -svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
> +static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
>  {
>  	struct svc_sock	*svsk =
>  		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> @@ -605,8 +292,7 @@ EXPORT_SYMBOL(svc_sock_names);
>  /*
>   * Check input queue length
>   */
> -static int
> -svc_recv_available(struct svc_sock *svsk)
> +static int svc_recv_available(struct svc_sock *svsk)
>  {
>  	struct socket	*sock = svsk->sk_sock;
>  	int		avail, err;
> @@ -619,8 +305,8 @@ svc_recv_available(struct svc_sock *svsk)
>  /*
>   * Generic recvfrom routine.
>   */
> -static int
> -svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
> +static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
> +			int buflen)
>  {
>  	struct svc_sock *svsk =
>  		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> @@ -640,8 +326,8 @@ svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
>  /*
>   * Set socket snd and rcv buffer lengths
>   */
> -static inline void
> -svc_sock_setbufsize(struct socket *sock, unsigned int snd, unsigned int rcv)
> +static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
> +				unsigned int rcv)
>  {
>  #if 0
>  	mm_segment_t	oldfs;
> @@ -666,8 +352,7 @@ svc_sock_setbufsize(struct socket *sock, unsigned int snd, unsigned int rcv)
>  /*
>   * INET callback when data has been received on the socket.
>   */
> -static void
> -svc_udp_data_ready(struct sock *sk, int count)
> +static void svc_udp_data_ready(struct sock *sk, int count)
>  {
>  	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
>  
> @@ -685,8 +370,7 @@ svc_udp_data_ready(struct sock *sk, int count)
>  /*
>   * INET callback when space is newly available on the socket.
>   */
> -static void
> -svc_write_space(struct sock *sk)
> +static void svc_write_space(struct sock *sk)
>  {
>  	struct svc_sock	*svsk = (struct svc_sock *)(sk->sk_user_data);
>  
> @@ -732,8 +416,7 @@ static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
>  /*
>   * Receive a datagram from a UDP socket.
>   */
> -static int
> -svc_udp_recvfrom(struct svc_rqst *rqstp)
> +static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>  {
>  	struct svc_sock	*svsk =
>  		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> @@ -827,7 +510,8 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>  		skb_free_datagram(svsk->sk_sk, skb);
>  	} else {
>  		/* we can use it in-place */
> -		rqstp->rq_arg.head[0].iov_base = skb->data + sizeof(struct udphdr);
> +		rqstp->rq_arg.head[0].iov_base = skb->data +
> +			sizeof(struct udphdr);
>  		rqstp->rq_arg.head[0].iov_len = len;
>  		if (skb_checksum_complete(skb)) {
>  			skb_free_datagram(svsk->sk_sk, skb);
> @@ -938,7 +622,8 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
>  			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
>  			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
>  
> -	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* might have come in before data_ready set up */
> +	/* data might have come in before data_ready set up */
> +	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  	set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
>  
>  	oldfs = get_fs();
> @@ -953,8 +638,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
>   * A data_ready event on a listening socket means there's a connection
>   * pending. Do not use state_change as a substitute for it.
>   */
> -static void
> -svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
> +static void svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
>  {
>  	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
>  
> @@ -986,8 +670,7 @@ svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
>  /*
>   * A state change on a connected socket means it's dying or dead.
>   */
> -static void
> -svc_tcp_state_change(struct sock *sk)
> +static void svc_tcp_state_change(struct sock *sk)
>  {
>  	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
>  
> @@ -1004,8 +687,7 @@ svc_tcp_state_change(struct sock *sk)
>  		wake_up_interruptible_all(sk->sk_sleep);
>  }
>  
> -static void
> -svc_tcp_data_ready(struct sock *sk, int count)
> +static void svc_tcp_data_ready(struct sock *sk, int count)
>  {
>  	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
>  
> @@ -1019,20 +701,6 @@ svc_tcp_data_ready(struct sock *sk, int count)
>  		wake_up_interruptible(sk->sk_sleep);
>  }
>  
> -static inline int svc_port_is_privileged(struct sockaddr *sin)
> -{
> -	switch (sin->sa_family) {
> -	case AF_INET:
> -		return ntohs(((struct sockaddr_in *)sin)->sin_port)
> -			< PROT_SOCK;
> -	case AF_INET6:
> -		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> -			< PROT_SOCK;
> -	default:
> -		return 0;
> -	}
> -}
> -
>  /*
>   * Accept a TCP connection
>   */
> @@ -1115,8 +783,7 @@ failed:
>  /*
>   * Receive data from a TCP socket.
>   */
> -static int
> -svc_tcp_recvfrom(struct svc_rqst *rqstp)
> +static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  {
>  	struct svc_sock	*svsk =
>  		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> @@ -1269,8 +936,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  /*
>   * Send out data on TCP socket.
>   */
> -static int
> -svc_tcp_sendto(struct svc_rqst *rqstp)
> +static int svc_tcp_sendto(struct svc_rqst *rqstp)
>  {
>  	struct xdr_buf	*xbufp = &rqstp->rq_res;
>  	int sent;
> @@ -1288,7 +954,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
>  
>  	sent = svc_sendto(rqstp, &rqstp->rq_res);
>  	if (sent != xbufp->len) {
> -		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
> +		printk(KERN_NOTICE 

Nit--git complained about trailing whitespace here; fixed in my version.

--b.
