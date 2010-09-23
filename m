From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2] NFS: handle inode==NULL in __put_nfs_open_context
Date: Thu, 23 Sep 2010 12:18:16 -0400
Message-ID: <1285258696.14171.0.camel@heimdal.trondhjem.org>
References: <1285244570.3329.7.camel@heimdal.trondhjem.org>
	 <1285258640-9599-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49614 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab0IWQSe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 12:18:34 -0400
In-Reply-To: <1285258640-9599-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-09-23 at 18:17 +0200, Benny Halevy wrote:
> inode may be NULL when put_nfs_open_context is called from nfs_atomic_lookup
> before d_add_unique(dentry, inode)
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/inode.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 2ff8142..702ed09 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -654,11 +654,14 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
>  {
>  	struct inode *inode = ctx->path.dentry->d_inode;
>  
> -	if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
> +	if (inode) {
> +		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
> +			return;
> +		list_del(&ctx->list);
> +		spin_unlock(&inode->i_lock);
> +		NFS_PROTO(inode)->close_context(ctx, is_sync);
> +	} else if (!atomic_dec_and_test(&ctx->lock_context.count))
>  		return;
> -	list_del(&ctx->list);
> -	spin_unlock(&inode->i_lock);
> -	NFS_PROTO(inode)->close_context(ctx, is_sync);
>  	if (ctx->cred != NULL)
>  		put_rpccred(ctx->cred);
>  	path_put(&ctx->path);

Thank you! Applied...
  Trond
