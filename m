From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,
	PATCH 5/15] knfsd: support RDMA transport	in	svc_create_socket.
Date: Fri, 18 May 2007 14:25:02 -0400
Message-ID: <1179512702.6488.121.camel@heimdal.trondhjem.org>
References: <1179510317.23385.118.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp78U-0005dx-Ty
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:25:07 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19guHWEWx9CntAk6qTnAX7Sw2Tkb6PKNIE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp78X-0001zG-2x
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:25:09 -0700
In-Reply-To: <1179510317.23385.118.camel@trinity.ogc.int>
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

On Fri, 2007-05-18 at 12:45 -0500, Tom Tucker wrote:
> Adds a call to create RDMA transports to svc_create_socket.
> Currently, we use IPPROTO_MAX, which is a work-around. The transport 
> switch should ultimately provide transport types that are advertised 
> by the transport drivers.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  net/sunrpc/svcsock.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b78e84b..9c2f8ee 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -46,6 +46,9 @@ #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/xdr.h>
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/stats.h>
> +#ifdef CONFIG_NFSD_RDMA
> +#include <linux/sunrpc/svc_rdma.h>
> +#endif
>  
>  /* SMP locking strategy:
>   *
> @@ -1805,6 +1808,11 @@ static int svc_create_socket(struct svc_
>  			serv->sv_program->pg_name, protocol,
>  			__svc_print_addr(sin, buf, sizeof(buf)));
>  
> +#ifdef CONFIG_NFSD_RDMA
> +	if (protocol == IPPROTO_MAX)
> +		return svc_rdma_create_listen(serv, protocol, 
> +					      (struct sockaddr*)sin);
> +#endif
>  	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
>  		printk(KERN_WARNING "svc: only UDP and TCP "
>  				"sockets supported\n");

Ditto... Please avoid inlined #ifdefs....



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
