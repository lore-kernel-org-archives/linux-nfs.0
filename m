Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43113 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab1BUStb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 13:49:31 -0500
Message-ID: <4D62B3BA.3060905@panasas.com>
Date: Mon, 21 Feb 2011 10:49:30 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/7] NFSv4.1: trigger LAYOUTGET for writes
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com> <1298310576-13523-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1298310576-13523-5-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-21 09:49, Fred Isaman wrote:
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/pnfs.c  |   25 +++++++++++++++++++++++++
>  fs/nfs/pnfs.h  |    7 +++++++
>  fs/nfs/write.c |   32 ++++++++++++++++++++------------
>  3 files changed, 52 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a7ea646..0ed3948d 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -876,6 +876,31 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
>  	pgio->pg_test = (ld && ld->pg_test) ? pnfs_read_pg_test : NULL;
>  }
>  
> +static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
> +			      struct nfs_page *prev,
> +			      struct nfs_page *req)
> +{
> +	if (pgio->pg_count == prev->wb_bytes) {
> +		/* This is first coelesce call for a series of nfs_pages */
> +		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> +						   prev->wb_context,
> +						   IOMODE_RW);
> +	}
> +	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
> +}
> +
> +/*
> + * rsize is already set by caller to MDS rsize.
> + */

This comment is confusing and looks out of place...

> +void
> +pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
> +{
> +	struct pnfs_layoutdriver_type *ld;
> +
> +	ld = NFS_SERVER(inode)->pnfs_curr_ld;
> +	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
> +}
> +
>  /*
>   * Call the appropriate parallel I/O subsystem read function.
>   */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index acbb778..1d4e631 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -123,6 +123,7 @@ void unset_pnfs_layoutdriver(struct nfs_server *);
>  enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
>  					    const struct rpc_call_ops *);
>  void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
> +void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
>  int pnfs_layout_process(struct nfs4_layoutget *lgp);
>  void pnfs_free_lseg_list(struct list_head *tmp_list);
>  void pnfs_destroy_layout(struct nfs_inode *);
> @@ -235,6 +236,12 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
>  	pgio->pg_test = NULL;
>  }
>  
> +static inline void
> +pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
> +{
> +	pgio->pg_test = NULL;
> +}
> +
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  #endif /* FS_NFS_PNFS_H */
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 0df18ae..6cf5de6 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -919,6 +919,8 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
>  	} while (nbytes != 0);
>  	atomic_set(&req->wb_complete, requests);
>  
> +	/* We know lseg==NULL */

Then maybe BUG_ON or WARN_ON(lseg != NULL)?

> +	lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_RW);
>  	ClearPageError(page);
>  	offset = 0;
>  	nbytes = count;
> @@ -940,6 +942,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
>  		nbytes -= wsize;
>  	} while (nbytes != 0);
>  
> +	put_lseg(lseg);
>  	return ret;
>  
>  out_bad:
> @@ -965,11 +968,18 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
>  	struct nfs_page		*req;
>  	struct page		**pages;
>  	struct nfs_write_data	*data;
> +	int ret;
>  
>  	data = nfs_writedata_alloc(npages);
> -	if (!data)
> -		goto out_bad;
> -
> +	if (!data) {
> +		while (!list_empty(head)) {
> +			req = nfs_list_entry(head->next);

nit: it'd be cleaner to define a nfs_list_first_entry helper in nfs_page.h
rather than using a combination of list helpers and open code (head->next).

> +			nfs_list_remove_request(req);
> +			nfs_redirty_request(req);
> +		}
> +		ret = -ENOMEM;
> +		goto out;
> +	}
>  	pages = data->pagevec;
>  	while (!list_empty(head)) {
>  		req = nfs_list_entry(head->next);
> @@ -979,16 +989,14 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
>  		*pages++ = req->wb_page;
>  	}
>  	req = nfs_list_entry(data->pages.next);
> +	if ((!lseg) && list_is_singular(&data->pages))
> +		lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_RW);
>  
>  	/* Set up the argument struct */
> -	return nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, lseg, how);
> - out_bad:
> -	while (!list_empty(head)) {
> -		req = nfs_list_entry(head->next);
> -		nfs_list_remove_request(req);
> -		nfs_redirty_request(req);
> -	}
> -	return -ENOMEM;
> +	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, lseg, how);
> +out:
> +	put_lseg(lseg);

Shouldn't you do that only if lseg was updated above?

Benny

> +	return ret;
>  }
>  
>  static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
> @@ -996,7 +1004,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
>  {
>  	size_t wsize = NFS_SERVER(inode)->wsize;
>  
> -	pgio->pg_test = NULL;
> +	pnfs_pageio_init_write(pgio, inode);
>  
>  	if (wsize < PAGE_CACHE_SIZE)
>  		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
