From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH -v2] pnfs: unlock lo_lock spinlock before calling specific
 layoutdriver's setup_layoutcommit() operation
Date: Tue, 25 May 2010 16:01:41 +0300
Message-ID: <4BFBCA35.5070104@panasas.com>
References: <20100525085119.GA7998@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25112 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754377Ab0EYNBo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 09:01:44 -0400
In-Reply-To: <20100525085119.GA7998@vmware>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/25/2010 11:51 AM, Tao Guo wrote:
> So in blocklayoutdriver, we can use GFP_KERNEL to do memory
> allocation in bl_setup_layoutcommit().
> 
> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
> ---
>  fs/nfs/pnfs.c |   63 ++++++++++++++++++++++++++------------------------------
>  1 files changed, 29 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d4e4ba9..bbd1548 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2075,15 +2075,23 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
>   * Set up the argument/result storage required for the RPC call.
>   */
>  static int
> -pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
> +pnfs_layoutcommit_setup(struct inode *inode,
> +			struct pnfs_layoutcommit_data *data, int sync)
>  {
> -	struct nfs_inode *nfsi = NFS_I(data->args.inode);
> -	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	struct nfs_server *nfss = NFS_SERVER(inode);
>  	int result = 0;
>  
>  	dprintk("%s Begin (sync:%d)\n", __func__, sync);
> +
> +	data->is_sync = sync;
> +	data->cred = nfsi->lo_cred;
> +	data->args.inode = inode;
>  	data->args.fh = NFS_FH(data->args.inode);
>  	data->args.layout_type = nfss->pnfs_curr_ld->id;
> +	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
> +	data->res.fattr = &data->fattr;
> +	nfs_fattr_init(&data->fattr);
>  
>  	/* TODO: Need to determine the correct values */
>  	data->args.time_modify_changed = 0;
> @@ -2098,19 +2106,21 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
>  	data->args.bitmask = nfss->attr_bitmask;
>  	data->res.server = nfss;
>  
> +	/* Clear layoutcommit properties in the inode so
> +	 * new lc info can be generated
> +	 */
> +	nfsi->pnfs_write_begin_pos = 0;
> +	nfsi->pnfs_write_end_pos = 0;
> +	nfsi->lo_cred = NULL;
> +
> +	spin_unlock(&nfsi->lo_lock);
> +

I don't like it when _unlock is done in a different function then _lock

Please see below proposal for somthing I would think should be more clear.

>  	/* Call layout driver to set the arguments.
>  	 */
> -	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit) {
> +	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit)
>  		result = nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit(
>  				&nfsi->layout, &data->args);
> -		if (result)
> -			goto out;
> -	}
> -	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
> -	data->res.fattr = &data->fattr;
> -	nfs_fattr_init(&data->fattr);
>  
> -out:
>  	dprintk("%s End Status %d\n", __func__, result);
>  	return result;
>  }
> @@ -2133,39 +2143,24 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  		return -ENOMEM;
>  
>  	spin_lock(&nfsi->lo_lock);
> -	if (!layoutcommit_needed(nfsi))
> -		goto out_unlock;
> -
> -	data->args.inode = inode;
> -	data->cred = nfsi->lo_cred;
> -
> -	/* Set up layout commit args*/
> -	status = pnfs_layoutcommit_setup(data, sync);
> -
> -	/* Clear layoutcommit properties in the inode so
> -	 * new lc info can be generated
> -	 */
> -	nfsi->pnfs_write_begin_pos = 0;
> -	nfsi->pnfs_write_end_pos = 0;
> -	nfsi->lo_cred = NULL;
> +	if (!layoutcommit_needed(nfsi)) {
> +		spin_unlock(&nfsi->lo_lock);
> +		goto out_free;
> +	}
>  
> +	/* Set up layout commit args */
> +	status = pnfs_layoutcommit_setup(inode, data, sync);
>  	if (status) {
>  		/* The layout driver failed to setup the layoutcommit */
>  		put_rpccred(data->cred);
> -		goto out_unlock;
> +		goto out_free;
>  	}
> -
> -	/* release lock on pnfs layoutcommit attrs */
> -	spin_unlock(&nfsi->lo_lock);
> -
> -	data->is_sync = sync;
>  	status = pnfs4_proc_layoutcommit(data);
>  out:
>  	dprintk("%s end (err:%d)\n", __func__, status);
>  	return status;
> -out_unlock:
> +out_free:
>  	pnfs_layoutcommit_free(data);
> -	spin_unlock(&nfsi->lo_lock);
>  	goto out;
>  }
>  

