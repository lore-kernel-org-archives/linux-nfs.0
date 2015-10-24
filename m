Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35836 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbbJXP3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:29:09 -0400
Received: by pasz6 with SMTP id z6so144430640pas.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:29:08 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org,
        Steve French <steve.french@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 3/9] nfs42: add .copy_file_range file operation
Date: Sun, 25 Oct 2015 07:17:10 +0800
Message-Id: <1445728636-10109-4-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4file.c | 95 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 52 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4aa5719..f1924d8 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -194,15 +194,60 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 	return nfs42_proc_allocate(filep, offset, len);
 }
 
+static ssize_t nfs42_copy_file_range(struct file *file_in, loff_t pos_in,
+				     struct file *file_out, loff_t pos_out,
+				     size_t len, unsigned int flags)
+{
+	struct inode *src_inode = file_inode(file_in);
+	struct inode *dst_inode = file_inode(file_out);
+	struct nfs_server *server = NFS_SERVER(src_inode);
+	unsigned int bs = server->clone_blksize;
+	int ret;
+
+	/* check alignment w.r.t. clone_blksize */
+	ret = -EINVAL;
+	if (bs) {
+		if (!IS_ALIGNED(pos_in, bs) || !IS_ALIGNED(pos_out, bs) ||
+		    (!IS_ALIGNED(len, bs) &&
+		     i_size_read(src_inode) != (pos_in + len)))
+			goto out;
+	}
+
+	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
+	lock_two_nondirectories(src_inode, dst_inode);
+
+	/* flush all pending writes on both src and dst so that server
+	 * has the latest data
+	 */
+	ret = nfs_sync_inode(src_inode);
+	if (ret)
+		goto out_unlock;
+	ret = nfs_sync_inode(dst_inode);
+	if (ret)
+		goto out_unlock;
+
+	ret = nfs42_proc_clone(file_in, file_out, pos_in, pos_out, len);
+
+	/* truncate inode page cache of the dst range so that future
+	 * reads can fetch new data from server
+	 */
+	if (!ret)
+		truncate_inode_pages_range(&dst_inode->i_data, pos_out,
+					   pos_out + len - 1);
+
+out_unlock:
+	unlock_two_nondirectories(src_inode, dst_inode);
+out:
+	return ret < 0 ? ret : len;
+}
+
 static noinline long
 nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 		  u64 src_off, u64 dst_off, u64 count)
 {
 	struct inode *dst_inode = file_inode(dst_file);
-	struct nfs_server *server = NFS_SERVER(dst_inode);
 	struct fd src_file;
 	struct inode *src_inode;
-	unsigned int bs = server->clone_blksize;
 	int ret;
 
 	/* dst file must be opened for writing */
@@ -240,48 +285,11 @@ nfs42_ioctl_clone(struct file *dst_file, unsigned long srcfd,
 	    src_inode->i_sb != dst_inode->i_sb)
 		goto out_fput;
 
-	/* check alignment w.r.t. clone_blksize */
-	ret = -EINVAL;
-	if (bs) {
-		if (!IS_ALIGNED(src_off, bs) || !IS_ALIGNED(dst_off, bs))
-			goto out_fput;
-		if (!IS_ALIGNED(count, bs) && i_size_read(src_inode) != (src_off + count))
-			goto out_fput;
-	}
-
-	/* XXX: do we lock at all? what if server needs CB_RECALL_LAYOUT? */
-	if (dst_inode < src_inode) {
-		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_CHILD);
-	} else {
-		mutex_lock_nested(&src_inode->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&dst_inode->i_mutex, I_MUTEX_CHILD);
-	}
-
-	/* flush all pending writes on both src and dst so that server
-	 * has the latest data */
-	ret = nfs_sync_inode(src_inode);
-	if (ret)
-		goto out_unlock;
-	ret = nfs_sync_inode(dst_inode);
-	if (ret)
-		goto out_unlock;
-
-	ret = nfs42_proc_clone(src_file.file, dst_file, src_off, dst_off, count);
-
-	/* truncate inode page cache of the dst range so that future reads can fetch
-	 * new data from server */
-	if (!ret)
-		truncate_inode_pages_range(&dst_inode->i_data, dst_off, dst_off + count - 1);
+	ret = nfs42_copy_file_range(src_file.file, src_off, dst_file,
+				    dst_off, count, 0);
+	if (ret > 0)
+		ret = 0;
 
-out_unlock:
-	if (dst_inode < src_inode) {
-		mutex_unlock(&src_inode->i_mutex);
-		mutex_unlock(&dst_inode->i_mutex);
-	} else {
-		mutex_unlock(&dst_inode->i_mutex);
-		mutex_unlock(&src_inode->i_mutex);
-	}
 out_fput:
 	fdput(src_file);
 out_drop_write:
@@ -344,6 +352,7 @@ const struct file_operations nfs4_file_operations = {
 	.splice_write	= iter_file_splice_write,
 #ifdef CONFIG_NFS_V4_2
 	.fallocate	= nfs42_fallocate,
+	.copy_file_range = nfs42_copy_file_range,
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
-- 
1.8.3.1

