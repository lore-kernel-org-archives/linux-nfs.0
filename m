From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/4] NFS: add nfs_killattr inode_operation
Date: Mon, 27 Aug 2007 13:27:23 -0400
Message-ID: <200708271727.l7RHRNXo007260@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Add the nfs_killattr inode operation. For NFS, we generally want the server
to handle clearing these bits. So the function is really just a noop.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c           |    3 +++
 fs/nfs/file.c          |    2 ++
 fs/nfs/inode.c         |   10 ++++++++++
 fs/nfs/nfs4proc.c      |    1 +
 fs/nfs/symlink.c       |    1 +
 include/linux/nfs_fs.h |    1 +
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 74fe1e2..ac22770 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -78,6 +78,7 @@ const struct inode_operations nfs_dir_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
+	.killattr	= nfs_killattr,
 };
 
 #ifdef CONFIG_NFS_V3
@@ -98,6 +99,7 @@ const struct inode_operations nfs3_dir_inode_operations = {
 	.getxattr	= nfs3_getxattr,
 	.setxattr	= nfs3_setxattr,
 	.removexattr	= nfs3_removexattr,
+	.killattr	= nfs_killattr,
 };
 #endif  /* CONFIG_NFS_V3 */
 
@@ -120,6 +122,7 @@ const struct inode_operations nfs4_dir_inode_operations = {
 	.getxattr       = nfs4_getxattr,
 	.setxattr       = nfs4_setxattr,
 	.listxattr      = nfs4_listxattr,
+	.killattr	= nfs_killattr,
 };
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 591d59c..169c2a9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -80,6 +80,7 @@ const struct inode_operations nfs_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
+	.killattr	= nfs_killattr,
 };
 
 #ifdef CONFIG_NFS_V3
@@ -91,6 +92,7 @@ const struct inode_operations nfs3_file_inode_operations = {
 	.getxattr	= nfs3_getxattr,
 	.setxattr	= nfs3_setxattr,
 	.removexattr	= nfs3_removexattr,
+	.killattr	= nfs_killattr,
 };
 #endif  /* CONFIG_NFS_v3 */
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 45633f9..3d68a8d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -316,6 +316,16 @@ out_no_inode:
 	goto out;
 }
 
+/*
+ * On NFS, we want the server to handle clearing of setuid/setgid. Make this
+ * a noop.
+ */
+void
+nfs_killattr(struct dentry *dentry, struct iattr *attr)
+{
+	return;
+}
+
 #define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET)
 
 int
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b49aa05..7643a25 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3711,6 +3711,7 @@ static const struct inode_operations nfs4_file_inode_operations = {
 	.getxattr	= nfs4_getxattr,
 	.setxattr	= nfs4_setxattr,
 	.listxattr	= nfs4_listxattr,
+	.killattr	= nfs_killattr,
 };
 
 const struct nfs_rpc_ops nfs_v4_clientops = {
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 83e865a..fd0a880 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -77,4 +77,5 @@ const struct inode_operations nfs_symlink_inode_operations = {
 	.put_link	= page_put_link,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
+	.killattr	= nfs_killattr,
 };
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c444d24..bea2cf1 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -301,6 +301,7 @@ extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_revalidate_mapping_nolock(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
+extern void nfs_killattr(struct dentry *dentry, struct iattr *attr);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern void nfs_begin_attr_update(struct inode *);
 extern void nfs_end_attr_update(struct inode *);
-- 
1.5.2.1

