Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab3FQPOb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:14:31 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v3 01/13] cifs: use posix_unblock_lock instead of locks_delete_block
Date: Mon, 17 Jun 2013 11:13:44 -0400
Message-Id: <1371482036-15958-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 66189be74 (CIFS: Fix VFS lock usage for oplocked files) exported
the locks_delete_block symbol. There's already an exported helper
function that provides this capability however, so make cifs use that
instead and turn locks_delete_block back into a static function.

Note that if fl->fl_next == NULL then this lock has already been through
locks_delete_block(), so we should be OK to ignore an ENOENT error here
and simply not retry the lock.

Cc: Pavel Shilovsky <piastryyy@gmail.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/cifs/file.c     |    2 +-
 fs/locks.c         |    3 +--
 include/linux/fs.h |    5 -----
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 48b29d2..44a4f18 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -999,7 +999,7 @@ try_again:
 		rc = wait_event_interruptible(flock->fl_wait, !flock->fl_next);
 		if (!rc)
 			goto try_again;
-		locks_delete_block(flock);
+		posix_unblock_lock(file, flock);
 	}
 	return rc;
 }
diff --git a/fs/locks.c b/fs/locks.c
index cb424a4..7a02064 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -496,13 +496,12 @@ static void __locks_delete_block(struct file_lock *waiter)
 
 /*
  */
-void locks_delete_block(struct file_lock *waiter)
+static void locks_delete_block(struct file_lock *waiter)
 {
 	lock_flocks();
 	__locks_delete_block(waiter);
 	unlock_flocks();
 }
-EXPORT_SYMBOL(locks_delete_block);
 
 /* Insert waiter into blocker's block list.
  * We use a circular list so that processes can be easily woken up in
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 43db02e..b9d7816 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1006,7 +1006,6 @@ extern int vfs_setlease(struct file *, long, struct file_lock **);
 extern int lease_modify(struct file_lock **, int);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
-extern void locks_delete_block(struct file_lock *waiter);
 extern void lock_flocks(void);
 extern void unlock_flocks(void);
 #else /* !CONFIG_FILE_LOCKING */
@@ -1151,10 +1150,6 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
 	return 1;
 }
 
-static inline void locks_delete_block(struct file_lock *waiter)
-{
-}
-
 static inline void lock_flocks(void)
 {
 }
-- 
1.7.1

