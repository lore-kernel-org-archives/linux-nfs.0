From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/4] VFS: Introduce the killattr inode operation for handling ATTR_KILL_S*ID
Date: Mon, 27 Aug 2007 13:27:13 -0400
Message-ID: <200708271727.l7RHRDmr007253@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760465AbXH0R1g@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This patch adds the killattr inode operation. inodes that have a
killattr operation defined are responsible for properly handling the
ATTR_KILL_SUID and ATTR_KILL_SGID bits within this operation. inodes
that do not have a killattr op will instead use "standard" logic which
turns these bits into a mode change if the setuid or setgid bits are
currently set in the inode's mode.

To enable this, the patch does the standard processing of these bits on
a set of local variables, and then has these local variables supercede
the values in the iattr when a killattr op isn't defined.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/attr.c          |   33 ++++++++++++++++++++-------------
 include/linux/fs.h |    1 +
 2 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index ae58bd3..77608d3 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -103,12 +103,11 @@ EXPORT_SYMBOL(inode_setattr);
 int notify_change(struct dentry * dentry, struct iattr * attr)
 {
 	struct inode *inode = dentry->d_inode;
-	mode_t mode;
+	mode_t mode = attr->ia_mode;
 	int error;
 	struct timespec now;
 	unsigned int ia_valid = attr->ia_valid;
 
-	mode = inode->i_mode;
 	now = current_fs_time(inode->i_sb);
 
 	attr->ia_ctime = now;
@@ -126,28 +125,36 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 			return error;
 	}
 	if (ia_valid & ATTR_KILL_SUID) {
-		attr->ia_valid &= ~ATTR_KILL_SUID;
-		if (mode & S_ISUID) {
+		ia_valid &= ~ATTR_KILL_SUID;
+		if (inode->i_mode & S_ISUID) {
 			if (!(ia_valid & ATTR_MODE)) {
-				ia_valid = attr->ia_valid |= ATTR_MODE;
-				attr->ia_mode = inode->i_mode;
+				ia_valid |= ATTR_MODE;
+				mode = inode->i_mode;
 			}
-			attr->ia_mode &= ~S_ISUID;
+			mode &= ~S_ISUID;
 		}
 	}
 	if (ia_valid & ATTR_KILL_SGID) {
-		attr->ia_valid &= ~ ATTR_KILL_SGID;
-		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
+		ia_valid &= ~ATTR_KILL_SGID;
+		if ((inode->i_mode & (S_ISGID | S_IXGRP)) ==
+					(S_ISGID | S_IXGRP)) {
 			if (!(ia_valid & ATTR_MODE)) {
-				ia_valid = attr->ia_valid |= ATTR_MODE;
-				attr->ia_mode = inode->i_mode;
+				ia_valid |= ATTR_MODE;
+				mode = inode->i_mode;
 			}
-			attr->ia_mode &= ~S_ISGID;
+			mode &= ~S_ISGID;
 		}
 	}
-	if (!attr->ia_valid)
+	if (!ia_valid)
 		return 0;
 
+	if (inode->i_op && inode->i_op->killattr) {
+		inode->i_op->killattr(dentry, attr);
+	} else {
+		attr->ia_valid = ia_valid;
+		attr->ia_mode = mode;
+	}
+
 	if (ia_valid & ATTR_SIZE)
 		down_write(&dentry->d_inode->i_alloc_sem);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 291d40b..d213539 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1220,6 +1220,7 @@ struct inode_operations {
 	void (*truncate_range)(struct inode *, loff_t, loff_t);
 	long (*fallocate)(struct inode *inode, int mode, loff_t offset,
 			  loff_t len);
+	void (*killattr) (struct dentry *dentry, struct iattr *attr);
 };
 
 struct seq_file;
-- 
1.5.2.1
