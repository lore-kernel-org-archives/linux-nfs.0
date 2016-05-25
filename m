Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from alln-iport-3.cisco.com ([173.37.142.90]:39992 "EHLO
	alln-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbcEYTD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 15:03:26 -0400
Subject: [PATCH RESEND] vfs: pass the flag setting by fcntl() to vfs
References: <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Miklos Szeredi <miklos@szeredi.hu>
From: Enke Chen <enkechen@cisco.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Enke Chen <enkechen@cisco.com>
Message-ID: <5e560bce-837d-c1eb-7f6a-eb4fbe994433@cisco.com>
Date: Wed, 25 May 2016 12:03:23 -0700
MIME-Version: 1.0
In-Reply-To: <c6b1075a-2eb5-a065-96ac-fc06ec04ea0f@cisco.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Folks:

Could you accept this patch submitted on May 5, 2016?

Thanks.   -- Enke

---
VFS: pass the flag setting by fcntl() to vfs

Several flags such as O_NONBLOCK are set using the fcntl() system call.
Currently the flags are validated in setfl() by the vfs using the
"check_flags" operation, but the eventual setting is not passed to the
vfs.

We have an application that uses the vfs/fuse and the flag O_NONBLOCK
is critical for the application.

This patch extends the "check_flags" function so that the flags are
passed to the vfs layer for setting in addition to validating. More
specifically:

  o add additional parameters to "check_flags", one for the file pointer,
    and one for setting. Also change the "flags" parameter from "int" to
    "unsigned int" to make it consistent with "filp->f_flags".

  o in setfl() pass the flags to vfs for setting once the flags are
    set correctly in the kernel.

  o use the "check_flags" operation in ioctl_fionbio() also for
    ioctl(fd, FIONOIO, &on).

  o make necessary adjustments to several files in fs/nfs (NFS is the
    only module using "check_flags").

Signed-off-by: Enke Chen <enkechen@cisco.com>

Version: 4.6.0_rc6_next_20160503

 Documentation/filesystems/Locking |    2 +-
 Documentation/filesystems/vfs.txt |    2 +-
 fs/fcntl.c                        |   10 +++++++++-
 fs/ioctl.c                        |    9 +++++++++
 fs/nfs/dir.c                      |    2 +-
 fs/nfs/file.c                     |    7 +++++--
 fs/nfs/internal.h                 |    2 +-
 fs/nfs/nfs4file.c                 |    2 +-
 include/linux/fs.h                |    2 +-
 9 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 75eea7c..c1cf807 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -452,7 +452,7 @@ prototypes:
 			loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long,
 			unsigned long, unsigned long, unsigned long);
-	int (*check_flags)(int);
+	int (*check_flags)(unsigned int, struct file *, int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *,
 			size_t, unsigned int);
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index c61a223..193ee19 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -822,7 +822,7 @@ struct file_operations {
 	int (*lock) (struct file *, int, struct file_lock *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
-	int (*check_flags)(int);
+	int (*check_flags)(unsigned int, struct file *, int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
diff --git a/fs/fcntl.c b/fs/fcntl.c
index 350a2c8..5582dc8 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -32,6 +32,7 @@
 static int setfl(int fd, struct file * filp, unsigned long arg)
 {
 	struct inode * inode = file_inode(filp);
+	unsigned int flags;
 	int error = 0;
 
 	/*
@@ -59,7 +60,7 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 	}
 
 	if (filp->f_op->check_flags)
-		error = filp->f_op->check_flags(arg);
+		error = filp->f_op->check_flags(arg, filp, 0);
 	if (error)
 		return error;
 
@@ -75,8 +76,15 @@ static int setfl(int fd, struct file * filp, unsigned long arg)
 	}
 	spin_lock(&filp->f_lock);
 	filp->f_flags = (arg & SETFL_MASK) | (filp->f_flags & ~SETFL_MASK);
+	flags = filp->f_flags;
 	spin_unlock(&filp->f_lock);
 
+	/*
+	 * Pass the flags to VFS for setting.
+	 */
+	if (filp->f_op->check_flags)
+		error = filp->f_op->check_flags(flags, filp, 1);
+
  out:
 	return error;
 }
diff --git a/fs/ioctl.c b/fs/ioctl.c
index 116a333..de06d93 100644
--- a/fs/ioctl.c
+++ b/fs/ioctl.c
@@ -496,6 +496,7 @@ static int file_ioctl(struct file *filp, unsigned int cmd,
 static int ioctl_fionbio(struct file *filp, int __user *argp)
 {
 	unsigned int flag;
+	unsigned int setfl;
 	int on, error;
 
 	error = get_user(on, argp);
@@ -512,7 +513,15 @@ static int ioctl_fionbio(struct file *filp, int __user *argp)
 		filp->f_flags |= flag;
 	else
 		filp->f_flags &= ~flag;
+	setfl = filp->f_flags;
 	spin_unlock(&filp->f_lock);
+
+	/*
+	 * Do the same as in fcntl().
+	 */
+	if (filp->f_op->check_flags)
+		error = filp->f_op->check_flags(setfl, filp, 1);
+
 	return error;
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index aaf7bd0..e16de49 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1495,7 +1495,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	dfprintk(VFS, "NFS: atomic_open(%s/%lu), %pd\n",
 			dir->i_sb->s_id, dir->i_ino, dentry);
 
-	err = nfs_check_flags(open_flags);
+	err = nfs_check_flags(open_flags, file, 0);
 	if (err)
 		return err;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 717a8d6..d049929 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -48,8 +48,11 @@ static const struct vm_operations_struct nfs_file_vm_ops;
 # define IS_SWAPFILE(inode)	(0)
 #endif
 
-int nfs_check_flags(int flags)
+int nfs_check_flags(unsigned int flags, struct file *filp, int setting)
 {
+	if (setting)
+		return 0;
+
 	if ((flags & (O_APPEND | O_DIRECT)) == (O_APPEND | O_DIRECT))
 		return -EINVAL;
 
@@ -68,7 +71,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 	dprintk("NFS: open file(%pD2)\n", filp);
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
-	res = nfs_check_flags(filp->f_flags);
+	res = nfs_check_flags(filp->f_flags, filp, 0);
 	if (res)
 		return res;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f1d1d2c..0916d99 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -368,7 +368,7 @@ ssize_t nfs_file_write(struct kiocb *, struct iov_iter *);
 int nfs_file_release(struct inode *, struct file *);
 int nfs_lock(struct file *, int, struct file_lock *);
 int nfs_flock(struct file *, int, struct file_lock *);
-int nfs_check_flags(int);
+int nfs_check_flags(unsigned int, struct file *, int);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index d039051..7ae0d15 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -44,7 +44,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 
 	dprintk("NFS: open file(%pd2)\n", dentry);
 
-	err = nfs_check_flags(openflags);
+	err = nfs_check_flags(openflags, filp, 0);
 	if (err)
 		return err;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index d61cd08..fdc9cc9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1717,7 +1717,7 @@ struct file_operations {
 	int (*lock) (struct file *, int, struct file_lock *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);
 	unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
-	int (*check_flags)(int);
+	int (*check_flags)(unsigned int, struct file *, int);
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
