Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59973 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750930AbdE3Qbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 12:31:43 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
Cc: Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] fs/locks: Use allocation rather than the stack in fcntl_getlk()
Date: Tue, 30 May 2017 12:31:38 -0400
Message-Id: <eb812a7fde61f4ed8a23911f89ceeef44b8df943.1496161312.git.bcodding@redhat.com>
In-Reply-To: <cover.1496161312.git.bcodding@redhat.com>
References: <cover.1496161312.git.bcodding@redhat.com>
In-Reply-To: <cover.1496161312.git.bcodding@redhat.com>
References: <cover.1496161312.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Struct file_lock is fairly large, so let's save some space on the stack by
using an allocation for struct file_lock in fcntl_getlk(), just as we do
for fcntl_setlk().

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index afefeb4ad6de..d7daa6c8932f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2086,14 +2086,17 @@ static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
  */
 int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock *flock)
 {
-	struct file_lock file_lock;
+	struct file_lock *fl;
 	int error;
 
+	fl = locks_alloc_lock();
+	if (fl == NULL)
+		return -ENOMEM;
 	error = -EINVAL;
 	if (flock->l_type != F_RDLCK && flock->l_type != F_WRLCK)
 		goto out;
 
-	error = flock_to_posix_lock(filp, &file_lock, flock);
+	error = flock_to_posix_lock(filp, fl, flock);
 	if (error)
 		goto out;
 
@@ -2103,23 +2106,22 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock *flock)
 			goto out;
 
 		cmd = F_GETLK;
-		file_lock.fl_flags |= FL_OFDLCK;
-		file_lock.fl_owner = filp;
+		fl->fl_flags |= FL_OFDLCK;
+		fl->fl_owner = filp;
 	}
 
-	error = vfs_test_lock(filp, &file_lock);
+	error = vfs_test_lock(filp, fl);
 	if (error)
 		goto out;
  
-	flock->l_type = file_lock.fl_type;
-	if (file_lock.fl_type != F_UNLCK) {
-		error = posix_lock_to_flock(flock, &file_lock);
+	flock->l_type = fl->fl_type;
+	if (fl->fl_type != F_UNLCK) {
+		error = posix_lock_to_flock(flock, fl);
 		if (error)
-			goto rel_priv;
+			goto out;
 	}
-rel_priv:
-	locks_release_private(&file_lock);
 out:
+	locks_free_lock(fl);
 	return error;
 }
 
@@ -2298,14 +2300,18 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
  */
 int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 *flock)
 {
-	struct file_lock file_lock;
+	struct file_lock *fl;
 	int error;
 
+	fl = locks_alloc_lock();
+	if (fl == NULL)
+		return -ENOMEM;
+
 	error = -EINVAL;
 	if (flock->l_type != F_RDLCK && flock->l_type != F_WRLCK)
 		goto out;
 
-	error = flock64_to_posix_lock(filp, &file_lock, flock);
+	error = flock64_to_posix_lock(filp, fl, flock);
 	if (error)
 		goto out;
 
@@ -2315,20 +2321,20 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 *flock)
 			goto out;
 
 		cmd = F_GETLK64;
-		file_lock.fl_flags |= FL_OFDLCK;
-		file_lock.fl_owner = filp;
+		fl->fl_flags |= FL_OFDLCK;
+		fl->fl_owner = filp;
 	}
 
-	error = vfs_test_lock(filp, &file_lock);
+	error = vfs_test_lock(filp, fl);
 	if (error)
 		goto out;
 
-	flock->l_type = file_lock.fl_type;
-	if (file_lock.fl_type != F_UNLCK)
-		posix_lock_to_flock64(flock, &file_lock);
+	flock->l_type = fl->fl_type;
+	if (fl->fl_type != F_UNLCK)
+		posix_lock_to_flock64(flock, fl);
 
-	locks_release_private(&file_lock);
 out:
+	locks_free_lock(fl);
 	return error;
 }
 
-- 
2.9.3

