Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36447 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758070Ab1EYQHH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 12:07:07 -0400
Message-ID: <4DDD2933.3000209@panasas.com>
Date: Wed, 25 May 2011 19:07:15 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: [PATCH] SQUASHME: pnfs: Fix NULL dereference in the -ENOMEM path
References: <4DDA8C3D.5080706@panasas.com> <1306168714-11721-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306168714-11721-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


In _pnfs_return_layout:

lrp pointer is checked for NULL after it was already accessed.

The rational here is that in _pnfs_return_layout we want to
de-ref and release the layout regardless of if we sent the
return or not (forgetfull). An eventual recall can return -ENOMATCHING
instead of -EDELAY.

So to keep the reasoning above, copy the stateid twice.

Benny if it is OK to not release the layout on -ENOMEM then the check
could just be moved above the spin_lock(), and the put_layout_hdr removed.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a07b007..c3ec577 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -628,6 +628,7 @@ _pnfs_return_layout(struct inode *ino)
 	struct nfs_inode *nfsi = NFS_I(ino);
 	LIST_HEAD(tmp_list);
 	struct nfs4_layoutreturn *lrp;
+	nfs4_stateid stateid;
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
@@ -642,7 +643,7 @@ _pnfs_return_layout(struct inode *ino)
 		kfree(lrp);
 		goto out;
 	}
-	lrp->args.stateid = nfsi->layout->plh_stateid;
+	stateid = nfsi->layout->plh_stateid;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
 	spin_unlock(&ino->i_lock);
@@ -655,6 +656,7 @@ _pnfs_return_layout(struct inode *ino)
 		status = -ENOMEM;
 		goto out;
 	}
+	lrp->args.stateid = stateid;
 	lrp->args.reclaim = 0;
 	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
 	lrp->args.inode = ino;
-- 
1.7.2.3


