Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:49598 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756359AbcAOVyU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jan 2016 16:54:20 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH] NFS: Simplify nfs_request_add_commit_list() arguments
Date: Fri, 15 Jan 2016 16:54:15 -0500
Message-ID: <1452894855-16637-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed that all the callers of this function pass cinfo->mds->list as
an argument in addition to the cinfo structure itself.  Let's get rid of
the extra argument, since it doesn't seem to be adding anything.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 2 +-
 fs/nfs/internal.h              | 2 +-
 fs/nfs/write.c                 | 7 +++----
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 02ec079..a73a0d3 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -957,7 +957,7 @@ filelayout_mark_request_commit(struct nfs_page *req,
 	u32 i, j;
 
 	if (fl->commit_through_mds) {
-		nfs_request_add_commit_list(req, &cinfo->mds->list, cinfo);
+		nfs_request_add_commit_list(req, cinfo);
 	} else {
 		/* Note that we are calling nfs4_fl_calc_j_index on each page
 		 * that ends up being committed to a data server.  An attractive
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9dea85f..303304f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -483,7 +483,7 @@ void nfs_retry_commit(struct list_head *page_list,
 		      struct nfs_commit_info *cinfo,
 		      u32 ds_commit_idx);
 void nfs_commitdata_release(struct nfs_commit_data *data);
-void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
+void nfs_request_add_commit_list(struct nfs_page *req,
 				 struct nfs_commit_info *cinfo);
 void nfs_request_add_commit_list_locked(struct nfs_page *req,
 		struct list_head *dst,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b93164..0551a0b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -803,11 +803,10 @@ EXPORT_SYMBOL_GPL(nfs_request_add_commit_list_locked);
  * holding the nfs_page lock.
  */
 void
-nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
-			    struct nfs_commit_info *cinfo)
+nfs_request_add_commit_list(struct nfs_page *req, struct nfs_commit_info *cinfo)
 {
 	spin_lock(cinfo->lock);
-	nfs_request_add_commit_list_locked(req, dst, cinfo);
+	nfs_request_add_commit_list_locked(req, &cinfo->mds->list, cinfo);
 	spin_unlock(cinfo->lock);
 	nfs_mark_page_unstable(req->wb_page, cinfo);
 }
@@ -865,7 +864,7 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 {
 	if (pnfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx))
 		return;
-	nfs_request_add_commit_list(req, &cinfo->mds->list, cinfo);
+	nfs_request_add_commit_list(req, cinfo);
 }
 
 static void
-- 
2.7.0

