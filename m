Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59009 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbaEVT5S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:57:18 -0400
Date: Thu, 22 May 2014 15:57:17 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix a module reference leak in svc_handle_xprt
Message-ID: <20140522195717.GF25423@fieldses.org>
References: <1400436322-5014-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400436322-5014-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 18, 2014 at 02:05:22PM -0400, Trond Myklebust wrote:
> If the accept() call fails, we need to put the module reference.

OK, applying for 3.16 and stable.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/svc_xprt.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 06c6ff0cb911..a4acaf2bcf18 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -730,6 +730,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  		newxpt = xprt->xpt_ops->xpo_accept(xprt);
>  		if (newxpt)
>  			svc_add_new_temp_xprt(serv, newxpt);
> +		else
> +			module_put(xprt->xpt_class->xcl_owner);
>  	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
>  		/* XPT_DATA|XPT_DEFERRED case: */
>  		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
> -- 
> 1.9.0
> 
