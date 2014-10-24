Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:48667 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094AbaJXL0r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 07:26:47 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so760716qac.12
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 04:26:47 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 24 Oct 2014 07:26:44 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeffrey Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        bfields@fieldses.org
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection
 when dropping a request
Message-ID: <20141024072644.6643f9ed@tlielax.poochiereds.net>
In-Reply-To: <1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
	<1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Oct 2014 13:08:28 +0300
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Both RFC3530 and RFC5661 impose a requirement on the server that it MUST NOT
> drop a request unless the connection is broken.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4proc.c         | 6 ++++++
>  include/linux/sunrpc/svc.h | 1 +
>  net/sunrpc/svc.c           | 4 ++++
>  3 files changed, 11 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index cdeb3cfd6f32..500ac76662a8 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1960,6 +1960,11 @@ static const char *nfsd4_op_name(unsigned opnum)
>  	return "unknown_operation";
>  }
>  
> +static void nfsd4_dropme(struct svc_rqst *rqstp)
> +{
> +	svc_close_xprt(rqstp->rq_xprt);
> +}
> +
>  #define nfsd4_voidres			nfsd4_voidargs
>  struct nfsd4_voidargs { int dummy; };
>  
> @@ -1989,6 +1994,7 @@ struct svc_version	nfsd_version4 = {
>  		.vs_nproc	= 2,
>  		.vs_proc	= nfsd_procedures4,
>  		.vs_dispatch	= nfsd_dispatch,
> +		.vs_dropme	= nfsd4_dropme,
>  		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
>  		.vs_rpcb_optnl	= 1,
>  };
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 21678464883a..824656da1f6d 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -400,6 +400,7 @@ struct svc_version {
>  	 * vs_dispatch == NULL means use default dispatcher.
>  	 */
>  	int			(*vs_dispatch)(struct svc_rqst *, __be32 *);
> +	void			(*vs_dropme)(struct svc_rqst *);
>  };
>  
>  /*
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index ca8a7958f4e6..09136abfef26 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1071,6 +1071,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  	struct svc_version	*versp = NULL;	/* compiler food */
>  	struct svc_procedure	*procp = NULL;
>  	struct svc_serv		*serv = rqstp->rq_server;
> +	void (*dropme)(struct svc_rqst *rqstp) = NULL;
>  	kxdrproc_t		xdr;
>  	__be32			*statp;
>  	u32			prog, vers, proc;
> @@ -1151,6 +1152,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  	if (vers >= progp->pg_nvers ||
>  	  !(versp = progp->pg_vers[vers]))
>  		goto err_bad_vers;
> +	dropme = versp->vs_dropme;
>  
>  	procp = versp->vs_proc + proc;
>  	if (proc >= versp->vs_nproc || !procp->pc_func)
> @@ -1228,6 +1230,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>   dropit:
>  	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
>  	dprintk("svc: svc_process dropit\n");
> +	if (dropme != NULL)
> +		dropme(rqstp);
>  	return 0;
>  
>  err_short_len:

(cc'ing Bruce too...)

I guess the theory here is that the client sent the request, and got a
TCP ACK and then the server never responded because it dropped the
request? That sounds plausible and we almost certainly want something
like the above for v4.0.

If the above patch fixes Christoph's problem with v4.1 though, then I
think we'll need more investigation into why. I don't see a way to get
a dropped request with v4.1. Those mainly occur due to interaction with
the DRC (disabled for v4.1) or with svc_defer (disabled for all v4
requests).

Is it possible that one of the nfsd threads is just hung while
processing an RPC and that's why you're not getting a response?

-- 
Jeff Layton <jlayton@primarydata.com>
