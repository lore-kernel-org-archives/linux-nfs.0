Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752933AbcI1XaD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Sep 2016 19:30:03 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: [PATCH v26 03/21] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD permission flags
Date: Thu, 29 Sep 2016 01:29:22 +0200
Message-Id: <1475105380-22837-4-git-send-email-agruenba@redhat.com>
In-Reply-To: <1475105380-22837-1-git-send-email-agruenba@redhat.com>
References: <1475105380-22837-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Normally, deleting a file requires MAY_WRITE access to the parent
directory.  With richacls, a file may be deleted with MAY_DELETE_CHILD access
to the parent directory or with MAY_DELETE_SELF access to the file.

To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
when checking for delete access inside a directory, and MAY_DELETE_SELF
when checking for delete access to a file itself.

The MAY_DELETE_SELF permission overrides the sticky directory check.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: J. Bruce Fields <bfields@redhat.com>
Reviewed-by: Steve French <steve.french@primarydata.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c         | 20 +++++++++++++-------
 include/linux/fs.h |  2 ++
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 7290dea..c8bc9fd 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -463,9 +463,9 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * this, letting us set arbitrary permissions for filesystem access without
  * changing the "normal" UIDs which are used for other things.
  *
- * MAY_WRITE must be set in @mask whenever MAY_APPEND, MAY_CREATE_FILE, or
- * MAY_CREATE_DIR are set.  That way, file systems that don't support these
- * permissions will check for MAY_WRITE instead.
+ * MAY_WRITE must be set in @mask whenever MAY_APPEND, MAY_CREATE_FILE,
+ * MAY_CREATE_DIR, or MAY_DELETE_CHILD are set.  That way, file systems that
+ * don't support these permissions will check for MAY_WRITE instead.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2780,14 +2780,20 @@ static int may_delete_or_replace(struct inode *dir, struct dentry *victim,
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
-	error = inode_permission(dir, mask);
+	error = inode_permission(dir, mask | MAY_WRITE | MAY_DELETE_CHILD);
+	if (!error && check_sticky(dir, inode))
+		error = -EPERM;
+	if (error && IS_RICHACL(inode) &&
+	    inode_permission(inode, MAY_DELETE_SELF) == 0 &&
+	    inode_permission(dir, mask) == 0)
+		error = 0;
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
 		return -EPERM;
 
-	if (check_sticky(dir, inode) || IS_APPEND(inode) ||
-	    IS_IMMUTABLE(inode) || IS_SWAPFILE(inode) || HAS_UNMAPPED_ID(inode))
+	if (IS_APPEND(inode) || IS_IMMUTABLE(inode) ||
+	    IS_SWAPFILE(inode) || HAS_UNMAPPED_ID(inode))
 		return -EPERM;
 	if (isdir) {
 		if (!d_is_dir(victim))
@@ -2805,7 +2811,7 @@ static int may_delete_or_replace(struct inode *dir, struct dentry *victim,
 
 static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 {
-	return may_delete_or_replace(dir, victim, isdir, MAY_WRITE | MAY_EXEC);
+	return may_delete_or_replace(dir, victim, isdir, MAY_EXEC);
 }
 
 static int may_replace(struct inode *dir, struct dentry *victim, bool isdir)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 54b2a07..f3e21b0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -86,6 +86,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.7.4

