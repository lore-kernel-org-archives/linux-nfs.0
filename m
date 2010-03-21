From: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: Fix a potential memory leak in auth_gss
Date: Sat, 20 Mar 2010 21:45:16 -0400
Message-ID: <20100321014516.GC30408@fieldses.org>
References: <1269026879.10771.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38691 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304Ab0CUBn2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Mar 2010 21:43:28 -0400
In-Reply-To: <1269026879.10771.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 19, 2010 at 03:27:59PM -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The function alloc_enc_pages() currently fails to release the pointer
> rqstp->rq_enc_pages in the error path.

Thanks, and it's simpler, too.  For what it's worth:

	Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/auth_gss/auth_gss.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 0cfccc2..c389ccf 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1280,9 +1280,8 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
>  	rqstp->rq_release_snd_buf = priv_release_snd_buf;
>  	return 0;
>  out_free:
> -	for (i--; i >= 0; i--) {
> -		__free_page(rqstp->rq_enc_pages[i]);
> -	}
> +	rqstp->rq_enc_pages_num = i;
> +	priv_release_snd_buf(rqstp);
>  out:
>  	return -EAGAIN;
>  }
> 
