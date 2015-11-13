Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53169 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbKMInX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:43:23 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] nfs: allow intra-file CLONE
Date: Fri, 13 Nov 2015 09:38:47 +0100
Message-Id: <1447403929-13743-4-git-send-email-hch@lst.de>
In-Reply-To: <1447403929-13743-1-git-send-email-hch@lst.de>
References: <1447403929-13743-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Originally CLONE didn't allow for intra-file clones, but we recently
updated the spec to support this feature which is also supported by
local Linux file systems.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4file.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index e45f686..4b4dd89 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -203,6 +203,7 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 	struct fd src_file;
 	struct inode *src_inode;
 	unsigned int bs = server->clone_blksize;
+	bool same_inode = false;
 	int ret;
 
 	/* dst file must be opened for writing */
@@ -221,10 +222,8 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 
 	src_inode = file_inode(src_file.file);
 
-	/* src and dst must be different files */
-	ret = -EINVAL;
 	if (src_inode == dst_inode)
-		goto out_fput;
+		same_inode = true;
 
 	/* src file must be opened for reading */
 	if (!(src_file.file->f_mode & FMODE_READ))
@@ -249,8 +248,16 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 			goto out_fput;
 	}
 
+	/* verify if ranges are overlapped within the same file */
+	if (same_inode) {
+		if (dst_off + count > src_off && dst_off < src_off + count)
+			goto out_fput;
+	}
+
 	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
-	if (dst_inode < src_inode) {
+	if (same_inode) {
+		mutex_lock(&src_inode->i_mutex);
+	} if (dst_inode < src_inode) {
 		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
 		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
 	} else {
@@ -275,7 +282,9 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 		truncate_inode_pages_range(&dst_inode->i_data, dst_off, dst_off + count - 1);
 
 out_unlock:
-	if (dst_inode < src_inode) {
+	if (same_inode) {
+		mutex_unlock(&src_inode->i_mutex);
+	} else if (dst_inode < src_inode) {
 		mutex_unlock(&src_inode->i_mutex);
 		mutex_unlock(&dst_inode->i_mutex);
 	} else {
-- 
1.9.1

