From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/3] pnfs_post_submit: Restore the pnfs_write_end part of "pnfs: commit and pnfs_write_end"
Date: Fri, 11 Jun 2010 03:35:51 -0400
Message-ID: <1276241751-18180-4-git-send-email-iisaman@netapp.com>
References: <1276241751-18180-1-git-send-email-iisaman@netapp.com>
 <1276241751-18180-2-git-send-email-iisaman@netapp.com>
 <1276241751-18180-3-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757144Ab0FKHgv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:36:51 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7akmR026274
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:36:50 -0700 (PDT)
In-Reply-To: <1276241751-18180-3-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

pnfs: commit and pnfs_write_end

Add hooks in the nfs_write_end path, giving a driver the potential for
post-copy manipulation of the page.

[pnfs: pass lseg from write_begin to write_end]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: fix pnfs_commit update_layout range]
    Whole file semantics are different for COMMIT (0,0) and layouts
    (0,NFS4_MAX_UINT64).
Reported-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/file.c             |    4 ++++
 fs/nfs/pnfs.c             |   16 +++++++++++++++-
 fs/nfs/pnfs.h             |   23 +++++++++++++++++++++++
 include/linux/nfs4_pnfs.h |    3 +++
 4 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 0999200..d453487 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -478,8 +478,12 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
+	status = pnfs_write_end(file, page, pos, len, copied, lseg);
+	if (status)
+		goto out;
 	status = nfs_updatepage(file, page, offset, copied, lseg);
 
+ out:
 	unlock_page(page);
 	page_cache_release(page);
 	pnfs_write_end_cleanup(file, fsdata);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f60420c..7c48713 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1693,7 +1693,21 @@ out:
 	return status;
 }
 
-/* Given an nfs request, determine if it should be flushed before proceeding.
+/* Return 0 on succes, negative on failure */
+/* CAREFUL - what happens if copied < len??? */
+int _pnfs_write_end(struct inode *inode, struct page *page,
+		    loff_t pos, unsigned len, unsigned copied,
+		    struct pnfs_layout_segment *lseg)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int status;
+
+	status = nfss->pnfs_curr_ld->ld_io_ops->write_end(inode, page,
+						pos, len, copied, lseg);
+	return status;
+}
+
+ /* Given an nfs request, determine if it should be flushed before proceeding.
  * It should default to returning False, returning True only if there is a
  * specific reason to flush.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 23cd4c3..ceb9934 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -75,6 +75,9 @@ int _pnfs_write_begin(struct inode *inode, struct page *page,
 		      loff_t pos, unsigned len,
 		      struct pnfs_layout_segment *lseg,
 		      struct pnfs_fsdata **fsdata);
+int _pnfs_write_end(struct inode *inode, struct page *page,
+		    loff_t pos, unsigned len, unsigned copied,
+		    struct pnfs_layout_segment *lseg);
 int _pnfs_do_flush(struct inode *inode, struct nfs_page *req);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
@@ -200,6 +203,19 @@ static inline int pnfs_do_flush(struct nfs_page *req)
 		return 0;
 }
 
+static inline int pnfs_write_end(struct file *filp, struct page *page,
+				 loff_t pos, unsigned len, unsigned copied,
+				 struct pnfs_layout_segment *lseg)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+
+	if (PNFS_EXISTS_LDIO_OP(nfss, write_end))
+		return _pnfs_write_end(inode, page, pos, len, copied, lseg);
+	else
+		return 0;
+}
+
 static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
 {
 	if (fsdata) {
@@ -324,6 +340,13 @@ static inline int pnfs_write_begin(struct file *filp, struct page *page,
 	return 0;
 }
 
+static inline int pnfs_write_end(struct file *filp, struct page *page,
+				 loff_t pos, unsigned len, unsigned copied,
+				 struct pnfs_layout_segment *lseg)
+{
+	return 0;
+}
+
 static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
 {
 }
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index e2e6cd0..a84d622 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -143,6 +143,9 @@ struct layoutdriver_io_operations {
 	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
 			    loff_t pos, unsigned count,
 			    struct pnfs_fsdata *fsdata);
+	int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
+			 unsigned count, unsigned copied,
+			 struct pnfs_layout_segment *lseg);
 
 	/* Consistency ops */
 	/* 2 problems:
-- 
1.6.6.1

