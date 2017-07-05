Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49558 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751654AbdGENwW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Jul 2017 09:52:22 -0400
Subject: Re: [PATCH v3 1/1] PNFS fix dangling DS mount
To: Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
References: <20170630195201.95597-1-kolga@netapp.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <1a35fcac-9cf0-31b5-7d40-ef43000c08c8@RedHat.com>
Date: Wed, 5 Jul 2017 09:52:20 -0400
MIME-Version: 1.0
In-Reply-To: <20170630195201.95597-1-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2017 03:52 PM, Olga Kornievskaia wrote:
> There is a regression by commit 8d40b0f14846 ("NFS filelayout:call
> GETDEVICEINFO after pnfs_layout_process completes"). It leaves the
> DS mount dangling.
> 
> Previously, filelayout_alloc_sec() would call filelayout_check_layout()
> which would call nfs4_find_get_deviceid which ups the count on the
> device_id. It's only called once and it's matched by the
> filelayout_free_lseg() that calls nfs4_fl_put_deviceid().
> 
> After that patch, each read/write ends up calling nfs4_find_get_deviceid
> and there is no balance for that. Instead, do nfs4_fl_put_deviceid()
> in the filelayout's .pg_cleanup and remove it from filelayout_free_lseg.
> 
> But we still need a reference to hold over the lifetime of the segment.
> For every new lseg that's created we need to take a reference on deviceid
> that uses it. It will be released in the "free_lseg" routine.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Tested-by: Steve Dickson <steved@redhat.com>

steved.

> ---
>  fs/nfs/filelayout/filelayout.c         | 21 +++++++++++++++++----
>  fs/nfs/flexfilelayout/flexfilelayout.c |  9 ++++++---
>  fs/nfs/pnfs.c                          | 13 ++++++++++---
>  fs/nfs/pnfs.h                          |  3 ++-
>  4 files changed, 35 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 1cf85d6..86d694e 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -909,9 +909,10 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
>  	struct pnfs_layout_hdr *lo;
>  	struct nfs4_filelayout_segment *fl;
>  	int status;
> +	bool new_layout = false;
>  
>  	lseg = pnfs_update_layout(ino, ctx, pos, count, iomode, strict_iomode,
> -				  gfp_flags);
> +				  gfp_flags, &new_layout);
>  	if (!lseg)
>  		lseg = ERR_PTR(-ENOMEM);
>  	if (IS_ERR(lseg))
> @@ -924,7 +925,8 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
>  	if (status) {
>  		pnfs_put_lseg(lseg);
>  		lseg = ERR_PTR(status);
> -	}
> +	} else if (new_layout)
> +		nfs4_get_deviceid(&fl->dsaddr->id_node);
>  out:
>  	return lseg;
>  }
> @@ -991,18 +993,29 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
>  	nfs_pageio_reset_write_mds(pgio);
>  }
>  
> +static void filelayout_pg_cleanup(struct nfs_pageio_descriptor *desc)
> +{
> +	if (desc->pg_lseg) {
> +		struct nfs4_filelayout_segment *fl =
> +			FILELAYOUT_LSEG(desc->pg_lseg);
> +
> +		nfs4_fl_put_deviceid(fl->dsaddr);
> +	}
> +	pnfs_generic_pg_cleanup(desc);
> +}
> +
>  static const struct nfs_pageio_ops filelayout_pg_read_ops = {
>  	.pg_init = filelayout_pg_init_read,
>  	.pg_test = filelayout_pg_test,
>  	.pg_doio = pnfs_generic_pg_readpages,
> -	.pg_cleanup = pnfs_generic_pg_cleanup,
> +	.pg_cleanup = filelayout_pg_cleanup,
>  };
>  
>  static const struct nfs_pageio_ops filelayout_pg_write_ops = {
>  	.pg_init = filelayout_pg_init_write,
>  	.pg_test = filelayout_pg_test,
>  	.pg_doio = pnfs_generic_pg_writepages,
> -	.pg_cleanup = pnfs_generic_pg_cleanup,
> +	.pg_cleanup = filelayout_pg_cleanup,
>  };
>  
>  static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 23542dc..53a4a19 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -820,7 +820,8 @@ static bool ff_layout_has_rw_segments(struct pnfs_layout_hdr *layout)
>  					   NFS4_MAX_UINT64,
>  					   IOMODE_READ,
>  					   strict_iomode,
> -					   GFP_KERNEL);
> +					   GFP_KERNEL,
> +					   NULL);
>  	if (IS_ERR(pgio->pg_lseg)) {
>  		pgio->pg_error = PTR_ERR(pgio->pg_lseg);
>  		pgio->pg_lseg = NULL;
> @@ -904,7 +905,8 @@ static bool ff_layout_has_rw_segments(struct pnfs_layout_hdr *layout)
>  						   NFS4_MAX_UINT64,
>  						   IOMODE_RW,
>  						   false,
> -						   GFP_NOFS);
> +						   GFP_NOFS,
> +						   NULL);
>  		if (IS_ERR(pgio->pg_lseg)) {
>  			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
>  			pgio->pg_lseg = NULL;
> @@ -960,7 +962,8 @@ static bool ff_layout_has_rw_segments(struct pnfs_layout_hdr *layout)
>  						   NFS4_MAX_UINT64,
>  						   IOMODE_RW,
>  						   false,
> -						   GFP_NOFS);
> +						   GFP_NOFS,
> +						   NULL);
>  		if (IS_ERR(pgio->pg_lseg)) {
>  			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
>  			pgio->pg_lseg = NULL;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index c383d09..fb011c6 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1698,7 +1698,8 @@ struct pnfs_layout_segment *
>  		   u64 count,
>  		   enum pnfs_iomode iomode,
>  		   bool strict_iomode,
> -		   gfp_t gfp_flags)
> +		   gfp_t gfp_flags,
> +		   bool *new)
>  {
>  	struct pnfs_layout_range arg = {
>  		.iomode = iomode,
> @@ -1764,8 +1765,12 @@ struct pnfs_layout_segment *
>  	if (lseg) {
>  		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
>  				PNFS_UPDATE_LAYOUT_FOUND_CACHED);
> +		if (new)
> +			*new = false;
>  		goto out_unlock;
>  	}
> +	if (new)
> +		*new = true;
>  
>  	if (!nfs4_valid_open_stateid(ctx->state)) {
>  		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
> @@ -2126,7 +2131,8 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
>  						   rd_size,
>  						   IOMODE_READ,
>  						   false,
> -						   GFP_KERNEL);
> +						   GFP_KERNEL,
> +						   NULL);
>  		if (IS_ERR(pgio->pg_lseg)) {
>  			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
>  			pgio->pg_lseg = NULL;
> @@ -2153,7 +2159,8 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
>  						   wb_size,
>  						   IOMODE_RW,
>  						   false,
> -						   GFP_NOFS);
> +						   GFP_NOFS,
> +						   NULL);
>  		if (IS_ERR(pgio->pg_lseg)) {
>  			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
>  			pgio->pg_lseg = NULL;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 99731e3..978fab0 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -291,7 +291,8 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
>  					       u64 count,
>  					       enum pnfs_iomode iomode,
>  					       bool strict_iomode,
> -					       gfp_t gfp_flags);
> +					       gfp_t gfp_flags,
> +					       bool *new);
>  void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
>  		const nfs4_stateid *arg_stateid,
>  		const struct pnfs_layout_range *range,
> 
