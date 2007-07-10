From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 19/20] knfsd: call svc_create_svcsock
Date: Tue, 10 Jul 2007 19:32:45 -0400
Message-ID: <1184110365.6480.41.camel@heimdal.trondhjem.org>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
	<20070710053500.28979.94056.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8PCL-0001LL-Qm
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 16:32:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18ZJkg468shPrJeqGX/apNEEVAHXd3M74k=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I8PCN-0007YZ-O5
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 16:32:53 -0700
In-Reply-To: <20070710053500.28979.94056.stgit@dell3.ogc.int>
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

On Tue, 2007-07-10 at 00:35 -0500, Tom Tucker wrote:
> Change the call to the socket specific svc_makesock to a call to the
> transport independent svc_create_svcsock function. This avoids 
> conditional #ifdef's for the rdma transport in the nfsd code. 
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  fs/nfsd/nfssvc.c     |    8 ++++----
>  net/sunrpc/svcsock.c |    1 +
>  2 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index ff55950..1499beb 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -235,8 +235,8 @@ static int nfsd_init_socks(int port)
>  
>  	error = lockd_up(IPPROTO_UDP);
>  	if (error >= 0) {
> -		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port,
> -					SVC_SOCK_DEFAULTS);
> +		error = svc_create_svcsock(nfsd_serv, "udp", port,
> +					   SVC_SOCK_DEFAULTS);
>  		if (error < 0)
>  			lockd_down();
>  	}
> @@ -246,8 +246,8 @@ static int nfsd_init_socks(int port)
>  #ifdef CONFIG_NFSD_TCP
>  	error = lockd_up(IPPROTO_TCP);
>  	if (error >= 0) {
> -		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port,
> -					SVC_SOCK_DEFAULTS);
> +		error = svc_create_svcsock(nfsd_serv, "tcp", port,
> +					   SVC_SOCK_DEFAULTS);
>  		if (error < 0)
>  			lockd_down();
>  	}
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b0e1b61..67a1d59 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -2111,6 +2111,7 @@ int svc_create_svcsock(struct svc_serv *
>   out:
>  	return ret;
>  }
> +EXPORT_SYMBOL(svc_create_svcsock);

...again. Really wants to be an EXPORT_SYMBOL_GPL().

>  /*
>   * Handle defer and revisit of requests
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
