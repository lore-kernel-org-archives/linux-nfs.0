Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17794 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/13] NFS: Remove BUG_ON() calls from the generic writeback code
Date: Mon, 15 Oct 2012 17:31:00 -0400
Message-Id: <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/write.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9347ab7..4e9eb0b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -239,21 +239,18 @@ int nfs_congestion_kb;
 #define NFS_CONGESTION_OFF_THRESH	\
 	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
 
-static int nfs_set_page_writeback(struct page *page)
+static void nfs_set_page_writeback(struct page *page)
 {
+	struct nfs_server *nfss = NFS_SERVER(page_file_mapping(page)->host);
 	int ret = test_set_page_writeback(page);
 
-	if (!ret) {
-		struct inode *inode = page_file_mapping(page)->host;
-		struct nfs_server *nfss = NFS_SERVER(inode);
+	WARN_ON_ONCE(ret != 0);
 
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+	if (atomic_long_inc_return(&nfss->writeback) >
+			NFS_CONGESTION_ON_THRESH) {
+		set_bdi_congested(&nfss->backing_dev_info,
+					BLK_RW_ASYNC);
 	}
-	return ret;
 }
 
 static void nfs_end_page_writeback(struct page *page)
@@ -315,9 +312,8 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	if (IS_ERR(req))
 		goto out;
 
-	ret = nfs_set_page_writeback(page);
-	BUG_ON(ret != 0);
-	BUG_ON(test_bit(PG_CLEAN, &req->wb_flags));
+	nfs_set_page_writeback(page);
+	WARN_ON_ONCE(test_bit(PG_CLEAN, &req->wb_flags));
 
 	if (!nfs_pageio_add_request(pgio, req)) {
 		nfs_redirty_request(req);
@@ -451,8 +447,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	BUG_ON (!NFS_WBACK_BUSY(req));
-
 	spin_lock(&inode->i_lock);
 	if (likely(!PageSwapCache(req->wb_page))) {
 		set_page_private(req->wb_page, 0);
@@ -1727,7 +1721,6 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 	struct nfs_page *req;
 	int ret = 0;
 
-	BUG_ON(!PageLocked(page));
 	for (;;) {
 		wait_on_page_writeback(page);
 		req = nfs_page_find_request(page);
-- 
1.7.11.7

