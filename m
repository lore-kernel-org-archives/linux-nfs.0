From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/3] pnfs_post_submit: Restore "pnfs: pnfs_do_flush" part 1
Date: Fri, 11 Jun 2010 03:35:49 -0400
Message-ID: <1276241751-18180-2-git-send-email-iisaman@netapp.com>
References: <1276241751-18180-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756833Ab0FKHgt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:36:49 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7akmP026274
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:36:48 -0700 (PDT)
In-Reply-To: <1276241751-18180-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

This adds the hooks in nfs_write_begin and nfs_write_end needed
by the block server

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
 fs/nfs/file.c             |   15 ++++++++---
 fs/nfs/pnfs.c             |   43 +++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   62 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4_pnfs.h |    7 +++++
 4 files changed, 123 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3066141..0999200 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -420,8 +420,7 @@ start:
 
 	ret = nfs_flush_incompatible(file, page, lseg);
 	if (ret) {
-		unlock_page(page);
-		page_cache_release(page);
+		goto out_err;
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
@@ -430,13 +429,19 @@ start:
 		if (!ret)
 			goto start;
 	}
-	*fsdata = lseg;
+	ret = pnfs_write_begin(file, page, pos, len, lseg, fsdata);
  out:
 	if (ret) {
 		put_lseg(lseg);
 		*fsdata = NULL;
 	}
 	return ret;
+
+ out_err:
+	unlock_page(page);
+	page_cache_release(page);
+	*pagep = NULL;
+	goto out;
 }
 
 static int nfs_write_end(struct file *file, struct address_space *mapping,
@@ -445,7 +450,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
-	struct pnfs_layout_segment *lseg = fsdata;
+	struct pnfs_layout_segment *lseg;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
@@ -472,10 +477,12 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
 	}
 
+	lseg = nfs4_pull_lseg_from_fsdata(file, fsdata);
 	status = nfs_updatepage(file, page, offset, copied, lseg);
 
 	unlock_page(page);
 	page_cache_release(page);
+	pnfs_write_end_cleanup(file, fsdata);
 	put_lseg(lseg);
 
 	if (status < 0)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0e91e9b..679171e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1658,6 +1658,41 @@ _pnfs_try_to_read_data(struct nfs_read_data *data,
 	return pnfs_readpages(data);
 }
 
+/*
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
+	status = NFS_SERVER(inode)->pnfs_curr_ld->ld_io_ops->write_begin(
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
 enum pnfs_try_status
 _pnfs_try_to_write_data(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops, int how)
@@ -1853,6 +1888,14 @@ out_free:
 	goto out;
 }
 
+void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
+{
+	if (fsdata) {
+		/* lseg refcounting handled directly in nfs_Write_end */
+		kfree(fsdata);
+	}
+}
+
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f3a3325..df5668d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,12 +64,17 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   size_t *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
 			    size_t *);
+void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
+int _pnfs_write_begin(struct inode *inode, struct page *page,
+		      loff_t pos, unsigned len,
+		      struct pnfs_layout_segment *lseg,
+		      struct pnfs_fsdata **fsdata);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
@@ -160,6 +165,32 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return ret;
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
+	if (lseg && PNFS_EXISTS_LDIO_OP(nfss, write_begin))
+		status = _pnfs_write_begin(inode, page, pos, len, lseg,
+					   (struct pnfs_fsdata **) fsdata);
+	return status;
+}
+
+static inline void pnfs_write_end_cleanup(struct file *filp, void *fsdata)
+{
+	if (fsdata) {
+		struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
+
+		if (PNFS_EXISTS_LDIO_OP(nfss, write_begin))
+			pnfs_free_fsdata(fsdata);
+	}
+}
+
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
@@ -209,6 +240,17 @@ static inline int pnfs_use_rpc(struct nfs_server *nfss)
 	return 1;
 }
 
+static inline struct pnfs_layout_segment *
+nfs4_pull_lseg_from_fsdata(struct file *filp, void *fsdata)
+{
+	if (fsdata) {
+		struct nfs_server *nfss = NFS_SERVER(filp->f_dentry->d_inode);
+
+		if (PNFS_EXISTS_LDIO_OP(nfss, write_begin))
+			return ((struct pnfs_fsdata *) fsdata)->lseg;
+	}
+	return fsdata;
+}
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
@@ -249,6 +291,19 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
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
 static inline int pnfs_get_write_status(struct nfs_write_data *data)
 {
 	return 0;
@@ -268,6 +323,13 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	return 0;
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
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 07cb761..0880a2e 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -30,6 +30,10 @@ struct pnfs_layoutdriver_type {
 	struct layoutdriver_policy_operations *ld_policy_ops;
 };
 
+struct pnfs_fsdata {
+	struct pnfs_layout_segment *lseg;
+};
+
 #if defined(CONFIG_NFS_V4_1)
 
 static inline struct nfs_inode *
@@ -136,6 +140,9 @@ struct layoutdriver_io_operations {
 			   struct page **pages, unsigned int pgbase,
 			   unsigned nr_pages, loff_t offset, size_t count,
 			   int sync, struct nfs_write_data *nfs_data);
+	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
+			    loff_t pos, unsigned count,
+			    struct pnfs_fsdata *fsdata);
 
 	/* Consistency ops */
 	/* 2 problems:
-- 
1.6.6.1

