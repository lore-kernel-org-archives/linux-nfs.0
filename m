From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v3] SQUASHME: pnfs: unlock lo_lock before calling layoutdriver's
 setup_layoutcommit
Date: Tue, 25 May 2010 17:40:06 +0300
Message-ID: <4BFBE146.1060906@panasas.com>
References: <20100525085119.GA7998@vmware> <4BFBD1C0.1040105@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>, Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:31904 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755315Ab0EYOib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 10:38:31 -0400
Received: by fg-out-1718.google.com with SMTP id d23so2363758fga.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 07:38:30 -0700 (PDT)
In-Reply-To: <4BFBD1C0.1040105@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
> From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
> 
> So in blocklayoutdriver, we can use GFP_KERNEL to do memory
> allocation in bl_setup_layoutcommit().
> 
> The state protected by the lo_lock here is clear now, which is the
> layout_commit's position and state. .i.e write_begin/end_pos,
> nfsi->lo_cred, and the call to pnfs_get_layout_stateid.

Yeah, this looks cleaner.
Tao, can you please test and ack this patch before I merge it?

Thanks!

Benny

> 
> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pnfs.c |   66 +++++++++++++++++++++++++++++---------------------------
>  1 files changed, 34 insertions(+), 32 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d4e4ba9..cf9cfe5 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2075,15 +2075,22 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
>   * Set up the argument/result storage required for the RPC call.
>   */
>  static int
> -pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
> +pnfs_layoutcommit_setup(struct inode *inode,
> +			struct pnfs_layoutcommit_data *data,
> +			loff_t write_begin_pos, loff_t write_end_pos, int sync)
>  {
> -	struct nfs_inode *nfsi = NFS_I(data->args.inode);
> -	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	struct nfs_server *nfss = NFS_SERVER(inode);
>  	int result = 0;
>  
>  	dprintk("%s Begin (sync:%d)\n", __func__, sync);
> -	data->args.fh = NFS_FH(data->args.inode);
> +
> +	data->is_sync = sync;
> +	data->args.inode = inode;
> +	data->args.fh = NFS_FH(inode);
>  	data->args.layout_type = nfss->pnfs_curr_ld->id;
> +	data->res.fattr = &data->fattr;
> +	nfs_fattr_init(&data->fattr);
>  
>  	/* TODO: Need to determine the correct values */
>  	data->args.time_modify_changed = 0;
> @@ -2091,26 +2098,19 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
>  	/* Set values from inode so it can be reset
>  	 */
>  	data->args.lseg.iomode = IOMODE_RW;
> -	data->args.lseg.offset = nfsi->pnfs_write_begin_pos;
> -	data->args.lseg.length = nfsi->pnfs_write_end_pos - nfsi->pnfs_write_begin_pos + 1;
> -	data->args.lastbytewritten =  min(nfsi->pnfs_write_end_pos,
> -					i_size_read(&nfsi->vfs_inode) - 1);
> +	data->args.lseg.offset = write_begin_pos;
> +	data->args.lseg.length = write_end_pos - write_begin_pos + 1;
> +	data->args.lastbytewritten =  min(write_end_pos,
> +					  i_size_read(inode) - 1);
>  	data->args.bitmask = nfss->attr_bitmask;
>  	data->res.server = nfss;
>  
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
> @@ -2122,6 +2122,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  {
>  	struct pnfs_layoutcommit_data *data;
>  	struct nfs_inode *nfsi = NFS_I(inode);
> +	loff_t write_begin_pos;
> +	loff_t write_end_pos;
> +
>  	int status = 0;
>  
>  	dprintk("%s Begin (sync:%d)\n", __func__, sync);
> @@ -2133,39 +2136,38 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
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
> +	if (!layoutcommit_needed(nfsi)) {
> +		spin_unlock(&nfsi->lo_lock);
> +		goto out_free;
> +	}
>  
>  	/* Clear layoutcommit properties in the inode so
>  	 * new lc info can be generated
>  	 */
> +	write_begin_pos = nfsi->pnfs_write_begin_pos;
> +	write_end_pos = nfsi->pnfs_write_end_pos;
> +	data->cred = nfsi->lo_cred;
>  	nfsi->pnfs_write_begin_pos = 0;
>  	nfsi->pnfs_write_end_pos = 0;
>  	nfsi->lo_cred = NULL;
> +	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
>  
> +	spin_unlock(&nfsi->lo_lock);
> +
> +	/* Set up layout commit args */
> +	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
> +					 write_end_pos, sync);
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

