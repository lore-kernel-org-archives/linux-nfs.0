Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932229AbaEaBMV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 May 2014 21:12:21 -0400
Date: Fri, 30 May 2014 21:12:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC/NFSD: Remove using of dprintk with KERN_WARNING
Message-ID: <20140531011218.GB27615@fieldses.org>
References: <5386B52C.6000505@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5386B52C.6000505@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b

On Thu, May 29, 2014 at 12:18:52PM +0800, Kinglong Mee wrote:
> When debugging, rpc prints messages from dprintk(KERN_WARNING ...)
> with "^A4" prefixed,
> 
> [ 2780.339988] ^A4nfsd: connect from unprivileged port: 127.0.0.1, port=35316
> 
> Trond tells,
> > dprintk != printk. We have NEVER supported dprintk(KERN_WARNING...)
> 
> This patch removes using of dprintk with KERN_WARNING.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfsfh.c      | 5 ++---
>  net/sunrpc/svcsock.c | 3 +--
>  2 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index a337106..ec83934 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -88,9 +88,8 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
>  	/* Check if the request originated from a secure port. */
>  	if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
>  		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> -		dprintk(KERN_WARNING
> -		       "nfsd: request from insecure port %s!\n",
> -		       svc_print_addr(rqstp, buf, sizeof(buf)));
> +		dprintk("nfsd: request from insecure port %s!\n",
> +		        svc_print_addr(rqstp, buf, sizeof(buf)));
>  		return nfserr_perm;
>  	}
>  
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index f3b8eb3..b507cd3 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -849,8 +849,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
>  	 * tell us anything.  For now just warn about unpriv connections.
>  	 */
>  	if (!svc_port_is_privileged(sin)) {
> -		dprintk(KERN_WARNING
> -			"%s: connect from unprivileged port: %s\n",
> +		dprintk("%s: connect from unprivileged port: %s\n",
>  			serv->sv_name,
>  			__svc_print_addr(sin, buf, sizeof(buf)));
>  	}
> -- 
> 1.9.3
> 
