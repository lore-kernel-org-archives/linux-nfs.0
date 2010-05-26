From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 5/8] pnfs-submit: request whole file layouts only
Date: Wed, 26 May 2010 11:42:12 +0300
Message-ID: <4BFCDEE4.1060303@panasas.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com> <1274119004-30213-2-git-send-email-batsakis@netapp.com> <1274119004-30213-3-git-send-email-batsakis@netapp.com> <1274119004-30213-4-git-send-email-batsakis@netapp.com> <1274119004-30213-5-git-send-email-batsakis@netapp.com> <1274119004-30213-6-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45112 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790Ab0EZImR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 04:42:17 -0400
Received: by fxm5 with SMTP id 5so4111032fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 01:42:15 -0700 (PDT)
In-Reply-To: <1274119004-30213-6-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 17, 2010, 20:56 +0300, Alexandros Batsakis <batsakis@netapp.com> wrote:
> In the first iteration of the pNFS code, we support only whole-file layouts.
> To facilitate the move to multiple-segments, we keep the segment processing
> code, but the segment list should always contain a max of one segment per I/O type
> 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/callback_proc.c |    7 ++++---
>  fs/nfs/pnfs.c          |   25 +++++--------------------
>  2 files changed, 9 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 8ef1502..bfada25 100644
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
>  					    RETURN_FILE);
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
> index ecf6dc2..2cc8895 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -546,12 +546,6 @@ pnfs_layout_from_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
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
> @@ -572,10 +566,10 @@ get_layout(struct inode *ino,
>  		return -ENOMEM;
>  	}
>  	lgp->lo = lo;
> -	lgp->args.minlength = PAGE_CACHE_SIZE;
> +	lgp->args.minlength = NFS4_MAX_UINT64;
>  	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
>  	lgp->args.lseg.iomode = range->iomode;
> -	lgp->args.lseg.offset = range->offset;
> +	lgp->args.lseg.offset = 0;
>  	lgp->args.lseg.length = max(range->length, lgp->args.minlength);

This is a protocol bug.

As per RFC5661, 18.43. Operation 50: LAYOUTGET:
   The second range is between loga_offset and loga_offset +
   loga_minlength - 1 inclusive.  This range indicates the required
   range the client needs the layout to cover.  Thus, loga_minlength
   MUST be less than or equal to loga_length.

Therefore, lseg.length must also be set to NFS4_MAX_UINT64

>  	lgp->args.type = server->pnfs_curr_ld->id;
>  	lgp->args.inode = ino;
> @@ -1068,8 +1062,8 @@ pnfs_update_layout(struct inode *ino,
>  {
>  	struct nfs4_pnfs_layout_segment arg = {
>  		.iomode = iomode,
> -		.offset = pos,
> -		.length = countg
> +		.offset = 0,
> +		.length = ~0

let's use NFS4_MAX_UINT64 rather than counting on the compiler for promoting ~0
to u64.

>  	};
>  	struct nfs_inode *nfsi = NFS_I(ino);
>  	struct pnfs_layout_type *lo;
> @@ -1159,7 +1153,6 @@ out_put:
>  void
>  pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  {
> -	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
>  	struct pnfs_layout_segment *lseg = NULL;
>  	struct nfs_inode *nfsi = PNFS_NFS_INODE(lgp->lo);
>  	time_t suspend = 0;
> @@ -1167,15 +1160,8 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  	dprintk("-->%s\n", __func__);
>  
>  	lgp->status = rpc_status;
> -	if (likely(!rpc_status)) {
> -		if (unlikely(res->layout.len <= 0)) {
> -			printk(KERN_ERR
> -			       "%s: ERROR!  Layout size is ZERO!\n", __func__);
> -			lgp->status = -EIO;
> -			goto get_out;
> -		}

This is an orthogonal issue.
Why not verify the resulting layout we got?

Benny

> +	if (likely(!rpc_status))
>  		goto out;
> -	}
>  
>  	dprintk("%s: ERROR retrieving layout %d\n", __func__, rpc_status);
>  	switch (rpc_status) {
> @@ -1250,7 +1236,6 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
>  		break;
>  	}
>  
> -get_out:
>  	/* remember that get layout failed and suspend trying */
>  	nfsi->layout.pnfs_layout_suspend = suspend;
>  	set_bit(lo_fail_bit(lgp->args.lseg.iomode),

