Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50793 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754434Ab1CWR72 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 13:59:28 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p2NHxRYF026750
	for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 10:59:27 -0700 (PDT)
Subject: Re: [PATCH 2/3] NFS: Create nfs_open_dir_context
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4D8A305E.6090006@netapp.com>
References: <4D8A305E.6090006@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 13:59:26 -0400
Message-ID: <1300903166.11677.34.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 13:39 -0400, Bryan Schumaker wrote:
> nfs_opendir() created a context that held much more information than we need for
> a readdir.  This patch introduces a slimmed-down nfs_open_dir_context that
> contains only the cookie and the cred used for RPC operations.  The new
> context will eventually be used to help detect readdir loops.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/dir.c           |   53 +++++++++++++++++++++++++++++++++++++++++------
>  fs/nfs/inode.c         |    1 -
>  include/linux/nfs_fs.h |    3 ++
>  3 files changed, 49 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index e9fa2c8..b503791 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -44,6 +44,7 @@
>  /* #define NFS_DEBUG_VERBOSE 1 */
>  
>  static int nfs_opendir(struct inode *, struct file *);
> +static int nfs_closedir(struct inode *, struct file *);
>  static int nfs_readdir(struct file *, void *, filldir_t);
>  static struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
>  static int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
> @@ -64,7 +65,7 @@ const struct file_operations nfs_dir_operations = {
>  	.read		= generic_read_dir,
>  	.readdir	= nfs_readdir,
>  	.open		= nfs_opendir,
> -	.release	= nfs_release,
> +	.release	= nfs_closedir,
>  	.fsync		= nfs_fsync_dir,
>  };
>  
> @@ -133,13 +134,32 @@ const struct inode_operations nfs4_dir_inode_operations = {
>  
>  #endif /* CONFIG_NFS_V4 */
>  
> +static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct rpc_cred *cred)
> +{
> +	struct nfs_open_dir_context *ctx;
> +	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
> +	if (ctx != NULL) {
> +		ctx->dir_cookie = 0;
> +		ctx->cred = get_rpccred(cred);
> +	}
> +	return ctx;
> +}
> +
> +static void put_nfs_open_dir_context(struct nfs_open_dir_context *ctx)
> +{
> +	put_rpccred(ctx->cred);
> +	kfree(ctx);
> +}
> +
>  /*
>   * Open file
>   */
>  static int
>  nfs_opendir(struct inode *inode, struct file *filp)
>  {
> -	int res;
> +	int res = 0;
> +	struct nfs_open_dir_context *ctx;
> +	struct rpc_cred *cred;
>  
>  	dfprintk(FILE, "NFS: open dir(%s/%s)\n",
>  			filp->f_path.dentry->d_parent->d_name.name,
> @@ -147,8 +167,15 @@ nfs_opendir(struct inode *inode, struct file *filp)
>  
>  	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
>  
> -	/* Call generic open code in order to cache credentials */
> -	res = nfs_open(inode, filp);
> +	cred = rpc_lookup_cred();
> +	if (IS_ERR(cred))
> +		return PTR_ERR(cred);
> +	ctx = alloc_nfs_open_dir_context(cred);
> +	if (IS_ERR(ctx)) {

As far as I can see, alloc_nfs_open_dir_context returns a NULL if it
fails, not an ERR_PTR() value.

> +		res = PTR_ERR(ctx);
> +		goto out;
> +	}
> +	filp->private_data = ctx;
>  	if (filp->f_path.dentry == filp->f_path.mnt->mnt_root) {
>  		/* This is a mountpoint, so d_revalidate will never
>  		 * have been called, so we need to refresh the


... otherwise this looks ok.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

