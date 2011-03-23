Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7499 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045Ab1CWTly (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 15:41:54 -0400
Message-ID: <4D8A4D16.1060702@panasas.com>
Date: Wed, 23 Mar 2011 21:42:14 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 08/12] NFSv4.1: add generic layer hooks for pnfs COMMIT
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com> <1300886875-5016-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-9-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=windows-1255; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-23 15:27, Fred Isaman wrote:
> We create three major hooks for the pnfs code.
>
> pnfs_mark_request_commit() is called during writeback_done from
> nfs_mark_request_commit, which gives the driver an opportunity to
> claim it wants control over commiting a particular req.
>
> pnfs_choose_commit_list() is called from nfs_scan_list
> to choose which list a given req should be added to, based on
> where we intend to send it for COMMIT.  It is up to the driver
> to have preallocated list headers for each destination it may need.
>
> pnfs_commit_list() is how the driver actually takes control, it is
> used instead of nfs_commit_list().
>
> In order to pass information between the above functions, we create
> a union in nfs_page to hold a lseg (which is possible because the req is
> not on any list while in transition), and add some flags to indicate
> if we need to use the pnfs code.
>
> Signed-off-by: Fred Isaman<iisaman@netapp.com>
> ---
>   fs/nfs/pagelist.c        |    5 ++-
>   fs/nfs/pnfs.h            |   73 ++++++++++++++++++++++++++++++++++++++++++++++
>   fs/nfs/write.c           |   41 ++++++++++++++++---------
>   include/linux/nfs_fs.h   |    1 +
>   include/linux/nfs_page.h |    6 +++-
>   5 files changed, 108 insertions(+), 18 deletions(-)
>
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index fd85618..87a593c 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -398,6 +398,7 @@ int nfs_scan_list(struct nfs_inode *nfsi,
>   	pgoff_t idx_end;
>   	int found, i;
>   	int res;
> +	struct list_head *list;
>
>   	res = 0;
>   	if (npages == 0)
> @@ -418,10 +419,10 @@ int nfs_scan_list(struct nfs_inode *nfsi,
>   			idx_start = req->wb_index + 1;
>   			if (nfs_set_page_tag_locked(req)) {
>   				kref_get(&req->wb_kref);
> -				nfs_list_remove_request(req);
>   				radix_tree_tag_clear(&nfsi->nfs_page_tree,
>   						req->wb_index, tag);
> -				nfs_list_add_request(req, dst);
> +				list = pnfs_choose_commit_list(req, dst);
> +				nfs_list_add_request(req, list);
>   				res++;
>   				if (res == INT_MAX)
>   					goto out;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 6380b94..5370f1b 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -74,6 +74,13 @@ struct pnfs_layoutdriver_type {
>   	/* test for nfs page cache coalescing */
>   	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
>
> +	/* Returns true if layoutdriver wants to divert this request to
> +	 * driver's commit routine.
> +	 */
> +	bool (*mark_pnfs_commit)(struct pnfs_layout_segment *lseg);
> +	struct list_head * (*choose_commit_list) (struct nfs_page *req);
> +	int (*commit_pagelist)(struct inode *inode, struct list_head *mds_pages, int how);
> +
>   	/*
>   	 * Return PNFS_ATTEMPTED to indicate the layout code has attempted
>   	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
> @@ -169,6 +176,51 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
>   	return nfss->pnfs_curr_ld != NULL;
>   }
>
> +static inline void
> +pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
> +{
> +	if (lseg) {
> +		struct pnfs_layoutdriver_type *ld;
> +
> +		ld = NFS_SERVER(req->wb_page->mapping->host)->pnfs_curr_ld;
> +		if (ld->mark_pnfs_commit&&  ld->mark_pnfs_commit(lseg)) {

nit: space before and after "&&"

> +			set_bit(PG_PNFS_COMMIT,&req->wb_flags);

nit: space after comma

> +			req->wb_commit_lseg = get_lseg(lseg);

What are the atomicity requirements of the PG_PNFS_COMMIT bit in 
wb_flags and the validity of wb_commit_lseg?

> +		}
> +	}
> +}
> +
> +static inline int
> +pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
> +{
> +	if (!test_and_clear_bit(NFS_INO_PNFS_COMMIT,&NFS_I(inode)->flags))
> +		return PNFS_NOT_ATTEMPTED;
> +	return NFS_SERVER(inode)->pnfs_curr_ld->commit_pagelist(inode, mds_pages, how);

Again, I don't get the concurrency control here...
NFS_INO_PNFS_COMMIT is set in pnfs_choose_commit_list under i_lock
but then pnfs_commit_list is called outside the i_lock so what 
guarantees that NFS_INO_PNFS_COMMIT is still valid with respect to the 
output of pnfs_choose_commit_list?

> +}
> +
> +static inline struct list_head *
> +pnfs_choose_commit_list(struct nfs_page *req, struct list_head *mds)
> +{
> +	struct list_head *rv;
> +
> +	if (test_and_clear_bit(PG_PNFS_COMMIT,&req->wb_flags)) {

nit: space after comma

> +		struct inode *inode = req->wb_commit_lseg->pls_layout->plh_inode;
> +
> +		set_bit(NFS_INO_PNFS_COMMIT,&NFS_I(inode)->flags);

nit: ditto

> +		rv = NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list(req);
> +		/* matched by ref taken when PG_PNFS_COMMIT is set */
> +		put_lseg(req->wb_commit_lseg);

Since wb_commit_lseg and wb_list are in a union, how about
		INIT_LIST_HEAD(&req->wb_list);

> +	} else
> +		rv = mds;
> +	return rv;
> +}
> +
> +static inline void pnfs_clear_request_commit(struct nfs_page *req)
> +{
> +	if (test_and_clear_bit(PG_PNFS_COMMIT,&req->wb_flags))
> +		put_lseg(req->wb_commit_lseg);

ditto

Benny

> +}
> +
>   #else  /* CONFIG_NFS_V4_1 */
>
>   static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
> @@ -252,6 +304,27 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
>   	pgio->pg_test = NULL;
>   }
>
> +static inline void
> +pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
> +{
> +}
> +
> +static inline int
> +pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how)
> +{
> +	return PNFS_NOT_ATTEMPTED;
> +}
> +
> +static inline struct list_head *
> +pnfs_choose_commit_list(struct nfs_page *req, struct list_head *mds)
> +{
> +	return mds;
> +}
> +
> +static inline void pnfs_clear_request_commit(struct nfs_page *req)
> +{
> +}
> +
>   #endif /* CONFIG_NFS_V4_1 */
>
>   #endif /* FS_NFS_PNFS_H */
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index f5f005e..6927a18 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -441,7 +441,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
>    * Add a request to the inode's commit list.
>    */
>   static void
> -nfs_mark_request_commit(struct nfs_page *req)
> +nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
>   {
>   	struct inode *inode = req->wb_context->path.dentry->d_inode;
>   	struct nfs_inode *nfsi = NFS_I(inode);
> @@ -453,6 +453,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>   			NFS_PAGE_TAG_COMMIT);
>   	nfsi->ncommit++;
>   	spin_unlock(&inode->i_lock);
> +	pnfs_mark_request_commit(req, lseg);

