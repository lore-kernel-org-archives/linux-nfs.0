Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60199 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab1KAGQ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Nov 2011 02:16:26 -0400
Subject: [PATCH] nfs: Fix unused variable warning from file.c
From: Rakib Mullick <rakib.mullick@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        akpm@linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Nov 2011 12:16:15 +0600
Message-ID: <1320128175.3340.3.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the following unused variable warning.

fs/nfs/file.c: In function ‘nfs_file_release’:
fs/nfs/file.c:140:17: warning: unused variable ‘dentry’
fs/nfs/file.c: In function ‘nfs_file_read’:
fs/nfs/file.c:237:9: warning: unused variable ‘count’
 

Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
---

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 28b8c3f..bd7dff0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -137,11 +137,9 @@ nfs_file_open(struct inode *inode, struct file *filp)
 static int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
-	struct dentry *dentry = filp->f_path.dentry;
-
 	dprintk("NFS: release(%s/%s)\n",
-			dentry->d_parent->d_name.name,
-			dentry->d_name.name);
+			filp->f_path.dentry->d_parent->d_name.name,
+			filp->f_path.dentry->d_name.name);
 
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	return nfs_release(inode, filp);
@@ -234,14 +232,13 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
 	ssize_t result;
-	size_t count = iov_length(iov, nr_segs);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
 
 	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		(unsigned long) count, (unsigned long) pos);
+		(unsigned long) iov_length(iov, nr_segs), (unsigned long) pos);
 
 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 	if (!result) {


