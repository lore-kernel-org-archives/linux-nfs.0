Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:45882 "HELO
	exprod5og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751233Ab0KKPQ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 10:16:57 -0500
Message-ID: <4CDC08E6.9070909@panasas.com>
Date: Thu, 11 Nov 2010 17:16:54 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/18] pnfs_submit: nfs4_layoutreturn_release should not
 reference results
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com> <1288884151-11128-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-7-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-04 17:22, Fred Isaman wrote:
> Since the release function may be called without sending any RPC,
> it must should not refer to any of the result fields.  This is
          ^^^^^^

must not

> better accomplished in the rpc_done function.
> 
> In the process, this basically reverts the commit
> "pnfs: do not change layout stateid when dropping layouts."

Not exactly, as the !lrp->res.valid noop case is now handled with
the same outcome, just implemented differently.

Otherwise, this patch looks good.

Benny
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/nfs4proc.c       |   17 ++++++++++++++---
>  fs/nfs/nfs4xdr.c        |    1 -
>  fs/nfs/pnfs.c           |   23 ++---------------------
>  fs/nfs/pnfs.h           |    3 ++-
>  include/linux/nfs_xdr.h |    1 -
>  5 files changed, 18 insertions(+), 27 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8d3965c..de3ed2f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5596,9 +5596,20 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
>  		server = NFS_SERVER(lrp->args.inode);
>  	else
>  		server = NULL;
> -	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN)
> +	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN) {
>  		nfs_restart_rpc(task, lrp->clp);
> +		return;
> +	}
> +	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE)) {
> +		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
>  
> +		spin_lock(&lo->inode->i_lock);
> +		if (lrp->res.lrs_present)
> +			pnfs_set_layout_stateid(lo, &lrp->res.stateid);
> +		else
> +			pnfs_invalidate_layout_stateid(lo);
> +		spin_unlock(&lo->inode->i_lock);
> +	}
>  	dprintk("<-- %s\n", __func__);
>  }
>  
> @@ -5607,8 +5618,8 @@ static void nfs4_layoutreturn_release(void *calldata)
>  	struct nfs4_layoutreturn *lrp = calldata;
>  
>  	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
> -
> -	pnfs_layoutreturn_release(lrp);
> +	if (lrp->args.return_type == RETURN_FILE)
> +		put_layout_hdr(lrp->args.inode);
>  	kfree(calldata);
>  	dprintk("<-- %s\n", __func__);
>  }
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index b71a482..10a6f4a 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -5286,7 +5286,6 @@ static int decode_layoutreturn(struct xdr_stream *xdr,
>  	p = xdr_inline_decode(xdr, 4);
>  	if (unlikely(!p))
>  		goto out_overflow;
> -	res->valid = true;
>  	res->lrs_present = be32_to_cpup(p);
>  	if (res->lrs_present)
>  		status = decode_stateid(xdr, &res->stateid);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 34f6914..44f4f30 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -449,7 +449,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>   *
>   * lo->stateid could be the open stateid, in which case we just use what given.
>   */
> -static void
> +void
>  pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>  			const nfs4_stateid *new)
>  {
> @@ -587,25 +587,6 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  	return ret;
>  }
>  
> -void
> -pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
> -{
> -	struct pnfs_layout_hdr *lo;
> -
> -	if (lrp->args.return_type != RETURN_FILE)
> -		return;
> -	lo = NFS_I(lrp->args.inode)->layout;
> -	spin_lock(&lrp->args.inode->i_lock);
> -	if (!lrp->res.valid)
> -		;	/* forgetful model internal release */
> -	else if (!lrp->res.lrs_present)
> -		pnfs_invalidate_layout_stateid(lo);
> -	else 
> -		pnfs_set_layout_stateid(lo, &lrp->res.stateid);
> -	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
> -	spin_unlock(&lrp->args.inode->i_lock);
> -}
> -
>  static int
>  return_layout(struct inode *ino, struct pnfs_layout_range *range,
>  	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
> @@ -675,7 +656,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
>  		list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
>  			if (should_free_lseg(lseg, &arg))
>  				mark_lseg_invalid(lseg, &tmp_list);
> -		/* Reference matched in pnfs_layoutreturn_release */
> +		/* Reference matched in nfs4_layoutreturn_release */
>  		get_layout_hdr_locked(lo);
>  		spin_unlock(&ino->i_lock);
>  		pnfs_free_lseg_list(&tmp_list);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index de4eaa8..f0232f5 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -201,10 +201,11 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
>  			   struct nfs_open_context *, struct list_head *);
>  void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
>  int pnfs_layout_process(struct nfs4_layoutget *lgp);
> -void pnfs_layoutreturn_release(struct nfs4_layoutreturn *lpr);
>  void pnfs_destroy_layout(struct nfs_inode *);
>  void pnfs_destroy_all_layouts(struct nfs_client *);
>  void put_layout_hdr(struct inode *inode);
> +void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
> +			     const nfs4_stateid *new);
>  void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo);
>  void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>  			     struct nfs4_state *open_state);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 0ee7cce..ebe11d3 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -270,7 +270,6 @@ struct nfs4_layoutreturn_args {
>  
>  struct nfs4_layoutreturn_res {
>  	struct nfs4_sequence_res seq_res;
> -	bool valid;	/* internal, true if received reply */
>  	u32 lrs_present;
>  	nfs4_stateid stateid;
>  };
