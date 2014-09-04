Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:36215 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbaIDMjP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:15 -0400
Received: by mail-qc0-f170.google.com with SMTP id r5so10348570qcx.15
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 12/17] locks: update Documentation/filesystems with new setlease semantics
Date: Thu,  4 Sep 2014 08:38:38 -0400
Message-Id: <1409834323-7171-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 Documentation/filesystems/Locking | 11 ++++++-----
 Documentation/filesystems/vfs.txt |  7 ++++---
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index f1997e9da61f..94d93b1f8b53 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -464,15 +464,12 @@ prototypes:
 			size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *,
 			size_t, unsigned int);
-	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*setlease)(struct file *, long, struct file_lock **, void **);
 	long (*fallocate)(struct file *, int, loff_t, loff_t);
 };
 
 locking rules:
-	All may block except for ->setlease.
-	No VFS locks held on entry except for ->setlease.
-
-->setlease has the file_list_lock held and must not sleep.
+	All may block.
 
 ->llseek() locking has moved from llseek to the individual llseek
 implementations.  If your fs is not using generic_file_llseek, you
@@ -496,6 +493,10 @@ components. And there are other reasons why the current interface is a mess...
 ->read on directories probably must go away - we should just enforce -EISDIR
 in sys_read() and friends.
 
+->setlease operations should call generic_setlease() before or after setting
+the lease within the individual filesystem to record the result of the
+operation
+
 --------------------------- dquot_operations -------------------------------
 prototypes:
 	int (*write_dquot) (struct dquot *);
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 61d65cc65c54..af9441f32a62 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -826,7 +826,7 @@ struct file_operations {
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, struct pipe_inode_info *, size_t, unsigned int);
-	int (*setlease)(struct file *, long arg, struct file_lock **);
+	int (*setlease)(struct file *, long arg, struct file_lock **, void **);
 	long (*fallocate)(struct file *, int mode, loff_t offset, loff_t len);
 	int (*show_fdinfo)(struct seq_file *m, struct file *f);
 };
@@ -895,8 +895,9 @@ otherwise noted.
   splice_read: called by the VFS to splice data from file to a pipe. This
 	       method is used by the splice(2) system call
 
-  setlease: called by the VFS to set or release a file lock lease.
-	    setlease has the file_lock_lock held and must not sleep.
+  setlease: called by the VFS to set or release a file lock lease. setlease
+	    implementations should call generic_setlease to record or remove
+	    the lease in the inode after setting it
 
   fallocate: called by the VFS to preallocate blocks or punch a hole.
 
-- 
1.9.3

