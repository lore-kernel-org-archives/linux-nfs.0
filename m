Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:54608 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435Ab1G1AMt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 20:12:49 -0400
Message-ID: <4E30A957.7080804@panasas.com>
Date: Wed, 27 Jul 2011 17:12:07 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v3 03/25] NFS41: Let layoutcommit handle multiple segments
References: <1311792048-12551-1-git-send-email-rees@umich.edu> <1311792048-12551-4-git-send-email-rees@umich.edu> <4E306F84.6030808@panasas.com> <1311798159.25645.32.camel@lade.trondhjem.org> <4E30762E.4000508@panasas.com> <20110727205804.GA13698@merit.edu> <4E307E6F.6090309@panasas.com> <20110727234041.GC14319@merit.edu>
In-Reply-To: <20110727234041.GC14319@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 04:40 PM, Jim Rees wrote:
> Boaz Harrosh wrote:
> 
>   On 07/27/2011 01:58 PM, Jim Rees wrote:
>   >   But I thought for simplicity since this patchset was reviewed then, I've
>   >   tested with this patch and it works good as well. If you are going to
>   >   break things up, I can test with the minimal patches and report what is
>   >   need in Stable. (Is anyone working on it?)
>   > 
>   > We may have over-squashed that one for block layout.  I can dig up the
>   > original patches if necessary, but I'm guessing you probably have them.
>   
>   Please do. Because by now I'm confused. the first I discovered it was
>   by git diff of a branch that worked. I lost tracked of where the code
>   was originated from.
> 
> Here is just the original multiple segments patch.  This is from the
> 88-patch set I sent out before Bakeathon.  I don't know if this would still
> apply separately.
> 

OK Thanks that one looks familiar enough. I'll test just with this one.

Where did the other changes come from? Is there a Benny's branch that
have them separated so I can have a look. I suspect I also need the one
that encodes the last_byte_written.

Thanks
Boaz

> From fc3381fa66adfcee4203b5a55ca6605bcfc8dafb Mon Sep 17 00:00:00 2001
> From: Peng Tao <bergwolf@gmail.com>
> Date: Tue, 31 May 2011 00:42:56 -0400
> Subject: [PATCH 03/89] pnfs: let layoutcommit code handle multiple segments
> 
> Some layout driver like block will have multiple segments.
> Generic code should be able to handle it.
> ---
>  fs/nfs/pnfs.c |   15 ++++++++++++---
>  fs/nfs/pnfs.h |    1 +
>  2 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index e3d618b..c18cda0 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1193,10 +1193,18 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
>  static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
>  {
>  	struct pnfs_layout_segment *lseg, *rv = NULL;
> +	loff_t max_pos = 0;
> +
> +	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
> +		if (lseg->pls_range.iomode == IOMODE_RW) {
> +			if (max_pos < lseg->pls_end_pos)
> +				max_pos = lseg->pls_end_pos;
> +			if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
> +				rv = lseg;
> +		}
> +	}
> +	rv->pls_end_pos = max_pos;
>  
> -	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
> -		if (lseg->pls_range.iomode == IOMODE_RW)
> -			rv = lseg;
>  	return rv;
>  }
>  
> @@ -1211,6 +1219,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
>  		/* references matched in nfs4_layoutcommit_release */
>  		get_lseg(wdata->lseg);
> +		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
>  		wdata->lseg->pls_lc_cred =
>  			get_rpccred(wdata->args.context->state->owner->so_cred);
>  		mark_as_dirty = true;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 53819d0..c6a9af2 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -36,6 +36,7 @@
>  enum {
>  	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
>  	NFS_LSEG_ROC,		/* roc bit received from server */
> +	NFS_LSEG_LAYOUTCOMMIT,	/* layoutcommit bit set for layoutcommit */
>  };
>  
>  struct pnfs_layout_segment {

