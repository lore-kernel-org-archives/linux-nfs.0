Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030581Ab2COSlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:41:01 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 06/11] NFSv4.1: send filelayout DS commits to the MDS on invalid deviceid
Date: Thu, 15 Mar 2012 14:40:45 -0400
Message-Id: <1331836850-5195-7-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-1-git-send-email-andros@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2528cb2..26c83b0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -847,12 +847,16 @@ filelayout_choose_commit_list(struct nfs_page *req,
 			      struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	u32 i, j;
 	struct list_head *list;
 
 	if (fl->commit_through_mds)
 		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
 
+	if (filelayout_test_devid_invalid(devid))
+		return NULL; /* Resend I/O (writes and commits) to MDS */
+
 	/* Note that we are calling nfs4_fl_calc_j_index on each page
 	 * that ends up being committed to a data server.  An attractive
 	 * alternative is to add a field to nfs_write_data and nfs_page
@@ -933,9 +937,14 @@ find_only_write_lseg_locked(struct inode *inode)
 {
 	struct pnfs_layout_segment *lseg;
 
-	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
+		struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
+		if (filelayout_test_devid_invalid(devid))
+			/* Resend I/O (writes and commits) to MDS */
+			return NULL;
 		if (lseg->pls_range.iomode == IOMODE_RW)
 			return get_lseg(lseg);
+	}
 	return NULL;
 }
 
-- 
1.7.6.4

