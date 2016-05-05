Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36743 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbcEESkT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 14:40:19 -0400
Received: by mail-qg0-f47.google.com with SMTP id w36so44620410qge.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 11:40:18 -0700 (PDT)
Message-ID: <1462473615.12332.9.camel@poochiereds.net>
Subject: Re: [RFC PATCH 4/6] nfs4: only tear down lsegs that precede seqid
 in LAYOUTRETURN args
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: hch@lst.de, Anna.Schumaker@netapp.com,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 05 May 2016 14:40:15 -0400
In-Reply-To: <1462472688-5663-5-git-send-email-jeff.layton@primarydata.com>
References: <1462472688-5663-1-git-send-email-jeff.layton@primarydata.com>
	 <1462472688-5663-5-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-05-05 at 14:24 -0400, Jeff Layton wrote:
> LAYOUTRETURN is "special" in that servers and clients are expected to
> work with old stateids. When the client sends a LAYOUTRETURN with an old
> stateid in it then the server is expected to only tear down layout
> segments that were present when that seqid was current. Ensure that the
> client handles its accounting accordingly.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/callback_proc.c |  3 ++-
>  fs/nfs/nfs42proc.c     |  2 +-
>  fs/nfs/nfs4proc.c      |  5 +++--
>  fs/nfs/pnfs.c          | 61 +++++++++++++++++++++++++++++++++-----------------
>  fs/nfs/pnfs.h          |  3 ++-
>  5 files changed, 48 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 618ced381a14..755838df9996 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -217,7 +217,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  	}
>  
>  	if (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
> -					&args->cbl_range)) {
> +				&args->cbl_range,
> +				be32_to_cpu(args->cbl_stateid.seqid))) {
>  		rv = NFS4_OK;
>  		goto unlock;
>  	}
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index dff83460e5a6..198bcc3e103d 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -232,7 +232,7 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
>  			 * with the current stateid.
>  			 */
>  			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
> -			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL);
> +			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
>  			spin_unlock(&inode->i_lock);
>  			pnfs_free_lseg_list(&head);
>  		} else
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 327b8c34d360..c0645b53c4bc 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7926,7 +7926,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>  			 * with the current stateid.
>  			 */
>  			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
> -			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL);
> +			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
>  			spin_unlock(&inode->i_lock);
>  			pnfs_free_lseg_list(&head);
>  		} else
> @@ -8118,7 +8118,8 @@ static void nfs4_layoutreturn_release(void *calldata)
>  
>  	dprintk("--> %s\n", __func__);
>  	spin_lock(&lo->plh_inode->i_lock);
> -	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range);
> +	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range,
> +			be32_to_cpu(lrp->args.stateid.seqid));
>  	pnfs_mark_layout_returned_if_empty(lo);
>  	if (lrp->res.lrs_present)
>  		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 12016ed54e1d..dc75db4c4849 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -270,7 +270,7 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
>  	};
>  
>  	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
> -	return pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range);
> +	return pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range, 0);
>  }
>  
>  static int
> @@ -308,7 +308,7 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
>  
>  	spin_lock(&inode->i_lock);
>  	pnfs_layout_set_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
> -	pnfs_mark_matching_lsegs_invalid(lo, &head, &range);
> +	pnfs_mark_matching_lsegs_invalid(lo, &head, &range, 0);
>  	spin_unlock(&inode->i_lock);
>  	pnfs_free_lseg_list(&head);
>  	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
> @@ -522,13 +522,35 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
>  	return rv;
>  }
>  
> -/* Returns count of number of matching invalid lsegs remaining in list
> - * after call.
> +/*
> + * Compare 2 layout stateid sequence ids, to see which is newer,
> + * taking into account wraparound issues.
> + */
> +static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
> +{
> +	return (s32)(s1 - s2) > 0;
> +}
> +
> +/**
> + * pnfs_mark_matching_lsegs_invalid - tear down lsegs or mark them for later
> + * @lo: layout header containing the lsegs
> + * @tmp_list: list head where doomed lsegs should go
> + * @recall_range: optional recall range argument to match (may be NULL)
> + * @seq: only invalidate lsegs obtained prior to this sequence (may be 0)
> + *
> + * Walk the list of lsegs in the layout header, and tear down any that should
> + * be destroyed. If "recall_range" is specified then the segment must match
> + * that range. If "seq" is non-zero, then only match segments that were handed
> + * out at or before that sequence.
> + *
> + * Returns number of matching invalid lsegs remaining in list after scanning
> + * it and purging them.
>   */
>  int
>  pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>  			    struct list_head *tmp_list,
> -			    const struct pnfs_layout_range *recall_range)
> +			    const struct pnfs_layout_range *recall_range,
> +			    u32 seq)
>  {
>  	struct pnfs_layout_segment *lseg, *next;
>  	int remaining = 0;
> @@ -540,10 +562,12 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>  	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
>  		if (!recall_range ||
>  		    should_free_lseg(&lseg->pls_range, recall_range)) {
> -			dprintk("%s: freeing lseg %p iomode %d "
> +			if (seq && pnfs_seqid_is_newer(lseg->pls_seq, seq))
> +				continue;
> +			dprintk("%s: freeing lseg %p iomode %d seq %u"
>  				"offset %llu length %llu\n", __func__,
> -				lseg, lseg->pls_range.iomode, lseg->pls_range.offset,
> -				lseg->pls_range.length);
> +				lseg, lseg->pls_range.iomode, lseg->pls_seq,
> +				lseg->pls_range.offset, lseg->pls_range.length);
>  			if (!mark_lseg_invalid(lseg, tmp_list))
>  				remaining++;
>  		}
> @@ -730,15 +754,6 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>  	pnfs_destroy_layouts_byclid(clp, false);
>  }
>  
> -/*
> - * Compare 2 layout stateid sequence ids, to see which is newer,
> - * taking into account wraparound issues.
> - */
> -static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
> -{
> -	return (s32)(s1 - s2) > 0;
> -}
> -
>  /* update lo->plh_stateid with new if is more recent */
>  void
>  pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
> @@ -1014,7 +1029,7 @@ _pnfs_return_layout(struct inode *ino)
>  	pnfs_get_layout_hdr(lo);
>  	empty = list_empty(&lo->plh_segs);
>  	pnfs_clear_layoutcommit(ino, &tmp_list);
> -	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
> +	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL, 0);
>  
>  	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
>  		struct pnfs_layout_range range = {
> @@ -1721,7 +1736,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
>  		 * inode invalid, and don't bother validating the stateid
>  		 * sequence number.
>  		 */
> -		pnfs_mark_matching_lsegs_invalid(lo, &free_me, NULL);
> +		pnfs_mark_matching_lsegs_invalid(lo, &free_me, NULL, 0);
>  
>  		nfs4_stateid_copy(&lo->plh_stateid, &res->stateid);
>  		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
> @@ -1775,7 +1790,8 @@ pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
>  int
>  pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
>  				struct list_head *tmp_list,
> -				const struct pnfs_layout_range *return_range)
> +				const struct pnfs_layout_range *return_range,
> +				u32 seq)
>  {
>  	struct pnfs_layout_segment *lseg, *next;
>  	int remaining = 0;
> @@ -1798,8 +1814,11 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
>  				continue;
>  			remaining++;
>  			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
> -			pnfs_set_plh_return_info(lo, return_range->iomode, lseg->pls_seq);
>  		}
> +
> +	if (remaining)
> +		pnfs_set_plh_return_info(lo, return_range->iomode, seq);
> +
>  	return remaining;
>  }
>  
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 47042084888c..bb68d354255e 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -266,7 +266,8 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
>  				  struct nfs4_state *open_state);
>  int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>  				struct list_head *tmp_list,
> -				const struct pnfs_layout_range *recall_range);
> +				const struct pnfs_layout_range *recall_range,
> +				u32 seq);
>  int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
>  				struct list_head *tmp_list,
>  				const struct pnfs_layout_range *recall_range);

Oops, I sent an earlier version of this set that didn't have a needed
fix. Must also fix the prototype for
pnfs_mark_matching_lsegs_return here, and the caller
in pnfs_error_mark_layout_for_return to pass in lseg->pls_seq for
"seq".

-- 
Jeff Layton <jlayton@poochiereds.net>
