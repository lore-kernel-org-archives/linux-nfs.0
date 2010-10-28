From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: handle lock context allocation failures in
 nfs_create_request
Date: Thu, 28 Oct 2010 14:17:39 -0400
Message-ID: <1288289859.14221.13.camel@heimdal.trondhjem.org>
References: <1288275037-22816-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1706 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760717Ab0J1SSK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 14:18:10 -0400
In-Reply-To: <1288275037-22816-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-10-28 at 10:10 -0400, Jeff Layton wrote:
> nfs_get_lock_context can return NULL on an allocation failure.
> 
> Reported-by: Steve Dickson <steved@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/pagelist.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 9194902..137b549 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -65,6 +65,13 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
>  	if (req == NULL)
>  		return ERR_PTR(-ENOMEM);
>  
> +	/* get lock context early so we can deal with alloc failures */
> +	req->wb_lock_context = nfs_get_lock_context(ctx);
> +	if (req->wb_lock_context == NULL) {
> +		nfs_page_free(req);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
>  	/* Initialize the request struct. Initially, we assume a
>  	 * long write-back delay. This will be adjusted in
>  	 * update_nfs_request below if the region is not locked. */
> @@ -79,7 +86,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
>  	req->wb_pgbase	= offset;
>  	req->wb_bytes   = count;
>  	req->wb_context = get_nfs_open_context(ctx);
> -	req->wb_lock_context = nfs_get_lock_context(ctx);
>  	kref_init(&req->wb_kref);
>  	return req;
>  }

Thanks! Applied!

Trond
