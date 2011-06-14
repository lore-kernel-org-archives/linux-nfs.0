Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37377 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab1FNVUf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:20:35 -0400
Message-ID: <4DF7D0A2.6060709@panasas.com>
Date: Tue, 14 Jun 2011 17:20:34 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
CC: Boaz Harrosh <"Boaz Harrosh bharrosh"@panasas.com>
Subject: [PATCH 7/8] pnfsd-exofs: Recall layouts on truncate
References: <4DF7CA2F.7030407@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Boaz Harrosh <Boaz Harrosh bharrosh@panasas.com>

* Define a new exofs_inode_recall_layout() which receives a function
  pointer. The function pointer is called when all layouts have returned,
  and before any new will be given.

* At exofs_layout_return() when all layouts recalled have returned,
  above exofs_inode_recall_layout() is awaken.

* At exofs_truncate() recall all layouts on the file.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[added u64 todo_data param starting 2.6.36]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd-exofs: Fix exofs_inode_recall_layout() sending 2 recalls]
    A misunderstanding of the wait_event_interruptible() macro has caused
    exofs to always issue two recalls in succession.

    Using __wait_event_interruptible() would fix that. But I don't like
    how this code is structured so change it around completely to be more
    flat and clear.
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/exofs/exofs.h  |   14 ++++++
 fs/exofs/export.c |  131 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/exofs/inode.c  |    7 ++-
 3 files changed, 147 insertions(+), 5 deletions(-)

diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index 3469d77..45c9fe5 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -99,6 +99,7 @@ struct exofs_sb_info {
 struct exofs_i_info {
 	struct inode   vfs_inode;          /* normal in-memory inode          */
 	wait_queue_head_t i_wq;            /* wait queue for inode            */
+	spinlock_t     i_layout_lock;      /* lock for layout/return/recall   */
 	unsigned long  i_flags;            /* various atomic flags            */
 	uint32_t       i_data[EXOFS_IDATA];/*short symlink names and device #s*/
 	uint32_t       i_dir_start_lookup; /* which page to start lookup      */
@@ -162,6 +163,9 @@ static inline unsigned exofs_io_state_size(unsigned numdevs)
  */
 #define OBJ_2BCREATED	0	/* object will be created soon*/
 #define OBJ_CREATED	1	/* object has been created on the osd*/
+/* Below are not used atomic but reuse the same i_flags */
+#define OBJ_LAYOUT_IS_GIVEN  2  /* inode has given layouts to clients*/
+#define OBJ_IN_LAYOUT_RECALL 3  /* inode is in the middle of a layout recall*/
 
 static inline int obj_2bcreated(struct exofs_i_info *oi)
 {
@@ -302,9 +306,19 @@ extern const struct inode_operations exofs_symlink_inode_operations;
 extern const struct inode_operations exofs_fast_symlink_inode_operations;
 
 /* export.c */
+typedef int (exofs_recall_fn)(struct inode *inode, u64 data);
 #ifdef CONFIG_PNFSD
+int exofs_inode_recall_layout(struct inode *inode, enum pnfs_iomode iomode,
+			      exofs_recall_fn todo, u64 todo_data);
 void exofs_init_export(struct super_block *sb);
 #else
+static inline int
+exofs_inode_recall_layout(struct inode *inode, enum pnfs_iomode iomode,
+exofs_recall_fn todo, u64 todo_data)
+{
+	return todo(inode, todo_data);
+}
+
 static inline void exofs_init_export(struct super_block *sb) {}
 #endif
 
diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 23c1666..c0705df 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -43,6 +43,36 @@ static void set_dev_id(struct nfs4_deviceid *pnfs_devid, u64 sbid, u64 devid)
 	dev_id->devid = devid;
 }
 
+static int cb_layout_recall(struct inode *inode, enum pnfs_iomode iomode,
+			    u64 offset, u64 length, void *cookie)
+{
+	struct nfsd4_pnfs_cb_layout cbl;
+	struct pnfsd_cb_ctl cb_ctl;
+	int status;
+
+	memset(&cb_ctl, 0, sizeof(cb_ctl));
+	status = pnfsd_get_cb_op(&cb_ctl);
+	if (unlikely(status)) {
+		EXOFS_ERR("%s: nfsd unloaded!! inode (0x%lx) status=%d\n",
+			  __func__, inode->i_ino, status);
+		goto err;
+	}
+
+	memset(&cbl, 0, sizeof(cbl));
+	cbl.cbl_recall_type = RETURN_FILE;
+	cbl.cbl_seg.layout_type = LAYOUT_OSD2_OBJECTS;
+	cbl.cbl_seg.iomode = iomode;
+	cbl.cbl_seg.offset = offset;
+	cbl.cbl_seg.length = length;
+	cbl.cbl_cookie = cookie;
+
+	status = cb_ctl.cb_op->cb_layout_recall(inode->i_sb, inode, &cbl);
+	pnfsd_put_cb_op(&cb_ctl);
+
+err:
+	return status;
+}
+
 static enum nfsstat4 exofs_layout_get(
 	struct inode *inode,
 	struct exp_xdr_stream *xdr,
@@ -56,6 +86,7 @@ static enum nfsstat4 exofs_layout_get(
 	struct pnfs_osd_layout layout;
 	__be32 *start;
 	unsigned i;
+	bool in_recall;
 	enum nfsstat4 nfserr;
 
 	res->lg_seg.offset = 0;
@@ -106,8 +137,16 @@ static enum nfsstat4 exofs_layout_get(
 	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
-	nfserr = NFS4_OK;
-	/* TODO: Takes the inode ref here, add to inode's layouts list */
+
+	spin_lock(&oi->i_layout_lock);
+	in_recall = test_bit(OBJ_IN_LAYOUT_RECALL, &oi->i_flags);
+	if (!in_recall) {
+		__set_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
+		nfserr = NFS4_OK;
+	} else {
+		nfserr = NFS4ERR_RECALLCONFLICT;
+	}
+	spin_unlock(&oi->i_layout_lock);
 
 out:
 	kfree(creds);
@@ -122,8 +161,23 @@ static int exofs_layout_commit(
 	const struct nfsd4_pnfs_layoutcommit_arg *args,
 	struct nfsd4_pnfs_layoutcommit_res *res)
 {
+	struct exofs_i_info *oi = exofs_i(inode);
 	struct timespec mtime;
 	loff_t i_size;
+	int in_recall;
+
+	/* In case of a recall we ignore the new size and mtime since they
+	 * are going to be changed again by truncate, and since we cannot take
+	 * the inode lock in that case.
+	 */
+	spin_lock(&oi->i_layout_lock);
+	in_recall = test_bit(OBJ_IN_LAYOUT_RECALL, &oi->i_flags);
+	spin_unlock(&oi->i_layout_lock);
+	if (in_recall) {
+		EXOFS_DBGMSG("(0x%lx) commit was called during recall\n",
+			     inode->i_ino);
+		return 0;
+	}
 
 	/* NOTE: I would love to call inode_setattr here
 	 *	 but i cannot since this will cause an eventual vmtruncate,
@@ -181,7 +235,20 @@ static int exofs_layout_return(
 {
 	/* TODO: Decode the pnfs_osd_ioerr if lrf_body_len > 0 */
 
-	/* TODO: When layout_get takes the inode ref put_ref here */
+	if (args->lr_cookie) {
+		struct exofs_i_info *oi = exofs_i(inode);
+		bool in_recall;
+
+		spin_lock(&oi->i_layout_lock);
+		in_recall = test_bit(OBJ_IN_LAYOUT_RECALL, &oi->i_flags);
+		__clear_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
+		spin_unlock(&oi->i_layout_lock);
+
+		/* TODO: how to communicate cookie with the waiter */
+		if (in_recall)
+			wake_up(&oi->i_wq); /* wakeup any recalls */
+	}
+
 	return 0;
 }
 
@@ -246,6 +313,64 @@ struct pnfs_export_operations exofs_pnfs_ops = {
 	.get_device_info = exofs_get_device_info,
 };
 
+static bool is_layout_returned(struct exofs_i_info *oi)
+{
+	bool layout_given;
+
+	spin_lock(&oi->i_layout_lock);
+	layout_given = test_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
+	spin_unlock(&oi->i_layout_lock);
+
+	return !layout_given;
+}
+
+int exofs_inode_recall_layout(struct inode *inode, enum pnfs_iomode iomode,
+			      exofs_recall_fn todo, u64 todo_data)
+{
+	struct exofs_i_info *oi = exofs_i(inode);
+	int layout_given;
+	int error = 0;
+
+	spin_lock(&oi->i_layout_lock);
+	layout_given = test_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
+	__set_bit(OBJ_IN_LAYOUT_RECALL, &oi->i_flags);
+	spin_unlock(&oi->i_layout_lock);
+
+	if (!layout_given)
+		goto exec;
+
+	for (;;) {
+		EXOFS_DBGMSG("(0x%lx) has_layout issue a recall\n",
+			     inode->i_ino);
+		error = cb_layout_recall(inode, iomode, 0, NFS4_MAX_UINT64,
+					 &oi->i_wq);
+		switch (error) {
+		case 0:
+		case -EAGAIN:
+			break;
+		case -ENOENT:
+			goto exec;
+		default:
+			goto err;
+		}
+
+		error = wait_event_interruptible(oi->i_wq,
+						 is_layout_returned(oi));
+		if (error)
+			goto err;
+	}
+
+exec:
+	error = todo(inode, todo_data);
+
+err:
+	spin_lock(&oi->i_layout_lock);
+	__clear_bit(OBJ_IN_LAYOUT_RECALL, &oi->i_flags);
+	spin_unlock(&oi->i_layout_lock);
+	EXOFS_DBGMSG("(0x%lx) return=>%d\n", inode->i_ino, error);
+	return error;
+}
+
 void exofs_init_export(struct super_block *sb)
 {
 	sb->s_pnfs_op = &exofs_pnfs_ops;
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 8472c09..1365e72 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -847,8 +847,9 @@ static inline int exofs_inode_is_fast_symlink(struct inode *inode)
 const struct osd_attr g_attr_logical_length = ATTR_DEF(
 	OSD_APAGE_OBJECT_INFORMATION, OSD_ATTR_OI_LOGICAL_LENGTH, 8);
 
-static int _do_truncate(struct inode *inode, loff_t newsize)
+static int _do_truncate(struct inode *inode, u64 data)
 {
+	loff_t newsize = data;
 	struct exofs_i_info *oi = exofs_i(inode);
 	int ret;
 
@@ -885,7 +886,8 @@ int exofs_setattr(struct dentry *dentry, struct iattr *iattr)
 
 	if ((iattr->ia_valid & ATTR_SIZE) &&
 	    iattr->ia_size != i_size_read(inode)) {
-		error = _do_truncate(inode, iattr->ia_size);
+		error = exofs_inode_recall_layout(inode, IOMODE_ANY,
+						  _do_truncate, iattr->ia_size);
 		if (unlikely(error))
 			return error;
 	}
@@ -998,6 +1000,7 @@ static void __oi_init(struct exofs_i_info *oi)
 {
 	init_waitqueue_head(&oi->i_wq);
 	oi->i_flags = 0;
+	spin_lock_init(&oi->i_layout_lock);
 }
 /*
  * Fill in an inode read from the OSD and set it up for use
-- 
1.7.3.4

