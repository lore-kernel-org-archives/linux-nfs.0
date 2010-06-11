From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/3] pnfs_post_submit: Restore "pnfs: pnfs_do_flush" part 2
Date: Fri, 11 Jun 2010 03:35:50 -0400
Message-ID: <1276241751-18180-3-git-send-email-iisaman@netapp.com>
References: <1276241751-18180-1-git-send-email-iisaman@netapp.com>
 <1276241751-18180-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756833Ab0FKHgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:36:50 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7akmQ026274
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:36:49 -0700 (PDT)
In-Reply-To: <1276241751-18180-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

pnfs: pnfs_do_flush

Adds a hook into the "check if request needs flushed" routines.
This will be needed to allow driver the ability to prevent comingling
of layout driver handled requests and fallback nfs requests.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: prevent offset overflow in _pnfs_do_flush]
[pnfs: pnfs_has_layout take_ref parameter should be bool]
[pnfs: clean up put_unlock_current_layout's interface]
[pnfs: introduce lseg valid bit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |   14 ++++++++++++++
 fs/nfs/pnfs.h             |   24 ++++++++++++++++++++++++
 fs/nfs/write.c            |    4 ++--
 include/linux/nfs4_pnfs.h |    3 +++
 4 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 679171e..f60420c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1693,6 +1693,20 @@ out:
 	return status;
 }
 
+/* Given an nfs request, determine if it should be flushed before proceeding.
+ * It should default to returning False, returning True only if there is a
+ * specific reason to flush.
+ */
+int _pnfs_do_flush(struct inode *inode, struct nfs_page *req)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int status = 0;
+
+	/* Note that lseg==NULL may be useful info for do_flush */
+	status = nfss->pnfs_curr_ld->ld_policy_ops->do_flush(req->wb_lseg, req);
+	return status;
+}
+
 enum pnfs_try_status
 _pnfs_try_to_write_data(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops, int how)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index df5668d..23cd4c3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -75,6 +75,7 @@ int _pnfs_write_begin(struct inode *inode, struct page *page,
 		      loff_t pos, unsigned len,
 		      struct pnfs_layout_segment *lseg,
 		      struct pnfs_fsdata **fsdata);
+int _pnfs_do_flush(struct inode *inode, struct nfs_page *req);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
@@ -181,6 +182,24 @@ static inline int pnfs_write_begin(struct file *filp, struct page *page,
 	return status;
 }
 
+/* req may not be locked, so we have to be prepared for req->wb_page being
+ * set to NULL at any time.
+ */
+static inline int pnfs_do_flush(struct nfs_page *req)
+{
+	struct page *page = req->wb_page;
+	struct inode *inode;
+
+	if (!page)
+		return 1;
+	inode = page->mapping->host;
+
+	if (PNFS_EXISTS_LDPOLICY_OP(NFS_SERVER(inode), do_flush))
+		return _pnfs_do_flush(inode, req);
+	else
+		return 0;
+}
+
 static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
 {
 	if (fsdata) {
@@ -291,6 +310,11 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+static inline int pnfs_do_flush(struct nfs_page *req)
+{
+	return 0;
+}
+
 static inline int pnfs_write_begin(struct file *filp, struct page *page,
 				   loff_t pos, unsigned len,
 				   struct pnfs_layout_segment *lseg,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e575f7a..bd1115f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -603,7 +603,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 * have flushed out requests having wrong owners.
 		 */
 		if (offset > rqend || end < req->wb_offset ||
-		    req->wb_lseg != lseg)
+		    req->wb_lseg != lseg || pnfs_do_flush(req))
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -710,7 +710,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page,
 		if (req == NULL)
 			return 0;
 		do_flush = req->wb_page != page || req->wb_context != ctx ||
-			req->wb_lseg != lseg;
+			req->wb_lseg != lseg || pnfs_do_flush(req);
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 0880a2e..e2e6cd0 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -199,6 +199,9 @@ struct layoutdriver_policy_operations {
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
+	/* Test for pre-write request flushing */
+	int (*do_flush)(struct pnfs_layout_segment *lseg, struct nfs_page *req);
+
 	/* Retreive the block size of the file system.
 	 * If gather_across_stripes == 1, then the file system will gather
 	 * requests into the block size.
-- 
1.6.6.1

