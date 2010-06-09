From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 20/24] pnfs_submit: API change: remove pnfs_commit layoutget
 invocation
Date: Wed, 09 Jun 2010 12:09:05 +0300
Message-ID: <4C0F5A31.1070705@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-6-git-send-email-iisaman@netapp.com> <1275970761-31806-7-git-send-email-iisaman@netapp.com> <1275970761-31806-8-git-send-email-iisaman@netapp.com> <1275970761-31806-9-git-send-email-iisaman@netapp.com> <1275970761-31806-10-git-send-email-iisaman@netapp.com> <1275970761-31806-11-git-send-email-iisaman@netapp.com> <1275970761-31806-12-git-send-email-iisaman@netapp.com> <1275970761-31806-13-git-send-email-iisaman@netapp.com> <1275970761-31806-14-git-send-email-iisaman@netapp.com> <1275970761-31806-15-git-send-email-iisaman@netapp.com> <1275970761-31806-16-git-send-email-iisaman@netapp.com> <1275970761-31806-17-git-send-email-iisaman@netapp.com> <1275970761-31806-18-git-send-email-iisaman@netapp.com> <12759707
 61-31806-19-git-send-email-iisaman@netapp.com> <1275970761-31806-20-git-send-email-iisaman@netapp.com> <1275970761-31806-21-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:32815 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761Ab0FIJJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 05:09:10 -0400
Received: by bwz11 with SMTP id 11so1477770bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jun 2010 02:09:08 -0700 (PDT)
In-Reply-To: <1275970761-31806-21-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 08, 2010, 7:19 +0300, Fred Isaman <iisaman@netapp.com> wrote:
> WARNING - this is an API change.
> 
> The layout driver's commit operation no longer takes an lseg.
> This is because each nfs_page may or may not have an associated lseg.
> It is the layout drivers task to send commits to the appropriate place.

So if the appropriate place for all pages that have no lseg associated
with them is the MDS why shouldn't the generic layer do that?

Benny

> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/internal.h        |    2 +-
>  fs/nfs/pagelist.c        |    5 ++-
>  fs/nfs/pnfs.c            |   79 ++++++++-------------------------------------
>  fs/nfs/pnfs.h            |   21 +++++-------
>  fs/nfs/write.c           |   23 +++++++------
>  include/linux/nfs_page.h |    3 +-
>  6 files changed, 43 insertions(+), 90 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index b754446..a30974a 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -286,7 +286,7 @@ extern int nfs_initiate_commit(struct nfs_write_data *data,
>  extern int pnfs_initiate_commit(struct nfs_write_data *data,
>  			       struct rpc_clnt *clnt,
>  			       const struct rpc_call_ops *call_ops,
> -			       int how);
> +				int how, int pnfs);
>  extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
>  extern void nfs_mark_list_commit(struct list_head *head);
>  #ifdef CONFIG_MIGRATION
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index c3e5a1f..c8de900 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -380,6 +380,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
>   * @idx_start: lower bound of page->index to scan
>   * @npages: idx_start + npages sets the upper bound to scan.
>   * @tag: tag to scan for
> + * @use_pnfs: will be set TRUE if commit needs to be handled by layout driver
>   *
>   * Moves elements from one of the inode request lists.
>   * If the number of requests is set to 0, the entire address_space
> @@ -389,7 +390,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
>   */
>  int nfs_scan_list(struct nfs_inode *nfsi,
>  		struct list_head *dst, pgoff_t idx_start,
> -		unsigned int npages, int tag)
> +		  unsigned int npages, int tag, int *use_pnfs)
>  {
>  	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
>  	struct nfs_page *req;
> @@ -420,6 +421,8 @@ int nfs_scan_list(struct nfs_inode *nfsi,
>  				radix_tree_tag_clear(&nfsi->nfs_page_tree,
>  						req->wb_index, tag);
>  				nfs_list_add_request(req, dst);
> +				if (req->wb_lseg)
> +					*use_pnfs = 1;
>  				res++;
>  				if (res == INT_MAX)
>  					goto out;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 4907e3a..9f28b28 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1672,19 +1672,11 @@ enum pnfs_try_status
>  _pnfs_try_to_commit(struct nfs_write_data *data,
>  		    const struct rpc_call_ops *call_ops, int how)
>  {
> -	struct inode *inode = data->inode;
> -
> -	if (!pnfs_enabled_sb(NFS_SERVER(inode))) {
> -		dprintk("%s: Not using pNFS I/O\n", __func__);
> -		return PNFS_NOT_ATTEMPTED;
> -	} else {
> -		/* data->call_ops and data->how set in nfs_commit_rpcsetup */
> -		dprintk("%s: Utilizing pNFS I/O\n", __func__);
> -		data->pdata.call_ops = call_ops;
> -		data->pdata.pnfs_error = 0;
> -		data->pdata.how = how;
> -		return pnfs_commit(data, how);
> -	}
> +	dprintk("%s: Utilizing pNFS I/O\n", __func__);
> +	data->pdata.call_ops = call_ops;
> +	data->pdata.pnfs_error = 0;
> +	data->pdata.how = how;
> +	return pnfs_commit(data, how);
>  }
>  
>  /* pNFS Commit callback function for all layout drivers */
> @@ -1705,76 +1697,33 @@ pnfs_commit_done(struct nfs_write_data *data)
>  		_pnfs_return_layout(data->inode, &range, NULL, RETURN_FILE,
>  				    true);
>  		pnfs_initiate_commit(data, NFS_CLIENT(data->inode),
> -				     pdata->call_ops, pdata->how);
> +				     pdata->call_ops, pdata->how, 1);
>  	}
>  }
>  
>  static enum pnfs_try_status
>  pnfs_commit(struct nfs_write_data *data, int sync)
>  {
> -	int result;
>  	struct nfs_inode *nfsi = NFS_I(data->inode);
>  	struct nfs_server *nfss = NFS_SERVER(data->inode);
> -	struct pnfs_layout_segment *lseg;
> -	struct nfs_page *first, *last, *p;
> -	int npages;
>  	enum pnfs_try_status trypnfs;
> -	u64 count;
>  
>  	dprintk("%s: Begin\n", __func__);
>  
> -	/* If the layout driver doesn't define its own commit function
> -	 * use standard NFSv4 commit
> -	 */
> -	first = last = nfs_list_entry(data->pages.next);
> -	npages = 0;
> -	list_for_each_entry(p, &data->pages, wb_list) {
> -		last = p;
> -		npages++;
> -	}
> -	/* COMMIT indicates the whole file with offset = count = 0
> -	 * whereas layout segments indicate whole file with offset = 0,
> -	 * count = NFS4_MAX_UINT64.
> +	/* We need to account for possibility that
> +	 * each nfs_page can point to a different lseg (or be NULL).
> +	 * For the immediate case of whole-file-only layouts, we at
> +	 * least know there can be only a single lseg.
> +	 * We still have to account for the possibility of some being NULL.
> +	 * This will be done by passing the buck to the layout driver.
>  	 */
> -	count = ((npages - 1) << PAGE_CACHE_SHIFT) + first->wb_bytes +
> -		 (first != last) ? last->wb_bytes : 0;
> -	if (first->wb_offset == 0 && count == 0)
> -		count = NFS4_MAX_UINT64;
> -
> -	/* FIXME: we really ought to keep the layout segment that we used
> -	   to write the page around for committing it and never ask for a
> -	   new one.  If it was recalled we better commit the data first
> -	   before returning it, otherwise the data needs to be rewritten,
> -	   either with a new layout or to the MDS */
> -	result = _pnfs_update_layout(data->inode,
> -				    NULL,
> -				    count,
> -				    first->wb_offset,
> -				    IOMODE_RW,
> -				    &lseg);
> -	/* If no layout have been retrieved,
> -	 * use standard NFSv4 commit
> -	 */
> -	if (result) {
> -		dprintk("%s: Updating layout failed (%d), retry with NFS \n",
> -			__func__, result);
> -		trypnfs = PNFS_NOT_ATTEMPTED;
> -		goto out;
> -	}
> -
> -	dprintk("%s: Calling layout driver commit\n", __func__);
> +	data->pdata.lseg = NULL;
>  	if (!pnfs_use_rpc(nfss))
>  		data->pdata.pnfsflags |= PNFS_NO_RPC;
> -	data->pdata.lseg = lseg;
>  	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(&nfsi->layout,
>  							sync, data);
> -	if (trypnfs == PNFS_NOT_ATTEMPTED) {
> +	if (trypnfs == PNFS_NOT_ATTEMPTED)
>  		data->pdata.pnfsflags &= ~PNFS_NO_RPC;
> -		data->pdata.lseg = NULL;
> -		put_lseg(lseg);
> -	}
> -
> -out:
>  	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
>  	return trypnfs;
>  }
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index ea54210..e231ca3 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -140,21 +140,18 @@ pnfs_try_to_commit(struct nfs_write_data *data,
>  		   const struct rpc_call_ops *call_ops,
>  		   int how)
>  {
> -	struct inode *inode = data->inode;
> -	struct nfs_server *nfss = NFS_SERVER(inode);
>  	enum pnfs_try_status ret;
>  
> -	/* Note that we check for "write_pagelist" and not for "commit"
> -	   since if async writes were done and pages weren't marked as stable
> -	   the commit method MUST be defined by the LD */
> -	/* FIXME: write_pagelist should probably be mandated */
> -	if (PNFS_EXISTS_LDIO_OP(nfss, write_pagelist))
> -		ret = _pnfs_try_to_commit(data, call_ops, how);
> -	else
> -		ret = PNFS_NOT_ATTEMPTED;
> -
> +	/* Unlike in pnfs_try_to_write_data and pnfs_try_to_read_data,
> +	 * we have no guarantee that all nfs_pages point to the same
> +	 * lseg.  However, if we reach here, we are guaranteed that at
> +	 * least one points to some lseg.
> +	 */
> +	ret = _pnfs_try_to_commit(data, call_ops, how);
>  	if (ret == PNFS_ATTEMPTED)
> -		nfs_inc_stats(inode, NFSIOS_PNFS_COMMIT);
> +		nfs_inc_stats(data->inode, NFSIOS_PNFS_COMMIT);
> +	else
> +		_pnfs_clear_lseg_from_pages(&data->pages);
>  	return ret;
>  }
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 811c776..ebc9452 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -527,7 +527,7 @@ nfs_need_commit(struct nfs_inode *nfsi)
>   * The requests are *not* checked to ensure that they form a contiguous set.
>   */
>  static int
> -nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
> +nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages, int *use_pnfs)
>  {
>  	struct nfs_inode *nfsi = NFS_I(inode);
>  	int ret;
> @@ -535,7 +535,8 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, u
>  	if (!nfs_need_commit(nfsi))
>  		return 0;
>  
> -	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
> +	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT,
> +			    use_pnfs);
>  	if (ret > 0)
>  		nfsi->ncommit -= ret;
>  	if (nfs_need_commit(NFS_I(inode)))
> @@ -1334,9 +1335,10 @@ EXPORT_SYMBOL(nfs_initiate_commit);
>  int pnfs_initiate_commit(struct nfs_write_data *data,
>  			 struct rpc_clnt *clnt,
>  			 const struct rpc_call_ops *call_ops,
> -			 int how)
> +			 int how, int pnfs)
>  {
> -	if (pnfs_try_to_commit(data, &nfs_commit_ops, how) == PNFS_ATTEMPTED)
> +	if (pnfs &&
> +	    (pnfs_try_to_commit(data, &nfs_commit_ops, how) == PNFS_ATTEMPTED))
>  		return pnfs_get_write_status(data);
>  
>  	return nfs_initiate_commit(data, clnt, &nfs_commit_ops, how);
> @@ -1347,7 +1349,7 @@ int pnfs_initiate_commit(struct nfs_write_data *data,
>   */
>  static int nfs_commit_rpcsetup(struct list_head *head,
>  		struct nfs_write_data *data,
> -		int how)
> +		int how, int pnfs)
>  {
>  	struct nfs_page *first = nfs_list_entry(head->next);
>  	struct inode *inode = first->wb_context->path.dentry->d_inode;
> @@ -1374,7 +1376,7 @@ static int nfs_commit_rpcsetup(struct list_head *head,
>  	data->args.context = first->wb_context;  /* used by commit done */
>  
>  	return pnfs_initiate_commit(data, NFS_CLIENT(inode), &nfs_commit_ops,
> -				    how);
> +				    how, pnfs);
>  }
>  
>  /* Handle memory error during commit */
> @@ -1398,7 +1400,7 @@ EXPORT_SYMBOL(nfs_mark_list_commit);
>   * Commit dirty pages
>   */
>  static int
> -nfs_commit_list(struct inode *inode, struct list_head *head, int how)
> +nfs_commit_list(struct inode *inode, struct list_head *head, int how, int pnfs)
>  {
>  	struct nfs_write_data	*data;
>  
> @@ -1407,7 +1409,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>  		goto out_bad;
>  
>  	/* Set up the argument struct */
> -	return nfs_commit_rpcsetup(head, data, how);
> +	return nfs_commit_rpcsetup(head, data, how, pnfs);
>   out_bad:
>  	nfs_mark_list_commit(head);
>  	nfs_commit_clear_lock(NFS_I(inode));
> @@ -1495,14 +1497,15 @@ static int nfs_commit_inode(struct inode *inode, int how)
>  	LIST_HEAD(head);
>  	int may_wait = how & FLUSH_SYNC;
>  	int res = 0;
> +	int use_pnfs = 0;
>  
>  	if (!nfs_commit_set_lock(NFS_I(inode), may_wait))
>  		goto out_mark_dirty;
>  	spin_lock(&inode->i_lock);
> -	res = nfs_scan_commit(inode, &head, 0, 0);
> +	res = nfs_scan_commit(inode, &head, 0, 0, &use_pnfs);
>  	spin_unlock(&inode->i_lock);
>  	if (res) {
> -		int error = nfs_commit_list(inode, &head, how);
> +		int error = nfs_commit_list(inode, &head, how, use_pnfs);
>  		if (error < 0)
>  			return error;
>  		if (may_wait) {
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index 18a455c..06e5157 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -83,7 +83,8 @@ extern	void nfs_release_request(struct nfs_page *req);
>  
>  
>  extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
> -			  pgoff_t idx_start, unsigned int npages, int tag);
> +			  pgoff_t idx_start, unsigned int npages, int tag,
> +			  int *use_pnfs);
>  extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  			     struct inode *inode,
>  			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),

