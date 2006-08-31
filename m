From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 4/22] When looking up a lockd host,
	pass hostname & length
Date: Thu, 31 Aug 2006 16:42:48 +1000
Message-ID: <17654.34024.497695.768321@cse.unsw.edu.au>
References: <20060805130647.GA8034@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GIgGR-0005iX-BR
	for nfs@lists.sourceforge.net; Wed, 30 Aug 2006 23:42:59 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GIgGQ-0002OS-Mx
	for nfs@lists.sourceforge.net; Wed, 30 Aug 2006 23:43:00 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 061F91FACB
	for <nfs@lists.sourceforge.net>; Thu, 31 Aug 2006 08:42:54 +0200 (CEST)
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Saturday August 5
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


(Finally got back to reviewing these lockd patches).

On Saturday August 5, okir@suse.de wrote:
> From: Olaf Kirch <okir@suse.de>
> Subject: When looking up a lockd host, pass hostname & length
> 
>   This patch adds the peer's hostname (and name length) to
>   all calls to nlm*_lookup_host functions. A subsequent patch
>   will make use of these.

Ok, this has me stumped.....

> Index: build/fs/lockd/svc4proc.c
> ===================================================================
> --- build.orig/fs/lockd/svc4proc.c
> +++ build/fs/lockd/svc4proc.c
> @@ -38,7 +38,7 @@ nlm4svc_retrieve_args(struct svc_rqst *r
>  		return nlm_lck_denied_nolocks;
>  
>  	/* Obtain host handle */
> -	if (!(host = nlmsvc_lookup_host(rqstp))
> +	if (!(host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len))
>  	 || (argp->monitor && nsm_monitor(host) < 0))
>  		goto no_locks;
>  	*hostp = host;

For the 'synchronous' lockd calls (e.g. nlm4svc_proc_lock) we pass
lock->caller as the host name, however 

> @@ -260,7 +260,7 @@ static int nlm4svc_callback(struct svc_r
>  	struct nlm_rqst	*call;
>  	int stat;
>  
> -	host = nlmsvc_lookup_host(rqstp);
> +	host = nlmsvc_lookup_host(rqstp, NULL, 0);
>  	if (host == NULL)
>  		return rpc_system_err;
>  

For the async one (e.g. nlm4svc_proc_lock_msg) we pass NULL.

Why is this so?

I'm going to change it to be
> +	host = nlmsvc_lookup_host(rqstp, argp->lock->caller,
> +                               argp->lock_len);

Ok?

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
