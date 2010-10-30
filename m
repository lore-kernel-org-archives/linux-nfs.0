Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab0J3Vb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:31:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] locks: prevent ENOMEM on lease unlock
Date: Sat, 30 Oct 2010 17:31:13 -0400
Message-Id: <1288474276-14288-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20101030212500.GE480@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Removing a lock shouldn't require any allocations; a failure due to
ENOMEM leaves the caller with a choice between retrying or giving up and
leaking an unused lease.

Next we should split the other lease calls into add and delete cases.
I wanted to start with just the bugfix.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   43 ++++++++++++++++++++++++++++++-------------
 1 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 50ec159..06c7773 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1441,7 +1441,8 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	return 0;
 
 out:
-	locks_free_lock(lease);
+	if (arg != F_UNLCK)
+		locks_free_lock(lease);
 	return error;
 }
 EXPORT_SYMBOL(generic_setlease);
@@ -1493,17 +1494,16 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
-/**
- *	fcntl_setlease	-	sets a lease on an open file
- *	@fd: open file descriptor
- *	@filp: file pointer
- *	@arg: type of lease to obtain
- *
- *	Call this fcntl to establish a lease on the file.
- *	Note that you also need to call %F_SETSIG to
- *	receive a signal when the lease is broken.
- */
-int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
+static int do_fcntl_delete_lease(struct file *filp)
+{
+	struct file_lock fl, *flp = &fl;
+
+	lease_init(filp, F_UNLCK, flp);
+
+	return vfs_setlease(filp, F_UNLCK, &flp);
+}
+
+static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 {
 	struct file_lock *fl;
 	struct fasync_struct *new;
@@ -1521,7 +1521,7 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 	}
 	lock_flocks();
 	error = __vfs_setlease(filp, arg, &fl);
-	if (error || arg == F_UNLCK)
+	if (error)
 		goto out_unlock;
 
 	/*
@@ -1550,6 +1550,23 @@ out_unlock:
 }
 
 /**
+ *	fcntl_setlease	-	sets a lease on an open file
+ *	@fd: open file descriptor
+ *	@filp: file pointer
+ *	@arg: type of lease to obtain
+ *
+ *	Call this fcntl to establish a lease on the file.
+ *	Note that you also need to call %F_SETSIG to
+ *	receive a signal when the lease is broken.
+ */
+int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
+{
+	if (arg == F_UNLCK)
+		return do_fcntl_delete_lease(filp);
+	return do_fcntl_add_lease(fd, filp, arg);
+}
+
+/**
  * flock_lock_file_wait - Apply a FLOCK-style lock to a file
  * @filp: The file to apply the lock to
  * @fl: The lock to be applied
-- 
1.7.1

