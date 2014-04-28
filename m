Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:59617 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756913AbaD1TrM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 15:47:12 -0400
Received: by mail-qa0-f49.google.com with SMTP id dc16so3439069qab.8
        for <linux-nfs@vger.kernel.org>; Mon, 28 Apr 2014 12:47:11 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-fsdevel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        David Howells <dhowells@redhat.com>, Sage Weil <sage@inktank.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        devel@driverdev.osuosl.org (open list:STAGING SUBSYSTEM),
        linux-kernel@vger.kernel.org (open list),
        v9fs-developer@lists.sourceforge.net (open list:9P FILE SYSTEM),
        linux-afs@lists.infradead.org (open list:AFS FILESYSTEM &...),
        ceph-devel@vger.kernel.org (open list:CEPH DISTRIBUTED...),
        fuse-devel@lists.sourceforge.net (open list:FUSE: FILESYSTEM...),
        linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND...)
Subject: [PATCH] locks: ensure that fl_owner is always initialized properly in flock and lease codepaths
Date: Mon, 28 Apr 2014 13:50:13 -0400
Message-Id: <1398707413-32384-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the fl_owner isn't set for flock locks. Some filesystems use
byte-range locks to simulate flock locks and there is a common idiom in
those that does:

    fl->fl_owner = (fl_owner_t)filp;
    fl->fl_start = 0;
    fl->fl_end = OFFSET_MAX;

Since flock locks are generally "owned" by the open file description,
move this into the common flock lock setup code. The fl_start and fl_end
fields are already set appropriately, so remove the unneeded setting of
that in flock ops in those filesystems as well.

Finally, the lease code also sets the fl_owner as if they were owned by
the process and not the open file description. This is incorrect as
leases have the same ownership semantics as flock locks. Set them the
same way. The lease code doesn't actually use the fl_owner value for
anything, so this is more for consistency's sake than a bugfix.

Reported-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 drivers/staging/lustre/lustre/llite/file.c | 17 ++++++-----------
 fs/9p/vfs_file.c                           |  3 ---
 fs/afs/flock.c                             |  4 ----
 fs/ceph/locks.c                            | 10 ++--------
 fs/fuse/file.c                             |  1 -
 fs/locks.c                                 |  4 +++-
 fs/nfs/file.c                              |  4 ----
 7 files changed, 11 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 8e844a6371e0..760ccd83f1f7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2691,20 +2691,15 @@ int ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FLOCK, 1);
 
-	if (file_lock->fl_flags & FL_FLOCK) {
+	if (file_lock->fl_flags & FL_FLOCK)
 		LASSERT((cmd == F_SETLKW) || (cmd == F_SETLK));
-		/* flocks are whole-file locks */
-		flock.l_flock.end = OFFSET_MAX;
-		/* For flocks owner is determined by the local file descriptor*/
-		flock.l_flock.owner = (unsigned long)file_lock->fl_file;
-	} else if (file_lock->fl_flags & FL_POSIX) {
-		flock.l_flock.owner = (unsigned long)file_lock->fl_owner;
-		flock.l_flock.start = file_lock->fl_start;
-		flock.l_flock.end = file_lock->fl_end;
-	} else {
+	else if (!(file_lock->fl_flags & FL_POSIX))
 		return -EINVAL;
-	}
+
+	flock.l_flock.owner = (unsigned long)file_lock->fl_owner;
 	flock.l_flock.pid = file_lock->fl_pid;
+	flock.l_flock.start = file_lock->fl_start;
+	flock.l_flock.end = file_lock->fl_end;
 
 	/* Somewhat ugly workaround for svc lockd.
 	 * lockd installs custom fl_lmops->lm_compare_owner that checks
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index d8223209d4b1..59e3fe3d56c0 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -352,9 +352,6 @@ static int v9fs_file_flock_dotl(struct file *filp, int cmd,
 		invalidate_mapping_pages(&inode->i_data, 0, -1);
 	}
 	/* Convert flock to posix lock */
-	fl->fl_owner = (fl_owner_t)filp;
-	fl->fl_start = 0;
-	fl->fl_end = OFFSET_MAX;
 	fl->fl_flags |= FL_POSIX;
 	fl->fl_flags ^= FL_FLOCK;
 
