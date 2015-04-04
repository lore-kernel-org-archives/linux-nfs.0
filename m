Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6393 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063AbbDDTNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Apr 2015 15:13:52 -0400
From: Dmitry Monakhov <dmonakhov@openvz.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
        Dmitry Monakhov <dmonakhov@openvz.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 09/16] nfs: use is_xxx_kiocb instead of filp->fl_flags
Date: Sat,  4 Apr 2015 23:13:18 +0400
Message-Id: <1428174805-853-10-git-send-email-dmonakhov@openvz.org>
In-Reply-To: <1428174805-853-1-git-send-email-dmonakhov@openvz.org>
References: <1428174805-853-1-git-send-email-dmonakhov@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: linux-nfs@vger.kernel.org
Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 fs/nfs/direct.c |    7 +++----
 fs/nfs/file.c   |    6 +++---
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c3929fb..76950c6 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -964,8 +964,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 				loff_t pos)
 {
 	ssize_t result = -EINVAL;
-	struct file *file = iocb->ki_filp;
-	struct address_space *mapping = file->f_mapping;
+	struct address_space *mapping = iocb->ki_filp->f_mapping;
 	struct inode *inode = mapping->host;
 	struct nfs_direct_req *dreq;
 	struct nfs_lock_context *l_ctx;
@@ -976,9 +975,9 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
 	dfprintk(FILE, "NFS: direct write(%pD2, %zd@%Ld)\n",
-		file, count, (long long) pos);
+		iocb->ki_filp, count, (long long) pos);
 
-	result = generic_write_checks(file, &pos, &count, 0);
+	result = generic_write_checks(iocb, &pos, &count, 0);
 	if (result)
 		goto out;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 37b1558..709cb7f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -170,7 +170,7 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 	struct inode *inode = file_inode(iocb->ki_filp);
 	ssize_t result;
 
-	if (iocb->ki_filp->f_flags & O_DIRECT)
+	if (is_direct_kiocb(iocb))
 		return nfs_file_direct_read(iocb, to, iocb->ki_pos);
 
 	dprintk("NFS: read(%pD2, %zu@%lu)\n",
@@ -680,7 +680,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (result)
 		return result;
 
-	if (file->f_flags & O_DIRECT)
+	if (is_direct_kiocb(iocb))
 		return nfs_file_direct_write(iocb, from, pos);
 
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
@@ -692,7 +692,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	/*
 	 * O_APPEND implies that we must revalidate the file length.
 	 */
-	if (file->f_flags & O_APPEND) {
+	if (is_append_kiocb(iocb)) {
 		result = nfs_revalidate_file_size(inode, file);
 		if (result)
 			goto out;
-- 
1.7.1

