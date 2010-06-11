From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 7/7] pnfs: Revert "pnfs_post_submit: Restore "pnfs: pnfs_do_flush" part 2"
Date: Fri, 11 Jun 2010 03:40:39 -0400
Message-ID: <1276242039-18649-8-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
 <1276242039-18649-2-git-send-email-iisaman@netapp.com>
 <1276242039-18649-3-git-send-email-iisaman@netapp.com>
 <1276242039-18649-4-git-send-email-iisaman@netapp.com>
 <1276242039-18649-5-git-send-email-iisaman@netapp.com>
 <1276242039-18649-6-git-send-email-iisaman@netapp.com>
 <1276242039-18649-7-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188Ab0FKHk7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:59 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVh027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:58 -0700 (PDT)
In-Reply-To: <1276242039-18649-7-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that block does not use do_flush, it can be removed entirely

Conflicts:

	fs/nfs/pnfs.c
	fs/nfs/pnfs.h

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |   14 --------------
 fs/nfs/pnfs.h             |   24 ------------------------
 fs/nfs/write.c            |    4 ++--
 include/linux/nfs4_pnfs.h |    3 ---
 4 files changed, 2 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d6ba358..10f133c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1716,20 +1716,6 @@ int _pnfs_write_end(struct inode *inode, struct page *page,
 	return status;
 }
 
- /* Given an nfs request, determine if it should be flushed before proceeding.
- * It should default to returning False, returning True only if there is a
- * specific reason to flush.
- */
-int _pnfs_do_flush(struct inode *inode, struct nfs_page *req)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	int status = 0;
-
-	/* Note that lseg==NULL may be useful info for do_flush */
-	status = nfss->pnfs_curr_ld->ld_policy_ops->do_flush(req->wb_lseg, req);
-	return status;
-}
-
 enum pnfs_try_status
 _pnfs_try_to_write_data(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops, int how)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index fd7c532..53308df 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -77,7 +77,6 @@ int _pnfs_write_begin(struct inode *inode, struct page *page,
 int _pnfs_write_end(struct inode *inode, struct page *page,
 		    loff_t pos, unsigned len, unsigned copied,
 		    struct pnfs_layout_segment *lseg);
-int _pnfs_do_flush(struct inode *inode, struct nfs_page *req);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
@@ -186,24 +185,6 @@ static inline int pnfs_write_begin(struct file *filp, struct page *page,
 	return status;
 }
 
-/* req may not be locked, so we have to be prepared for req->wb_page being
- * set to NULL at any time.
- */
-static inline int pnfs_do_flush(struct nfs_page *req)
-{
-	struct page *page = req->wb_page;
-	struct inode *inode;
-
-	if (!page)
-		return 1;
-	inode = page->mapping->host;
-
-	if (PNFS_EXISTS_LDPOLICY_OP(NFS_SERVER(inode), do_flush))
-		return _pnfs_do_flush(inode, req);
-	else
-		return 0;
-}
-
 static inline int pnfs_write_end(struct file *filp, struct page *page,
 				 loff_t pos, unsigned len, unsigned copied,
 				 struct pnfs_layout_segment *lseg)
@@ -335,11 +316,6 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-static inline int pnfs_do_flush(struct nfs_page *req)
-{
-	return 0;
-}
-
 static inline int pnfs_write_begin(struct file *filp, struct page *page,
 				   loff_t pos, unsigned len,
 				   struct pnfs_layout_segment *lseg,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0dee870..ea36845 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -603,7 +603,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 * have flushed out requests having wrong owners.
 		 */
 		if (offset > rqend || end < req->wb_offset ||
-		    req->wb_lseg != lseg || pnfs_do_flush(req))
+		    req->wb_lseg != lseg)
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -712,7 +712,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page,
 		if (req == NULL)
 			return 0;
 		do_flush = req->wb_page != page || req->wb_context != ctx ||
-			req->wb_lseg != lseg || pnfs_do_flush(req);
+			req->wb_lseg != lseg;
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b7772c8..7016305 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -210,9 +210,6 @@ struct layoutdriver_policy_operations {
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
-	/* Test for pre-write request flushing */
-	int (*do_flush)(struct pnfs_layout_segment *lseg, struct nfs_page *req);
-
 	/* Retreive the block size of the file system.
 	 * If gather_across_stripes == 1, then the file system will gather
 	 * requests into the block size.
-- 
1.6.6.1

