Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f52.google.com ([74.125.83.52]:59113 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3AUOyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:20 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so2726406eek.25
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:19 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 1/9] SQUASHME: pnfsd: fix lrs_present calculation
Date: Mon, 21 Jan 2013 16:54:15 +0200
Message-Id: <1358780055-5884-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lrs_present must be set to zero iff the client holds no layout state on
the respective file.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 3931e52..5c50d8a 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -893,7 +893,7 @@ struct super_block *
 	struct nfs4_layout *lp, *nextlp;
 
 	dprintk("%s: clp %p fp %p\n", __func__, clp, fp);
-	lrp->lrs_present = 1;
+	lrp->lrs_present = 0;
 	spin_lock(&layout_lock);
 	list_for_each_entry_safe (lp, nextlp, &fp->fi_layouts, lo_perfile) {
 		dprintk("%s: lp %p client %p,%p lo_type %x,%x iomode %d,%d\n",
@@ -901,19 +901,22 @@ struct super_block *
 			lp->lo_client, clp,
 			lp->lo_seg.layout_type, lrp->args.lr_seg.layout_type,
 			lp->lo_seg.iomode, lrp->args.lr_seg.iomode);
-		if (lp->lo_client != clp ||
-		    lp->lo_seg.layout_type != lrp->args.lr_seg.layout_type ||
+		if (lp->lo_client != clp)
+			continue;
+		if (lp->lo_seg.layout_type != lrp->args.lr_seg.layout_type ||
 		    (lp->lo_seg.iomode != lrp->args.lr_seg.iomode &&
 		     lrp->args.lr_seg.iomode != IOMODE_ANY) ||
-		     !lo_seg_overlapping(&lp->lo_seg, &lrp->args.lr_seg))
+		     !lo_seg_overlapping(&lp->lo_seg, &lrp->args.lr_seg)) {
+			lrp->lrs_present = 1;
 			continue;
+		}
 		layouts_found++;
 		trim_layout(&lp->lo_seg, &lrp->args.lr_seg);
 		if (!lp->lo_seg.length) {
-			lrp->lrs_present = 0;
 			dequeue_layout(lp);
 			destroy_layout(lp);
-		}
+		} else
+			lrp->lrs_present = 1;
 	}
 	if (ls && layouts_found && lrp->lrs_present)
 		update_layout_stateid_locked(ls, &lrp->lr_sid);
-- 
1.7.11.7

