Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965819Ab3FUM6y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 08:58:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v4 01/14] locks: drop the unused filp argument to posix_unblock_lock
Date: Fri, 21 Jun 2013 08:58:09 -0400
Message-Id: <1371819502-26363-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svclock.c |    2 +-
 fs/locks.c         |    4 +---
 include/linux/fs.h |    5 ++---
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e703318..a469098 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -276,7 +276,7 @@ static int nlmsvc_unlink_block(struct nlm_block *block)
 	dprintk("lockd: unlinking block %p...\n", block);
 
 	/* Remove block from list */
-	status = posix_unblock_lock(block->b_file->f_file, &block->b_call->a_args.lock.fl);
+	status = posix_unblock_lock(&block->b_call->a_args.lock.fl);
 	nlmsvc_remove_block(block);
 	return status;
 }
diff --git a/fs/locks.c b/fs/locks.c
index cb424a4..72fb2b7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2099,13 +2099,12 @@ void locks_remove_flock(struct file *filp)
 
 /**
  *	posix_unblock_lock - stop waiting for a file lock
- *      @filp:   how the file was opened
  *	@waiter: the lock which was waiting
  *
  *	lockd needs to block waiting for locks.
  */
 int
-posix_unblock_lock(struct file *filp, struct file_lock *waiter)
+posix_unblock_lock(struct file_lock *waiter)
 {
 	int status = 0;
 
@@ -2117,7 +2116,6 @@ posix_unblock_lock(struct file *filp, struct file_lock *waiter)
 	unlock_flocks();
 	return status;
 }
-
 EXPORT_SYMBOL(posix_unblock_lock);
 
 /**
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 43db02e..9f160c6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -994,7 +994,7 @@ extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
 extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
 extern int posix_lock_file_wait(struct file *, struct file_lock *);
-extern int posix_unblock_lock(struct file *, struct file_lock *);
+extern int posix_unblock_lock(struct file_lock *);
 extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
@@ -1084,8 +1084,7 @@ static inline int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
 	return -ENOLCK;
 }
 
-static inline int posix_unblock_lock(struct file *filp,
-				     struct file_lock *waiter)
+static inline int posix_unblock_lock(struct file_lock *waiter)
 {
 	return -ENOENT;
 }
-- 
1.7.1

