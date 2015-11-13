Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53239 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbbKMIn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:43:29 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] nfs: reduce the amount of ifdefs for v4.2 in nfs4file.c
Date: Fri, 13 Nov 2015 09:38:49 +0100
Message-Id: <1447403929-13743-6-git-send-email-hch@lst.de>
In-Reply-To: <1447403929-13743-1-git-send-email-hch@lst.de>
References: <1447403929-13743-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs4file.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 5f63f2d..49dbeab 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -309,18 +309,6 @@ static long nfs42_ioctl_clone_range(struct file *dst_file, void __user *argp)
 	return nfs42_ioctl_clone(dst_file, args.src_fd, args.src_offset,
 				 args.dest_offset, args.src_length);
 }
-#else
-static long nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
-		u64 src_off, u64 dst_off, u64 count)
-{
-	return -ENOTTY;
-}
-
-static long nfs42_ioctl_clone_range(struct file *dst_file, void __user *argp)
-{
-	return -ENOTTY;
-}
-#endif /* CONFIG_NFS_V4_2 */
 
 long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -335,13 +323,9 @@ long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	return -ENOTTY;
 }
+#endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
-#ifdef CONFIG_NFS_V4_2
-	.llseek		= nfs4_file_llseek,
-#else
-	.llseek		= nfs_file_llseek,
-#endif
 	.read_iter	= nfs_file_read,
 	.write_iter	= nfs_file_write,
 	.mmap		= nfs_file_mmap,
@@ -353,11 +337,14 @@ const struct file_operations nfs4_file_operations = {
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= iter_file_splice_write,
-#ifdef CONFIG_NFS_V4_2
-	.fallocate	= nfs42_fallocate,
-#endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
+#ifdef CONFIG_NFS_V4_2
+	.llseek		= nfs4_file_llseek,
+	.fallocate	= nfs42_fallocate,
 	.unlocked_ioctl = nfs4_ioctl,
 	.compat_ioctl	= nfs4_ioctl,
+#else
+	.llseek		= nfs_file_llseek,
+#endif
 };
-- 
1.9.1

