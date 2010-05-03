From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/8] SQUASHME: pnfs_submit: Revert the pnfs_write_end part of "pnfs: commit and pnfs_write_end"
Date: Sun,  2 May 2010 21:00:42 -0400
Message-ID: <1272848449-19170-2-git-send-email-iisaman@netapp.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31966 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755048Ab0EEDH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:58 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cgX024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:39 -0700 (PDT)
In-Reply-To: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts sections of commit db413b6aad54478ff0a11852b93aade64969f0ca.

pnfs_write_end is not used by the layout driver.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c             |    4 ----
 fs/nfs/pnfs.c             |   14 --------------
 fs/nfs/pnfs.h             |   23 -----------------------
 include/linux/nfs4_pnfs.h |    3 ---
 4 files changed, 0 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 47eec55..4398953 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -487,12 +487,8 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}
 
-	status = pnfs_write_end(file, page, pos, len, copied, fsdata);
-	if (status)
-		goto out;
 	status = nfs_updatepage(file, page, offset, copied, fsdata);
 
- out:
 	unlock_page(page);
 	page_cache_release(page);
 	pnfs_write_end_cleanup(fsdata);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c76b791..46fe088 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1965,20 +1965,6 @@ out:
 	return status;
 }
 
-/* Return 0 on succes, negative on failure */
-/* CAREFUL - what happens if copied < len??? */
-int _pnfs_write_end(struct inode *inode, struct page *page,
-		    loff_t pos, unsigned len,
-		    unsigned copied, struct pnfs_fsdata *fsdata)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	int status;
-
-	status = nfss->pnfs_curr_ld->ld_io_ops->write_end(inode, page,
-						pos, len, copied, fsdata);
-	return status;
-}
-
 /* Given an nfs request, determine if it should be flushed before proceeding.
  * It should default to returning False, returning True only if there is a
  * specific reason to flush.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7dc3ecc..1c94984 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -76,9 +76,6 @@ void pnfs_destroy_layout(struct nfs_inode *);
 int _pnfs_write_begin(struct inode *inode, struct page *page,
 		      loff_t pos, unsigned len,
 		      struct pnfs_fsdata **fsdata);
-int _pnfs_write_end(struct inode *inode, struct page *page,
-		    loff_t pos, unsigned len,
-		    unsigned copied, struct pnfs_fsdata *fsdata);
 int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
 		   struct pnfs_fsdata *fsdata);
 void _pnfs_modify_new_write_request(struct nfs_page *req,
@@ -200,19 +197,6 @@ static inline int pnfs_do_flush(struct nfs_page *req, void *fsdata)
 		return 0;
 }
 
-static inline int pnfs_write_end(struct file *filp, struct page *page,
-				 loff_t pos, unsigned len, unsigned copied,
-				 void *fsdata)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct nfs_server *nfss = NFS_SERVER(inode);
-
-	if (PNFS_EXISTS_LDIO_OP(nfss, write_end))
-		return _pnfs_write_end(inode, page, pos, len, copied, fsdata);
-	else
-		return 0;
-}
-
 static inline void pnfs_write_end_cleanup(void *fsdata)
 {
 	pnfs_free_fsdata(fsdata);
@@ -312,13 +296,6 @@ static inline int pnfs_write_begin(struct file *filp, struct page *page,
 	return 0;
 }
 
-static inline int pnfs_write_end(struct file *filp, struct page *page,
-				 loff_t pos, unsigned len, unsigned copied,
-				 void *fsdata)
-{
-	return 0;
-}
-
 static inline void pnfs_write_end_cleanup(void *fsdata)
 {
 }
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 3caac60..e01a065 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -142,9 +142,6 @@ struct layoutdriver_io_operations {
 	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
 			    loff_t pos, unsigned count,
 			    struct pnfs_fsdata *fsdata);
-	int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
-			 unsigned count, unsigned copied,
-			 struct pnfs_fsdata *fsdata);
 	void (*new_request)(struct pnfs_layout_segment *lseg,
 			    struct nfs_page *req, loff_t pos, unsigned count,
 			    struct pnfs_fsdata *fsdata);
-- 
1.6.6.1

