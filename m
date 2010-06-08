From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 5/8] pnfs-submit: request whole-file layouts only
Date: Tue, 08 Jun 2010 10:14:09 +0300
Message-ID: <4C0DEDC1.6070105@panasas.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com> <1275945113-3436-2-git-send-email-batsakis@netapp.com> <1275945113-3436-3-git-send-email-batsakis@netapp.com> <1275945113-3436-4-git-send-email-batsakis@netapp.com> <1275945113-3436-5-git-send-email-batsakis@netapp.com> <1275945113-3436-6-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65053 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab0FHHOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 03:14:14 -0400
Received: by fxm8 with SMTP id 8so2613628fxm.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 00:14:13 -0700 (PDT)
In-Reply-To: <1275945113-3436-6-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-06-08 00:11, Alexandros Batsakis wrote:
> In the first iteration of the pNFS code, we support only whole file layouts.
> To facilitate the move to multiple-segments, we keep the segment processing
> code, but the segment list should always contain at most one segment per I/O type
> 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/callback_proc.c |    7 ++++---
>  fs/nfs/pnfs.c          |   25 ++++++++-----------------
>  2 files changed, 12 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 8752239..16b4510 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -213,6 +213,10 @@ static int pnfs_recall_layout(void *data)
>     then return layouts, resume after layoutreturns complete
>   */
>  
> +	/* support whole file layouts only */
> +	rl.cbl_seg.offset = 0;
> +	rl.cbl_seg.length = NFS4_MAX_UINT64;
> +
>  	if (rl.cbl_recall_type == RETURN_FILE) {
>  		status = pnfs_return_layout(inode, &rl.cbl_seg, &rl.cbl_stateid,
>  					    RETURN_FILE, true);
> @@ -221,9 +225,6 @@ static int pnfs_recall_layout(void *data)
>  		goto out;
>  	}
>  
> -	rl.cbl_seg.offset = 0;
> -	rl.cbl_seg.length = NFS4_MAX_UINT64;
> -
>  	/* FIXME: This loop is inefficient, running in O(|s_inodes|^2) */
>  	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
>  		/* XXX need to check status on pnfs_return_layout */
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index dd7ad26..8985e9f 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -551,12 +551,6 @@ pnfs_layout_from_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
>  *    for now, assume that whole file layouts are requested.
>  *    arg->offset: 0
>  *    arg->length: all ones
> -*
> -*    for now, assume the LAYOUTGET operation is triggered by an I/O request.
> -*    the count field is the count in the I/O request, and will be used
> -*    as the minlength. for the file operation that piggy-backs
> -*    the LAYOUTGET operation with an OPEN, s
> -*    arg->minlength = count.
>  */
>  static int
>  get_layout(struct inode *ino,
> @@ -577,11 +571,11 @@ get_layout(struct inode *ino,
>  		return -ENOMEM;
>  	}
>  	lgp->lo = lo;
> -	lgp->args.minlength = PAGE_CACHE_SIZE;
> +	lgp->args.minlength = NFS4_MAX_UINT64;
>  	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
>  	lgp->args.lseg.iomode = range->iomode;
> -	lgp->args.lseg.offset = range->offset;
> -	lgp->args.lseg.length = max(range->length, lgp->args.minlength);
> +	lgp->args.lseg.offset = 0;
> +	lgp->args.lseg.length = NFS4_MAX_UINT64;

I'm not sure how well this will work for pnfs-obj writes.
We might have to revert it in the pnfs post-submit branch.

Benny

>  	lgp->args.type = server->pnfs_curr_ld->id;
>  	lgp->args.inode = ino;
>  	lgp->lsegpp = lsegpp;
> @@ -756,7 +750,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  	else {
>  		arg.iomode = IOMODE_ANY;
>  		arg.offset = 0;
> -		arg.length = ~0;
> +		arg.length = NFS4_MAX_UINT64;
>  	}
>  	if (type == RETURN_FILE) {
>  		lo = get_lock_current_layout(nfsi);
> @@ -1051,8 +1045,8 @@ pnfs_update_layout(struct inode *ino,
>  {
>  	struct nfs4_pnfs_layout_segment arg = {
>  		.iomode = iomode,
> -		.offset = pos,
> -		.length = count
> +		.offset = 0,
> +		.length = ~0
>  	};
>  	struct nfs_inode *nfsi = NFS_I(ino);
>  	struct pnfs_layout_type *lo;
> @@ -1142,7 +1136,6 @@ out_put:
>  void
>  pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  {
> -	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
>  	struct pnfs_layout_segment *lseg = NULL;
>  	struct nfs_inode *nfsi = PNFS_NFS_INODE(lgp->lo);
>  	time_t suspend = 0;
> @@ -1151,11 +1144,10 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  
>  	lgp->status = rpc_status;
>  	if (likely(!rpc_status)) {
> -		if (unlikely(res->layout.len <= 0)) {
> +		if (unlikely(lgp->res.layout.len < 0)) {
>  			printk(KERN_ERR
> -			       "%s: ERROR!  Layout size is ZERO!\n", __func__);
> +			       "%s: ERROR Returned layout size is ZERO\n", __func__);
>  			lgp->status = -EIO;
> -			goto get_out;
>  		}
>  		goto out;
>  	}
> @@ -1233,7 +1225,6 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  		break;
>  	}
>  
> -get_out:
>  	/* remember that get layout failed and suspend trying */
>  	nfsi->layout.pnfs_layout_suspend = suspend;
>  	set_bit(lo_fail_bit(lgp->args.lseg.iomode),

