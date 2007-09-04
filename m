From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits are set, then skip mode change
Date: Tue, 4 Sep 2007 10:37:04 -0400
Message-ID: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net,
	ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org, unionfs@filesystems.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <reiserfs-devel-owner@vger.kernel.org>
Sender: reiserfs-devel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

If the ATTR_KILL_S*ID bits are set then any mode change is only for
clearing the setuid/setgid bits. For NFS skip the mode change and
let the server handle it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 45633f9..441bd8b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -327,6 +327,10 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
 
+	/* skip mode change if it's just for clearing setuid/setgid */
+	if (attr->ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
+		attr->ia_valid &= ~ATTR_MODE;
+
 	if (attr->ia_valid & ATTR_SIZE) {
 		if (!S_ISREG(inode->i_mode) || attr->ia_size == i_size_read(inode))
 			attr->ia_valid &= ~ATTR_SIZE;
-- 
1.5.2.1

