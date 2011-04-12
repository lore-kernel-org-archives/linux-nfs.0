From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] Don't mark_inode_dirty_sync() while holding lock
Date: Tue, 12 Apr 2011 18:23:29 -0400
Message-ID: <1302647009.25410.10.camel@lade.trondhjem.org>
References: <1302643028-76672-1-git-send-email-dros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: andros@netapp.com, trond@netapp.com, linux-nfs@vger.kernel.org
To: Weston Andros Adamson <dros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58472 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab1DLWXr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 18:23:47 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p3CMNVla019447
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 15:23:31 -0700 (PDT)
In-Reply-To: <1302643028-76672-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-04-12 at 17:17 -0400, Weston Andros Adamson wrote:
> mark_inode_dirty_sync() grabs the same inode lock!
> 
> race conditions between holding the lock in pnfs_set_layoutcommit() and in
> mark_inode_dirty_sync() can result in a second call to pnfs_layoutcommit_inode(), but
> this will be a noop as NFS_INO_LAYOUTCOMMIT won't be set in the second call


I'm missing a "Signed-off-by:" here.

> ---
>  fs/nfs/pnfs.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d9ab972..d71997e 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1004,6 +1004,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  {
>  	struct nfs_inode *nfsi = NFS_I(wdata->inode);
>  	loff_t end_pos = wdata->args.offset + wdata->res.count;
> +	int mark_as_dirty = false;

Strictly speaking, an 'int' does not take values in the set 'true' and
'false'.
 
>  	spin_lock(&nfsi->vfs_inode.i_lock);
>  	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
> @@ -1011,13 +1012,18 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  		get_lseg(wdata->lseg);
>  		wdata->lseg->pls_lc_cred =
>  			get_rpccred(wdata->args.context->state->owner->so_cred);
> -		mark_inode_dirty_sync(wdata->inode);
> +		mark_as_dirty = true;
>  		dprintk("%s: Set layoutcommit for inode %lu ",
>  			__func__, wdata->inode->i_ino);
>  	}
>  	if (end_pos > wdata->lseg->pls_end_pos)
>  		wdata->lseg->pls_end_pos = end_pos;
>  	spin_unlock(&nfsi->vfs_inode.i_lock);
> +
> +	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
> +	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
> +	if (mark_as_dirty)
> +		mark_inode_dirty_sync(wdata->inode);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);

Otherwise this looks fine. Please correct and resend.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

