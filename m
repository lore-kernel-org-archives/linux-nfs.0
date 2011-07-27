Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:42023 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab1G0LCv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 07:02:51 -0400
Subject: [PATCH 1/3] Return 32/64-bit dir name hash according to usage type
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, tytso@mit.edu
Date: Wed, 27 Jul 2011 13:02:49 +0200
Message-ID: <20110727110249.204979.58769.stgit@localhost.localdomain>
In-Reply-To: <20110727110148.204979.49551.stgit@localhost.localdomain>
References: <20110727110148.204979.49551.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fan Yong <yong.fan@whamcloud.com>

Traditionally ext2/3/4 has returned a 32-bit hash value from llseek()
to appease NFSv2, which can only handle a 32-bit cookie for seekdir()
and telldir().  However, this causes problems if there are 32-bit hash
collisions, since the NFSv2 server can get stuck resending the same
entries from the directory repeatedly.

Allow ext4 to return a full 64-bit hash (both major and minor) for
telldir to decrease the chance of hash collisions.  This still needs
integration on the NFS side.

Signed-off-by: Fan Yong <yong.fan@whamcloud.com>
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 fs/ext4/dir.c               |  160 ++++++++++++++++++++++++++++++++++---------
 fs/fcntl.c                  |    5 +
 include/asm-generic/fcntl.h |    9 ++
 3 files changed, 138 insertions(+), 36 deletions(-)

diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index 164c560..8258240 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -32,24 +32,8 @@ static unsigned char ext4_filetype_table[] = {
 	DT_UNKNOWN, DT_REG, DT_DIR, DT_CHR, DT_BLK, DT_FIFO, DT_SOCK, DT_LNK
 };
 
-static int ext4_readdir(struct file *, void *, filldir_t);
 static int ext4_dx_readdir(struct file *filp,
 			   void *dirent, filldir_t filldir);
-static int ext4_release_dir(struct inode *inode,
-				struct file *filp);
-
-const struct file_operations ext4_dir_operations = {
-	.llseek		= ext4_llseek,
-	.read		= generic_read_dir,
-	.readdir	= ext4_readdir,		/* we take BKL. needed?*/
-	.unlocked_ioctl = ext4_ioctl,
-#ifdef CONFIG_COMPAT
-	.compat_ioctl	= ext4_compat_ioctl,
-#endif
-	.fsync		= ext4_sync_file,
-	.release	= ext4_release_dir,
-};
-
 
 static unsigned char get_dtype(struct super_block *sb, int filetype)
 {
@@ -254,22 +238,117 @@ out:
 	return ret;
 }
 
+static inline int is_32bit_api(void)
+{
+#ifdef HAVE_IS_COMPAT_TASK
+	return is_compat_task();
+#else
+	return (BITS_PER_LONG == 32);
+#endif
+}
+
 /*
  * These functions convert from the major/minor hash to an f_pos
  * value.
  *
- * Currently we only use major hash numer.  This is unfortunate, but
- * on 32-bit machines, the same VFS interface is used for lseek and
- * llseek, so if we use the 64 bit offset, then the 32-bit versions of
- * lseek/telldir/seekdir will blow out spectacularly, and from within
- * the ext2 low-level routine, we don't know if we're being called by
- * a 64-bit version of the system call or the 32-bit version of the
- * system call.  Worse yet, NFSv2 only allows for a 32-bit readdir
- * cookie.  Sigh.
+ * Upper layer should specify O_32BITHASH or O_64BITHASH explicitly.
+ * On the other hand, we allow ext4 to be mounted directly on both 32-bit
+ * and 64-bit nodes, under such case, neither O_32BITHASH nor O_64BITHASH
+ * is specified.
  */
