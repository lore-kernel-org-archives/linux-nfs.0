Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:49748 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbaDYN40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 09:56:26 -0400
Received: by mail-qg0-f52.google.com with SMTP id j5so3994794qga.25
        for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 06:56:25 -0700 (PDT)
Message-ID: <535A6986.5090109@gmail.com>
Date: Fri, 25 Apr 2014 09:56:22 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>,
        trond.myklebust@primarydata.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 14/18 v2] nfs: remove list of [rw]data from pgio header
References: <1398363328-7100-1-git-send-email-dros@primarydata.com> <1398363328-7100-15-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-15-git-send-email-dros@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/24/2014 02:15 PM, Weston Andros Adamson wrote:
> Since the ability to split pages into subpage requests has been added,
> nfs_pgio_header->rpc_list only ever has one wdata/rdata.

[rw]data structs don't exist anymore.  Can you update the patch description?

Anna

>
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  fs/nfs/pageio.c         | 35 ++++-------------------------------
>  fs/nfs/pnfs.c           | 41 +++++++++++++++--------------------------
>  include/linux/nfs_xdr.h |  4 +++-
>  3 files changed, 22 insertions(+), 58 deletions(-)
>
> diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
> index 1899977..f578cc9 100644
> --- a/fs/nfs/pageio.c
> +++ b/fs/nfs/pageio.c
> @@ -29,7 +29,6 @@ struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *ops)
>  		struct nfs_pgio_header *hdr = &header->header;
>  
>  		INIT_LIST_HEAD(&hdr->pages);
> -		INIT_LIST_HEAD(&hdr->rpc_list);
>  		spin_lock_init(&hdr->lock);
>  		atomic_set(&hdr->refcnt, 0);
>  		hdr->rw_ops = ops;
> @@ -182,37 +181,12 @@ static int nfs_do_pgio(struct nfs_pgio_data *data,
>  	return nfs_initiate_pgio(NFS_CLIENT(inode), data, call_ops, how, 0);
>  }
>  
> -int nfs_do_multiple_pgios(struct list_head *head,
> -				 const struct rpc_call_ops *call_ops,
> -				 int how)
> -{
> -	struct nfs_pgio_data *data;
> -	int ret = 0;
> -
> -	while (!list_empty(head)) {
> -		int ret2;
> -
> -		data = list_first_entry(head, struct nfs_pgio_data, list);
> -		list_del_init(&data->list);
> -
> -		ret2 = nfs_do_pgio(data, call_ops, how);
> -		 if (ret == 0)
> -			 ret = ret2;
> -	}
> -	return ret;
> -}
> -
>  static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
>  			  struct nfs_pgio_header *hdr)
>  {
> -	struct nfs_pgio_data *data;
> -
>  	set_bit(NFS_IOHDR_REDO, &hdr->flags);
> -	while (!list_empty(&hdr->rpc_list)) {
> -		data = list_first_entry(&hdr->rpc_list, struct nfs_pgio_data, list);
> -		list_del(&data->list);
> -		nfs_pgio_data_release(data);
> -	}
> +	nfs_pgio_data_release(hdr->data);
> +	hdr->data = NULL;
>  	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>  	return -ENOMEM;
>  }
> @@ -254,7 +228,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
>  
>  	/* Set up the argument struct */
>  	nfs_pgio_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
> -	list_add(&data->list, &hdr->rpc_list);
> +	hdr->data = data;
>  	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>  	return 0;
>  }
> @@ -276,8 +250,7 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
>  	atomic_inc(&hdr->refcnt);
>  	ret = nfs_generic_pgio(desc, hdr);
>  	if (ret == 0)
> -		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
> -					    desc->pg_rpc_callops, 0);
> +		ret = nfs_do_pgio(hdr->data, desc->pg_rpc_callops, 0);
>  	if (atomic_dec_and_test(&hdr->refcnt))
>  		hdr->completion_ops->completion(hdr);
>  	return ret;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 354c53c..6ef108b 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1573,23 +1573,18 @@ pnfs_try_to_write_data(struct nfs_pgio_data *wdata,
>  }
>  
>  static void
> -pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *head, int how)
> +pnfs_do_write(struct nfs_pageio_descriptor *desc,
> +	      struct nfs_pgio_header *hdr, int how)
>  {
> -	struct nfs_pgio_data *data;
> +	struct nfs_pgio_data *data = hdr->data;
>  	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
>  	struct pnfs_layout_segment *lseg = desc->pg_lseg;
> +	enum pnfs_try_status trypnfs;
>  
>  	desc->pg_lseg = NULL;
> -	while (!list_empty(head)) {
> -		enum pnfs_try_status trypnfs;
> -
> -		data = list_first_entry(head, struct nfs_pgio_data, list);
> -		list_del_init(&data->list);
> -
> -		trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
> -		if (trypnfs == PNFS_NOT_ATTEMPTED)
> -			pnfs_write_through_mds(desc, data);
> -	}
> +	trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
> +	if (trypnfs == PNFS_NOT_ATTEMPTED)
> +		pnfs_write_through_mds(desc, data);
>  	pnfs_put_lseg(lseg);
>  }
>  
> @@ -1623,7 +1618,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>  		pnfs_put_lseg(desc->pg_lseg);
>  		desc->pg_lseg = NULL;
>  	} else
> -		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
> +		pnfs_do_write(desc, hdr, desc->pg_ioflags);
>  	if (atomic_dec_and_test(&hdr->refcnt))
>  		hdr->completion_ops->completion(hdr);
>  	return ret;
> @@ -1731,23 +1726,17 @@ pnfs_try_to_read_data(struct nfs_pgio_data *rdata,
>  }
>  
>  static void
> -pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *head)
> +pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
>  {
> -	struct nfs_pgio_data *data;
> +	struct nfs_pgio_data *data = hdr->data;
>  	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
>  	struct pnfs_layout_segment *lseg = desc->pg_lseg;
> +	enum pnfs_try_status trypnfs;
>  
>  	desc->pg_lseg = NULL;
> -	while (!list_empty(head)) {
> -		enum pnfs_try_status trypnfs;
> -
> -		data = list_first_entry(head, struct nfs_pgio_data, list);
> -		list_del_init(&data->list);
> -
> -		trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
> -		if (trypnfs == PNFS_NOT_ATTEMPTED)
> -			pnfs_read_through_mds(desc, data);
> -	}
> +	trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
> +	if (trypnfs == PNFS_NOT_ATTEMPTED)
> +		pnfs_read_through_mds(desc, data);
>  	pnfs_put_lseg(lseg);
>  }
>  
> @@ -1782,7 +1771,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>  		pnfs_put_lseg(desc->pg_lseg);
>  		desc->pg_lseg = NULL;
>  	} else
> -		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
> +		pnfs_do_read(desc, hdr);
>  	if (atomic_dec_and_test(&hdr->refcnt))
>  		hdr->completion_ops->completion(hdr);
>  	return ret;
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index dacd240..29828c7 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1255,11 +1255,13 @@ enum {
>  	NFS_IOHDR_NEED_RESCHED,
>  };
>  
> +struct nfs_pgio_data;
> +
>  struct nfs_pgio_header {
>  	struct inode		*inode;
>  	struct rpc_cred		*cred;
>  	struct list_head	pages;
> -	struct list_head	rpc_list;
> +	struct nfs_pgio_data	*data;
>  	atomic_t		refcnt;
>  	struct nfs_page		*req;
>  	struct nfs_writeverf	verf;		/* Used for writes */

