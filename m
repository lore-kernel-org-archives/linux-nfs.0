Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37941 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbbC0Qvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:51:47 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 06/39] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD permission flags
Date: Fri, 27 Mar 2015 17:50:04 +0100
Message-Id: <aa523375eda7b7aa5b2096df3de899a7b631af6c.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Normally, deleting a file requires write and execute access to the parent
directory.  With Richacls, a process with MAY_DELETE_SELF access to a file may
delete the file even without write access to the parent directory.

To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission() when
checking for delete access inside a directory, and MAY_DELETE_SELF when
checking for delete access to a file itelf.

The MAY_DELETE_SELF permission does not override the sticky directory check.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c         | 15 +++++++++++----
 include/linux/fs.h |  2 ++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a8bc030..a8d1674 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -455,7 +455,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * changing the "normal" UIDs which are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2452,7 +2452,7 @@ static int may_delete(struct inode *dir, struct dentry *victim,
 		      bool isdir, bool replace)
 {
 	struct inode *inode = victim->d_inode;
-	int error, mask = MAY_WRITE | MAY_EXEC;
+	int error, mask = MAY_EXEC;
 
 	if (d_is_negative(victim))
 		return -ENOENT;
@@ -2462,8 +2462,15 @@ static int may_delete(struct inode *dir, struct dentry *victim,
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
 	if (replace)
-		mask |= isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
-	error = inode_permission(dir, mask);
+		mask |= MAY_WRITE | (isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE);
+	error = inode_permission(dir, mask | MAY_WRITE | MAY_DELETE_CHILD);
+	if (error && IS_RICHACL(inode)) {
+		/* Deleting is also permitted with MAY_EXEC on the directory
+		 * and MAY_DELETE_SELF on the inode.  */
+		if (!inode_permission(inode, MAY_DELETE_SELF) &&
+		    !inode_permission(dir, mask))
+			error = 0;
+	}
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bbe1d26..101abcf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -82,6 +82,8 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.1.0

