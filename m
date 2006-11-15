From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 01/10] SUNRPC: Allocate a private data area
	for	socket-specific rpc_xprt fields
Date: Wed, 15 Nov 2006 12:22:48 -0500
Message-ID: <1163611368.5691.181.camel@lade.trondhjem.org>
References: <20061025164602.6410.27449.stgit@localhost.localdomain>
	<20061025164657.6410.31504.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkOTh-0007R3-FY
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:23:13 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/qUxZWniwLtZkFfLAasc51yBNHlf+NmOM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkOTg-0007xE-Un
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:23:14 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061025164657.6410.31504.stgit@localhost.localdomain>
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

On Wed, 2006-10-25 at 12:46 -0400, Chuck Lever wrote:
> When setting up a new transport instance, allocate enough memory for an
> rpc_xprt and a private area.  As part of the same memory allocation, it
> will be easy to find one, given a pointer to the other.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtsock.c |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index a6f778f..44df649 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -125,6 +125,10 @@ static inline void xs_pktdump(char *msg,
>  }
>  #endif
>  
> +struct sock_xprt {
> +	struct rpc_xprt		xprt;
> +};
> +
>  static void xs_format_peer_addresses(struct rpc_xprt *xprt)
>  {
>  	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
> @@ -1352,6 +1356,7 @@ static struct rpc_xprt_ops xs_tcp_ops = 
>  
>  static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen, unsigned int slot_table_size)
>  {
> +	struct sock_xprt *sx;
                            ^^ sux?

Could we please just call these sock_xprt?

>  	struct rpc_xprt *xprt;
>  
>  	if (addrlen > sizeof(xprt->addr)) {
> @@ -1359,11 +1364,12 @@ static struct rpc_xprt *xs_setup_xprt(st
>  		return ERR_PTR(-EBADF);
>  	}
>  
> -	xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL);
> -	if (xprt == NULL) {
> +	sx = kzalloc(sizeof(struct sock_xprt), GFP_KERNEL);

sizeof(*sock_xprt) please.

> +	if (sx == NULL) {
>  		dprintk("RPC:      xs_setup_xprt: couldn't allocate rpc_xprt\n");
>  		return ERR_PTR(-ENOMEM);
>  	}
> +	xprt = &sx->xprt;
>  
>  	xprt->max_reqs = slot_table_size;
>  	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
