Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36597 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdHCNqD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:03 -0400
Received: by mail-it0-f68.google.com with SMTP id r9so1313800ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 23/28] NFS: Use an atomic_long_t to count the number of commits
Date: Thu,  3 Aug 2017 09:45:18 -0400
Message-Id: <20170803134523.4922-24-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-23-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
 <20170803134523.4922-23-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c          |  2 +-
 fs/nfs/write.c          | 12 +++++++-----
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0480eb02299a..134d9f560240 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2012,7 +2012,7 @@ static void init_once(void *foo)
 	INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
 	INIT_LIST_HEAD(&nfsi->commit_info.list);
 	atomic_long_set(&nfsi->nrequests, 0);
-	nfsi->commit_info.ncommit = 0;
+	atomic_long_set(&nfsi->commit_info.ncommit, 0);
 	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 	init_rwsem(&nfsi->rmdir_sem);
 	mutex_init(&nfsi->commit_mutex);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 08093552f115..12479c25028e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -857,7 +857,7 @@ nfs_request_add_commit_list_locked(struct nfs_page *req, struct list_head *dst,
 {
 	set_bit(PG_CLEAN, &req->wb_flags);
 	nfs_list_add_request(req, dst);
-	cinfo->mds->ncommit++;
+	atomic_long_inc(&cinfo->mds->ncommit);
 }
 EXPORT_SYMBOL_GPL(nfs_request_add_commit_list_locked);
 
@@ -903,7 +903,7 @@ nfs_request_remove_commit_list(struct nfs_page *req,
 	if (!test_and_clear_bit(PG_CLEAN, &(req)->wb_flags))
 		return;
 	nfs_list_remove_request(req);
-	cinfo->mds->ncommit--;
+	atomic_long_dec(&cinfo->mds->ncommit);
 }
 EXPORT_SYMBOL_GPL(nfs_request_remove_commit_list);
 
@@ -1017,7 +1017,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 unsigned long
 nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
-	return cinfo->mds->ncommit;
+	return atomic_long_read(&cinfo->mds->ncommit);
 }
 
 /* NFS_I(cinfo->inode)->commit_mutex held by caller */
@@ -1057,8 +1057,10 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 {
 	int ret = 0;
 
+	if (!atomic_long_read(&cinfo->mds->ncommit))
+		return 0;
 	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
-	if (cinfo->mds->ncommit > 0) {
+	if (atomic_long_read(&cinfo->mds->ncommit) > 0) {
 		const int max = INT_MAX;
 
 		ret = nfs_scan_commit_list(&cinfo->mds->list, dst,
@@ -1890,7 +1892,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	int ret = 0;
 
 	/* no commits means nothing needs to be done */
-	if (!nfsi->commit_info.ncommit)
+	if (!atomic_long_read(&nfsi->commit_info.ncommit))
 		return ret;
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ca3bcc4ed4e5..84943a4c53c7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1476,7 +1476,7 @@ struct nfs_pgio_header {
 
 struct nfs_mds_commit_info {
 	atomic_t rpcs_out;
-	unsigned long		ncommit;
+	atomic_long_t		ncommit;
 	struct list_head	list;
 };
 
-- 
2.13.3

