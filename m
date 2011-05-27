Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9089 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab1E0P2L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2011 11:28:11 -0400
Message-ID: <4DDFC30A.6060606@panasas.com>
Date: Fri, 27 May 2011 18:28:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 28/32] NFSv4.1: unify pnfs_pageio_init functions
References: <4DDD7392.6040505@panasas.com> <1306358998-17872-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358998-17872-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 12:29 AM, Benny Halevy wrote:
> Use common code for pnfs_pageio_init_{read,write} and use
> a common generic pg_test function.
> 
> Note that this function always assumes the the layout driver's
> pg_test method is implemented.
> 

murphy law for programming says that if you do not test some code
it will fail no matter how simple it is.
Even code that if you'd test it it would be fine. The fact you did
not test it is the cause of why it fails. (You let a low chance
possibility in)

So with this patch pnfs stops working!
I'll send a patch as reply

> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/pagelist.c |    1 +
>  fs/nfs/pnfs.c     |   57 ++++++++++++++--------------------------------------
>  fs/nfs/pnfs.h     |   19 +++++++----------
>  fs/nfs/read.c     |    2 +-
>  fs/nfs/write.c    |    3 +-
>  5 files changed, 27 insertions(+), 55 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index c80add6..0918ea8 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -229,6 +229,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  	desc->pg_ioflags = io_flags;
>  	desc->pg_error = 0;
>  	desc->pg_lseg = NULL;
> +	desc->pg_test = NULL;
>  }
>  
>  /**
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 00b1282..f7a9405 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1043,46 +1043,30 @@ out_forget_reply:
>  	goto out;
>  }
>  
> -static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
> -			     struct nfs_page *prev,
> -			     struct nfs_page *req)
> -{
> -	if (pgio->pg_count == prev->wb_bytes) {
> -		/* This is first coelesce call for a series of nfs_pages */
> -		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> -						   prev->wb_context,
> -						   req_offset(req),
> -						   pgio->pg_count,
> -						   IOMODE_READ,
> -						   GFP_KERNEL);
> -	} else if (pgio->pg_lseg &&
> -		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
> -						pgio->pg_lseg->pls_range.length))
> -		return 0;
> -	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
> -}
> -
> -void
> -pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
> +int
> +pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> +		     struct nfs_page *req)
>  {
> -	struct pnfs_layoutdriver_type *ld;
> +	enum pnfs_iomode access_type;
> +	gfp_t gfp_flags;
>  
> -	ld = NFS_SERVER(inode)->pnfs_curr_ld;
> -	pgio->pg_test = (ld && ld->pg_test) ? pnfs_read_pg_test : NULL;
> -}
> -
> -static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
> -			      struct nfs_page *prev,
> -			      struct nfs_page *req)
> -{
> +	/* We assume that pg_ioflags == 0 iff we're reading a page */
> +	if (pgio->pg_ioflags == 0) {
> +		access_type = IOMODE_READ;
> +		gfp_flags = GFP_KERNEL;
> +	} else {
> +		access_type = IOMODE_RW;
> +		gfp_flags = GFP_NOFS;
> +	}
> +		

nit, Two extra tabs

Boaz

>  	if (pgio->pg_count == prev->wb_bytes) {
>  		/* This is first coelesce call for a series of nfs_pages */
>  		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>  						   prev->wb_context,
>  						   req_offset(req),
>  						   pgio->pg_count,
> -						   IOMODE_RW,
> -						   GFP_NOFS);
> +						   access_type,
> +						   gfp_flags);
>  	} else if (pgio->pg_lseg &&
>  		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
>  						pgio->pg_lseg->pls_range.length))
> @@ -1090,15 +1074,6 @@ static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
>  	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
>  }
>  
> -void
> -pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
> -{
> -	struct pnfs_layoutdriver_type *ld;
> -
> -	ld = NFS_SERVER(inode)->pnfs_curr_ld;
> -	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
> -}
> -
>  /*
>   * Called by non rpc-based layout drivers
>   */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 25da946..cc61ae0 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -158,8 +158,7 @@ enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
>  					     const struct rpc_call_ops *, int);
>  enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
>  					    const struct rpc_call_ops *);
> -void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
> -void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
> +int pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
>  int pnfs_layout_process(struct nfs4_layoutget *lgp);
>  void pnfs_free_lseg_list(struct list_head *tmp_list);
>  void pnfs_destroy_layout(struct nfs_inode *);
> @@ -293,6 +292,12 @@ static inline int pnfs_return_layout(struct inode *ino)
>  	return 0;
>  }
>  
> +static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio, struct inode *inode)
> +{
> +	if (NFS_SERVER(inode)->pnfs_curr_ld)
> +		pgio->pg_test = pnfs_generic_pg_test;
> +}
> +
>  #else  /* CONFIG_NFS_V4_1 */
>  
>  static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
> @@ -376,16 +381,8 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
>  {
>  }
>  
> -static inline void
> -pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
> -{
> -	pgio->pg_test = NULL;
> -}
> -
> -static inline void
> -pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
> +static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *, struct inode *)
>  {
> -	pgio->pg_test = NULL;
>  }
>  
>  static inline void
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 540c8bc..6bd09a8 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -664,7 +664,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
>  	if (ret == 0)
>  		goto read_complete; /* all pages were read */
>  
> -	pnfs_pageio_init_read(&pgio, inode);
> +	pnfs_pageio_init(&pgio, inode);
>  	if (rsize < PAGE_CACHE_SIZE)
>  		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
>  	else
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 7edb72f..d81c5c0 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1036,8 +1036,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
>  {
>  	size_t wsize = NFS_SERVER(inode)->wsize;
>  
> -	pnfs_pageio_init_write(pgio, inode);
> -
> +	pnfs_pageio_init(pgio, inode);
>  	if (wsize < PAGE_CACHE_SIZE)
>  		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
>  	else

