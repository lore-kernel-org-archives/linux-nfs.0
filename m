From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/4] CIFS: add cifs_killattr inode_operation
Date: Mon, 27 Aug 2007 13:27:33 -0400
Message-ID: <200708271727.l7RHRXdK007265@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760678AbXH0R2p@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

..make it just clear the ATTR_KILL_S*ID bits since we want the
server to handle it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/cifs/cifsfs.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index cabb6a5..c357c55 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -553,6 +553,13 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int origin)
 	return remote_llseek(file, offset, origin);
 }
 
+/* The server should handle this, so we just clear the bits */
+static void cifs_killattr(struct dentry *dentry, struct iattr *attr)
+{
+	attr->ia_valid &= ~(ATTR_KILL_SUID|ATTR_KILL_SGID);
+	return;
+}
+
 static struct file_system_type cifs_fs_type = {
 	.owner = THIS_MODULE,
 	.name = "cifs",
@@ -574,6 +581,7 @@ const struct inode_operations cifs_dir_inode_ops = {
 	.setattr = cifs_setattr,
 	.symlink = cifs_symlink,
 	.mknod   = cifs_mknod,
+	.killattr = cifs_killattr,
 #ifdef CONFIG_CIFS_XATTR
 	.setxattr = cifs_setxattr,
 	.getxattr = cifs_getxattr,
@@ -588,6 +596,7 @@ const struct inode_operations cifs_file_inode_ops = {
 	.getattr = cifs_getattr, /* do we need this anymore? */
 	.rename = cifs_rename,
 	.permission = cifs_permission,
+	.killattr = cifs_killattr,
 #ifdef CONFIG_CIFS_XATTR
 	.setxattr = cifs_setxattr,
 	.getxattr = cifs_getxattr,
-- 
1.5.2.1
