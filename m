From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 5/5] SQUASHME pnfs-submit: filelayout: use new alloc_layout
 API
Date: Wed, 30 Jun 2010 12:06:34 +0300
Message-ID: <4C2B091A.907@panasas.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com> <1277829737-5465-2-git-send-email-andros@netapp.com> <1277829737-5465-3-git-send-email-andros@netapp.com> <1277829737-5465-4-git-send-email-andros@netapp.com> <1277829737-5465-5-git-send-email-andros@netapp.com> <1277829737-5465-6-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: benny@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16760 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751907Ab0F3JGg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 05:06:36 -0400
In-Reply-To: <1277829737-5465-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/29/2010 07:42 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c |   11 +++++++----
>  fs/nfs/nfs4filelayout.h |    7 +++++++
>  2 files changed, 14 insertions(+), 4 deletions(-)
> 

Won't you go head and submit an API change to the other two layout drivers?

> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 57a0010..07d5bf6 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -301,11 +301,14 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
>   * will use the pnfs_layout_type type to refer to the layout for this
>   * inode from now on.
>   */
> -static void *
> +static struct pnfs_layout_type *
>  filelayout_alloc_layout(struct inode *inode)
>  {
> +	struct nfs4_filelayout *flp;
> +
>  	dprintk("NFS_FILELAYOUT: allocating layout\n");
> -	return kzalloc(sizeof(struct nfs4_filelayout), GFP_KERNEL);
> +	flp =  kzalloc(sizeof(struct nfs4_filelayout), GFP_KERNEL);
> +	return flp ? &flp->fl_cache : NULL;
>  }
>  
>  /* Free a filelayout layout structure
> @@ -471,7 +474,7 @@ static struct pnfs_layout_segment *
>  filelayout_alloc_lseg(struct pnfs_layout_type *layoutid,
>  		      struct nfs4_pnfs_layoutget_res *lgr)
>  {
> -	struct nfs4_filelayout *flo = PNFS_LD_DATA(layoutid);
> +	struct nfs4_filelayout *flo = FILE_LO_CACHE(layoutid);
>  	struct pnfs_layout_segment *lseg;
>  	int rc;
>  
> @@ -693,7 +696,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
>  ssize_t
>  filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
>  {
> -	struct nfs4_filelayout *flo = PNFS_LD_DATA(layoutid);
> +	struct nfs4_filelayout *flo = FILE_LO_CACHE(layoutid);
>  
>  	return flo->stripe_unit;
>  }
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index de8391f..eca459f 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -68,6 +68,7 @@ struct nfs4_filelayout_segment {
>  };
>  
>  struct nfs4_filelayout {
> +	struct pnfs_layout_type fl_cache;
>  	int uncommitted_write;
>  	loff_t last_commit_size;
>  	u64 layout_id;
> @@ -77,6 +78,12 @@ struct nfs4_filelayout {
>  extern struct nfs_fh *
>  nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
>  
> +static inline struct nfs4_filelayout *
> +FILE_LO_CACHE(struct pnfs_layout_type *lo_cache)
> +{
> +	return container_of(lo_cache, struct nfs4_filelayout, fl_cache);
> +}
> +

The name? why the __CACHE? why not just FILE_LO()? the struct it returns
name is nfs4_filelayout, simple.

Boaz

>  extern struct pnfs_client_operations *pnfs_callback_ops;
>  
>  extern void nfs4_fl_free_deviceid_callback(struct kref *);

