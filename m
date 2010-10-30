Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42913 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417Ab0J3Vb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:31:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] locks: fix setlease methods to free passed-in lock
Date: Sat, 30 Oct 2010 17:31:15 -0400
Message-Id: <1288474276-14288-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20101030212500.GE480@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We modified setlease to require the caller to allocate the new lease in
the case of creating a new lease, but forgot to fix up the filesystem
methods.

Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Steve French <sfrench@samba.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/cifs/cifsfs.c   |    5 ++++-
 fs/gfs2/file.c     |    2 ++
 fs/locks.c         |    3 ++-
 fs/nfs/file.c      |    3 ++-
 include/linux/fs.h |    1 +
 5 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 75c4eaa..54745b6 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -625,8 +625,11 @@ static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
 		   knows that the file won't be changed on the server
 		   by anyone else */
 		return generic_setlease(file, arg, lease);
-	else
+	else {
+		if (arg != F_UNLCK)
+			locks_free_lock(*lease);
 		return -EAGAIN;
+	}
 }
 
 struct file_system_type cifs_fs_type = {
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index aa99647..ac943c1 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -629,6 +629,8 @@ static ssize_t gfs2_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
 
 static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl)
 {
+	if (arg != F_UNLCK)
+		locks_free_lock(*fl);
 	return -EINVAL;
 }
 
diff --git a/fs/locks.c b/fs/locks.c
index 63fbc41..5b526a9 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -186,7 +186,7 @@ void locks_release_private(struct file_lock *fl)
 EXPORT_SYMBOL_GPL(locks_release_private);
 
 /* Free a lock which is not in use. */
-static void locks_free_lock(struct file_lock *fl)
+void locks_free_lock(struct file_lock *fl)
 {
 	BUG_ON(waitqueue_active(&fl->fl_wait));
 	BUG_ON(!list_empty(&fl->fl_block));
@@ -195,6 +195,7 @@ static void locks_free_lock(struct file_lock *fl)
 	locks_release_private(fl);
 	kmem_cache_free(filelock_cache, fl);
 }
+EXPORT_SYMBOL(locks_free_lock);
 
 void locks_init_lock(struct file_lock *fl)
 {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e756075..1e524fb 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -884,6 +884,7 @@ static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
 			file->f_path.dentry->d_parent->d_name.name,
 			file->f_path.dentry->d_name.name, arg);
-
+	if (arg != F_UNLCK)
+		locks_free_lock(*fl);
 	return -EINVAL;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7b7b507..1eb2939 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1129,6 +1129,7 @@ extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
 /* fs/locks.c */
+void locks_free_lock(struct file_lock *fl);
 extern void locks_init_lock(struct file_lock *);
 extern struct file_lock * locks_alloc_lock(void);
 extern void locks_copy_lock(struct file_lock *, struct file_lock *);
-- 
1.7.1