Why do this out of the i_lock?

>   	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>   	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>   	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> @@ -481,10 +482,11 @@ int nfs_write_need_commit(struct nfs_write_data *data)
>   }
>
>   static inline
> -int nfs_reschedule_unstable_write(struct nfs_page *req)
> +int nfs_reschedule_unstable_write(struct nfs_page *req,
> +				  struct nfs_write_data *data)
>   {
>   	if (test_and_clear_bit(PG_NEED_COMMIT,&req->wb_flags)) {
> -		nfs_mark_request_commit(req);
> +		nfs_mark_request_commit(req, data->lseg);
>   		return 1;
>   	}
>   	if (test_and_clear_bit(PG_NEED_RESCHED,&req->wb_flags)) {
> @@ -495,7 +497,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
>   }
>   #else
>   static inline void
> -nfs_mark_request_commit(struct nfs_page *req)
> +nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
>   {
>   }
>
> @@ -512,7 +514,8 @@ int nfs_write_need_commit(struct nfs_write_data *data)
>   }
>
>   static inline
> -int nfs_reschedule_unstable_write(struct nfs_page *req)
> +int nfs_reschedule_unstable_write(struct nfs_page *req,
> +				  struct nfs_write_data *data)
>   {
>   	return 0;
>   }
> @@ -615,9 +618,11 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
>   	}
>
>   	if (nfs_clear_request_commit(req)&&
> -			radix_tree_tag_clear(&NFS_I(inode)->nfs_page_tree,
> -				req->wb_index, NFS_PAGE_TAG_COMMIT) != NULL)
> +	    radix_tree_tag_clear(&NFS_I(inode)->nfs_page_tree,
> +				 req->wb_index, NFS_PAGE_TAG_COMMIT) != NULL) {
>   		NFS_I(inode)->ncommit--;
> +		pnfs_clear_request_commit(req);
> +	}
>
>   	/* Okay, the request matches. Update the region */
>   	if (offset<  req->wb_offset) {
> @@ -765,11 +770,12 @@ int nfs_updatepage(struct file *file, struct page *page,
>   	return status;
>   }
>
> -static void nfs_writepage_release(struct nfs_page *req)
> +static void nfs_writepage_release(struct nfs_page *req,
> +				  struct nfs_write_data *data)
>   {
>   	struct page *page = req->wb_page;
>
> -	if (PageError(req->wb_page) || !nfs_reschedule_unstable_write(req))
> +	if (PageError(req->wb_page) || !nfs_reschedule_unstable_write(req, data))
>   		nfs_inode_remove_request(req);
>   	nfs_clear_page_tag_locked(req);
>   	nfs_end_page_writeback(page);
> @@ -1087,7 +1093,7 @@ static void nfs_writeback_release_partial(void *calldata)
>
>   out:
>   	if (atomic_dec_and_test(&req->wb_complete))
> -		nfs_writepage_release(req);
> +		nfs_writepage_release(req, data);
>   	nfs_writedata_release(calldata);
>   }
>
> @@ -1154,7 +1160,7 @@ static void nfs_writeback_release_full(void *calldata)
>
>   		if (nfs_write_need_commit(data)) {
>   			memcpy(&req->wb_verf,&data->verf, sizeof(req->wb_verf));
> -			nfs_mark_request_commit(req);
> +			nfs_mark_request_commit(req, data->lseg);
>   			dprintk(" marked for commit\n");
>   			goto next;
>   		}
> @@ -1357,14 +1363,15 @@ static void nfs_init_commit(struct nfs_write_data *data,
>   	nfs_fattr_init(&data->fattr);
>   }
>
> -static void nfs_retry_commit(struct list_head *page_list)
> +static void nfs_retry_commit(struct list_head *page_list,
> +		      struct pnfs_layout_segment *lseg)
>   {
>   	struct nfs_page *req;
>
>   	while (!list_empty(page_list)) {
>   		req = nfs_list_entry(page_list->next);
>   		nfs_list_remove_request(req);
> -		nfs_mark_request_commit(req);
> +		nfs_mark_request_commit(req, lseg);
>   		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>   		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
>   			     BDI_RECLAIMABLE);
> @@ -1389,7 +1396,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>   	nfs_init_commit(data, head);
>   	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops, how);
>    out_bad:
> -	nfs_retry_commit(head);
> +	nfs_retry_commit(head, NULL);
>   	nfs_commit_clear_lock(NFS_I(inode));
>   	return -ENOMEM;
>   }
> @@ -1477,7 +1484,11 @@ int nfs_commit_inode(struct inode *inode, int how)
>   	res = nfs_scan_commit(inode,&head, 0, 0);
>   	spin_unlock(&inode->i_lock);
>   	if (res) {
> -		int error = nfs_commit_list(inode,&head, how);
> +		int error;
> +
> +		error = pnfs_commit_list(inode,&head, how);
> +		if (error == PNFS_NOT_ATTEMPTED)
> +			error = nfs_commit_list(inode,&head, how);
>   		if (error<  0)
>   			return error;
>   		if (!may_wait)
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index cb2add4..f64ea14 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -221,6 +221,7 @@ struct nfs_inode {
>   #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
>   #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
>   #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
> +#define NFS_INO_PNFS_COMMIT	(8)		/* use pnfs code for commit */

nit: alignment

>
>   static inline struct nfs_inode *NFS_I(const struct inode *inode)
>   {
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index 92d54c8..8023e4e 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -33,11 +33,15 @@ enum {
>   	PG_CLEAN,
>   	PG_NEED_COMMIT,
>   	PG_NEED_RESCHED,
> +	PG_PNFS_COMMIT,
>   };
>
>   struct nfs_inode;
>   struct nfs_page {
> -	struct list_head	wb_list;	/* Defines state of page: */
> +	union {
> +		struct list_head	wb_list;	/* Defines state of page: */
> +		struct pnfs_layout_segment *wb_commit_lseg; /* Used when PG_PNFS_COMMIT set */
> +	};
>   	struct page		*wb_page;	/* page to read in/write out */
>   	struct nfs_open_context	*wb_context;	/* File state context info */
>   	struct nfs_lock_context	*wb_lock_context;	/* lock context info */

