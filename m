From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/7] reiserfs: turn of ATTR_KILL_S*ID at beginning of reiserfs_setattr
Date: Mon, 10 Sep 2007 10:52:32 -0400
Message-ID: <200709101452.l8AEqWgZ016277@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net,
	ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org, unionfs@filesystems.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760014AbXIJOyV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

reiserfs_setattr can call notify_change recursively using the same
iattr struct. This could cause it to trip the BUG() in notify_change.
Fix reiserfs to clear those bits near the beginning of the function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/reiserfs/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index 9ea1200..0804289 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -3061,7 +3061,11 @@ int reiserfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
 	int error;
-	unsigned int ia_valid = attr->ia_valid;
+	unsigned int ia_valid;
+
+	/* must be turned off for recursive notify_change calls */
+	ia_valid = attr->ia_valid &= ~(ATTR_KILL_SUID|ATTR_KILL_SGID);
+
 	reiserfs_write_lock(inode->i_sb);
 	if (attr->ia_valid & ATTR_SIZE) {
 		/* version 2 items will be caught by the s_maxbytes check
-- 
1.5.2.1
