Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649AbcD2M6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 08:58:01 -0400
Subject: [PATCH 3/6] statx: Ext4: Return enhanced file attributes
From: David Howells <dhowells@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-ext4@vger.kernel.org
Date: Fri, 29 Apr 2016 13:57:59 +0100
Message-ID: <20160429125759.23636.10635.stgit@warthog.procyon.org.uk>
In-Reply-To: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return enhanced file attributes from the Ext4 filesystem.  This includes
the following:

 (1) The inode creation time (i_crtime) as i_btime, setting STATX_BTIME.

 (2) The inode i_version as st_version if a file with I_VERSION set or a
     directory, setting STATX_VERSION.

 (3) FS_xxx_FL flags are returned as for ioctl(FS_IOC_GETFLAGS), setting
     STATX_IOC_FLAGS.

This requires that all ext4 inodes have a getattr call, not just some of
them, so to this end, split the ext4_getattr() function and only call part
of it where appropriate.

Example output:

	[root@andromeda ~]# ./samples/statx/test-statx /usr
	statx(/usr) = 0
	results=37ef
	  Size: 4096            Blocks: 16         IO Block: 4096    directory
	Device: 08:02           Inode: 1572865     Links: 14
	Access: (0755/drwxr-xr-x)  Uid:     0   Gid:     0
	Access: 2015-11-03 16:12:30.000000000+0000
	Modify: 2013-10-18 15:29:18.000000000+0100
	Change: 2013-10-18 15:29:18.000000000+0100
	Data version: 2fh
	Inode flags: 00000000 (-------- -------- -------- --------)
	IO-blocksize: blksize=4096

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ext4/ext4.h    |    2 ++
 fs/ext4/file.c    |    2 +-
 fs/ext4/inode.c   |   30 +++++++++++++++++++++++++++---
 fs/ext4/namei.c   |    2 ++
 fs/ext4/symlink.c |    2 ++
 5 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 349afebe21ee..2f25eaa63f39 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2549,6 +2549,8 @@ extern int  ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
 				struct kstat *stat);
 extern void ext4_evict_inode(struct inode *);
 extern void ext4_clear_inode(struct inode *);
+extern int  ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
+			      struct kstat *stat);
 extern int  ext4_sync_inode(handle_t *, struct inode *);
 extern void ext4_dirty_inode(struct inode *, int);
 extern int ext4_change_inode_journal_flag(struct inode *, int);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index fa2208bae2e1..45c7b8644d0e 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -715,7 +715,7 @@ const struct file_operations ext4_file_operations = {
 
 const struct inode_operations ext4_file_inode_operations = {
 	.setattr	= ext4_setattr,
-	.getattr	= ext4_getattr,
+	.getattr	= ext4_file_getattr,
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 981a1fc30eaa..309b6cff8afc 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5100,11 +5100,35 @@ err_out:
 int ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		 struct kstat *stat)
 {
-	struct inode *inode;
-	unsigned long long delalloc_blocks;
+	struct inode *inode = d_inode(dentry);
+	struct ext4_inode *raw_inode;
+	struct ext4_inode_info *ei = EXT4_I(inode);
+
+	stat->result_mask |= STATX_GEN;
+	stat->gen = inode->i_generation;
+
+	if (EXT4_FITS_IN_INODE(raw_inode, ei, i_crtime)) {
+		stat->result_mask |= STATX_BTIME;
+		stat->btime.tv_sec = ei->i_crtime.tv_sec;
+		stat->btime.tv_nsec = ei->i_crtime.tv_nsec;
+	}
+
+	if (S_ISDIR(inode->i_mode) || IS_I_VERSION(inode)) {
+		stat->result_mask |= STATX_VERSION;
+		stat->version = inode->i_version;
+	}
 
-	inode = d_inode(dentry);
 	generic_fillattr(inode, stat);
+	return 0;
+}
+
+int ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
+		      struct kstat *stat)
+{
+	struct inode *inode = dentry->d_inode;
+	u64 delalloc_blocks;
+
+	ext4_getattr(mnt, dentry, stat);
 
 	/*
 	 * If there is inline data in the inode, the inode will normally not
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 48e4b8907826..9b5fdc971e22 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -3882,6 +3882,7 @@ const struct inode_operations ext4_dir_inode_operations = {
 	.tmpfile	= ext4_tmpfile,
 	.rename2	= ext4_rename2,
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
@@ -3893,6 +3894,7 @@ const struct inode_operations ext4_dir_inode_operations = {
 
 const struct inode_operations ext4_special_inode_operations = {
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
index 75ed5c2f0c16..54015f3d7516 100644
--- a/fs/ext4/symlink.c
+++ b/fs/ext4/symlink.c
@@ -105,6 +105,7 @@ const struct inode_operations ext4_symlink_inode_operations = {
 	.readlink	= generic_readlink,
 	.get_link	= page_get_link,
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
@@ -115,6 +116,7 @@ const struct inode_operations ext4_fast_symlink_inode_operations = {
 	.readlink	= generic_readlink,
 	.get_link	= simple_get_link,
 	.setattr	= ext4_setattr,
+	.getattr	= ext4_getattr,
 	.setxattr	= generic_setxattr,
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,

