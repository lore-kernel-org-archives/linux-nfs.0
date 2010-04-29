From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 07/13] SQUASHME pnfs_submit: remove struct pnfs_mount_type
Date: Thu, 29 Apr 2010 19:28:20 +0300
Message-ID: <4BD9B3A4.8090005@panasas.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com> <1272493465-3398-2-git-send-email-andros@netapp.com> <1272493465-3398-3-git-send-email-andros@netapp.com> <1272493465-3398-4-git-send-email-andros@netapp.com> <1272493465-3398-5-git-send-email-andros@netapp.com> <1272493465-3398-6-git-send-email-andros@netapp.com> <1272493465-3398-7-git-send-email-andros@netapp.com> <1272493465-3398-8-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:46712 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933515Ab0D3RpA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Apr 2010 13:45:00 -0400
Received: by wwb34 with SMTP id 34so367756wwb.19
        for <linux-nfs@vger.kernel.org>; Fri, 30 Apr 2010 10:44:57 -0700 (PDT)
In-Reply-To: <1272493465-3398-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/29/2010 01:24 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The pnfs_mount_type structure was used to store per layout type device id
> caches. It is no longer needed with the generic device id cache in struct
> nfs_client.
> 

Same here NACK

> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c   |   40 +++++++---------------------------------
>  fs/nfs/pnfs.c             |    8 ++------
>  include/linux/nfs4_pnfs.h |   15 +--------------
>  include/linux/nfs_fs_sb.h |    2 --
>  4 files changed, 10 insertions(+), 55 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 8d6f685..36a8fe1 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -68,45 +68,19 @@ struct pnfs_client_operations *pnfs_callback_ops;
>  ssize_t filelayout_get_stripesize(struct pnfs_layout_type *);
>  struct layoutdriver_io_operations filelayout_io_operations;
>  
> -/* Initialize and return the pnfs_mount_type structure so the
> - * pNFS_client can refer to the mount point later on
> - */
> -struct pnfs_mount_type*
> +int
>  filelayout_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
>  {
> -	struct filelayout_mount_type *fl_mt;
> -	struct pnfs_mount_type *mt;
> -
> -	fl_mt = kmalloc(sizeof(struct filelayout_mount_type), GFP_KERNEL);
> -	if (!fl_mt)
> -		goto error_ret;
> -
> -	mt = kmalloc(sizeof(struct pnfs_mount_type), GFP_KERNEL);
> -	if (!mt)
> -		goto cleanup_fl_mt;
> -
> -	fl_mt->fl_sb = sb;
> -	mt->mountid = (void *)fl_mt;
>  
>  	if (nfs4_alloc_init_deviceid_cache(NFS_SB(sb)->nfs_client,
> -					   nfs4_fl_free_deviceid_callback))
> -		goto cleanup_mt;
> -
> +					   nfs4_fl_free_deviceid_callback)) {
> +		printk(KERN_WARNING "%s: deviceid cache could not be "
> +			"initialized\n", __func__);
> +		return 0;
> +	}
>  	dprintk("%s: deviceid cache has been initialized successfully\n",
>  		__func__);
> -	return mt;
> -
> -cleanup_mt: ;
> -	kfree(mt);
> -
> -cleanup_fl_mt: ;
> -	kfree(fl_mt);
> -
> -error_ret: ;
> -	printk(KERN_WARNING "%s: deviceid cache could not be initialized\n",
> -		__func__);
> -
> -	return NULL;
> +	return 1;
>  }
>  
>  /* This function is used by the layout driver to calculate the
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 0e03259..3362ef5 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -207,16 +207,14 @@ void
>  set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
>  {
>  	struct pnfs_module *mod;
> -	struct pnfs_mount_type *mt;
>  	struct nfs_server *server = NFS_SB(sb);
>  
>  	if (server->pnfs_curr_ld)
>  		return;
>  
>  	if (id > 0 && find_pnfs(id, &mod)) {
> -		mt = mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
> -			sb, fh);
> -		if (!mt) {
> +		if (!mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
> +			sb, fh)) {
>  			printk(KERN_ERR "%s: Error initializing mount point "
>  			       "for layout driver %u. ", __func__, id);
>  			goto out_err;
> @@ -226,7 +224,6 @@ set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
>  		 * and has taken a reference on the nfs_client cl_devid_cache
>  		 */
>  		server->pnfs_curr_ld = mod->pnfs_ld_type;
> -		server->pnfs_mountid = mt;
>  		server->nfs_client->rpc_ops = &pnfs_v4_clientops;
>  		dprintk("%s: pNFS module for %u set\n", __func__, id);
>  		return;
> @@ -236,7 +233,6 @@ set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
>  out_err:
>  	dprintk("Using NFSv4 I/O\n");
>  	server->pnfs_curr_ld = NULL;
> -	server->pnfs_mountid = NULL;
>  	return;
>  }
>  
> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
> index 4fdf87e..7ca8f85 100644
> --- a/include/linux/nfs4_pnfs.h
> +++ b/include/linux/nfs4_pnfs.h
> @@ -30,13 +30,6 @@ struct pnfs_layoutdriver_type {
>  	struct layoutdriver_policy_operations *ld_policy_ops;
>  };
>  
> -/* Layout driver specific identifier for a mount point.  For each mountpoint
> - * a reference is stored in the nfs_server structure.
> - */
> -struct pnfs_mount_type {
> -	void *mountid;
> -};
> -
>  struct pnfs_fsdata {
>  	int ok_to_use_pnfs;
>  	struct pnfs_layout_segment *lseg;
> @@ -62,12 +55,6 @@ PNFS_NFS_SERVER(struct pnfs_layout_type *lo)
>  	return NFS_SERVER(PNFS_INODE(lo));
>  }
>  
> -static inline struct pnfs_mount_type *
> -PNFS_MOUNTID(struct pnfs_layout_type *lo)
> -{
> -	return NFS_SERVER(PNFS_INODE(lo))->pnfs_mountid;
> -}
> -
>  static inline void *
>  PNFS_LD_DATA(struct pnfs_layout_type *lo)
>  {
> @@ -181,7 +168,7 @@ struct layoutdriver_io_operations {
>  
>  	/* Registration information for a new mounted file system
>  	 */
> -	struct pnfs_mount_type * (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
> +	int (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
>  };
>  
>  enum layoutdriver_policy_flags {
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index bb0aa9c..9b160d4 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -165,8 +165,6 @@ struct nfs_server {
>  #ifdef CONFIG_NFS_V4_1
>  	u32				pnfs_fs_ltype;/* fs_layouttype attr */
>  	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
> -	struct pnfs_mount_type         *pnfs_mountid; /* Mount identifier for
> -							 layout driver */
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  	void (*destroy)(struct nfs_server *);