diff --git a/fs/afs/flock.c b/fs/afs/flock.c
index a8cf2cff836c..4baf1d2b39e4 100644
--- a/fs/afs/flock.c
+++ b/fs/afs/flock.c
@@ -555,10 +555,6 @@ int afs_flock(struct file *file, int cmd, struct file_lock *fl)
 		return -ENOLCK;
 
 	/* we're simulating flock() locks using posix locks on the server */
-	fl->fl_owner = (fl_owner_t) file;
-	fl->fl_start = 0;
-	fl->fl_end = OFFSET_MAX;
-
 	if (fl->fl_type == F_UNLCK)
 		return afs_do_unlk(file, fl);
 	return afs_do_setlk(file, fl);
diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index d94ba0df9f4d..db8c1ca15d72 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -52,10 +52,7 @@ static int ceph_lock_message(u8 lock_type, u16 operation, struct file *file,
 	else
 		length = fl->fl_end - fl->fl_start + 1;
 
-	if (lock_type == CEPH_LOCK_FCNTL)
-		owner = secure_addr(fl->fl_owner);
-	else
-		owner = secure_addr(fl->fl_file);
+	owner = secure_addr(fl->fl_owner);
 
 	dout("ceph_lock_message: rule: %d, op: %d, owner: %llx, pid: %llu, "
 	     "start: %llu, length: %llu, wait: %d, type: %d", (int)lock_type,
@@ -313,10 +310,7 @@ int lock_to_ceph_filelock(struct file_lock *lock,
 	cephlock->length = cpu_to_le64(lock->fl_end - lock->fl_start + 1);
 	cephlock->client = cpu_to_le64(0);
 	cephlock->pid = cpu_to_le64((u64)lock->fl_pid);
-	if (lock->fl_flags & FL_POSIX)
-		cephlock->owner = cpu_to_le64(secure_addr(lock->fl_owner));
-	else
-		cephlock->owner = cpu_to_le64(secure_addr(lock->fl_file));
+	cephlock->owner = cpu_to_le64(secure_addr(lock->fl_owner));
 
 	switch (lock->fl_type) {
 	case F_RDLCK:
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 13f8bdec5110..0b25fec89558 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2281,7 +2281,6 @@ static int fuse_file_flock(struct file *file, int cmd, struct file_lock *fl)
 		struct fuse_file *ff = file->private_data;
 
 		/* emulate flock with POSIX locks */
-		fl->fl_owner = (fl_owner_t) file;
 		ff->flock = true;
 		err = fuse_setlk(file, fl, 1);
 	}
diff --git a/fs/locks.c b/fs/locks.c
index e663aeac579e..2129ba8ac062 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -322,6 +322,7 @@ static int flock_make_lock(struct file *filp, struct file_lock **lock,
 		return -ENOMEM;
 
 	fl->fl_file = filp;
+	fl->fl_owner = (fl_owner_t)filp;
 	fl->fl_pid = current->tgid;
 	fl->fl_flags = FL_FLOCK;
 	fl->fl_type = type;
@@ -439,7 +440,7 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
 	if (assign_type(fl, type) != 0)
 		return -EINVAL;
 
-	fl->fl_owner = current->files;
+	fl->fl_owner = (fl_owner_t)filp;
 	fl->fl_pid = current->tgid;
 
 	fl->fl_file = filp;
@@ -2304,6 +2305,7 @@ void locks_remove_file(struct file *filp)
 
 	if (filp->f_op->flock) {
 		struct file_lock fl = {
+			.fl_owner = (fl_owner_t)filp,
 			.fl_pid = current->tgid,
 			.fl_file = filp,
 			.fl_flags = FL_FLOCK,
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 284ca901fe16..c1edf7336315 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -916,10 +916,6 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 		is_local = 1;
 
 	/* We're simulating flock() locks using posix locks on the server */
-	fl->fl_owner = (fl_owner_t)filp;
-	fl->fl_start = 0;
-	fl->fl_end = OFFSET_MAX;
-
 	if (fl->fl_type == F_UNLCK)
 		return do_unlk(filp, cmd, fl, is_local);
 	return do_setlk(filp, cmd, fl, is_local);
-- 
1.9.0

