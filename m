From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] pnfs-submit: filelayout: Support dense layouts
Date: Thu, 17 Jun 2010 11:59:35 -0400
Message-ID: <4C1A4667.10400@panasas.com>
References: <1276695226-11787-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27657 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760265Ab0FQP73 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:59:29 -0400
In-Reply-To: <1276695226-11787-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.35-rc3-2010-06-17

Thanks!

Benny

On Jun. 16, 2010, 9:33 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> We were silently accepting dense layouts but using sparse fh selection
> and flawed offset calculations.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c    |   72 ++++++++++++++++++++-----------------------
>  fs/nfs/nfs4filelayout.h    |   11 +-----
>  fs/nfs/nfs4filelayoutdev.c |   38 ++++++++++++++++-------
>  3 files changed, 62 insertions(+), 59 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 8a83c0d..57a0010 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -100,36 +100,26 @@ filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
>   * offset of the file on the dserver based on whether the
>   * layout type is STRIPE_DENSE or STRIPE_SPARSE
>   */
> -loff_t
> -filelayout_get_dserver_offset(loff_t offset,
> -			      struct nfs4_filelayout_segment *layout)
> +static loff_t
> +filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
>  {
> -	if (!layout)
> -		return offset;
> +	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
>  
> -	switch (layout->stripe_type) {
> +	switch (flseg->stripe_type) {
>  	case STRIPE_SPARSE:
>  		return offset;
>  
>  	case STRIPE_DENSE:
>  	{
> -		u32 stripe_size;
> -		u32 stripe_unit;
> -		loff_t off;
> -		loff_t tmp;
> -		u32 stripe_unit_idx;
> -
> -		stripe_size = layout->stripe_unit * layout->num_fh;
> -		/* XXX I do this because do_div seems to take a 32 bit dividend */
> -		stripe_unit = layout->stripe_unit;
> -		tmp = off = offset;
> -
> -		do_div(off, stripe_size);
> -		stripe_unit_idx = do_div(tmp, stripe_unit);
> -
> -		return off * stripe_unit + stripe_unit_idx;
> +		u32 stripe_width;
> +		u64 tmp, off;
> +		u32 unit = flseg->stripe_unit;
> +
> +		stripe_width = unit * FILE_DSADDR(lseg)->stripe_count;
> +		tmp = off = offset - flseg->pattern_offset;
> +		do_div(tmp, stripe_width);
> +		return tmp * unit + do_div(off, unit);
>  	}
> -
>  	default:
>  		BUG();
>  	}
> @@ -218,18 +208,17 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
>  			 struct nfs_read_data *data)
>  {
>  	struct inode *inode = PNFS_INODE(layoutid);
> -	struct nfs4_filelayout_segment *flseg;
> +	struct pnfs_layout_segment *lseg = data->pdata.lseg;
>  	struct nfs4_pnfs_ds *ds;
>  	u32 idx;
> +	struct nfs_fh *fh;
>  
>  	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu\n",
>  		__func__, inode->i_ino, nr_pages, pgbase, count, offset);
>  
> -	flseg = LSEG_LD_DATA(data->pdata.lseg);
> -
>  	/* Retrieve the correct rpc_client for the byte range */
> -	idx = nfs4_fl_calc_ds_index(data->pdata.lseg, offset);
> -	ds = nfs4_fl_prepare_ds(data->pdata.lseg, idx);
> +	idx = nfs4_fl_calc_ds_index(lseg, offset);
> +	ds = nfs4_fl_prepare_ds(lseg, idx);
>  	if (!ds) {
>  		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
>  		return PNFS_NOT_ATTEMPTED;
> @@ -239,7 +228,9 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
>  
>  	/* just try the first data server for the index..*/
>  	data->fldata.ds_nfs_client = ds->ds_clp;
> -	data->args.fh = nfs4_fl_select_ds_fh(flseg, idx);
> +	fh = nfs4_fl_select_ds_fh(lseg, offset);
> +	if (fh)
> +		data->args.fh = fh;
>  
>  	/* Now get the file offset on the dserver
>  	 * Set the read offset to this offset, and
> @@ -247,8 +238,7 @@ filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
>  	 * In the case of aync reads, the offset will be reset in the
>  	 * call_ops->rpc_call_done() routine.
>  	 */
> -	data->args.offset = filelayout_get_dserver_offset(offset,
> -							  flseg);
> +	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
>  	data->fldata.orig_offset = offset;
>  
>  	/* Perform an asynchronous read */
> @@ -269,16 +259,17 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
>  			  struct nfs_write_data *data)
>  {
>  	struct inode *inode = PNFS_INODE(layoutid);
> -	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(data->pdata.lseg);
> +	struct pnfs_layout_segment *lseg = data->pdata.lseg;
>  	struct nfs4_pnfs_ds *ds;
>  	u32 idx;
> +	struct nfs_fh *fh;
>  
>  	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu sync %d\n",
>  		__func__, inode->i_ino, nr_pages, pgbase, count, offset, sync);
>  
>  	/* Retrieve the correct rpc_client for the byte range */
> -	idx = nfs4_fl_calc_ds_index(data->pdata.lseg, offset);
> -	ds = nfs4_fl_prepare_ds(data->pdata.lseg, idx);
> +	idx = nfs4_fl_calc_ds_index(lseg, offset);
> +	ds = nfs4_fl_prepare_ds(lseg, idx);
>  	if (!ds) {
>  		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
>  		return PNFS_NOT_ATTEMPTED;
> @@ -288,12 +279,14 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
>  		htonl(ds->ds_ip_addr), ntohs(ds->ds_port), ds->r_addr);
>  
>  	data->fldata.ds_nfs_client = ds->ds_clp;
> -	data->args.fh = nfs4_fl_select_ds_fh(flseg, idx);
> +	fh = nfs4_fl_select_ds_fh(lseg, offset);
> +	if (fh)
> +		data->args.fh = fh;
>  
>  	/* Get the file offset on the dserver. Set the write offset to
>  	 * this offset and save the original offset.
>  	 */
> -	data->args.offset = filelayout_get_dserver_offset(offset, flseg);
> +	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
>  	data->fldata.orig_offset = offset;
>  
>  	/* Perform an asynchronous write The offset will be reset in the
> @@ -649,6 +642,8 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
>  			clnt = NFS_CLIENT(dsdata->inode);
>  			ds = NULL;
>  		} else {
> +			struct nfs_fh *fh;
> +
>  			call_ops = &filelayout_commit_call_ops;
>  			req = nfs_list_entry(dsdata->pages.next);
>  			ds = nfs4_fl_prepare_ds(req->wb_lseg, idx);
> @@ -660,9 +655,10 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
>  			}
>  			clnt = ds->ds_clp->cl_rpcclient;
>  			dsdata->fldata.ds_nfs_client = ds->ds_clp;
> -			dsdata->args.fh = \
> -				nfs4_fl_select_ds_fh(LSEG_LD_DATA(req->wb_lseg),
> -						     idx);
> +			file_offset = (loff_t)req->wb_index << PAGE_CACHE_SHIFT;
> +			fh = nfs4_fl_select_ds_fh(req->wb_lseg, file_offset);
> +			if (fh)
> +				dsdata->args.fh = fh;
>  		}
>  		dprintk("%s: Initiating commit: %llu USE DS:\n",
>  			__func__, file_offset);
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index 3697926..29e481d 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -80,15 +80,8 @@ struct filelayout_mount_type {
>  	struct super_block *fl_sb;
>  };
>  
> -static inline struct nfs_fh *
> -nfs4_fl_select_ds_fh(struct nfs4_filelayout_segment *flseg, u32 idx)
> -{
> -	/* FRED - what about case == 0??? */
> -	if (flseg->num_fh == 1)
> -		return &flseg->fh_array[0];
> -	else
> -		return &flseg->fh_array[idx];
> -}
> +extern struct nfs_fh *
> +nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
>  
>  extern struct pnfs_client_operations *pnfs_callback_ops;
>  
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 404dd5f..5842c09 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -558,28 +558,42 @@ nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
>   * Then: ((res + fsi) % dsaddr->stripe_count)
>   */
>  static inline u32
> -_nfs4_fl_calc_j_index(loff_t offset,
> -		      struct nfs4_file_layout_dsaddr *dsaddr,
> -		      struct nfs4_filelayout_segment *layout)
> +_nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
>  {
> +	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
>  	u64 tmp;
>  
> -	tmp = offset - layout->pattern_offset;
> -	do_div(tmp, layout->stripe_unit);
> -	tmp += layout->first_stripe_index;
> -	return do_div(tmp, dsaddr->stripe_count);
> +	tmp = offset - flseg->pattern_offset;
> +	do_div(tmp, flseg->stripe_unit);
> +	tmp += flseg->first_stripe_index;
> +	return do_div(tmp, FILE_DSADDR(lseg)->stripe_count);
>  }
>  
>  u32
>  nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset)
>  {
> -	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
> -	struct nfs4_file_layout_dsaddr *dsaddr;
>  	u32 j;
>  
> -	dsaddr = FILE_DSADDR(lseg);
> -	j = _nfs4_fl_calc_j_index(offset, dsaddr, flseg);
> -	return dsaddr->stripe_indices[j];
> +	j = _nfs4_fl_calc_j_index(lseg, offset);
> +	return FILE_DSADDR(lseg)->stripe_indices[j];
> +}
> +
> +struct nfs_fh *
> +nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset)
> +{
> +	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
> +	u32 i;
> +
> +	if (flseg->stripe_type == STRIPE_SPARSE) {
> +		if (flseg->num_fh == 1)
> +			i = 0;
> +		else if (flseg->num_fh == 0)
> +			return NULL;
> +		else
> +			i = nfs4_fl_calc_ds_index(lseg, offset);
> +	} else
> +		i = _nfs4_fl_calc_j_index(lseg, offset);
> +	return &flseg->fh_array[i];
>  }
>  
>  struct nfs4_pnfs_ds *
