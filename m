From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/9] SUNRPC: Remove sock and inet fields from
	rpc_xprt
Date: Wed, 18 Oct 2006 16:26:37 -0400
Message-ID: <1161203197.6095.128.camel@lade.trondhjem.org>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211510.8734.77710.stgit@ingres.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaI09-0003bD-R9
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:26:57 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaI09-00057y-Jn
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:26:58 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061012211510.8734.77710.stgit@ingres.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-10-12 at 17:15 -0400, Chuck Lever wrote:
> The "sock" and "inet" fields are socket-specific.  Move them to a private
> data structure maintained entirely within net/sunrpc/xprtsock.c
> 
> Test plan:
> Connectathon.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/xprt.h |    4 +--
>  net/sunrpc/xprtsock.c       |   68 ++++++++++++++++++++++++++-----------------
>  2 files changed, 43 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index d791901..4c074a7 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -17,6 +17,8 @@ #include <linux/sunrpc/sched.h>
>  #include <linux/sunrpc/xdr.h>
>  #include <linux/sunrpc/msg_prot.h>
>  
> +#include <net/sock.h>
> +
>  extern unsigned int xprt_udp_slot_table_entries;
>  extern unsigned int xprt_tcp_slot_table_entries;
>  
> @@ -126,8 +128,6 @@ struct rpc_xprt_ops {
>  struct rpc_xprt {
>  	struct kref		kref;		/* Reference count */
>  	struct rpc_xprt_ops *	ops;		/* transport methods */
> -	struct socket *		sock;		/* BSD socket layer */
> -	struct sock *		inet;		/* INET layer */
>  
>  	struct rpc_timeout	timeout;	/* timeout parms */
>  	struct sockaddr_storage	addr;		/* server address */
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 5ddb20d..79088e8 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -127,6 +127,12 @@ #endif
>  
>  struct xs_xprt {
>  	struct rpc_xprt		xprt;
> +
> +	/*
> +	 * Network layer
> +	 */
> +	struct socket *		sock;
> +	struct sock *		inet;
>  };
>  
>  static inline struct xs_xprt *xs_private_data(struct rpc_xprt *xprt)
> @@ -134,6 +140,11 @@ static inline struct xs_xprt *xs_private
>  	return (struct xs_xprt *) xprt;
>  }
>  
> +static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
> +{
> +	return (struct rpc_xprt *) sk->sk_user_data;
> +}
> +
>  static void xs_format_peer_addresses(struct rpc_xprt *xprt)
>  {
>  	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
> @@ -300,19 +311,20 @@ static void xs_nospace(struct rpc_task *
>  {
>  	struct rpc_rqst *req = task->tk_rqstp;
>  	struct rpc_xprt *xprt = req->rq_xprt;
> +	struct socket *sock = xs_private_data(xprt)->sock;
>  
>  	dprintk("RPC: %4d xmit incomplete (%u left of %u)\n",
>  			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
>  			req->rq_slen);
>  
> -	if (test_bit(SOCK_ASYNC_NOSPACE, &xprt->sock->flags)) {
> +	if (test_bit(SOCK_ASYNC_NOSPACE, &sock->flags)) {
>  		/* Protect against races with write_space */
>  		spin_lock_bh(&xprt->transport_lock);
>  
>  		/* Don't race with disconnect */
>  		if (!xprt_connected(xprt))
>  			task->tk_status = -ENOTCONN;
> -		else if (test_bit(SOCK_NOSPACE, &xprt->sock->flags))
> +		else if (test_bit(SOCK_NOSPACE, &sock->flags))
>  			xprt_wait_for_buffer_space(task);
>  
>  		spin_unlock_bh(&xprt->transport_lock);
> @@ -344,8 +356,10 @@ static int xs_udp_send_request(struct rp
>  				req->rq_svec->iov_len);
>  
>  	req->rq_xtime = jiffies;
> -	status = xs_sendpages(xprt->sock, (struct sockaddr *) &xprt->addr,
> -				xprt->addrlen, xdr, req->rq_bytes_sent);
> +	status = xs_sendpages(xs_private_data(xprt)->sock,
> +			      (struct sockaddr *) &xprt->addr,
> +			      xprt->addrlen, xdr,
> +			      req->rq_bytes_sent);
>  
>  	dprintk("RPC:      xs_udp_send_request(%u) = %d\n",
>  			xdr->len - req->rq_bytes_sent, status);
> @@ -415,8 +429,8 @@ static int xs_tcp_send_request(struct rp
>  	 * called sendmsg(). */
>  	while (1) {
>  		req->rq_xtime = jiffies;
> -		status = xs_sendpages(xprt->sock, NULL, 0, xdr,
> -						req->rq_bytes_sent);
> +		status = xs_sendpages(xs_private_data(xprt)->sock,
> +					NULL, 0, xdr, req->rq_bytes_sent);
>  
>  		dprintk("RPC:      xs_tcp_send_request(%u) = %d\n",
>  				xdr->len - req->rq_bytes_sent, status);
> @@ -494,8 +508,9 @@ out_release:
>   */
>  static void xs_close(struct rpc_xprt *xprt)
>  {
> -	struct socket *sock = xprt->sock;
> -	struct sock *sk = xprt->inet;
> +	struct xs_xprt *private = xs_private_data(xprt);
> +	struct socket *sock = private->sock;
> +	struct sock *sk = private->inet;
>  
>  	if (!sk)
>  		goto clear_close_wait;
> @@ -503,8 +518,8 @@ static void xs_close(struct rpc_xprt *xp
>  	dprintk("RPC:      xs_close xprt %p\n", xprt);
>  
>  	write_lock_bh(&sk->sk_callback_lock);
> -	xprt->inet = NULL;
> -	xprt->sock = NULL;
> +	private->inet = NULL;
> +	private->sock = NULL;
>  
>  	sk->sk_user_data = NULL;
>  	sk->sk_data_ready = xprt->old_data_ready;
> @@ -540,11 +555,6 @@ static void xs_destroy(struct rpc_xprt *
>  	kfree(xprt);
>  }
>  
> -static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
> -{
> -	return (struct rpc_xprt *) sk->sk_user_data;
> -}
> -
>  /**
>   * xs_udp_data_ready - "data ready" callback for UDP sockets
>   * @sk: socket with data to read
> @@ -961,7 +971,8 @@ static void xs_tcp_write_space(struct so
>  
>  static void xs_udp_do_set_buffer_size(struct rpc_xprt *xprt)
>  {
> -	struct sock *sk = xprt->inet;
> +	struct xs_xprt *private = xs_private_data(xprt);

Please don't use 'private' as a variable name. That just serves to
obfuscate.

> +	struct sock *sk = private->inet;
>  
>  	if (xprt->rcvsize) {
>  		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
> @@ -1077,7 +1088,8 @@ static int xs_bindresvport(struct rpc_xp
>  static void xs_udp_connect_worker(void *args)
>  {
>  	struct rpc_xprt *xprt = (struct rpc_xprt *) args;
> -	struct socket *sock = xprt->sock;
> +	struct xs_xprt *private = xs_private_data(xprt);
> +	struct socket *sock = private->sock;
>  	int err, status = -EIO;
>  
>  	if (xprt->shutdown || !xprt_bound(xprt))
> @@ -1099,7 +1111,7 @@ static void xs_udp_connect_worker(void *
>  	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
>  			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
>  
> -	if (!xprt->inet) {
> +	if (!private->inet) {
>  		struct sock *sk = sock->sk;
>  
>  		write_lock_bh(&sk->sk_callback_lock);
> @@ -1116,8 +1128,8 @@ static void xs_udp_connect_worker(void *
>  		xprt_set_connected(xprt);
>  
>  		/* Reset to new socket */
> -		xprt->sock = sock;
> -		xprt->inet = sk;
> +		private->sock = sock;
> +		private->inet = sk;
>  
>  		write_unlock_bh(&sk->sk_callback_lock);
>  	}
> @@ -1135,7 +1147,7 @@ out:
>  static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
>  {
>  	int result;
> -	struct socket *sock = xprt->sock;
> +	struct socket *sock = xs_private_data(xprt)->sock;
>  	struct sockaddr any;
>  
>  	dprintk("RPC:      disconnecting xprt %p to reuse port\n", xprt);
> @@ -1161,13 +1173,14 @@ static void xs_tcp_reuse_connection(stru
>  static void xs_tcp_connect_worker(void *args)
>  {
>  	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
> -	struct socket *sock = xprt->sock;
> +	struct xs_xprt *private = xs_private_data(xprt);
> +	struct socket *sock = private->sock;
>  	int err, status = -EIO;
>  
>  	if (xprt->shutdown || !xprt_bound(xprt))
>  		goto out;
>  
> -	if (!xprt->sock) {
> +	if (!private->sock) {
>  		/* start from scratch */
>  		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
>  			dprintk("RPC:      can't create TCP transport socket (%d).\n", -err);
> @@ -1185,7 +1198,7 @@ static void xs_tcp_connect_worker(void *
>  	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
>  			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
>  
> -	if (!xprt->inet) {
> +	if (!private->inet) {
>  		struct sock *sk = sock->sk;
>  
>  		write_lock_bh(&sk->sk_callback_lock);
> @@ -1208,8 +1221,8 @@ static void xs_tcp_connect_worker(void *
>  		xprt_clear_connected(xprt);
>  
>  		/* Reset to new socket */
> -		xprt->sock = sock;
> -		xprt->inet = sk;
> +		private->sock = sock;
> +		private->inet = sk;
>  
>  		write_unlock_bh(&sk->sk_callback_lock);
>  	}
> @@ -1258,11 +1271,12 @@ out_clear:
>  static void xs_connect(struct rpc_task *task)
>  {
>  	struct rpc_xprt *xprt = task->tk_xprt;
> +	struct xs_xprt *private = xs_private_data(xprt);
>  
>  	if (xprt_test_and_set_connecting(xprt))
>  		return;
>  
> -	if (xprt->sock != NULL) {
> +	if (private->sock != NULL) {
>  		dprintk("RPC:      xs_connect delayed xprt %p for %lu seconds\n",
>  				xprt, xprt->reestablish_timeout / HZ);
>  		schedule_delayed_work(&xprt->connect_worker,


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
