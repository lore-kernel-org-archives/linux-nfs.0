Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33479 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbcGOOph (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2016 10:45:37 -0400
Received: by mail-qk0-f169.google.com with SMTP id p74so103235443qka.0
        for <linux-nfs@vger.kernel.org>; Fri, 15 Jul 2016 07:45:37 -0700 (PDT)
Message-ID: <1468593935.3584.6.camel@redhat.com>
Subject: Re: [PATCH 1/4] pNFS: Fix post-layoutget error handling in
 pnfs_update_layout()
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Date: Fri, 15 Jul 2016 10:45:35 -0400
In-Reply-To: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
References: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-07-14 at 18:58 -0400, Trond Myklebust wrote:
> The non-retry error path is currently broken and ends up releasing the
> reference to the layout twice. It also can end up clearing the
> NFS_LAYOUT_FIRST_LAYOUTGET flag twice, causing a race.
> 
> In addition, the retry path will fail to decrement the plh_outstanding
> counter.
> 
> Fixes: 183d9e7b112aa ("pnfs: rework LAYOUTGET retry handling")
> Cc: stable@vger.kernel.org # 4.7
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 0fbe734cc38c..73b0dc90265a 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1645,6 +1645,7 @@ lookup_again:
>  	lseg = send_layoutget(lo, ctx, &stateid, &arg, &timeout, gfp_flags);
>  	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
>  				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
> +	atomic_dec(&lo->plh_outstanding);
>  	if (IS_ERR(lseg)) {
>  		switch(PTR_ERR(lseg)) {
>  		case -ERECALLCONFLICT:
> @@ -1652,26 +1653,25 @@ lookup_again:
>  				lseg = NULL;
>  			/* Fallthrough */
>  		case -EAGAIN:
> -			pnfs_put_layout_hdr(lo);
> -			if (first)
> -				pnfs_clear_first_layoutget(lo);
> -			if (lseg) {
> -				trace_pnfs_update_layout(ino, pos, count,
> -					iomode, lo, lseg, PNFS_UPDATE_LAYOUT_RETRY);
> -				goto lookup_again;
> -			}
> -			/* Fallthrough */
> +			break;
>  		default:
>  			if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
>  				pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
>  				lseg = NULL;
>  			}
>  		}
> +		if (lseg) {
> +			pnfs_put_layout_hdr(lo);
> +			if (first)
> +				pnfs_clear_first_layoutget(lo);
> +			trace_pnfs_update_layout(ino, pos, count,
> +				iomode, lo, lseg, PNFS_UPDATE_LAYOUT_RETRY);
> +			goto lookup_again;
> +		}
>  	} else {
>  		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
>  	}
>  
> -	atomic_dec(&lo->plh_outstanding);
>  out_put_layout_hdr:
>  	if (first)
>  		pnfs_clear_first_layoutget(lo);

The whole set looks good to me. Nice catches all around!

Reviewed-by: Jeff Layton <jlayton@redhat.com>
