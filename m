Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39494 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751620AbdDKQuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Apr 2017 12:50:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 3/6] locks: Set FL_CLOSE when removing flock locks on close()
Date: Tue, 11 Apr 2017 12:50:09 -0400
Message-Id: <693a6f25085b236ffd35de63cb0d55dbe9e17c16.1491917365.git.bcodding@redhat.com>
In-Reply-To: <cover.1491917365.git.bcodding@redhat.com>
References: <cover.1491917365.git.bcodding@redhat.com>
In-Reply-To: <cover.1491917365.git.bcodding@redhat.com>
References: <cover.1491917365.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
NFS will check for this flag to ensure an unlock is sent in a following
patch.

Fuse handles flock and posix locks differently for FL_CLOSE, and so
requires a fixup to retain the existing behavior for flock.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/fuse/file.c     | 2 +-
 fs/locks.c         | 2 +-
 include/linux/fs.h | 2 ++
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 2401c5dabb2a..50d90e15a3b9 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2172,7 +2172,7 @@ static int fuse_setlk(struct file *file, struct file_lock *fl, int flock)
 	}
 
 	/* Unlock on close is handled by the flush method */
-	if (fl->fl_flags & FL_CLOSE)
+	if ((fl->fl_flags & FL_CLOSE_POSIX) == FL_CLOSE_POSIX)
 		return 0;
 
 	fuse_lk_fill(&args, file, fl, opcode, pid, flock, &inarg);
diff --git a/fs/locks.c b/fs/locks.c
index 26811321d39b..af2031a1fcff 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2504,7 +2504,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 		.fl_owner = filp,
 		.fl_pid = current->tgid,
 		.fl_file = filp,
-		.fl_flags = FL_FLOCK,
+		.fl_flags = FL_FLOCK | FL_CLOSE,
 		.fl_type = F_UNLCK,
 		.fl_end = OFFSET_MAX,
 	};
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2ba074328894..e964ae0a9c29 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -903,6 +903,8 @@ static inline struct file *get_file(struct file *f)
 #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
 #define FL_LAYOUT	2048	/* outstanding pNFS layout */
 
+#define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
+
 /*
  * Special return value from posix_lock_file() and vfs_lock_file() for
  * asynchronous locking.
-- 
2.9.3

