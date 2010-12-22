Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7648 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752246Ab0LVVna convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Dec 2010 16:43:30 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBMLhCnI016604
	for <linux-nfs@vger.kernel.org>; Wed, 22 Dec 2010 13:43:12 -0800 (PST)
Subject: Re: [PATCH 06/15] pnfs: change how lsegs are removed from layout
 list
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1292990449-20057-7-git-send-email-iisaman@netapp.com>
References: <1292990449-20057-1-git-send-email-iisaman@netapp.com>
	 <1292990449-20057-7-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 22 Dec 2010 16:43:11 -0500
Message-ID: <1293054191.6422.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-12-21 at 23:00 -0500, Fred Isaman wrote:
> This is to prepare the way for sensible io draining.  Instead of just
> removing the lseg from the list, we instead clear the VALID flag
> (preventing new io from grabbing references to the lseg) and remove
> the reference holding it in the list.  Thus the lseg will be removed
> once any io in progress completes and any references still held are
> dropped.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/inode.c |    2 +-
>  fs/nfs/pnfs.c  |  121 ++++++++++++++++++++++++++++++++++++-------------------
>  fs/nfs/pnfs.h  |    8 +++-
>  3 files changed, 87 insertions(+), 44 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e67e31c..43a69da 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c

> -/* Called without i_lock held, as the free_lseg call may sleep */
> -static void
> -destroy_lseg(struct kref *kref)
> +static void free_lseg(struct pnfs_layout_segment *lseg)
>  {
> -	struct pnfs_layout_segment *lseg =
> -		container_of(kref, struct pnfs_layout_segment, pls_refcount);
>  	struct inode *ino = lseg->pls_layout->plh_inode;
>  
> -	dprintk("--> %s\n", __func__);
> +	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
>  	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>  	/* Matched by get_layout_hdr in pnfs_insert_layout */
>  	put_layout_hdr(ino);
>  }

<snip>

>  static void
> -pnfs_free_lseg_list(struct list_head *tmp_list)
> +pnfs_free_lseg_list(struct list_head *free_me)
>  {
> -	struct pnfs_layout_segment *lseg;
> +	struct pnfs_layout_segment *lseg, *tmp;
>  
> -	while (!list_empty(tmp_list)) {
> -		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
> -				pls_list);
> -		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
> -		list_del(&lseg->pls_list);
> -		put_lseg(lseg);
> -	}
> +	list_for_each_entry_safe(lseg, tmp, free_me, pls_list)
> +		free_lseg(lseg);
> +	INIT_LIST_HEAD(free_me);
>  }

The above looks very dubious to me. Why is this change needed, and what
guarantees do we have that free_lseg() will do the right thing w.r.t.
removing stuff from the list?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

