From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 6/8] pnfs-submit: change layouts list to be similar to
 the other state list management
Date: Wed, 26 May 2010 11:49:24 +0300
Message-ID: <4BFCE094.7020302@panasas.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com> <1274119004-30213-2-git-send-email-batsakis@netapp.com> <1274119004-30213-3-git-send-email-batsakis@netapp.com> <1274119004-30213-4-git-send-email-batsakis@netapp.com> <1274119004-30213-5-git-send-email-batsakis@netapp.com> <1274119004-30213-6-git-send-email-batsakis@netapp.com> <1274119004-30213-7-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50427 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536Ab0EZIta (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 04:49:30 -0400
Received: by fxm5 with SMTP id 5so4118084fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 01:49:29 -0700 (PDT)
In-Reply-To: <1274119004-30213-7-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-05-17 20:56, Alexandros Batsakis wrote:
> The current design keeps a list (nfs_client) of inodes having layouts.
> In order to make that code more similar to delegation handling (and in general to the rest of the NFS code), this patch changes the list element to layouts directly.
> No backpointer from the layout to the inode is needed as the inode can be accesed by a container_of() call
> 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/callback_proc.c    |    9 +++++++--
>  fs/nfs/client.c           |    2 +-
>  fs/nfs/inode.c            |    4 ++--
>  fs/nfs/pnfs.c             |   10 ++++------
>  include/linux/nfs_fs.h    |    3 +--
>  include/linux/nfs_fs_sb.h |    2 +-
>  6 files changed, 16 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index bfada25..24e2571 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -76,7 +76,6 @@ static int (*nfs_validate_delegation_stateid(struct nfs_client *clp))(struct nfs
>  	return nfs4_validate_delegation_stateid;
>  }
>  
> -
>  __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
>  {
>  	struct nfs_client *clp;
> @@ -140,6 +139,7 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
>  			    const struct cb_pnfs_layoutrecallargs *args)
>  {
>  	struct nfs_inode *nfsi;
> +	struct pnfs_layout_type *layout;
>  	struct nfs_server *server;
>  	struct inode *ino = NULL;
>  
> @@ -147,9 +147,14 @@ nfs_layoutrecall_find_inode(struct nfs_client *clp,
>  		__func__, args->cbl_recall_type, clp);
>  
>  	spin_lock(&clp->cl_lock);
> -	list_for_each_entry(nfsi, &clp->cl_lo_inodes, lo_inodes) {
> +	list_for_each_entry(layout, &clp->cl_layouts, lo_layouts) {
> +		nfsi = PNFS_NFS_INODE(layout);
> +		if (!nfsi)
> +			continue;
> +
>  		dprintk("%s: Searching inode=%lu\n",
>  			__func__, nfsi->vfs_inode.i_ino);
> +
>  		if (args->cbl_recall_type == RETURN_FILE) {
>  		    if (nfs_compare_fh(&args->cbl_fh, &nfsi->fh))
>  			continue;
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index d4759dd..d60e5d7 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -157,7 +157,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	if (!IS_ERR(cred))
>  		clp->cl_machine_cred = cred;
>  #if defined(CONFIG_NFS_V4_1)
> -	INIT_LIST_HEAD(&clp->cl_lo_inodes);
> +	INIT_LIST_HEAD(&clp->cl_layouts);
>  #endif
>  	nfs_fscache_get_client_cookie(clp);
>  
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index ab599be..adf3280 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1363,7 +1363,7 @@ static void pnfs_destroy_inode(struct nfs_inode *nfsi)
>  	if (!list_empty(&nfsi->layout.segs))
>  		pnfs_destroy_layout(nfsi);
>  
> -	BUG_ON(!list_empty(&nfsi->lo_inodes));
> +	BUG_ON(!list_empty(&nfsi->layout.lo_layouts));
>  	BUG_ON(!list_empty(&nfsi->layout.segs));
>  	BUG_ON(nfsi->layout.refcount);
>  	BUG_ON(nfsi->layout.ld_data);
> @@ -1381,10 +1381,10 @@ void nfs_destroy_inode(struct inode *inode)
>  static void pnfs_init_once(struct nfs_inode *nfsi)
>  {
>  #ifdef CONFIG_NFS_V4_1
> -	INIT_LIST_HEAD(&nfsi->lo_inodes);
>  	init_waitqueue_head(&nfsi->lo_waitq);
>  	spin_lock_init(&nfsi->lo_lock);
>  	seqlock_init(&nfsi->layout.seqlock);
> +	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
>  	INIT_LIST_HEAD(&nfsi->layout.segs);
>  	nfsi->layout.refcount = 0;
>  	nfsi->layout.ld_data = NULL;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 2cc8895..3b4dea0 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -364,10 +364,10 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
>  		io_ops->free_layout(lo->ld_data);
>  		lo->ld_data = NULL;
>  
> -		/* Unlist the inode. */
> +		/* Unlist the layout. */
>  		clp = NFS_SERVER(&nfsi->vfs_inode)->nfs_client;
>  		spin_lock(&clp->cl_lock);
> -		list_del_init(&nfsi->lo_inodes);
> +		list_del_init(&lo->lo_layouts);
>  		spin_unlock(&clp->cl_lock);
>  	}
>  out:
> @@ -881,10 +881,8 @@ alloc_init_layout(struct inode *ino)
>  
>  	BUG_ON(lo->ld_data != NULL);
>  	lo->ld_data = ld_data;
> -	seqlock_init(&lo->seqlock);
>  	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
>  	lo->refcount = 1;
> -	INIT_LIST_HEAD(&lo->segs);
>  	lo->roc_iomode = 0;
>  	return lo;
>  }
> @@ -940,8 +938,8 @@ get_lock_alloc_layout(struct inode *ino)
>  			lock_current_layout(nfsi);
>  
>  			spin_lock(&clp->cl_lock);
> -			if (list_empty(&nfsi->lo_inodes))
> -				list_add_tail(&nfsi->lo_inodes, &clp->cl_lo_inodes);
> +			if (list_empty(&lo->lo_layouts))
> +				list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
>  			spin_unlock(&clp->cl_lock);
>  		} else
>  			lo = ERR_PTR(-ENOMEM);
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 2434bba..2a80be8 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -99,6 +99,7 @@ struct posix_acl;
>  
>  struct pnfs_layout_type {
>  	int refcount;
> +	struct list_head lo_layouts;	/* other inode layouts */

It's "other client layouts" actually.
I think the name is confusing.
How about "per_client" instead?

Benny

>  	struct list_head segs;		/* layout segments list */
>  	int roc_iomode;			/* iomode to return on close, 0=none */
>  	seqlock_t seqlock;		/* Protects the stateid */
> @@ -205,8 +206,6 @@ struct nfs_inode {
>  
>  	/* pNFS layout information */
>  #if defined(CONFIG_NFS_V4_1)
> -	/* Inodes having layouts */
> -	struct list_head	lo_inodes;
>  	wait_queue_head_t lo_waitq;
>  	spinlock_t lo_lock;
>  	struct pnfs_layout_type layout;
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 00a4e7e..0c92889 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -86,7 +86,7 @@ struct nfs_client {
>  	/* The flags used for obtaining the clientid during EXCHANGE_ID */
>  	u32			cl_exchange_flags;
>  	struct nfs4_session	*cl_session; 	/* sharred session */
> -	struct list_head	cl_lo_inodes;	/* Inodes having layouts */
> +	struct list_head	cl_layouts;
>  	struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
>  #endif /* CONFIG_NFS_V4_1 */
>  

