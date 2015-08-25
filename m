Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33270 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbbHYPf1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:35:27 -0400
Received: by pacti10 with SMTP id ti10so54530155pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:35:26 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 07/11] nfs42: add .copy_range file operation
Date: Tue, 25 Aug 2015 23:33:45 +0800
Message-Id: <1440516829-116041-8-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4file.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index dcd39d4..c335cb0 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -4,6 +4,7 @@
  *  Copyright (C) 1992  Rick Sladkey
  */
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/nfs_fs.h>
 #include "internal.h"
@@ -166,6 +167,54 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 		return nfs42_proc_deallocate(filep, offset, len);
 	return nfs42_proc_allocate(filep, offset, len);
 }
+
+static noinline int
+nfs42_file_clone_range(struct file *src_file, struct file *dst_file,
+		       loff_t src_off, size_t dst_off, loff_t count)
+{
+	struct inode *dst_inode = file_inode(dst_file);
+	struct inode *src_inode = file_inode(src_file);
+	int ret;
+
+	/* src and dst must be different files */
+	if (src_inode == dst_inode)
+		return -EINVAL;
+
+	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
+	if (dst_inode < src_inode) {
+		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
+	} else {
+		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_CHILD);
+	}
+
+	/* flush all pending writes on both src and dst so that server
+	 * has the latest data */
+	ret = nfs_sync_inode(src_inode);
+	if (ret)
+		goto out_unlock;
+	ret = nfs_sync_inode(dst_inode);
+	if (ret)
+		goto out_unlock;
+
+	ret = nfs42_proc_clone(src_file, dst_file, src_off, dst_off, count);
+
+	/* truncate inode page cache of the dst range so that future reads can fetch
+	 * new data from server */
+	if (!ret)
+		truncate_inode_pages_range(&dst_inode->i_data, dst_off, dst_off + count - 1);
+
+out_unlock:
+	if (dst_inode < src_inode) {
+		mutex_unlock(&src_inode->i_mutex);
+		mutex_unlock(&dst_inode->i_mutex);
+	} else {
+		mutex_unlock(&dst_inode->i_mutex);
+		mutex_unlock(&src_inode->i_mutex);
+	}
+	return ret;
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
@@ -187,6 +236,7 @@ const struct file_operations nfs4_file_operations = {
 	.splice_write	= iter_file_splice_write,
 #ifdef CONFIG_NFS_V4_2
 	.fallocate	= nfs42_fallocate,
+	.clone_range	= nfs42_file_clone_range,
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
-- 
1.8.3.1

