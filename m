From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/9] SUNRPC: Allocate a private data area
	for	socket-specific rpc_xprt fields
Date: Wed, 18 Oct 2006 16:18:45 -0400
Message-ID: <1161202725.6095.123.camel@lade.trondhjem.org>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211508.8734.89856.stgit@ingres.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaHsV-0002te-Cy
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:19:10 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaHsR-0004HH-Oj
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:19:04 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061012211508.8734.89856.stgit@ingres.dsl.sfldmi.ameritech.net>
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
> When setting up a new transport instance, allocate enough memory for an
> rpc_xprt and a private area.  As part of the same memory allocation, it
> will be easy to find one, given a pointer to the other.
> 
> Test plan:
> Compile kernel with CONFIG_NFS enabled.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtsock.c |   15 +++++++++++++--
>  1 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index a6f778f..5ddb20d 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -125,6 +125,15 @@ static inline void xs_pktdump(char *msg,
>  }
>  #endif
>  
> +struct xs_xprt {
> +	struct rpc_xprt		xprt;
> +};

That name tells you nothing about what it contains. How about something
like 'struct rpc_xprt_sock' instead?

> +static inline struct xs_xprt *xs_private_data(struct rpc_xprt *xprt)
> +{
> +	return (struct xs_xprt *) xprt;

Should use container_of() instead of a cast.

Why do we want this extra wrapper anyway? It gives you no extra type
security compared to container_of().

> +}
> +
>  static void xs_format_peer_addresses(struct rpc_xprt *xprt)
>  {
>  	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
> @@ -1352,6 +1361,7 @@ static struct rpc_xprt_ops xs_tcp_ops = 
>  
>  static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen, unsigned int slot_table_size)
>  {
> +	struct xs_xprt *private;
>  	struct rpc_xprt *xprt;
>  
>  	if (addrlen > sizeof(xprt->addr)) {
> @@ -1359,11 +1369,12 @@ static struct rpc_xprt *xs_setup_xprt(st
>  		return ERR_PTR(-EBADF);
>  	}
>  
> -	xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL);
> -	if (xprt == NULL) {
> +	private = kzalloc(sizeof(struct xs_xprt), GFP_KERNEL);
> +	if (private == NULL) {
>  		dprintk("RPC:      xs_setup_xprt: couldn't allocate rpc_xprt\n");
>  		return ERR_PTR(-ENOMEM);
>  	}
> +	xprt = &private->xprt;
>  
>  	xprt->max_reqs = slot_table_size;
>  	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
