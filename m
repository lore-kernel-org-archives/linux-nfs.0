Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40250 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab3AYS5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 13:57:50 -0500
Date: Fri, 25 Jan 2013 13:57:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org, rees@umich.edu
Subject: Re: sunrpc: socket buffer size tuneable
Message-ID: <20130125185748.GC29596@fieldses.org>
References: <20130125005930.GC30652@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130125005930.GC30652@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2013 at 06:59:30PM -0600, Ben Myers wrote:
> At 1020 threads the send buffer size wraps and becomes negative causing
> the nfs server to grind to a halt.  Rather than setting bufsize based
> upon the number of nfsd threads, make the buffer sizes tuneable via
> module parameters.
> 
> Set the buffer sizes in terms of the number of rpcs you want to fit into
> the buffer.

>From private communication, my understanding is that the original
problem here was due to memory pressure forcing the tcp send buffer size
below the size required to hold a single rpc.

In which case the important variable here is lock_bufsize, as that's
what prevents the buffer size from going too low.

Cc'ing Jim Rees in case he remembers: I seem to recall discussing this
possibility, wondering whether we needed a special interface to the
network layer allowing us to set a minimum, and deciding it wasn't
really necessary at the time as we didn't think the network layer would
actually do this.  Is that right?  In which case either we were wrong,
or something changed.

--b.

> 
> Signed-off-by: Ben Myers <bpm@sgi.com>
> ---
> 
> v2: moved tuneables to net/sunrpc/svcsock.c, allow user to lock buffer 
> size
> 
>  net/sunrpc/sunrpc_syms.c |   39 +++++++++++++++++++++++++++++++++++
>  net/sunrpc/svcsock.c     |   52 ++++++++++++++++++++++++++---------------------
>  2 files changed, 68 insertions(+), 23 deletions(-)
> 
> Index: xfs/net/sunrpc/svcsock.c
> ===================================================================
> --- xfs.orig/net/sunrpc/svcsock.c
> +++ xfs/net/sunrpc/svcsock.c
> @@ -57,6 +57,47 @@
>  
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
> +/*
> + * Size each socket's send and receive buffers based upon the number of rpcs
> + * we'd like to be able to fit into them.  The TCP rcvbuf is enough for just a
> + * few requests.  TCP sndbuf is the same as the tcp_slot_table_entries default,
> + * the maximum number of in-flight rpcs for a client.  UDP sndbuf and rcvbuf
> + * defaults are the same as the udp_slot_table_entries default.
> + *
> + * Setting these too small can cause nfsd threads to block when sending.
> + */
> +static int tcp_rcvbuf_nrpc = 8;
> +static int tcp_sndbuf_nrpc = 8;
> +
> +static int udp_rcvbuf_nrpc = 6;
> +static int udp_sndbuf_nrpc = 6;
> +
> +static bool lock_bufsize = false;
> +
> +/*
> + * Minimum for bufsize settings is enough space for 6 rpcs, maximum is enough
> + * space for 128 rpcs.
> + */
> +static int param_set_bufsize_nrpc(const char *val, struct kernel_param *kp)
> +{
> +	char	*endp;
> +	int 	num = simple_strtol(val, &endp, 0);
> +
> +	if (endp == val || (*endp && *endp != '\n') || num < 6 || num > 128)
> +		return -EINVAL;
> +	*((int *)kp->arg) = num;
> +	return 0;
> +}
> +
> +module_param_call(tcp_rcvbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
> +	          &tcp_rcvbuf_nrpc, 0644);
> +module_param_call(tcp_sndbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
> +		  &tcp_sndbuf_nrpc, 0644);
> +module_param_call(udp_rcvbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
> +	          &udp_rcvbuf_nrpc, 0644);
> +module_param_call(udp_sndbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
> +	          &udp_sndbuf_nrpc, 0644);
> +module_param(lock_bufsize, bool, 0644);
>  
>  static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
>  					 int flags);
> @@ -375,8 +416,8 @@ static int svc_partial_recvfrom(struct s
>  /*
>   * Set socket snd and rcv buffer lengths
>   */
> -static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
> -				unsigned int rcv)
> +static void svc_sock_setbufsize(struct socket *sock, int snd, int rcv,
> +				bool lock)
>  {
>  #if 0
>  	mm_segment_t	oldfs;
> @@ -392,8 +433,17 @@ static void svc_sock_setbufsize(struct s
>  	 * DaveM said I could!
>  	 */
>  	lock_sock(sock->sk);
> -	sock->sk->sk_sndbuf = snd * 2;
> -	sock->sk->sk_rcvbuf = rcv * 2;
> +	sock->sk->sk_sndbuf = snd;
> +	sock->sk->sk_rcvbuf = rcv;
> +
> +	if (lock) {
> +		/*
> +		 * The socket buffer can be resized by the networking code
> +		 * unless you specify that this is not to be done.
> +		 */
> +		sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
> +	}
> +
>  	sock->sk->sk_write_space(sock->sk);
>  	release_sock(sock->sk);
>  #endif
> @@ -525,18 +575,17 @@ static int svc_udp_recvfrom(struct svc_r
>  	size_t len;
>  	int err;
>  
> -	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
> -	    /* udp sockets need large rcvbuf as all pending
> -	     * requests are still in that buffer.  sndbuf must
> -	     * also be large enough that there is enough space
> -	     * for one reply per thread.  We count all threads
> -	     * rather than threads in a particular pool, which
> -	     * provides an upper bound on the number of threads
> -	     * which will access the socket.
> -	     */
> -	    svc_sock_setbufsize(svsk->sk_sock,
> -				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
> -				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
> +	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags)) {
> +		/*
> +		 * UDP sockets need a large rcvbuf as all pending requests are
> +		 * still in that buffer.  sndbuf must also be large enough to
> +		 * fit a reply for each request the server could be processing.
> +		 */
> +		svc_sock_setbufsize(svsk->sk_sock,
> +				    udp_sndbuf_nrpc * serv->sv_max_mesg,
> +				    udp_rcvbuf_nrpc * serv->sv_max_mesg,
> +				    lock_bufsize);
> +	}
>  
>  	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  	skb = NULL;
> @@ -695,13 +744,14 @@ static void svc_udp_init(struct svc_sock
>  	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
>  	svsk->sk_sk->sk_write_space = svc_write_space;
>  
> -	/* initialise setting must have enough space to
> -	 * receive and respond to one request.
> -	 * svc_udp_recvfrom will re-adjust if necessary
> +	/*
> +	 * Initial setting must have enough space to receive and respond to one
> +	 * request.  svc_udp_recvfrom will readjust if necessary.
>  	 */
>  	svc_sock_setbufsize(svsk->sk_sock,
> -			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
> -			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
> +			    udp_sndbuf_nrpc * svsk->sk_xprt.xpt_server->sv_max_mesg,
> +			    udp_rcvbuf_nrpc * svsk->sk_xprt.xpt_server->sv_max_mesg,
> +			    lock_bufsize);
>  
>  	/* data might have come in before data_ready set up */
>  	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
> @@ -1377,8 +1427,10 @@ static struct svc_sock *svc_setup_socket
>  		/* initialise setting must have enough space to
>  		 * receive and respond to one request.
>  		 */
> -		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
> -					4 * serv->sv_max_mesg);
> +		svc_sock_setbufsize(svsk->sk_sock,
> +				tcp_sndbuf_nrpc * serv->sv_max_mesg,
> +				tcp_rcvbuf_nrpc * serv->sv_max_mesg,
> +				lock_bufsize);
>  		svc_tcp_init(svsk, serv);
>  	}
>  
