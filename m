Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33436 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756700AbbCCTCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 14:02:08 -0500
Received: by iecar1 with SMTP id ar1so61161033iec.0
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 11:02:07 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Fix a regression in the read() syscall
Date: Tue,  3 Mar 2015 14:02:02 -0500
Message-Id: <1425409323-51301-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When invalidating the page cache for a regular file, we want to first
sync all dirty data to disk and then call invalidate_inode_pages2().
The latter relies on nfs_launder_page() and nfs_release_page() to deal
respectively with dirty pages, and unstable written pages.

When commit 9590544694bec ("NFS: avoid deadlocks with loop-back mounted
NFS filesystems.") changed the behaviour of nfs_release_page(), then it
made it possible for invalidate_inode_pages2() to fail with an EBUSY.
Unfortunately, that error is then propagated back to read().

Let's therefore work around the problem for now by protecting the call
to sync the data and invalidate_inode_pages2() so that they are atomic
w.r.t. the addition of new writes.
Later on, we can revisit whether or not we still need nfs_launder_page()
and nfs_release_page().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c          |  4 ++--
 fs/nfs/inode.c         | 37 ++++++++++++++++++++++++++++++++++---
 include/linux/nfs_fs.h |  1 +
 3 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c045c7169fa0..41963ffca597 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -178,7 +178,7 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 		iocb->ki_filp,
 		iov_iter_count(to), (unsigned long) iocb->ki_pos);
 
-	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
+	result = nfs_revalidate_mapping_protected(inode, iocb->ki_filp->f_mapping);
 	if (!result) {
 		result = generic_file_read_iter(iocb, to);
 		if (result > 0)
@@ -199,7 +199,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	dprintk("NFS: splice_read(%pD2, %lu@%Lu)\n",
 		filp, (unsigned long) count, (unsigned long long) *ppos);
 
-	res = nfs_revalidate_mapping(inode, filp->f_mapping);
+	res = nfs_revalidate_mapping_protected(inode, filp->f_mapping);
 	if (!res) {
 		res = generic_file_splice_read(filp, ppos, pipe, count, flags);
 		if (res > 0)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5026c44a98e1..8edb7d049565 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1067,11 +1067,14 @@ static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
 }
 
 /**
- * nfs_revalidate_mapping - Revalidate the pagecache
+ * __nfs_revalidate_mapping - Revalidate the pagecache
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
+ * @may_lock - take inode->i_mutex?
  */
-int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
+static int __nfs_revalidate_mapping(struct inode *inode,
+		struct address_space *mapping,
+		bool may_lock)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	unsigned long *bitlock = &nfsi->flags;
@@ -1120,7 +1123,12 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 	trace_nfs_invalidate_mapping_enter(inode);
-	ret = nfs_invalidate_mapping(inode, mapping);
+	if (may_lock) {
+		mutex_lock(&inode->i_mutex);
+		ret = nfs_invalidate_mapping(inode, mapping);
+		mutex_unlock(&inode->i_mutex);
+	} else
+		ret = nfs_invalidate_mapping(inode, mapping);
 	trace_nfs_invalidate_mapping_exit(inode, ret);
 
 	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
@@ -1130,6 +1138,29 @@ out:
 	return ret;
 }
 
+/**
+ * nfs_revalidate_mapping - Revalidate the pagecache
+ * @inode - pointer to host inode
+ * @mapping - pointer to mapping
+ */
+int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
+{
+	return __nfs_revalidate_mapping(inode, mapping, false);
+}
+
+/**
+ * nfs_revalidate_mapping_protected - Revalidate the pagecache
+ * @inode - pointer to host inode
+ * @mapping - pointer to mapping
+ *
+ * Differs from nfs_revalidate_mapping() in that it grabs the inode->i_mutex
+ * while invalidating the mapping.
+ */
+int nfs_revalidate_mapping_protected(struct inode *inode, struct address_space *mapping)
+{
+	return __nfs_revalidate_mapping(inode, mapping, true);
+}
+
 static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 59b1516b9fd4..b01ccf371fdc 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -356,6 +356,7 @@ extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
+extern int nfs_revalidate_mapping_protected(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr, struct nfs_fattr *);
 extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
-- 
2.1.0

