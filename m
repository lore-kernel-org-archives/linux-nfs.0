Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53843 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759212Ab2FARVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 13:21:15 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] NFSv4.1 do not call LAYOUTRETURN when there are no legs
Date: Fri,  1 Jun 2012 13:19:36 -0400
Message-Id: <1338571178-2096-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

mark_matching_lsegs_invalid() does not indicate if the plh_segs list is
empty on entrance - and it can be empty on exit.

When the plh_segs list is emtpy, mark_matching_lsegs_invalid removes
the pnfs_layout_hdr creation reference.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b8323aa..854df5e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -646,7 +646,14 @@ out_err_free:
 	return NULL;
 }
 
-/* Initiates a LAYOUTRETURN(FILE) */
+/*
+ * Initiates a LAYOUTRETURN(FILE), and removes the pnfs_layout_hdr
+ * when the layout segment list is empty.
+ *
+ * Note that a pnfs_layout_hdr can exist with an empty layout segment
+ * list when LAYOUTGET has failed, or when LAYOUTGET succeeded, but the
+ * deviceid is marked invalid.
+ */
 int
 _pnfs_return_layout(struct inode *ino)
 {
@@ -655,7 +662,7 @@ _pnfs_return_layout(struct inode *ino)
 	LIST_HEAD(tmp_list);
 	struct nfs4_layoutreturn *lrp;
 	nfs4_stateid stateid;
-	int status = 0;
+	int status = 0, empty = 0;
 
 	dprintk("--> %s\n", __func__);
 
@@ -669,11 +676,17 @@ _pnfs_return_layout(struct inode *ino)
 	stateid = nfsi->layout->plh_stateid;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
+	empty = list_empty(&lo->plh_segs);
 	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 	lo->plh_block_lgets++;
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
+	if (empty) {
+		put_layout_hdr(lo);
+		dprintk("%s: no layout segments to return\n", __func__);
+		return status;
+	}
 	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
 
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
-- 
1.7.6.4

