Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:34413 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756461Ab1IHKAu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 06:00:50 -0400
From: <tao.peng@emc.com>
To: <gusev.vitaliy@nexenta.com>, <Trond.Myklebust@netapp.com>
CC: <gusev.vitaliy@gmail.com>, <linux-nfs@vger.kernel.org>
Date: Thu, 8 Sep 2011 06:00:25 -0400
Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
Message-ID: <F19688880B763E40B28B2B462677FBF805C3299C9C@MX09A.corp.emc.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
In-Reply-To: <4E669B21.30006@nexenta.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Gusev,

> -----Original Message-----
> From: Vitaliy Gusev [mailto:gusev.vitaliy@nexenta.com]
> Sent: Wednesday, September 07, 2011 6:14 AM
> To: Trond Myklebust
> Cc: Vitaliy Gusev; Peng, Tao; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
> 
> >> @@ -1376,7 +1376,8 @@ static void pnfs_list_write_lseg(struct inode *inode,
> struct list_head *listp)
> >>
> >>   	list_for_each_entry(lseg,&NFS_I(inode)->layout->plh_segs, pls_list) {
> >>   		if (lseg->pls_range.iomode == IOMODE_RW&&
> >> -		    test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags))
> >> +		    test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags)&&
> >> +		    list_empty(&lseg->pls_lc_list))
> >>   			list_add(&lseg->pls_lc_list, listp);
> >>   	}
> >>   }
> >
> > If the lseg is already part of one layoutcommit, but we're sending a
> > second one for the same range (presumably because we wrote more data in
> > the same region), then the above causes the lseg to be excluded.
> 
> 
> Yes, lseg is excluded, This patch does exactly only exclusion of lseg.
> lseg is used here only to get/put reference on this lseg, so skipping is
> correct.
> 
> 
> However, checking on list_empty can occur (on other CPU) in the middle:
> 
> 	list_del_init(&lseg->pls_lc_list);
> Here >>>>>>
> 	if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
> 			       &lseg->pls_flags))
> 		put_lseg(lseg);
> 
> 
> So list_del_init must be executed under the same lock as
> pnfs_list_write_lseg, i.e. inode->i_lock.
Yes, you are right. How about following patch?

>From 14c6da67565fb31c2d2775ccefd93251f348910d Mon Sep 17 00:00:00 2001
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 8 Sep 2011 00:57:02 -0400
Subject: [PATCH] nfsv4: fix race in layoutcommit lseg list create/free

Since there can be more than one layoutcommit proc happen the same time,
lseg list create/free should be protected. Otherwise lseg list
may get corrupted.

Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c77039..da7c20c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5964,6 +5964,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 	struct pnfs_layout_segment *lseg, *tmp;
 
 	pnfs_cleanup_layoutcommit(data);
+	spin_lock(&data->args.inode->i_lock);
 	/* Matched by references in pnfs_set_layoutcommit */
 	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
 		list_del_init(&lseg->pls_lc_list);
@@ -5971,6 +5972,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 				       &lseg->pls_flags))
 			put_lseg(lseg);
 	}
+	spin_unlock(&data->args.inode->i_lock);
 	put_rpccred(data->cred);
 	kfree(data);
 }
-- 
1.7.4.2

> 
> 
> >
> > I agree that the current code causes list corruption, but before
> > applying something like the above patch, I'd like to understand why it
> > is correct.
> >
> > Trond
> >
> 

