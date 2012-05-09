Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54379 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758312Ab2EIQGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 12:06:35 -0400
Date: Wed, 9 May 2012 12:06:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: do array overrun check in svc_recv before
 allocating pages
Message-ID: <20120509160634.GC24233@fieldses.org>
References: <1336146252-8669-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336146252-8669-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 04, 2012 at 11:44:12AM -0400, Jeff Layton wrote:
> There's little point in waiting until after we allocate all of the pages
> to see if we're going to overrun the array. In the event that this
> calculation is really off we could end up scribbling over a bunch of
> memory and make it tougher to debug.

OK, thanks.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/svc_xprt.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 4bda09d..8195c6a 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -601,6 +601,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  
>  	/* now allocate needed pages.  If we get a failure, sleep briefly */
>  	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
> +	BUG_ON(pages >= RPCSVC_MAXPAGES);
>  	for (i = 0; i < pages ; i++)
>  		while (rqstp->rq_pages[i] == NULL) {
>  			struct page *p = alloc_page(GFP_KERNEL);
> @@ -615,7 +616,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  			rqstp->rq_pages[i] = p;
>  		}
>  	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
> -	BUG_ON(pages >= RPCSVC_MAXPAGES);
>  
>  	/* Make arg->head point to first page and arg->pages point to rest */
>  	arg = &rqstp->rq_arg;
> -- 
> 1.7.7.6
> 
