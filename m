From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd-exofs: Fix exofs_inode_recall_layout() sending
 2 recalls
Date: Tue, 29 Jun 2010 14:41:19 +0300
Message-ID: <4C29DBDF.1080904@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16256 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751963Ab0F2LlV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 07:41:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


A misunderstanding of the wait_event_interruptible() macro has caused
exofs to always issue two recalls in succession.

Using __wait_event_interruptible() would fix that. But I don't like
how this code is structured so change it around completely to be more
flat and clear.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   67 +++++++++++++++++++---------------------------------
 1 files changed, 25 insertions(+), 42 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 8beebfe..ae3e9fd 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -332,45 +332,15 @@ struct pnfs_export_operations exofs_pnfs_ops = {
 	.get_device_info = exofs_get_device_info,
 };
 
-static bool is_layout_returned(struct exofs_i_info *oi, enum pnfs_iomode iomode,
-			      u64 offset, u64 length, void *cookie, int *status)
+static bool is_layout_returned(struct exofs_i_info *oi)
 {
-	struct inode *inode = &oi->vfs_inode;
-	bool done;
-	int error;
-
-	/* We most probably have finished the recall, unless there was an out-
-	 * of-memory condition when sending the recall. For forward progress
-	 * some recalls where sent and some not, resend these that where lost
-	 * before. If cb_layout_recall returns with -ENOENT we know we are
-	 * done for sure.
-	 */
-
-	error = cb_layout_recall(inode, iomode, offset, length, cookie);
-
-	switch (error) {
-	case 0:
-	case -EAGAIN:
-		done = false;
-		break;
-	case -ENOENT:
-		done = true;
-		break;
-	default:
-		goto err;
-	}
+	bool layout_given;
 
-	*status = 0;
-	return done;
+	spin_lock(&oi->i_layout_lock);
+	layout_given = test_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
+	spin_unlock(&oi->i_layout_lock);
 
-err:
-	/* this will cause wait_event_interruptible below to break with
-	 * an -ERESTARTSY return. If nfsd is able to unload we probably
-	 * should break out of any nfs loops
-	 */
-	*status = error;
-	restart_syscall();
-	return false;
+	return !layout_given;
 }
 
 int exofs_inode_recall_layout(struct inode *inode, enum pnfs_iomode iomode,
@@ -388,13 +358,26 @@ int exofs_inode_recall_layout(struct inode *inode, enum pnfs_iomode iomode,
 	if (!layout_given)
 		goto exec;
 
-	EXOFS_DBGMSG("(0x%lx) has_layout issue a recall\n", inode->i_ino);
+	for (;;) {
+		EXOFS_DBGMSG("(0x%lx) has_layout issue a recall\n",
+			     inode->i_ino);
+		error = cb_layout_recall(inode, iomode, 0, NFS4_MAX_UINT64,
+					 &oi->i_wq);
+		switch (error) {
+		case 0:
+		case -EAGAIN:
+			break;
+		case -ENOENT:
+			goto exec;
+		default:
+			goto err;
+		}
 
-	wait_event_interruptible(oi->i_wq,
-			is_layout_returned(oi, iomode, 0, NFS4_MAX_UINT64,
-					   todo, &error));
-	if (error)
-		goto err;
+		error = wait_event_interruptible(oi->i_wq,
+						 is_layout_returned(oi));
+		if (error)
+			goto err;
+	}
 
 exec:
 	error = todo(inode);
-- 
1.6.6.1

