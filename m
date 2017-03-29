Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932571AbdC2BQj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Mar 2017 21:16:39 -0400
Date: Tue, 28 Mar 2017 21:16:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Chuck Lever <chucklever@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
Message-ID: <20170329011638.GA20963@fieldses.org>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
 <1490577699.6879.1.camel@poochiereds.net>
 <62622BEB-E234-4035-94FE-0C34E00693AE@gmail.com>
 <FBC1AD99-AF91-42B7-9C38-C68DA5454C94@oracle.com>
 <1490612833.2808.1.camel@poochiereds.net>
 <1490618353.6879.3.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1490618353.6879.3.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 27, 2017 at 08:39:13AM -0400, Jeff Layton wrote:
> Something like this patch maybe? Builds but is otherwise untested. It
> might not DTRT though in the (nonsensical) case where you have a server
> that is listening on UDP but doesn't support v2 or v3. Not sure I
> really care about that too much.

I don't think this is worth the trouble.

A client that attempts to mount NFSv4 over UDP is operating out of spec,
and we don't owe them much.

I'm not even convinced that transport-specific high/low version returns
are correct.  A client could in theory be configured to prefer UDP and
NFSv3, but to fall back to NFSv4 and TCP if NFSv3 was unavailable, and
this would break that.  That would be legal but admittedly odd client
behavior.

If somebody actually hits a case where this patch would help, then let's
reconsider.

--b.

> 
> [PATCH] sunrpc: dynamically set versions in PROG_MISMATCH error reply
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/sunrpc/svc.h |  2 --
>  net/sunrpc/svc.c           | 47 ++++++++++++++++++++++++++++++++++------------
>  2 files changed, 35 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index e770abeed32d..f19321cfcf21 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -381,8 +381,6 @@ struct svc_deferred_req {
>  struct svc_program {
>  	struct svc_program *	pg_next;	/* other programs (same xprt) */
>  	u32			pg_prog;	/* program number */
> -	unsigned int		pg_lovers;	/* lowest version */
> -	unsigned int		pg_hivers;	/* highest version */
>  	unsigned int		pg_nvers;	/* number of versions */
>  	struct svc_version **	pg_vers;	/* version array */
>  	char *			pg_name;	/* service name */
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index a08aeb56b8e4..c81f68064313 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -441,18 +441,13 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  	serv->sv_ops = ops;
>  	xdrsize = 0;
>  	while (prog) {
> -		prog->pg_lovers = prog->pg_nvers-1;
>  		for (vers=0; vers<prog->pg_nvers ; vers++)
> -			if (prog->pg_vers[vers]) {
> -				prog->pg_hivers = vers;
> -				if (prog->pg_lovers > vers)
> -					prog->pg_lovers = vers;
> -				if (prog->pg_vers[vers]->vs_xdrsize > xdrsize)
> -					xdrsize = prog->pg_vers[vers]->vs_xdrsize;
> -			}
> +			if (prog->pg_vers[vers] &&
> +			    prog->pg_vers[vers]->vs_xdrsize > xdrsize)
> +				xdrsize = prog->pg_vers[vers]->vs_xdrsize;
>  		prog = prog->pg_next;
>  	}
> -	serv->sv_xdrsize   = xdrsize;
> +	serv->sv_xdrsize = xdrsize;
>  	INIT_LIST_HEAD(&serv->sv_tempsocks);
>  	INIT_LIST_HEAD(&serv->sv_permsocks);
>  	init_timer(&serv->sv_temptimer);
> @@ -1086,6 +1081,36 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
>  static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...) {}
>  #endif
>  
> +static void
> +svc_set_prog_mismatch(struct svc_rqst *rqstp, struct svc_program *prog,
> +		      struct kvec *resv)
> +{
> +	unsigned int vers, hi = 0, lo = prog->pg_nvers - 1;
> +	struct svc_version *versp;
> +
> +	for (vers = 0; vers < prog->pg_nvers ; vers++) {
> +		versp = prog->pg_vers[vers];
> +		if (!versp)
> +			continue;
> +
> +		/*
> +		 * Don't report this version if it needs congestion control
> +		 * and the xprt doesn't provide it.
> +		 */
> +		if (versp->vs_need_cong_ctrl &&
> +		    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
> +			continue;
> +
> +		hi = vers;
> +		if (lo > vers)
> +			lo = vers;
> +	}
> +
> +	svc_putnl(resv, RPC_PROG_MISMATCH);
> +	svc_putnl(resv, lo);
> +	svc_putnl(resv, hi);
> +}
> +
>  /*
>   * Common routine for processing the RPC request.
>   */
> @@ -1315,9 +1340,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  		       vers, prog, progp->pg_name);
>  
>  	serv->sv_stats->rpcbadfmt++;
> -	svc_putnl(resv, RPC_PROG_MISMATCH);
> -	svc_putnl(resv, progp->pg_lovers);
> -	svc_putnl(resv, progp->pg_hivers);
> +	svc_set_prog_mismatch(rqstp, progp, resv);
>  	goto sendit;
>  
>  err_bad_proc:
> -- 
> 2.9.3
