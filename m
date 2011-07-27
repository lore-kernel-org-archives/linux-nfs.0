Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36589 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681Ab1G0Tr0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 15:47:26 -0400
Subject: Re: [PATCH v3 04/25] NFS41: save layoutcommit cred after first
 successful layoutget
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 15:47:21 -0400
In-Reply-To: <1311792048-12551-5-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-5-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311796041.25645.17.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Peng Tao <bergwolf@gmail.com>
> 
> Save it in layout header instead of in every segment.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/pnfs.c |   12 ++++++------
>  fs/nfs/pnfs.h |    1 -
>  2 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index dae19dd..fbebd2a 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -211,6 +211,7 @@ destroy_layout_hdr(struct pnfs_layout_hdr *lo)
>  	dprintk("%s: freeing layout cache %p\n", __func__, lo);
>  	BUG_ON(!list_empty(&lo->plh_layouts));
>  	NFS_I(lo->plh_inode)->layout = NULL;
> +	put_rpccred(lo->plh_lc_cred);
>  	pnfs_free_layout_hdr(lo);
>  }
>  
> @@ -1007,6 +1008,10 @@ pnfs_update_layout(struct inode *ino,
>  		list_del_init(&lo->plh_layouts);
>  		spin_unlock(&clp->cl_lock);
>  	}
> +	if (first) {
> +		lo->plh_lc_cred =
> +			get_rpccred(ctx->state->owner->so_cred);
> +	}

Hmm... This whole 'first' thing is inherently racy. What if two threads
are calling pnfs_update_layout at the same time: they both see
list_empty(&lo->plh_segs), and both conclude that they need to
initialise the layout header. _BOOM_....

The correct thing to do here is either to initialise the layout header
correctly inside pnfs_find_alloc_layout(), or to add a flag for
->plh_flags that can be used with test_and_clear_bit() to get _one_ of
the processes to perform the initialisation.
Personally, I'd prefer the former.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

