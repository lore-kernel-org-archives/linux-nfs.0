Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52703 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123Ab1FGR03 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:29 -0400
Date: Tue, 7 Jun 2011 13:26:19 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 04/88] pnfs_post_submit: Restore the pnfs_write_end part of
 "pnfs: commit and pnfs_write_end"
Message-ID: <a1a8d0f583118dcee2341d282ae2355204797429.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/file.c |    4 ++++
 fs/nfs/pnfs.h |   25 +++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8c54b32..3af1c00 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -466,8 +466,12 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
+	status = pnfs_write_end(file, page, pos, len, copied, lseg);
+	if (status)
+		goto out;
 	status = nfs_updatepage(file, page, offset, copied);
 
+out:
 	unlock_page(page);
 	page_cache_release(page);
 	pnfs_write_end_cleanup(file, fsdata);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5712053..cfa8ea6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -113,6 +113,9 @@ struct pnfs_layoutdriver_type {
 	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
 			    loff_t pos, unsigned count,
 			    struct pnfs_fsdata *fsdata);
+	int (*write_end)(struct inode *inode, struct page *page, loff_t pos,
+			 unsigned count, unsigned copied,
+			 struct pnfs_layout_segment *lseg);
 
 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
 
@@ -333,6 +336,21 @@ static inline int pnfs_write_begin(struct file *filp, struct page *page,
 	return status;
 }
 
+/* CAREFUL - what happens if copied < len??? */
+static inline int pnfs_write_end(struct file *filp, struct page *page,
+				 loff_t pos, unsigned len, unsigned copied,
+				 struct pnfs_layout_segment *lseg)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+
+	if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_end)
+		return nfss->pnfs_curr_ld->write_end(inode, page, pos, len,
+						     copied, lseg);
+	else
+		return 0;
+}
+
 static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
 {
 	struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
@@ -432,6 +450,13 @@ static inline int pnfs_write_begin(struct file *filp, struct page *page,
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
-- 
1.7.4.1

