Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:48101 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbaHWOlf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:35 -0400
Received: by mail-qa0-f44.google.com with SMTP id f12so10815020qad.31
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:33 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] locks: clean up vfs_setlease kerneldoc comments
Date: Sat, 23 Aug 2014 10:41:12 -0400
Message-Id: <1408804878-1331-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the latter paragraphs seem ambiguous and just plain wrong.
In particular the break_lease comment makes no sense. We call
break_lease (and break_deleg) from all sorts of vfs-layer functions,
so there is clearly such a method.

Also, we are close to being able to allow for "real" filesystem
setlease methods so remove the final comment about it not being a
full implementation yet.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 41 +++++++++++++++++------------------------
 1 file changed, 17 insertions(+), 24 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index bedb817a5cc4..597e71a1e90f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1705,30 +1705,23 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 }
 
 /**
- *	vfs_setlease        -       sets a lease on an open file
- *	@filp: file pointer
- *	@arg: type of lease to obtain
- *	@lease: file_lock to use
- *
- *	Call this to establish a lease on the file.
- *	The (*lease)->fl_lmops->lm_break operation must be set; if not,
- *	break_lease will oops!
- *
- *	This will call the filesystem's setlease file method, if
- *	defined.  Note that there is no getlease method; instead, the
- *	filesystem setlease method should call back to setlease() to
- *	add a lease to the inode's lease list, where fcntl_getlease() can
- *	find it.  Since fcntl_getlease() only reports whether the current
- *	task holds a lease, a cluster filesystem need only do this for
- *	leases held by processes on this node.
- *
- *	There is also no break_lease method; filesystems that
- *	handle their own leases should break leases themselves from the
- *	filesystem's open, create, and (on truncate) setattr methods.
- *
- *	Warning: the only current setlease methods exist only to disable
- *	leases in certain cases.  More vfs changes may be required to
- *	allow a full filesystem lease implementation.
+ * vfs_setlease        -       sets a lease on an open file
+ * @filp: file pointer
+ * @arg: type of lease to obtain
+ * @lease: file_lock to use when adding a lease
+ *
+ * Call this to establish a lease on the file. The "lease" argument is not
+ * used for F_UNLCK requests and may be NULL. For commands that set or alter
+ * an existing lease, the (*lease)->fl_lmops->lm_break operation must be set;
+ * if not, this function will return -EINVAL (and generate a scary-looking
+ * stack trace).
+ *
+ * This will call the filesystem's setlease file method, if defined. Note that
+ * there is no getlease method; instead, the filesystem setlease method should
+ * call back to generic_setlease() to add a lease to the inode's lease list,
+ * where fcntl_getlease() can find it.  Since fcntl_getlease() only reports
+ * whether the current task holds a lease, a cluster filesystem need only do
+ * this for leases held by processes on this node.
  */
 
 int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
-- 
1.9.3

