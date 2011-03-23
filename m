Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49330 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753635Ab1CWSZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 14:25:25 -0400
Date: Wed, 23 Mar 2011 14:25:24 -0400
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "Trond >> Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS: Detect loops in a readdir due to bad cookies
Message-ID: <20110323182524.GB25284@fieldses.org>
References: <4D8A3060.807@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D8A3060.807@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 23, 2011 at 01:39:44PM -0400, Bryan Schumaker wrote:
> Some filesystems (such as ext4) can return the same cookie value for multiple

Do the ext4 people know about this?  (And what's the easiest way to
reproduce it?)

--b.

> files.  If we try to start a readdir with one of these cookies, the server will
> return the first file found with a cookie of the same value.  This can cause 
> the client to enter an infinite loop.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/dir.c           |   23 ++++++++++++++++++++++-
>  include/linux/nfs_fs.h |    2 ++
>  2 files changed, 24 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b503791..dc475a7 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -139,7 +139,9 @@ static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct rpc_cred *
>  	struct nfs_open_dir_context *ctx;
>  	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
>  	if (ctx != NULL) {
> +		ctx->duped = 0;
>  		ctx->dir_cookie = 0;
> +		ctx->dup_cookie = 0;
>  		ctx->cred = get_rpccred(cred);
>  	}
>  	return ctx;
> @@ -342,11 +344,18 @@ static
>  int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
>  {
>  	int i;
> +	int new_pos;
>  	int status = -EAGAIN;
> +	struct nfs_open_dir_context *ctx = desc->file->private_data;
>  
>  	for (i = 0; i < array->size; i++) {
>  		if (array->array[i].cookie == *desc->dir_cookie) {
> -			desc->file->f_pos = desc->current_index + i;
> +			new_pos = desc->current_index + i;
> +			if (new_pos < desc->file->f_pos) {
> +				ctx->dup_cookie = *desc->dir_cookie;
> +				ctx->duped = 1;
> +			}
> +			desc->file->f_pos = new_pos;
>  			desc->cache_entry_index = i;
>  			return 0;
>  		}
> @@ -731,6 +740,18 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
>  	int i = 0;
>  	int res = 0;
>  	struct nfs_cache_array *array = NULL;
> +	struct nfs_open_dir_context *ctx = file->private_data;
> +
> +	if (ctx->duped == 1 && ctx->dup_cookie == *desc->dir_cookie) {
> +		if (printk_ratelimit()) {
> +			pr_notice("NFS: directory %s/%s contains a readdir loop.  "
> +				"Please contact your server vendor.",
> +				file->f_dentry->d_parent->d_name.name,
> +				file->f_dentry->d_name.name);
> +		}
> +		res = -ELOOP;
> +		goto out;
> +	}
>  
>  	array = nfs_readdir_get_array(desc->page);
>  	if (IS_ERR(array)) {
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 4b87c00..bbb812b 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -97,7 +97,9 @@ struct nfs_open_context {
>  
>  struct nfs_open_dir_context {
>  	struct rpc_cred *cred;
> +	int duped;
>  	__u64 dir_cookie;
> +	__u64 dup_cookie;
>  };
>  
>  /*
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
