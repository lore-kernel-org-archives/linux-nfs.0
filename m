From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/4] Fix networked filesystems to handle
	ATTR_KILL_ bits correctly
Date: Mon, 20 Aug 2007 16:53:28 -0400
Message-ID: <200708202053.l7KKrSqZ017768@dantu.rdu.redhat.com>
Cc: nfs@lists.sourceforge.net, linux-cifs-client@lists.samba.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
Errors-To: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
List-ID: <nfs.lists.sourceforge.net>

This fixes NFS and CIFS to take advantage of the new scheme for
handling setuid/setgid bits. For these filesystems we want to just
let the server handle clearing these bits since the client may not
have permissions to do so.

For CIFS, this adds a patch to clear the ATTR_KILL bits so that
notify_change doesn't try to do a second setattr. NFS already clears
these bits, and this just updates a comment to make it clear
that doing this is more than an optimization.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/cifs/inode.c |    5 +++++
 fs/nfs/inode.c  |    6 +++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index dd41677..9668b45 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1429,6 +1429,11 @@ int cifs_setattr(struct dentry *direntry, struct iattr *attrs)
 	cifs_sb = CIFS_SB(direntry->d_inode->i_sb);
 	pTcon = cifs_sb->tcon;
 
+	/* We may not have permissions to clear the setuid/setgid flags. So
+	 * ignore them and let the server handle it.
+	 */
+	attrs->ia_valid &= ~(ATTR_KILL_SUID|ATTR_KILL_SGID);
+
 	if ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NO_PERM) == 0) {
 		/* check if we have permission to change attrs */
 		rc = inode_change_ok(direntry->d_inode, attrs);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 93fc788..b257f18 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -332,7 +332,11 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 			attr->ia_valid &= ~ATTR_SIZE;
 	}
 
-	/* Optimization: if the end result is no change, don't RPC */
+	/*
+	 * Optimization: if the end result is no change, don't RPC. This
+	 * also clears the ATTR_KILL_* flags, which is now needed by
+	 * notify_change.
+	 */
 	attr->ia_valid &= NFS_VALID_ATTRS;
 	if (attr->ia_valid == 0)
 		return 0;
-- 
1.5.2.2
