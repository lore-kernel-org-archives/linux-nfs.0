Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35325 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbaIDMjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:06 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so9999723qgf.28
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:05 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 06/17] locks: clean up vfs_setlease kerneldoc comments
Date: Thu,  4 Sep 2014 08:38:32 -0400
Message-Id: <1409834323-7171-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the latter paragraphs seem ambiguous and just plain wrong.
In particular the break_lease comment makes no sense. We call
break_lease (and break_deleg) from all sorts of vfs-layer functions,
so there is clearly such a method.

Also get rid of some of the other comments about what's needed for
a full implementation.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c | 34 ++++++++++------------------------
 1 file changed, 10 insertions(+), 24 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 1289b74fffbf..81a4628f5594 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1708,30 +1708,16 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
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
+ * if not, this function will return -ENOLCK (and generate a scary-looking
+ * stack trace).
  */
 
 int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
-- 
1.9.3

