Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:32781 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932776AbbHDLyd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:54:33 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 03/40] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD permission flags
Date: Tue,  4 Aug 2015 13:53:01 +0200
Message-Id: <1438689218-6921-4-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Normally, deleting a file requires write and execute access to the parent
directory.  With Richacls, a process with MAY_DELETE_SELF access to a file
may delete the file even without write access to the parent directory.

To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
when checking for delete access inside a directory, and MAY_DELETE_SELF
when checking for delete access to a file itelf.

The MAY_DELETE_SELF permission does not override the sticky directory
check.  It probably should.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c         | 15 +++++++++++----
 include/linux/fs.h |  2 ++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 3504d36..2ac759c 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -454,7 +454,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * changing the "normal" UIDs which are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2527,7 +2527,7 @@ static int may_delete(struct inode *dir, struct dentry *victim,
 		      bool isdir, bool replace)
 {
 	struct inode *inode = d_backing_inode(victim);
-	int error, mask = MAY_WRITE | MAY_EXEC;
+	int error, mask = MAY_EXEC;
 
 	if (d_is_negative(victim))
 		return -ENOENT;
@@ -2537,8 +2537,15 @@ static int may_delete(struct inode *dir, struct dentry *victim,
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
index 9c44f27..abf5b0e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -83,6 +83,8 @@ typedef void (dax_iodone_t)(struct buffer_head *bh_map, int uptodate);
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.5.0

