Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hub024-nj-5.exch024.serverdata.net ([206.225.165.120]:23036
	"EHLO HUB024-nj-5.exch024.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753555Ab1G0K4b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 06:56:31 -0400
From: Anand Avati <avati@gluster.com>
To: <miklos@szeredi.hu>
CC: <fuse-devel@lists.sourceforge.net>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, Anand Avati <avati@gluster.com>
Subject: [PATCH v2 1/2] vfs: pass 'struct file *' as parameter to ->check_flags() methods
Date: Wed, 27 Jul 2011 03:56:18 -0700
Message-ID: <1311764179-20326-1-git-send-email-avati@gluster.com>
In-Reply-To: <n>
References: <n>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

FUSE needs to selectively permit ->check_flags() on a per-file basis as it
does not support setting/unsetting O_DIRECT flag on an open file. Hence
passing 'struct file *' as a parameter to ->check_flags() is necessary to
inspect and compare file->f_flags with the new flags.

Signed-off-by: Anand Avati <avati@gluster.com>
---
 Documentation/filesystems/Locking |    2 +-
 Documentation/filesystems/vfs.txt |    2 +-
 fs/bad_inode.c                    |    2 +-
 fs/fcntl.c                        |    2 +-
 fs/nfs/file.c                     |    6 +++---
 include/linux/fs.h                |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 57d827d..9619841 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -426,7 +426,7 @@ prototypes:
 			loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long,
 			unsigned long, unsigned long, unsigned long);
-	int (*check_flags)(int);
+	int (*check_flags)(struct file *, int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *,
 			size_t, unsigned int);
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 88b9f55..442aefb 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -764,7 +764,7 @@ struct file_operations {
 	ssize_t (*sendfile) (struct file *, loff_t *, size_t, read_actor_t, void *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
-	int (*check_flags)(int);
+	int (*check_flags)(struct file *, int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, struct pipe_inode_info *, size_t, unsigned int);
diff --git a/fs/bad_inode.c b/fs/bad_inode.c
index bfcb18f..c7eef18 100644
--- a/fs/bad_inode.c
+++ b/fs/bad_inode.c
@@ -120,7 +120,7 @@ static unsigned long bad_file_get_unmapped_area(struct file *file,
 	return -EIO;
 }
 
-static int bad_file_check_flags(int flags)
+static int bad_file_check_flags(struct file *filp, int flags)
 {
 	return -EIO;
 }
diff --git a/fs/fcntl.c b/fs/fcntl.c
index 22764c7..1a2a6d3 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -174,7 +174,7 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 	}
 
 	if (filp->f_op && filp->f_op->check_flags)
-		error = filp->f_op->check_flags(arg);
+		error = filp->f_op->check_flags(filp, arg);
 	if (error)
 		return error;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2f093ed..9f96a8b 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -56,7 +56,7 @@ static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
 static int  nfs_file_flush(struct file *, fl_owner_t id);
 static int  nfs_file_fsync(struct file *, int datasync);
-static int nfs_check_flags(int flags);
+static int nfs_check_flags(struct file *, int flags);
 static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl);
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl);
 static int nfs_setlease(struct file *file, long arg, struct file_lock **fl);
@@ -105,7 +105,7 @@ const struct inode_operations nfs3_file_inode_operations = {
 # define IS_SWAPFILE(inode)	(0)
 #endif
 
-static int nfs_check_flags(int flags)
+static int nfs_check_flags(struct file *filp, int flags)
 {
 	if ((flags & (O_APPEND | O_DIRECT)) == (O_APPEND | O_DIRECT))
 		return -EINVAL;
@@ -126,7 +126,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 			filp->f_path.dentry->d_name.name);
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
-	res = nfs_check_flags(filp->f_flags);
+	res = nfs_check_flags(filp, filp->f_flags);
 	if (res)
 		return res;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b5b9792..98ce7c7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1564,7 +1564,7 @@ struct file_operations {
 	int (*lock) (struct file *, int, struct file_lock *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
-	int (*check_flags)(int);
+	int (*check_flags)(struct file *, int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
-- 
1.7.4.4

