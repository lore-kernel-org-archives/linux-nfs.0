Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53490 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756051Ab2FBXA4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jun 2012 19:00:56 -0400
Message-ID: <4FCA9B0E.5070304@panasas.com>
Date: Sun, 3 Jun 2012 02:00:30 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <andros@netapp.com>
CC: <trond.myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1 do not call LAYOUTRETURN when there are no
 legs
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
In-Reply-To: <1338571178-2096-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2012 08:19 PM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 


I wish you would send your patches preceded with a [PATCHSET 0/x]
That gives us a short summery and a little background on its motivation.

For example here, what are the problems you encounter, how did you test
it and so on...

Do these actually depend and/or fix your previous "send layout_return ..."
In files layout?

(You can still send all patches by git send-email command line just the same
 just add a [PATCHSET 0/x]-xxx-yyy.txt and it will get sent first, right?)

Thanks
Boaz

> mark_matching_lsegs_invalid() does not indicate if the plh_segs list is
> empty on entrance - and it can be empty on exit.
> 
> When the plh_segs list is emtpy, mark_matching_lsegs_invalid removes
> the pnfs_layout_hdr creation reference.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c |   17 +++++++++++++++--
>  1 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index b8323aa..854df5e 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -646,7 +646,14 @@ out_err_free:
>  	return NULL;
>  }
>  
> -/* Initiates a LAYOUTRETURN(FILE) */
> +/*
> + * Initiates a LAYOUTRETURN(FILE), and removes the pnfs_layout_hdr
> + * when the layout segment list is empty.
> + *
> + * Note that a pnfs_layout_hdr can exist with an empty layout segment
> + * list when LAYOUTGET has failed, or when LAYOUTGET succeeded, but the
> + * deviceid is marked invalid.
> + */
>  int
>  _pnfs_return_layout(struct inode *ino)
>  {
> @@ -655,7 +662,7 @@ _pnfs_return_layout(struct inode *ino)
>  	LIST_HEAD(tmp_list);
>  	struct nfs4_layoutreturn *lrp;
>  	nfs4_stateid stateid;
> -	int status = 0;
> +	int status = 0, empty = 0;
>  
>  	dprintk("--> %s\n", __func__);
>  
> @@ -669,11 +676,17 @@ _pnfs_return_layout(struct inode *ino)
>  	stateid = nfsi->layout->plh_stateid;
>  	/* Reference matched in nfs4_layoutreturn_release */
>  	get_layout_hdr(lo);
> +	empty = list_empty(&lo->plh_segs);
>  	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
>  	lo->plh_block_lgets++;
>  	spin_unlock(&ino->i_lock);
>  	pnfs_free_lseg_list(&tmp_list);
>  
> +	if (empty) {
> +		put_layout_hdr(lo);
> +		dprintk("%s: no layout segments to return\n", __func__);
> +		return status;
> +	}
>  	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
>  
>  	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);


