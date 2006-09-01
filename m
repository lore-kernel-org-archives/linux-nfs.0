From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 019 of 19] knfsd: Register all RPC programs with
 portmapper by default
Date: Fri, 01 Sep 2006 09:25:10 -0400
Message-ID: <44F834B6.9060507@redhat.com>
References: <20060901141639.27206.patches@notabene>
	<1060901043948.27677@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ91N-0000rU-VR
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 06:25:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GJ91N-0004V7-9y
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 06:25:22 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060901043948.27677@suse.de>
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

NeilBrown wrote:
> From: Olaf Kirch <okir@suse.de>
>
>   The NFSACL patches introduced support for multiple RPC services
>   listening on the same transport. However, only the first of these
>   services was registered with portmapper. This was perfectly fine
>   for nfsacl, as you traditionally do not want these to show up in a
>   portmapper listing.
>
>   The patch below changes the default behavior to always register
>   all services listening on a given transport, but retains the
>   old behavior for nfsacl services.
>
> Signed-off-by: Olaf Kirch <okir@suse.de>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./fs/nfsd/nfs2acl.c          |    1 +
>  ./fs/nfsd/nfs3acl.c          |    1 +
>  ./include/linux/sunrpc/svc.h |    3 +++
>  ./net/sunrpc/svc.c           |   37 +++++++++++++++++++++++--------------
>  4 files changed, 28 insertions(+), 14 deletions(-)
>
> diff .prev/fs/nfsd/nfs2acl.c ./fs/nfsd/nfs2acl.c
> --- .prev/fs/nfsd/nfs2acl.c	2006-09-01 12:22:10.000000000 +1000
> +++ ./fs/nfsd/nfs2acl.c	2006-09-01 12:22:11.000000000 +1000
> @@ -333,4 +333,5 @@ struct svc_version	nfsd_acl_version2 = {
>  		.vs_proc	= nfsd_acl_procedures2,
>  		.vs_dispatch	= nfsd_dispatch,
>  		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
> +		.vs_hidden	= 1,
>  };
>
> diff .prev/fs/nfsd/nfs3acl.c ./fs/nfsd/nfs3acl.c
> --- .prev/fs/nfsd/nfs3acl.c	2006-09-01 12:22:10.000000000 +1000
> +++ ./fs/nfsd/nfs3acl.c	2006-09-01 12:22:11.000000000 +1000
> @@ -263,5 +263,6 @@ struct svc_version	nfsd_acl_version3 = {
>  		.vs_proc	= nfsd_acl_procedures3,
>  		.vs_dispatch	= nfsd_dispatch,
>  		.vs_xdrsize	= NFS3_SVC_XDRSIZE,
> +		.vs_hidden	= 1,
>  };
>  
>
> diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
> --- .prev/include/linux/sunrpc/svc.h	2006-09-01 12:22:10.000000000 +1000
> +++ ./include/linux/sunrpc/svc.h	2006-09-01 12:22:11.000000000 +1000
> @@ -304,6 +304,9 @@ struct svc_version {
>  	struct svc_procedure *	vs_proc;	/* per-procedure info */
>  	u32			vs_xdrsize;	/* xdrsize needed for this version */
>  
> +	unsigned int		vs_hidden : 1;	/* Don't register with portmapper.
> +						 * Only used for nfsacl so far. */
> +
>  	/* Override dispatch function (e.g. when caching replies).
>  	 * A return value of 0 means drop the request. 
>  	 * vs_dispatch == NULL means use default dispatcher.
>
> diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
> --- .prev/net/sunrpc/svc.c	2006-09-01 12:22:11.000000000 +1000
> +++ ./net/sunrpc/svc.c	2006-09-01 12:22:11.000000000 +1000
> @@ -644,23 +644,32 @@ svc_register(struct svc_serv *serv, int 
>  	unsigned long		flags;
>  	int			i, error = 0, dummy;
>  
> -	progp = serv->sv_program;
> -
> -	dprintk("RPC: svc_register(%s, %s, %d)\n",
> -		progp->pg_name, proto == IPPROTO_UDP? "udp" : "tcp", port);
> -
>  	if (!port)
>  		clear_thread_flag(TIF_SIGPENDING);
>  
> -	for (i = 0; i < progp->pg_nvers; i++) {
> -		if (progp->pg_vers[i] == NULL)
> -			continue;
> -		error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
> -		if (error < 0)
> -			break;
> -		if (port && !dummy) {
> -			error = -EACCES;
> -			break;
> +	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
> +		for (i = 0; i < progp->pg_nvers; i++) {
> +			if (progp->pg_vers[i] == NULL)
> +				continue;
> +
> +			dprintk("RPC: svc_register(%s, %s, %d, %d)%s\n",
> +					progp->pg_name,
> +					proto == IPPROTO_UDP?  "udp" : "tcp",
> +					port,
> +					i,
> +					progp->pg_vers[i]->vs_hidden?
> +						" (but not telling portmap)" : "");
> +
> +			if (progp->pg_vers[i]->vs_hidden)
> +				continue;
> +
> +			error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
> +			if (error < 0)
> +				break;
> +			if (port && !dummy) {
> +				error = -EACCES;
> +				break;
> +			}
>  		}
>  	}

Just out of curiosity, why does the dprintk say "svc_register", but the
code calls rpc_register?

    Thanx...

       ps

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
