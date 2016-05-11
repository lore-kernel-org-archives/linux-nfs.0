Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:36764 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216AbcEKP3r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2016 11:29:47 -0400
Received: by mail-qg0-f66.google.com with SMTP id f74so3196340qge.3
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2016 08:29:47 -0700 (PDT)
Message-ID: <1462980582.7287.1.camel@poochiereds.net>
Subject: Re: [PATCH v2 8/9] pnfs: lift retry logic from send_layoutget to
 pnfs_update_layout
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 May 2016 11:29:42 -0400
In-Reply-To: <1462962074-6989-9-git-send-email-jeff.layton@primarydata.com>
References: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
	 <1462962074-6989-9-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-05-11 at 06:21 -0400, Jeff Layton wrote:
> If we get back something like NFS4ERR_OLD_STATEID, that will be
> translated into -EAGAIN, and the do/while loop in send_layoutget
> will drive the call again.
> 
> This is not quite what we want, I think. An error like that is a
> sign that something has changed. That something could have been a
> concurrent LAYOUTGET that would give us a usable lseg.
> 
> Lift the retry logic into pnfs_update_layout instead. That allows
> us to redo the layout search, and may spare us from having to issue
> an RPC.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 67 ++++++++++++++++++++++++++++++-----------------------------
>  1 file changed, 34 insertions(+), 33 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 5f6ed295acb5..ed3ab3e81f38 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -839,7 +839,6 @@ send_layoutget(struct pnfs_layout_hdr *lo,
>  	struct inode *ino = lo->plh_inode;
>  	struct nfs_server *server = NFS_SERVER(ino);
>  	struct nfs4_layoutget *lgp;
> -	struct pnfs_layout_segment *lseg;
>  	loff_t i_size;
>  
>  	dprintk("--> %s\n", __func__);
> @@ -849,42 +848,30 @@ send_layoutget(struct pnfs_layout_hdr *lo,
>  	 * store in lseg. If we race with a concurrent seqid morphing
>  	 * op, then re-send the LAYOUTGET.
>  	 */
> -	do {
> -		lgp = kzalloc(sizeof(*lgp), gfp_flags);
> -		if (lgp == NULL)
> -			return NULL;
> -

Just spotted this bug. The above should return ERR_PTR(-ENOMEM). Fixed
in my nfs-4.7 branch.

> -		i_size = i_size_read(ino);
> -
> -		lgp->args.minlength = PAGE_SIZE;
> -		if (lgp->args.minlength > range->length)
> -			lgp->args.minlength = range->length;
> -		if (range->iomode == IOMODE_READ) {
> -			if (range->offset >= i_size)
> -				lgp->args.minlength = 0;
> -			else if (i_size - range->offset < lgp->args.minlength)
> -				lgp->args.minlength = i_size - range->offset;
> -		}
> -		lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
> -		pnfs_copy_range(&lgp->args.range, range);
> -		lgp->args.type = server->pnfs_curr_ld->id;
> -		lgp->args.inode = ino;
> -		lgp->args.ctx = get_nfs_open_context(ctx);
> -		lgp->gfp_flags = gfp_flags;
> -		lgp->cred = lo->plh_lc_cred;
> +	lgp = kzalloc(sizeof(*lgp), gfp_flags);
> +	if (lgp == NULL)
> +		return NULL;
>  
> -		lseg = nfs4_proc_layoutget(lgp, gfp_flags);
> -	} while (lseg == ERR_PTR(-EAGAIN));
> +	i_size = i_size_read(ino);
>  
> -	if (IS_ERR(lseg)) {
> -		if (!nfs_error_is_fatal(PTR_ERR(lseg)))
> -			lseg = NULL;
> -	} else {
> -		pnfs_layout_clear_fail_bit(lo,
> -				pnfs_iomode_to_fail_bit(range->iomode));
> +	lgp->args.minlength = PAGE_SIZE;
> +	if (lgp->args.minlength > range->length)
> +		lgp->args.minlength = range->length;
> +	if (range->iomode == IOMODE_READ) {
> +	if (range->offset >= i_size)
> +			lgp->args.minlength = 0;
> +		else if (i_size - range->offset < lgp->args.minlength)
> +			lgp->args.minlength = i_size - range->offset;
>  	}
> +	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
> +	pnfs_copy_range(&lgp->args.range, range);
> +	lgp->args.type = server->pnfs_curr_ld->id;
> +	lgp->args.inode = ino;
> +	lgp->args.ctx = get_nfs_open_context(ctx);
> +	lgp->gfp_flags = gfp_flags;
> +	lgp->cred = lo->plh_lc_cred;
>  
> -	return lseg;
> +	return nfs4_proc_layoutget(lgp, gfp_flags);
>  }
>  
>  static void pnfs_clear_layoutcommit(struct inode *inode,
> @@ -1646,6 +1633,20 @@ lookup_again:
>  		arg.length = PAGE_ALIGN(arg.length);
>  
>  	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
> +	if (IS_ERR(lseg)) {
> +		if (lseg == ERR_PTR(-EAGAIN)) {
> +			if (first)
> +				pnfs_clear_first_layoutget(lo);
> +			pnfs_put_layout_hdr(lo);
> +			goto lookup_again;
> +		}
> +
> +		if (!nfs_error_is_fatal(PTR_ERR(lseg)))
> +			lseg = NULL;
> +	} else {
> +		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
> +	}
> +
>  	atomic_dec(&lo->plh_outstanding);
>  	trace_pnfs_update_layout(ino, pos, count, iomode, lo,
>  				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
-- 
Jeff Layton <jlayton@poochiereds.net>
