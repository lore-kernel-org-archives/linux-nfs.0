Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753818Ab2IUUxT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:53:19 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 26/26] NFSv4.1: Remove the NFS_LAYOUT_RETURNED state
Date: Fri, 21 Sep 2012 16:50:21 -0400
Message-Id: <1348260621-10294-26-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-25-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-21-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-23-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-24-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-25-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It serves no purpose that the test for whether or not we have valid
layout segments doesn't already serve.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c |  7 +------
 fs/nfs/pnfs.h | 19 -------------------
 2 files changed, 1 insertion(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a5edf27..f0872f5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -662,7 +662,7 @@ _pnfs_return_layout(struct inode *ino)
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo || pnfs_test_layout_returned(lo)) {
+	if (!lo) {
 		spin_unlock(&ino->i_lock);
 		dprintk("NFS: %s no layout to return\n", __func__);
 		goto out;
@@ -680,7 +680,6 @@ _pnfs_return_layout(struct inode *ino)
 		goto out;
 	}
 	lo->plh_block_lgets++;
-	pnfs_mark_layout_returned(lo);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
@@ -691,7 +690,6 @@ _pnfs_return_layout(struct inode *ino)
 		status = -ENOMEM;
 		pnfs_layout_io_set_failed(lo, IOMODE_RW);
 		pnfs_layout_io_set_failed(lo, IOMODE_READ);
-		pnfs_clear_layout_returned(lo);
 		pnfs_put_layout_hdr(lo);
 		goto out;
 	}
@@ -1084,9 +1082,6 @@ pnfs_update_layout(struct inode *ino,
 	if (list_empty(&lo->plh_segs))
 		first = true;
 
-	/* Enable LAYOUTRETURNs */
-	pnfs_clear_layout_returned(lo);
-
 	spin_unlock(&ino->i_lock);
 	if (first) {
 		/* The lo must be on the clp list if there is any
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 92f6ce6..6cede2c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -62,7 +62,6 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
-	NFS_LAYOUT_RETURNED,		/* layout has already been returned */
 };
 
 enum layoutdriver_policy_flags {
@@ -259,24 +258,6 @@ void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
 
-static inline void
-pnfs_mark_layout_returned(struct pnfs_layout_hdr *lo)
-{
-	set_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
-}
-
-static inline void
-pnfs_clear_layout_returned(struct pnfs_layout_hdr *lo)
-{
-	clear_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
-}
-
-static inline bool
-pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
-{
-	return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
-}
-
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
-- 
1.7.11.4