SQUASHME: apply this on top of: pnfs: unlock lo_lock spinlock before calling layoutdriver's setup_layoutcommit

(BTW subject line too long see above)

lock/unlock on same call sight. it is also much more clear what is protected by the spinlock which is
the write_begin/end_pos and most importantly the nfsi->lo_cred which is also the state variable.
(layoutcommit_needed)

I'm also sending a [PATCH -v3] which is a squash of this with Toa's patch.

---
git diff --stat -p -M fs/nfs/pnfs.c
 fs/nfs/pnfs.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bbd1548..88d4865 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2076,7 +2076,8 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
  */
 static int
 pnfs_layoutcommit_setup(struct inode *inode,
-			struct pnfs_layoutcommit_data *data, int sync)
+			struct pnfs_layoutcommit_data *data,
+			loff_t write_begin_pos, loff_t write_end_pos, int sync)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_server *nfss = NFS_SERVER(inode);
@@ -2099,22 +2100,13 @@ pnfs_layoutcommit_setup(struct inode *inode,
 	/* Set values from inode so it can be reset
 	 */
 	data->args.lseg.iomode = IOMODE_RW;
-	data->args.lseg.offset = nfsi->pnfs_write_begin_pos;
-	data->args.lseg.length = nfsi->pnfs_write_end_pos - nfsi->pnfs_write_begin_pos + 1;
-	data->args.lastbytewritten =  min(nfsi->pnfs_write_end_pos,
-					i_size_read(&nfsi->vfs_inode) - 1);
+	data->args.lseg.offset = write_begin_pos;
+	data->args.lseg.length = write_end_pos - write_begin_pos + 1;
+	data->args.lastbytewritten =  min(write_end_pos,
+					  i_size_read(&nfsi->vfs_inode) - 1);
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
-	/* Clear layoutcommit properties in the inode so
-	 * new lc info can be generated
-	 */
-	nfsi->pnfs_write_begin_pos = 0;
-	nfsi->pnfs_write_end_pos = 0;
-	nfsi->lo_cred = NULL;
-
-	spin_unlock(&nfsi->lo_lock);
-
 	/* Call layout driver to set the arguments.
 	 */
 	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit)
@@ -2132,6 +2124,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	struct pnfs_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	loff_t write_begin_pos;
+	loff_t write_end_pos;
+
 	int status = 0;
 
 	dprintk("%s Begin (sync:%d)\n", __func__, sync);
@@ -2148,8 +2143,20 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		goto out_free;
 	}
 
+	/* Clear layoutcommit properties in the inode so
+	 * new lc info can be generated
+	 */
+	write_begin_pos = nfsi->pnfs_write_begin_pos;
+	write_end_pos = nfsi->pnfs_write_end_pos;
+	nfsi->pnfs_write_begin_pos = 0;
+	nfsi->pnfs_write_end_pos = 0;
+	nfsi->lo_cred = NULL;
+
+	spin_unlock(&nfsi->lo_lock);
+
 	/* Set up layout commit args */
-	status = pnfs_layoutcommit_setup(inode, data, sync);
+	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
+					 write_end_pos, sync);
 	if (status) {
 		/* The layout driver failed to setup the layoutcommit */
 		put_rpccred(data->cred);