-#define hash2pos(major, minor)	(major >> 1)
-#define pos2maj_hash(pos)	((pos << 1) & 0xffffffff)
-#define pos2min_hash(pos)	(0)
+static inline loff_t hash2pos(struct file *filp, __u32 major, __u32 minor)
+{
+	if ((filp->f_flags & O_32BITHASH) ||
+	    (!(filp->f_flags & O_64BITHASH) && is_32bit_api()))
+		return major >> 1;
+	else
+		return ((__u64)(major >> 1) << 32) | (__u64)minor;
+}
+
+static inline __u32 pos2maj_hash(struct file *filp, loff_t pos)
+{
+	if ((filp->f_flags & O_32BITHASH) ||
+	    (!(filp->f_flags & O_64BITHASH) && is_32bit_api()))
+		return (pos << 1) & 0xffffffff;
+	else
+		return ((pos >> 32) << 1) & 0xffffffff;
+}
+
+static inline __u32 pos2min_hash(struct file *filp, loff_t pos)
+{
+	if ((filp->f_flags & O_32BITHASH) ||
+	    (!(filp->f_flags & O_64BITHASH) && is_32bit_api()))
+		return 0;
+	else
+		return pos & 0xffffffff;
+}
+
+/*
+ * ext4_dir_llseek() based on generic_file_llseek() to handle both
+ * non-htree and htree directories, where the "offset" is in terms
+ * of the filename hash value instead of the byte offset.
+ *
+ * NOTE: offsets obtained *before* ext4_set_inode_flag(dir, EXT4_INODE_INDEX)
+ *       will be invalid once the directory was converted into a dx directory
+ */
+loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)
+{
+	struct inode *inode = file->f_mapping->host;
+	loff_t ret = -EINVAL;
+	int is_dx_dir = ext4_test_inode_flag(inode, EXT4_INODE_INDEX);
+
+	mutex_lock(&inode->i_mutex);
+
+	switch (origin) {
+	case SEEK_END:
+		if (unlikely(offset > 0))
+			goto out_err; /* not supported for directories */
+		if (is_dx_dir)
+			offset = EXT4_HTREE_EOF;
+		else
+			offset = inode->i_size;
+		break;
+	case SEEK_CUR:
+		/*
+		 * Here we special-case the lseek(fd, 0, SEEK_CUR)
+		 * position-querying operation.  Avoid rewriting the "same"
+		 * f_pos value back to the file because a concurrent read(),
+		 * write() or lseek() might have altered it
+		 */
+		if (offset == 0) {
+			offset = file->f_pos;
+			goto out_ok;
+		}
+
+		/* NOTE: relative offsets with dx directories might not work
+		 *       as expected, as it is difficult to figure out the
+		 *       correct offset between dx hashes */
+		offset += file->f_pos;
+		break;
+	}
+
+	if (unlikely(offset < 0))
+		goto out_err;
+
+	if (!is_dx_dir) {
+		if (offset > inode->i_sb->s_maxbytes)
+			goto out_err;
+	} else if (offset > EXT4_HTREE_EOF)
+		goto out_err;
+
+	/* Special lock needed here? */
+	if (offset != file->f_pos) {
+		file->f_pos = offset;
+		file->f_version = 0;
+	}
+
+out_ok:
+	ret = offset;
+out_err:
+	mutex_unlock(&inode->i_mutex);
+
+	return ret;
+}
 
 /*
  * This structure holds the nodes of the red-black tree used to store
@@ -330,15 +409,16 @@ static void free_rb_tree_fname(struct rb_root *root)
 }
 
 
-static struct dir_private_info *ext4_htree_create_dir_info(loff_t pos)
+static struct dir_private_info *ext4_htree_create_dir_info(struct file *filp,
+							   loff_t pos)
 {
 	struct dir_private_info *p;
 
 	p = kzalloc(sizeof(struct dir_private_info), GFP_KERNEL);
 	if (!p)
 		return NULL;
-	p->curr_hash = pos2maj_hash(pos);
-	p->curr_minor_hash = pos2min_hash(pos);
+	p->curr_hash = pos2maj_hash(filp, pos);
+	p->curr_minor_hash = pos2min_hash(filp, pos);
 	return p;
 }
 
@@ -429,7 +509,7 @@ static int call_filldir(struct file *filp, void *dirent,
 		       "null fname?!?\n");
 		return 0;
 	}
-	curr_pos = hash2pos(fname->hash, fname->minor_hash);
+	curr_pos = hash2pos(filp, fname->hash, fname->minor_hash);
 	while (fname) {
 		error = filldir(dirent, fname->name,
 				fname->name_len, curr_pos,
@@ -454,7 +534,7 @@ static int ext4_dx_readdir(struct file *filp,
 	int	ret;
 
 	if (!info) {
-		info = ext4_htree_create_dir_info(filp->f_pos);
+		info = ext4_htree_create_dir_info(filp, filp->f_pos);
 		if (!info)
 			return -ENOMEM;
 		filp->private_data = info;
@@ -468,8 +548,8 @@ static int ext4_dx_readdir(struct file *filp,
 		free_rb_tree_fname(&info->root);
 		info->curr_node = NULL;
 		info->extra_fname = NULL;
-		info->curr_hash = pos2maj_hash(filp->f_pos);
-		info->curr_minor_hash = pos2min_hash(filp->f_pos);
+		info->curr_hash = pos2maj_hash(filp, filp->f_pos);
+		info->curr_minor_hash = pos2min_hash(filp, filp->f_pos);
 	}
 
 	/*
@@ -540,3 +620,15 @@ static int ext4_release_dir(struct inode *inode, struct file *filp)
 
 	return 0;
 }
+
+const struct file_operations ext4_dir_operations = {
+	.llseek		= ext4_dir_llseek,
+	.read		= generic_read_dir,
+	.readdir	= ext4_readdir,
+	.unlocked_ioctl = ext4_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= ext4_compat_ioctl,
+#endif
+	.fsync		= ext4_sync_file,
+	.release	= ext4_release_dir,
+};
diff --git a/fs/fcntl.c b/fs/fcntl.c
index 22764c7..cb6ef40 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -835,14 +835,15 @@ static int __init fcntl_init(void)
 	 * Exceptions: O_NONBLOCK is a two bit define on parisc; O_NDELAY
 	 * is defined as O_NONBLOCK on some platforms and not on others.
 	 */
