Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:31278 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084AbcGNXQJ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2016 19:16:09 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: List Linux <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] pNFS: Fix post-layoutget error handling in
 pnfs_update_layout()
Date: Thu, 14 Jul 2016 23:15:50 +0000
Message-ID: <69402880-98F0-4B0D-A0FC-877B803D974B@primarydata.com>
References: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 14, 2016, at 18:58, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
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
> fs/nfs/pnfs.c | 20 ++++++++++----------
> 1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 0fbe734cc38c..73b0dc90265a 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1645,6 +1645,7 @@ lookup_again:
> 	lseg = send_layoutget(lo, ctx, &stateid, &arg, &timeout, gfp_flags);
> 	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
> 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
> +	atomic_dec(&lo->plh_outstanding);
> 	if (IS_ERR(lseg)) {
> 		switch(PTR_ERR(lseg)) {
> 		case -ERECALLCONFLICT:
> @@ -1652,26 +1653,25 @@ lookup_again:
> 				lseg = NULL;
> 			/* Fallthrough */
> 		case -EAGAIN:
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
> 		default:
> 			if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
> 				pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
> 				lseg = NULL;
> 			}
> 		}
> +		if (lseg) {
> +			pnfs_put_layout_hdr(lo);

Yes, I’m aware I need to move this to after the trace_pnfs_update_layout() below (and before “goto lookup_again”). I managed to send out an earlier version of the patch that is being committed to linux-next.

> +			if (first)
> +				pnfs_clear_first_layoutget(lo);
> +			trace_pnfs_update_layout(ino, pos, count,
> +				iomode, lo, lseg, PNFS_UPDATE_LAYOUT_RETRY);
> +			goto lookup_again;
> +		}
> 	} else {
> 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
> 	}
> 
> -	atomic_dec(&lo->plh_outstanding);
> out_put_layout_hdr:
> 	if (first)
> 		pnfs_clear_first_layoutget(lo);
> -- 
> 2.7.4
> 

