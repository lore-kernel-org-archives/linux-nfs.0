Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757749Ab2FTTDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:03:51 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 4/4] NFSv4.1 do not send LAYOUTRETURN on emtpy plh_segs list
Date: Wed, 20 Jun 2012 15:03:34 -0400
Message-Id: <1340219014-5749-5-git-send-email-andros@netapp.com>
In-Reply-To: <1340219014-5749-1-git-send-email-andros@netapp.com>
References: <1340219014-5749-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

mark_matching_lsegs_invalid() resets the mds_threshold counters and can
dereference the layout hdr on an initial empty plh_segs list. It returns 0 both
in the case of an initial empty list and in a non-emtpy list that was cleared
by calls to mark_lseg_invalid.

Don't send a LAYOUTRETURN if the list was initially empty.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3dfd0a6..2669710 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -651,7 +651,14 @@ out_err_free:
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
@@ -660,7 +667,7 @@ _pnfs_return_layout(struct inode *ino)
 	LIST_HEAD(tmp_list);
 	struct nfs4_layoutreturn *lrp;
 	nfs4_stateid stateid;
-	int status = 0;
+	int status = 0, empty;
 
 	dprintk("NFS: %s for inode %lu\n", __func__, ino->i_ino);
 
@@ -668,13 +675,21 @@ _pnfs_return_layout(struct inode *ino)
 	lo = nfsi->layout;
 	if (!lo || pnfs_test_layout_returned(lo)) {
 		spin_unlock(&ino->i_lock);
-		dprintk("%s: no layout to return\n", __func__);
-		return status;
+		dprintk("NFS: %s no layout to return\n", __func__);
+		goto out;
 	}
 	stateid = nfsi->layout->plh_stateid;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
+	empty = list_empty(&lo->plh_segs);
 	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
+	/* Don't send a LAYOUTRETURN if list was initially empty */
+	if (empty) {
+		spin_unlock(&ino->i_lock);
+		put_layout_hdr(lo);
+		dprintk("NFS: %s no layout segments to return\n", __func__);
+		goto out;
+	}
 	lo->plh_block_lgets++;
 	pnfs_mark_layout_returned(lo);
 	spin_unlock(&ino->i_lock);
-- 
1.7.6.4

