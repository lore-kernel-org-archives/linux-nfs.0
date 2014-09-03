Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17054 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbaICQTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 12:19:17 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] NFS: Unconditionally enable commit code
Date: Wed, 3 Sep 2014 12:19:07 -0400
Message-ID: <1409761150-30257-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The goal is to create a generic NFS module with code that does not
depend on what versions of NFS are enabled.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/direct.c        | 14 -------------
 fs/nfs/write.c         | 54 --------------------------------------------------
 include/linux/nfs_fs.h |  8 --------
 3 files changed, 76 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 65ef6e0..dda4b86 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -178,7 +178,6 @@ static int nfs_direct_set_or_cmp_hdr_verf(struct nfs_direct_req *dreq,
 	return memcmp(verfp, &hdr->verf, sizeof(struct nfs_writeverf));
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 /*
  * nfs_direct_cmp_commit_data_verf - compare verifier for commit data
  * @dreq - direct request possibly spanning multiple servers
@@ -197,7 +196,6 @@ static int nfs_direct_cmp_commit_data_verf(struct nfs_direct_req *dreq,
 	WARN_ON_ONCE(verfp->committed < 0);
 	return memcmp(verfp, &data->verf, sizeof(struct nfs_writeverf));
 }
-#endif
 
 /**
  * nfs_direct_IO - NFS address space operation for direct I/O
@@ -576,7 +574,6 @@ out:
 	return result;
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_pageio_descriptor desc;
@@ -700,17 +697,6 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
 	schedule_work(&dreq->work); /* Calls nfs_direct_write_schedule_work */
 }
 
-#else
-static void nfs_direct_write_schedule_work(struct work_struct *work)
-{
-}
-
-static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
-{
-	nfs_direct_complete(dreq, true);
-}
-#endif
-
 static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 {
 	struct nfs_direct_req *dreq = hdr->dreq;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 175d5d0..70a6f03 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -749,7 +749,6 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 /**
  * nfs_request_add_commit_list - add request to a commit list
  * @req: pointer to a struct nfs_page
@@ -867,36 +866,6 @@ int nfs_write_need_commit(struct nfs_pgio_header *hdr)
 	return hdr->verf.committed != NFS_FILE_SYNC;
 }
 
-#else
-static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
-				      struct inode *inode)
-{
-}
-
-void nfs_init_cinfo(struct nfs_commit_info *cinfo,
-		    struct inode *inode,
-		    struct nfs_direct_req *dreq)
-{
-}
-
-void
-nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
-			struct nfs_commit_info *cinfo)
-{
-}
-
-static void
-nfs_clear_request_commit(struct nfs_page *req)
-{
-}
-
-int nfs_write_need_commit(struct nfs_pgio_header *hdr)
-{
-	return 0;
-}
-
-#endif
-
 static void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
 	struct nfs_commit_info cinfo;
@@ -932,7 +901,6 @@ out:
 	hdr->release(hdr);
 }
 
-#if  IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 unsigned long
 nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
@@ -989,19 +957,6 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 	return ret;
 }
 
-#else
-unsigned long nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
-{
-	return 0;
-}
-
-int nfs_scan_commit(struct inode *inode, struct list_head *dst,
-		    struct nfs_commit_info *cinfo)
-{
-	return 0;
-}
-#endif
-
 /*
  * Search for an existing write request, and attempt to update
  * it to reflect a new dirty region on a given page.
@@ -1394,7 +1349,6 @@ static int nfs_writeback_done(struct rpc_task *task,
 		return status;
 	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, hdr->res.count);
 
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 	if (hdr->res.verf->committed < hdr->args.stable &&
 	    task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
@@ -1416,7 +1370,6 @@ static int nfs_writeback_done(struct rpc_task *task,
 			complain = jiffies + 300 * HZ;
 		}
 	}
-#endif
 
 	/* Deal with the suid/sgid bit corner case */
 	if (nfs_should_remove_suid(inode))
@@ -1469,7 +1422,6 @@ static void nfs_writeback_result(struct rpc_task *task,
 }
 
 
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
@@ -1778,12 +1730,6 @@ out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;
 }
-#else
-static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
-{
-	return 0;
-}
-#endif
 
 int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5180a7e..fd334d4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -529,17 +529,9 @@ extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_commit_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_commit_data *data);
-#else
-static inline int
-nfs_commit_inode(struct inode *inode, int how)
-{
-	return 0;
-}
-#endif
 
 static inline int
 nfs_have_writebacks(struct inode *inode)
-- 
2.1.0

