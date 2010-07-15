From: David Howells <dhowells@redhat.com>
Subject: [PATCH 06/18] xstat: Ext4: Return extended attributes [ver #6]
Date: Thu, 15 Jul 2010 03:17:16 +0100
Message-ID: <20100715021716.5544.88673.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <samba-technical-bounces@lists.samba.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the Ext4 filesystem.  This includes the
following:

 (1) The inode creation time (i_crtime) as i_btime.

 (2) The inode i_generation as i_gen if not the root directory.

 (3) The inode i_version as st_data_version if a file with I_VERSION set or a
     directory.

 (4) FS_xxx_FL flags as for FS_IOC_GETFLAGS.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ext4/ext4.h    |    2 ++
 fs/ext4/file.c    |    2 +-
 fs/ext4/inode.c   |   32 +++++++++++++++++++++++++++++---
 fs/ext4/namei.c   |    2 ++
 fs/ext4/symlink.c |    2 ++
 5 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 19a4de5..96823f3 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1571,6 +1571,8 @@ extern int  ext4_write_inode(struct inode *, struct writeback_control *);
 extern int  ext4_setattr(struct dentry *, struct iattr *);
 extern int  ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
 				struct kstat *stat);
+extern int  ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
+				struct kstat *stat);
 extern void ext4_delete_inode(struct inode *);
 extern int  ext4_sync_inode(handle_t *, struct inode *);
 extern void ext4_dirty_inode(struct inode *);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 5313ae4..18c29ab 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -150,7 +150,7 @@ const struct file_operations ext4_file_operations = {
 const struct inode_operations ext4_file_inode_operations = {
 	.truncate	= ext4_truncate,
 	.setattr	= ext4_setattr,
-	.getattr	= ext4_getattr,
+	.getattr	= ext4_file_getattr,
 #ifdef CONFIG_EXT4_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 42272d6..822a4ad 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5550,12 +5550,38 @@ err_out:
 int ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		 struct kstat *stat)
 {
-	struct inode *inode;
-	unsigned long delalloc_blocks;
+	struct inode *inode = dentry->d_inode;
+	struct ext4_inode_info *ei = EXT4_I(inode);
 
-	inode = dentry->d_inode;
 	generic_fillattr(inode, stat);
 
+	stat->result_mask |= XSTAT_REQUEST_BTIME;
+	stat->btime.tv_sec = EXT4_I(inode)->i_crtime.tv_sec;
+	stat->btime.tv_nsec = EXT4_I(inode)->i_crtime.tv_nsec;
+
+	if (inode->i_ino != EXT4_ROOT_INO) {
+		stat->result_mask |= XSTAT_REQUEST_GEN;
+		stat->gen = inode->i_generation;
+	}
+	if (S_ISDIR(inode->i_mode) || test_opt(inode->i_sb, I_VERSION)) {
+		stat->result_mask |= XSTAT_REQUEST_DATA_VERSION;
+		stat->data_version = inode->i_version;
+	}
+
+	ext4_get_inode_flags(ei);
+	stat->inode_flags |= ei->i_flags & EXT4_FL_USER_VISIBLE;
+	stat->result_mask |= XSTAT_REQUEST_INODE_FLAGS;
+	return 0;
+}
+
+int ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
+		      struct kstat *stat)
+{
+	struct inode *inode = dentry->d_inode;
+	unsigned long delalloc_blocks;
+
+	ext4_getattr(mnt, dentry, stat);
+
 	/*
 	 * We can't update i_blocks if the block allocation is delayed
 	 * otherwise in the case of system crash before the real block
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index a43e661..0f776c7 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -2542,6 +2542,7 @@ const struct inode_operations ext4_dir_inode_operations = {
 	.mknod		= ext4_mknod,
 	.rename		= ext4_rename,
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 #ifdef CONFIG_EXT4_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
@@ -2554,6 +2555,7 @@ const struct inode_operations ext4_dir_inode_operations = {
 
 const struct inode_operations ext4_special_inode_operations = {
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 #ifdef CONFIG_EXT4_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
index ed9354a..d8fe7fb 100644
--- a/fs/ext4/symlink.c
+++ b/fs/ext4/symlink.c
@@ -35,6 +35,7 @@ const struct inode_operations ext4_symlink_inode_operations = {
 	.follow_link	= page_follow_link_light,
 	.put_link	= page_put_link,
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 #ifdef CONFIG_EXT4_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
@@ -47,6 +48,7 @@ const struct inode_operations ext4_fast_symlink_inode_operations = {
 	.readlink	= generic_readlink,
 	.follow_link	= ext4_follow_link,
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 #ifdef CONFIG_EXT4_FS_XATTR
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
