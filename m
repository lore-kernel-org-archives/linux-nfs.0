From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/30] NFS: cleanup - remove struct nfs_inode->ncommit
Date: Wed, 11 Mar 2009 14:41:08 -0400
Message-ID: <20090311184107.5578.49207.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644AbZCKSoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:12 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi45K012186
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:09 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |    1 -
 fs/nfs/write.c         |   25 ++++++++++++++++---------
 include/linux/nfs_fs.h |    3 +--
 3 files changed, 17 insertions(+), 12 deletions(-)


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b7656bd..00f116c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1345,7 +1345,6 @@ static void init_once(void *foo)
 	INIT_LIST_HEAD(&nfsi->access_cache_entry_lru);
 	INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
 	INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
-	nfsi->ncommit = 0;
 	nfsi->npages = 0;
 	atomic_set(&nfsi->silly_count, 1);
 	INIT_HLIST_HEAD(&nfsi->silly_list);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9f98458..1a99993 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -404,7 +404,6 @@ nfs_mark_request_commit(struct nfs_page *req)
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	spin_lock(&inode->i_lock);
-	nfsi->ncommit++;
 	set_bit(PG_CLEAN, &(req)->wb_flags);
 	radix_tree_tag_set(&nfsi->nfs_page_tree,
 			req->wb_index,
@@ -523,6 +522,12 @@ static void nfs_cancel_commit_list(struct list_head *head)
 	}
 }
 
+static int
+nfs_need_commit(struct nfs_inode *nfsi)
+{
+	return radix_tree_tagged(&nfsi->nfs_page_tree, NFS_PAGE_TAG_COMMIT);
+}
+
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * nfs_scan_commit - Scan an inode for commit requests
@@ -538,16 +543,18 @@ static int
 nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	int res = 0;
 
-	if (nfsi->ncommit != 0) {
-		res = nfs_scan_list(nfsi, dst, idx_start, npages,
-				NFS_PAGE_TAG_COMMIT);
-		nfsi->ncommit -= res;
-	}
-	return res;
+	if (!nfs_need_commit(nfsi))
+		return 0;
+
+	return nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
 }
 #else
+static inline int nfs_need_commit(struct nfs_inode *nfsi)
+{
+	return 0;
+}
+
 static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
 {
 	return 0;
@@ -820,7 +827,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->args.stable  = NFS_UNSTABLE;
 	if (how & FLUSH_STABLE) {
 		data->args.stable = NFS_DATA_SYNC;
-		if (!NFS_I(inode)->ncommit)
+		if (!nfs_need_commit(NFS_I(inode)))
 			data->args.stable = NFS_FILE_SYNC;
 	}
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index db867b0..c9fecd3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -166,8 +166,7 @@ struct nfs_inode {
 	 */
 	struct radix_tree_root	nfs_page_tree;
 
-	unsigned long		ncommit,
-				npages;
+	unsigned long		npages;
 
 	/* Open contexts for shared mmap writes */
 	struct list_head	open_files;

