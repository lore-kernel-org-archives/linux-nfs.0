Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab0J3Vb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:31:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] locks: fix leaks on setlease errors
Date: Sat, 30 Oct 2010 17:31:14 -0400
Message-Id: <1288474276-14288-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20101030212500.GE480@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We're depending on setlease to free the passed-in lease on failure.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 06c7773..63fbc41 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1371,20 +1371,22 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	struct inode *inode = dentry->d_inode;
 	int error, rdlease_count = 0, wrlease_count = 0;
 
+	lease = *flp;
+
+	error = -EACCES;
 	if ((current_fsuid() != inode->i_uid) && !capable(CAP_LEASE))
-		return -EACCES;
+		goto out;
+	error = -EINVAL;
 	if (!S_ISREG(inode->i_mode))
-		return -EINVAL;
+		goto out;
 	error = security_file_lock(filp, arg);
 	if (error)
-		return error;
+		goto out;
 
 	time_out_leases(inode);
 
 	BUG_ON(!(*flp)->fl_lmops->fl_break);
 
-	lease = *flp;
-
 	if (arg != F_UNLCK) {
 		error = -EAGAIN;
 		if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
-- 
1.7.1

