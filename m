Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33708 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752928AbdGLT6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Jul 2017 15:58:00 -0400
Date: Wed, 12 Jul 2017 15:57:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: Remove NULL element at the end of rq_pages
Message-ID: <20170712195759.GA19030@fieldses.org>
References: <20170712160657.24663.66681.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170712160657.24663.66681.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 12, 2017 at 12:10:40PM -0400, Chuck Lever wrote:
> Bruce points out that the NULL final element of rq_pages is unneeded
> by nfs_read_actor. Remove it.
> 
> Thus the 260th element of rq_pages is also no longer needed.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi Bruce-
> 
> I've been testing this one. No issues for NFSv4.0 on RDMA with
> krb5i, but NFSv4.0 on TCP with krb5i encounters a problem. The
> server log shows this message:
> 
> rpc-srv/tcp: nfsd: sent only 108 when sending 140 bytes - shutting down socket
> 
> And iozone stalls on the client. I haven't looked more closely.

Huh.

OK, well maybe there is some code I haven't spotted that depends on that
final NULL in rq_pages, or maybe this is just an unrelated bug, but I
think it's safest just to stick your previous version (from Message-ID:
<20170630160258.11995.10205.stgit@klimt.1015granger.net>) back into the
series and then sort this out later.

But we should clean up these constants and comments, it's confusing
stuff in exactly the sort of code where a mistake could mean letting
anyone on the internet write to your memory.

--b.

> 
> 
>  include/linux/sunrpc/svc.h |    2 +-
>  net/sunrpc/svc_xprt.c      |    1 -
>  2 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index d741399..5500544 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -246,7 +246,7 @@ struct svc_rqst {
>  	size_t			rq_xprt_hlen;	/* xprt header len */
>  	struct xdr_buf		rq_arg;
>  	struct xdr_buf		rq_res;
> -	struct page		*rq_pages[RPCSVC_MAXPAGES + 1];
> +	struct page		*rq_pages[RPCSVC_MAXPAGES];
>  	struct page *		*rq_respages;	/* points into rq_pages */
>  	struct page *		*rq_next_page; /* next reply page to use */
>  	struct page *		*rq_page_end;  /* one past the last page */
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index d16a8b4..b7efd16 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -680,7 +680,6 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
>  			rqstp->rq_pages[i] = p;
>  		}
>  	rqstp->rq_page_end = &rqstp->rq_pages[i];
> -	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
>  
>  	/* Make arg->head point to first page and arg->pages point to rest */
>  	arg = &rqstp->rq_arg;
