From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/19] NFS/SUNRPC: support transport protocol
	naming
Date: Mon, 10 Sep 2007 20:25:32 -0400
Message-ID: <46E5E07C.5070202@oracle.com>
References: <EXNANE01tacom1iaCRq000004bb@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020909090004080103090804"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUtZo-0008CE-3w
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:26:00 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IUtZr-0004Ou-CY
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:26:04 -0700
In-Reply-To: <EXNANE01tacom1iaCRq000004bb@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------020909090004080103090804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Just a general comment.

I don't see how this will make it easier to add NFS client support for 
new RPC transports.  I thought we recently decided to pass down a 
string, and let the transports themselves register a netid that matches it?

For example, these changes are required to support RDMA -- you can't 
just ship a new RDMA SUNRPC transport module and expect it to work 
without this ULP change.  Likewise, if we add SCTP sometime in the 
future, will we want to make this same kind of modification to the NFS 
client before the SCTP SUNRCP transport module works correctly?

Talpey, Thomas wrote:
> NFS/SUNRPC: support transport protocol naming
> 
> To prepare for including non-sockets-based RPC transports, select
> RPC transports by an identifier (to be used in following patches).
> 
> Signed-off-by: Tom Talpey <tmt@netapp.com>
> 
> ---
> 
>  include/linux/sunrpc/xprt.h     |    5 ++---
>  include/linux/sunrpc/xprtsock.h |   11 +++++++++++
>  net/sunrpc/clnt.c               |    2 +-
>  net/sunrpc/xprt.c               |    8 +++-----
>  net/sunrpc/xprtsock.c           |    6 ++----
>  5 files changed, 19 insertions(+), 13 deletions(-)
> 
> Index: kernel/include/linux/sunrpc/xprt.h
> ===================================================================
> --- kernel.orig/include/linux/sunrpc/xprt.h
> +++ kernel/include/linux/sunrpc/xprt.h
> @@ -187,7 +187,7 @@ struct rpc_xprt {
>  };
>  
>  struct xprt_create {
> -	int			proto;		/* IPPROTO_UDP or IPPROTO_TCP */
> +	int			ident;		/* XPRT_TRANSPORT identifier */
>  	struct sockaddr *	srcaddr;	/* optional local address */
>  	struct sockaddr *	dstaddr;	/* remote peer address */
>  	size_t			addrlen;
> @@ -196,8 +196,7 @@ struct xprt_create {
>  
>  struct xprt_class {
>  	struct list_head	list;
> -	unsigned short		family;
> -	int			protocol;
> +	int			ident;		/* XPRT_TRANSPORT identifier */
>  	struct rpc_xprt *	(*setup)(struct xprt_create *);
>  	struct module		*owner;
>  	char			name[32];
> Index: kernel/include/linux/sunrpc/xprtsock.h
> ===================================================================
> --- kernel.orig/include/linux/sunrpc/xprtsock.h
> +++ kernel/include/linux/sunrpc/xprtsock.h
> @@ -19,6 +19,17 @@ int		init_socket_xprt(void);
>  void		cleanup_socket_xprt(void);
>  
>  /*
> + * RPC transport identifiers for UDP, TCP
> + *
> + * To preserve compatibility with the historical use of raw IP protocol
> + * id's for transport selection, these are specified with the previous
> + * values. No such restriction exists for new transports, except that
> + * they may not collide with these values (17 and 6, respectively).
> + */
> +#define XPRT_TRANSPORT_UDP	IPPROTO_UDP
> +#define XPRT_TRANSPORT_TCP	IPPROTO_TCP
> +
> +/*
>   * RPC slot table sizes for UDP, TCP transports
>   */
>  extern unsigned int xprt_udp_slot_table_entries;
> Index: kernel/net/sunrpc/xprt.c
> ===================================================================
> --- kernel.orig/net/sunrpc/xprt.c
> +++ kernel/net/sunrpc/xprt.c
> @@ -104,7 +104,7 @@ int xprt_register_transport(struct xprt_
>  	spin_lock(&xprt_list_lock);
>  	list_for_each_entry(t, &xprt_list, list) {
>  		/* don't register the same transport class twice */
> -		if (t == transport)
> +		if (t->ident == transport->ident)
>  			goto out;
>  	}
>  
> @@ -987,15 +987,13 @@ struct rpc_xprt *xprt_create_transport(s
>  
>  	spin_lock(&xprt_list_lock);
>  	list_for_each_entry(t, &xprt_list, list) {
> -		if ((t->family == args->dstaddr->sa_family) &&
> -		    (t->protocol == args->proto)) {
> +		if (t->ident == args->ident) {
>  			spin_unlock(&xprt_list_lock);
>  			goto found;
>  		}
>  	}
>  	spin_unlock(&xprt_list_lock);
> -	printk(KERN_ERR "RPC: transport (%u/%d) not supported\n",
> -			args->dstaddr->sa_family, args->proto);
> +	printk(KERN_ERR "RPC: transport (%d) not supported\n", args->ident);
>  	return ERR_PTR(-EIO);
>  
>  found:
> Index: kernel/net/sunrpc/xprtsock.c
> ===================================================================
> --- kernel.orig/net/sunrpc/xprtsock.c
> +++ kernel/net/sunrpc/xprtsock.c
> @@ -1955,8 +1955,7 @@ static struct xprt_class	xs_udp_transpor
>  	.list		= LIST_HEAD_INIT(xs_udp_transport.list),
>  	.name		= "udp",
>  	.owner		= THIS_MODULE,
> -	.family		= AF_INET,
> -	.protocol	= IPPROTO_UDP,
> +	.ident		= IPPROTO_UDP,
>  	.setup		= xs_setup_udp,
>  };
>  
> @@ -1964,8 +1963,7 @@ static struct xprt_class	xs_tcp_transpor
>  	.list		= LIST_HEAD_INIT(xs_tcp_transport.list),
>  	.name		= "tcp",
>  	.owner		= THIS_MODULE,
> -	.family		= AF_INET,
> -	.protocol	= IPPROTO_TCP,
> +	.ident		= IPPROTO_TCP,
>  	.setup		= xs_setup_tcp,
>  };
>  
> Index: kernel/net/sunrpc/clnt.c
> ===================================================================
> --- kernel.orig/net/sunrpc/clnt.c
> +++ kernel/net/sunrpc/clnt.c
> @@ -235,7 +235,7 @@ struct rpc_clnt *rpc_create(struct rpc_c
>  	struct rpc_xprt *xprt;
>  	struct rpc_clnt *clnt;
>  	struct xprt_create xprtargs = {
> -		.proto = args->protocol,
> +		.ident = args->protocol,
>  		.srcaddr = args->saddress,
>  		.dstaddr = args->address,
>  		.addrlen = args->addrsize,
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--------------020909090004080103090804
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------020909090004080103090804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------020909090004080103090804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020909090004080103090804--
