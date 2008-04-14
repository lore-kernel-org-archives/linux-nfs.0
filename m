From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 09/24] SUNRPC: Use unsigned index when looping over
	arrays
Date: Mon, 14 Apr 2008 14:51:13 -0400
Message-ID: <20080414185113.GK15950@fieldses.org>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net> <20080414162745.12741.37176.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49682 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932207AbYDNSvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 14:51:31 -0400
In-Reply-To: <20080414162745.12741.37176.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 14, 2008 at 12:27:45PM -0400, Chuck Lever wrote:
> Clean up: Suppress a harmless compiler warning in the RPC server related
> to array indices.
> 
> ARRAY_SIZE() returns a size_t, so use unsigned type for a loop index when
> looping over arrays.

OK (and thanks for the "harmless compiler warning clarification").--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/svc.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index a290e15..c1e763b 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -528,8 +528,9 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
>  static void
>  svc_release_buffer(struct svc_rqst *rqstp)
>  {
> -	int i;
> -	for (i=0; i<ARRAY_SIZE(rqstp->rq_pages); i++)
> +	unsigned int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(rqstp->rq_pages); i++)
>  		if (rqstp->rq_pages[i])
>  			put_page(rqstp->rq_pages[i]);
>  }
> 
