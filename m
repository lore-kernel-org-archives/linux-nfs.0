Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52511 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab1FGR0Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:16 -0400
Date: Tue, 7 Jun 2011 13:26:13 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 03/88] pnfs_post_submit: Restore "pnfs: pnfs_do_flush" part 1
Message-ID: <534e134963773eafc731043ba01c0d34bc8ccf88.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

This adds the hooks in nfs_write_begin and nfs_write_end needed
by the block server

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: prevent offset overflow in _pnfs_do_flush]
[pnfs: pnfs_has_layout take_ref parameter should be bool]
[pnfs: clean up put_unlock_current_layout's interface]
[pnfs: introduce lseg valid bit]
[pnfsblock: cleanup pnfs_free_fsdata]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/file.c |   18 +++++++++++++-
 fs/nfs/pnfs.c |   41 +++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 129 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2f093ed..8c54b32 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -384,12 +384,15 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
 	int once_thru = 0;
+	struct pnfs_layout_segment *lseg;
 
 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
-
+	lseg = pnfs_update_layout(mapping->host,
+				  nfs_file_open_context(file),
+				  pos, len, IOMODE_RW, GFP_NOFS);
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
@@ -409,6 +412,9 @@ start:
 	if (ret) {
 		unlock_page(page);
 		page_cache_release(page);
+		*pagep = NULL;
+		*fsdata = NULL;
+		goto out;
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
@@ -417,6 +423,12 @@ start:
 		if (!ret)
 			goto start;
 	}
+	ret = pnfs_write_begin(file, page, pos, len, lseg, fsdata);
+ out:
+	if (ret) {
+		put_lseg(lseg);
+		*fsdata = NULL;
+	}
 	return ret;
 }
 
@@ -426,6 +438,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
+	struct pnfs_layout_segment *lseg;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
@@ -452,10 +465,13 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}
 
+	lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
 	status = nfs_updatepage(file, page, offset, copied);
 
 	unlock_page(page);
 	page_cache_release(page);
+	pnfs_write_end_cleanup(file, fsdata);
+	put_lseg(lseg);
 
 	if (status < 0)
 		return status;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 12b228a..c88a8ee 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1138,6 +1138,41 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 }
 
 /*
+ * This gives the layout driver an opportunity to read in page "around"
+ * the data to be written.  It returns 0 on success, otherwise an error code
+ * which will either be passed up to user, or ignored if
+ * some previous part of write succeeded.
+ * Note the range [pos, pos+len-1] is entirely within the page.
+ */
+int _pnfs_write_begin(struct inode *inode, struct page *page,
+		      loff_t pos, unsigned len,
+		      struct pnfs_layout_segment *lseg,
+		      struct pnfs_fsdata **fsdata)
+{
+	struct pnfs_fsdata *data;
+	int status = 0;
+
+	dprintk("--> %s: pos=%llu len=%u\n",
+		__func__, (unsigned long long)pos, len);
+	data = kzalloc(sizeof(struct pnfs_fsdata), GFP_KERNEL);
+	if (!data) {
+		status = -ENOMEM;
+		goto out;
+	}
+	data->lseg = lseg; /* refcount passed into data to be managed there */
+	status = NFS_SERVER(inode)->pnfs_curr_ld->write_begin(
+						lseg, page, pos, len, data);
+	if (status) {
+		kfree(data);
+		data = NULL;
+	}
+out:
+	*fsdata = data;
+	dprintk("<-- %s: status=%d\n", __func__, status);
+	return status;
+}
+
+/*
  * Called by non rpc-based layout drivers
  */
 int
@@ -1250,6 +1285,12 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
+void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
+{
+	/* lseg refcounting handled directly in nfs_write_end */
+	kfree(fsdata);
+}
+
 /*
  * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
  * NFS_UNSTABLE WRITEs with a COMMIT to data servers must store enough
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b3481e5..5712053 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -54,6 +54,10 @@ enum pnfs_try_status {
 	PNFS_NOT_ATTEMPTED = 1,
 };
 
+struct pnfs_fsdata {
+	struct pnfs_layout_segment *lseg;
+};
+
 #ifdef CONFIG_NFS_V4_1
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
@@ -106,6 +110,9 @@ struct pnfs_layoutdriver_type {
 	 */
 	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
 	enum pnfs_try_status (*write_pagelist) (struct nfs_write_data *nfs_data, int how);
+	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
+			    loff_t pos, unsigned count,
+			    struct pnfs_fsdata *fsdata);
 
 	void (*free_deviceid_node) (struct nfs4_deviceid_node *);
 
@@ -180,6 +187,7 @@ enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
+void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 void pnfs_cleanup_layoutcommit(struct inode *,
 			       struct nfs4_layoutcommit_data *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
@@ -193,6 +201,10 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
+int _pnfs_write_begin(struct inode *inode, struct page *page,
+		      loff_t pos, unsigned len,
+		      struct pnfs_layout_segment *lseg,
+		      struct pnfs_fsdata **fsdata);
 int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *recall_range);
@@ -305,6 +317,32 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
 		PNFS_LAYOUTRET_ON_SETATTR;
 }
 
+static inline int pnfs_write_begin(struct file *filp, struct page *page,
+				   loff_t pos, unsigned len,
+				   struct pnfs_layout_segment *lseg,
+				   void **fsdata)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int status = 0;
+
+	*fsdata = lseg;
+	if (lseg && nfss->pnfs_curr_ld->write_begin)
+		status = _pnfs_write_begin(inode, page, pos, len, lseg,
+					   (struct pnfs_fsdata **) fsdata);
+	return status;
+}
+
+static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
+{
+	struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
+
+	if (fsdata && nfss->pnfs_curr_ld) {
+		if (nfss->pnfs_curr_ld->write_begin)
+			pnfs_free_fsdata(fsdata);
+	}
+}
+
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -325,6 +363,19 @@ static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
 		pgio->pg_test = ld->pg_test;
 }
 
+static inline struct pnfs_layout_segment *
+nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
+{
+	if (fsdata) {
+		struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
+
+		if (nfss->pnfs_curr_ld && nfss->pnfs_curr_ld->write_begin)
+			return ((struct pnfs_fsdata *) fsdata)->lseg;
+		return (struct pnfs_layout_segment *)fsdata;
+	}
+	return NULL;
+}
+
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -372,6 +423,19 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }
 
+static inline int pnfs_write_begin(struct file *filp, struct page *page,
+				   loff_t pos, unsigned len,
+				   struct pnfs_layout_segment *lseg,
+				   void **fsdata)
+{
+	*fsdata = NULL;
+	return 0;
+}
+
+static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
+{
+}
+
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
 {
@@ -443,6 +507,13 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
 {
 }
+
+static inline struct pnfs_layout_segment *
+nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
-- 
1.7.4.1

