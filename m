Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49936 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770Ab1BUTPu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 14:15:50 -0500
Subject: [PATCH] NFS: account direct-io into task io accounting
To: linux-nfs@vger.kernel.org
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org
Date: Mon, 21 Feb 2011 22:15:46 +0300
Message-ID: <20110221191546.5920.96947.stgit@localhost6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Account complete NFS direct-io reads and writes into Task I/O Accounting.

NFS have unusual direct-io implementation,
thus accounting in generic code does not work.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/nfs/direct.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9943a75..bab4185 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -45,6 +45,7 @@
 #include <linux/pagemap.h>
 #include <linux/kref.h>
 #include <linux/slab.h>
+#include <linux/task_io_accounting_ops.h>
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
@@ -939,8 +940,10 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 		goto out;
 
 	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
-	if (retval > 0)
+	if (retval > 0) {
 		iocb->ki_pos = pos + retval;
+		task_io_account_read(retval);
+	}
 
 out:
 	return retval;
@@ -1001,8 +1004,10 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 
 	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
 
-	if (retval > 0)
+	if (retval > 0) {
 		iocb->ki_pos = pos + retval;
+		task_io_account_write(retval);
+	}
 
 out:
 	return retval;