-	BUILD_BUG_ON(19 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
+	BUILD_BUG_ON(21 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
 		O_RDONLY	| O_WRONLY	| O_RDWR	|
 		O_CREAT		| O_EXCL	| O_NOCTTY	|
 		O_TRUNC		| O_APPEND	| /* O_NONBLOCK	| */
 		__O_SYNC	| O_DSYNC	| FASYNC	|
 		O_DIRECT	| O_LARGEFILE	| O_DIRECTORY	|
 		O_NOFOLLOW	| O_NOATIME	| O_CLOEXEC	|
-		__FMODE_EXEC	| O_PATH
+		__FMODE_EXEC	| O_PATH        | O_32BITHASH   |
+		O_64BITHASH
 		));
 
 	fasync_cache = kmem_cache_create("fasync_cache",
diff --git a/include/asm-generic/fcntl.h b/include/asm-generic/fcntl.h
index 84793c7..a40e1d5 100644
--- a/include/asm-generic/fcntl.h
+++ b/include/asm-generic/fcntl.h
@@ -84,10 +84,19 @@
 #define O_PATH		010000000
 #endif
 
+
 #ifndef O_NDELAY
 #define O_NDELAY	O_NONBLOCK
 #endif
 
+#ifndef O_32BITHASH
+#define O_32BITHASH	020000000	/* use 64 bit hash from dir llseek() */
+#endif
+#ifndef O_64BITHASH
+#define O_64BITHASH	040000000	/* use 32 bit hash from dir llseek() */
+#endif
+
+
 #define F_DUPFD		0	/* dup */
 #define F_GETFD		1	/* get close_on_exec */
 #define F_SETFD		2	/* set/clear close_on_exec */

