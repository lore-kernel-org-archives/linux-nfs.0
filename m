From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 02/25] SUNRPC: Create a helper to tell whether
	a	transport is bound
Date: Wed, 09 Aug 2006 11:19:52 -0400
Message-ID: <1155136792.5731.84.camel@localhost>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
	<20060809145853.3914.64708.stgit@picasso.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAprD-0002NH-Ac
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:20:31 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GAprA-0001jN-5L
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:20:31 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20060809145853.3914.64708.stgit@picasso.dsl.sfldmi.ameritech.net>
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

On Wed, 2006-08-09 at 10:58 -0400, Chuck Lever wrote:
> Hide the contents and format of xprt->addr by eliminating direct uses
> of the xprt->addr.sin_port field.  This change is required to support
> alternate RPC host address formats (eg IPv6).
> 
> Test-plan:
> Destructive testing (unplugging the network temporarily).  Repeated runs of
> Connectathon locking suite with UDP and TCP.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/xprt.h |   16 ++++++++++++++++
>  net/sunrpc/clnt.c           |   10 +++++-----
>  net/sunrpc/xprt.c           |    6 +++++-
>  net/sunrpc/xprtsock.c       |   16 ++++++++++++----
>  4 files changed, 38 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 3a0cca2..e65474f 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -269,6 +269,7 @@ #define XPRT_LOCKED		(0)
>  #define XPRT_CONNECTED		(1)
>  #define XPRT_CONNECTING		(2)
>  #define XPRT_CLOSE_WAIT		(3)
> +#define XPRT_BOUND		(4)
>  
>  static inline void xprt_set_connected(struct rpc_xprt *xprt)
>  {
> @@ -312,6 +313,21 @@ static inline int xprt_test_and_set_conn
>  	return test_and_set_bit(XPRT_CONNECTING, &xprt->state);
>  }
>  
> +static inline void xprt_set_bound(struct rpc_xprt *xprt)
> +{
> +	set_bit(XPRT_BOUND, &xprt->state);
> +}
> +
> +static inline int xprt_bound(struct rpc_xprt *xprt)
> +{
> +	return test_bit(XPRT_BOUND, &xprt->state);
> +}
> +
> +static inline void xprt_clear_bound(struct rpc_xprt *xprt)
> +{
> +	clear_bit(XPRT_BOUND, &xprt->state);
> +}
> +
>  #endif /* __KERNEL__*/
>  
>  #endif /* _LINUX_SUNRPC_XPRT_H */
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index d6409e7..4f353dd 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -148,7 +148,6 @@ rpc_new_client(struct rpc_xprt *xprt, ch
>  	clnt->cl_maxproc  = version->nrprocs;
>  	clnt->cl_protname = program->name;
>  	clnt->cl_pmap	  = &clnt->cl_pmap_default;
> -	clnt->cl_port     = xprt->addr.sin_port;
>  	clnt->cl_prog     = program->number;
>  	clnt->cl_vers     = version->number;
>  	clnt->cl_prot     = xprt->prot;
> @@ -156,7 +155,7 @@ rpc_new_client(struct rpc_xprt *xprt, ch
>  	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
>  	rpc_init_wait_queue(&clnt->cl_pmap_default.pm_bindwait, "bindwait");
>  
> -	if (!clnt->cl_port)
> +	if (!xprt_bound(clnt->cl_xprt))
>  		clnt->cl_autobind = 1;
>  
>  	clnt->cl_rtt = &clnt->cl_rtt_default;
> @@ -573,7 +572,7 @@ EXPORT_SYMBOL(rpc_max_payload);
>  void rpc_force_rebind(struct rpc_clnt *clnt)
>  {
>  	if (clnt->cl_autobind)
> -		clnt->cl_port = 0;
> +		xprt_clear_bound(clnt->cl_xprt);
>  }
>  EXPORT_SYMBOL(rpc_force_rebind);
>  
> @@ -785,14 +784,15 @@ static void
>  call_bind(struct rpc_task *task)
>  {
>  	struct rpc_clnt	*clnt = task->tk_client;
> +	struct rpc_xprt *xprt = task->tk_xprt;
>  
>  	dprintk("RPC: %4d call_bind (status %d)\n",
>  				task->tk_pid, task->tk_status);
>  
>  	task->tk_action = call_connect;
> -	if (!clnt->cl_port) {
> +	if (!xprt_bound(xprt)) {
>  		task->tk_action = call_bind_status;
> -		task->tk_timeout = task->tk_xprt->bind_timeout;
> +		task->tk_timeout = xprt->bind_timeout;
>  		rpc_getport(task, clnt);
>  	}
>  }
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index e8c2bc4..10ba1f6 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -534,7 +534,11 @@ void xprt_connect(struct rpc_task *task)
>  	dprintk("RPC: %4d xprt_connect xprt %p %s connected\n", task->tk_pid,
>  			xprt, (xprt_connected(xprt) ? "is" : "is not"));
>  
> -	if (!xprt->addr.sin_port) {
> +	if (xprt->shutdown) {
> +		task->tk_status = -EIO;
> +		return;
> +	}

Why are you reinstating the test for xprt->shutdown? It was removed
because it is pretty much useless there. Any task should already have
been signalled to exit by rpc_shutdown_client()...

> +	if (!xprt_bound(xprt)) {
>  		task->tk_status = -EIO;
>  		return;
>  	}
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 441bd53..43b59c2 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -974,6 +974,8 @@ static void xs_set_port(struct rpc_xprt 
>  {
>  	dprintk("RPC:      setting port for xprt %p to %u\n", xprt, port);
>  	xprt->addr.sin_port = htons(port);
> +	if (port != 0)
> +		xprt_set_bound(xprt);

Hmm... This looks odd. If port == 0, why not exit immediately?

Furthermore, what if the port is already bound: is it correct to set it
again? IOW: should it be conditional on test_and_set_bit()?

Cheers,
  Trond

>  }
>  
>  static int xs_bindresvport(struct rpc_xprt *xprt, struct socket *sock)
> @@ -1016,7 +1018,7 @@ static void xs_udp_connect_worker(void *
>  	struct socket *sock = xprt->sock;
>  	int err, status = -EIO;
>  
> -	if (xprt->shutdown || xprt->addr.sin_port == 0)
> +	if (xprt->shutdown || !xprt_bound(xprt))
>  		goto out;
>  
>  	dprintk("RPC:      xs_udp_connect_worker for xprt %p\n", xprt);
> @@ -1099,7 +1101,7 @@ static void xs_tcp_connect_worker(void *
>  	struct socket *sock = xprt->sock;
>  	int err, status = -EIO;
>  
> -	if (xprt->shutdown || xprt->addr.sin_port == 0)
> +	if (xprt->shutdown || !xprt_bound(xprt))
>  		goto out;
>  
>  	dprintk("RPC:      xs_tcp_connect_worker for xprt %p\n", xprt);
> @@ -1307,8 +1309,11 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
>  	if (xprt->slot == NULL)
>  		return -ENOMEM;
>  
> -	xprt->prot = IPPROTO_UDP;
> +	if (ntohs(xprt->addr.sin_port) != 0)
> +		xprt_set_bound(xprt);
>  	xprt->port = xs_get_random_port();
> +
> +	xprt->prot = IPPROTO_UDP;
>  	xprt->tsh_size = 0;
>  	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
>  	/* XXX: header size can vary due to auth type, IPv6, etc. */
> @@ -1348,8 +1353,11 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
>  	if (xprt->slot == NULL)
>  		return -ENOMEM;
>  
> -	xprt->prot = IPPROTO_TCP;
> +	if (ntohs(xprt->addr.sin_port) != 0)
> +		xprt_set_bound(xprt);
>  	xprt->port = xs_get_random_port();
> +
> +	xprt->prot = IPPROTO_TCP;
>  	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
>  	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
>  	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
