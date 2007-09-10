From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/7] VFS: make notify_change pass ATTR_KILL_S*ID to setattr operations
Date: Mon, 10 Sep 2007 10:52:42 -0400
Message-ID: <200709101452.l8AEqg0V016288@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net,
	ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org, unionfs@filesystems.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <reiserfs-devel-owner@vger.kernel.org>
Sender: reiserfs-devel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Make notify_change not clear the ATTR_KILL_S*ID bits in the ia_vaid that
gets passed to the setattr inode operation. This allows the filesystems
to reinterpret whether this mode change is simply intended to clear the
setuid/setgid bits.

This means that notify_change should never be called with both ATTR_MODE
and either of the ATTR_KILL_S*ID bits set, since the filesystem would
have no way to know what part of the mode change was intentional. If
it is called this way, consider it a BUG().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/attr.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index ae58bd3..966b73e 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -103,12 +103,11 @@ EXPORT_SYMBOL(inode_setattr);
 int notify_change(struct dentry * dentry, struct iattr * attr)
 {
 	struct inode *inode = dentry->d_inode;
-	mode_t mode;
+	mode_t mode = inode->i_mode;
 	int error;
 	struct timespec now;
 	unsigned int ia_valid = attr->ia_valid;
 
-	mode = inode->i_mode;
 	now = current_fs_time(inode->i_sb);
 
 	attr->ia_ctime = now;
@@ -125,18 +124,25 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 		if (error)
 			return error;
 	}
+
+	/*
+	 * We now pass ATTR_KILL_S*ID to the lower level setattr function so
+	 * that the function has the ability to reinterpret a mode change
+	 * that's due to these bits. This adds an implicit restriction that
+	 * no function will ever call notify_change with both ATTR_MODE and
+	 * ATTR_KILL_S*ID set.
+	 */
+	if ((ia_valid & (ATTR_KILL_SUID|ATTR_KILL_SGID)) &&
+	    (ia_valid & ATTR_MODE))
+		BUG();
+
 	if (ia_valid & ATTR_KILL_SUID) {
-		attr->ia_valid &= ~ATTR_KILL_SUID;
 		if (mode & S_ISUID) {
-			if (!(ia_valid & ATTR_MODE)) {
-				ia_valid = attr->ia_valid |= ATTR_MODE;
-				attr->ia_mode = inode->i_mode;
-			}
-			attr->ia_mode &= ~S_ISUID;
+			ia_valid = attr->ia_valid |= ATTR_MODE;
+			attr->ia_mode = (inode->i_mode & ~S_ISUID);
 		}
 	}
 	if (ia_valid & ATTR_KILL_SGID) {
-		attr->ia_valid &= ~ ATTR_KILL_SGID;
 		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
 			if (!(ia_valid & ATTR_MODE)) {
 				ia_valid = attr->ia_valid |= ATTR_MODE;
@@ -145,7 +151,7 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
 			attr->ia_mode &= ~S_ISGID;
 		}
 	}
-	if (!attr->ia_valid)
+	if (!(attr->ia_valid & ~(ATTR_KILL_SUID | ATTR_KILL_SGID)))
 		return 0;
 
 	if (ia_valid & ATTR_SIZE)
-- 
1.5.2.1

