Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757548Ab2ENSr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 14:47:26 -0400
From: Josef Bacik <josef@redhat.com>
To: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, adilger@dilger.ca, tytso@mit.edu
Subject: [PATCH] ext4: fix how i_version is modified and turn it on by default
Date: Mon, 14 May 2012 14:47:19 -0400
Message-Id: <1337021239-2790-1-git-send-email-josef@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes MS_I_VERSION be turned on by default.  Ext4 had been
unconditionally doing i_version++ in a few cases anway so the mount option
was kind of silly.  This patch also removes the update in mark_inode_dirty
and makes all of the cases where we update ctime also do inode_inc_iversion.
file_update_time takes care of the write case and all the places where we
update iversion are protected by the i_mutex so there should be no extra
i_lock overhead in the normal non-exported fs case.  Thanks,

Signed-off-by: Josef Bacik <josef@redhat.com>
---
 fs/ext4/acl.c      |    1 +
 fs/ext4/extents.c  |    3 +++
 fs/ext4/indirect.c |    1 +
 fs/ext4/inode.c    |    3 ---
 fs/ext4/ioctl.c    |    2 ++
 fs/ext4/namei.c    |   14 ++++++++++----
 fs/ext4/super.c    |    5 +++--
 fs/ext4/xattr.c    |    1 +
 8 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index a5c29bb..fb3ff80 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -202,6 +202,7 @@ ext4_set_acl(handle_t *handle, struct inode *inode, int type,
 			if (error < 0)
 				return error;
 			else {
+				inode_inc_iversion(inode);
 				inode->i_ctime = ext4_current_time(inode);
 				ext4_mark_inode_dirty(handle, inode);
 				if (error == 0)
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 74f23c2..a9ac029 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -4249,6 +4249,7 @@ out_stop:
 	if (inode->i_nlink)
 		ext4_orphan_del(handle, inode);
 
+	inode_inc_iversion(inode);
 	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
 	ext4_mark_inode_dirty(handle, inode);
 	ext4_journal_stop(handle);
@@ -4261,6 +4262,7 @@ static void ext4_falloc_update_inode(struct inode *inode,
 
 	if (update_ctime) {
 		now = current_fs_time(inode->i_sb);
+		inode_inc_iversion(inode);
 		if (!timespec_equal(&inode->i_ctime, &now))
 			inode->i_ctime = now;
 	}
@@ -4905,6 +4907,7 @@ int ext4_ext_punch_hole(struct file *file, loff_t offset, loff_t length)
 
 out:
 	ext4_orphan_del(handle, inode);
+	inode_inc_iversion(inode);
 	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
 	ext4_mark_inode_dirty(handle, inode);
 	ext4_journal_stop(handle);
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 830e1b2..45ed6d4 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -1476,6 +1476,7 @@ do_indirects:
 
 out_unlock:
 	up_write(&ei->i_data_sem);
+	inode_inc_iversion(inode);
 	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
 	ext4_mark_inode_dirty(handle, inode);
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index feaa82f..d11b4e5 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4314,9 +4314,6 @@ int ext4_mark_iloc_dirty(handle_t *handle,
 {
 	int err = 0;
 
-	if (test_opt(inode->i_sb, I_VERSION))
-		inode_inc_iversion(inode);
-
 	/* the do_update_inode consumes one bh->b_count */
 	get_bh(iloc->bh);
 
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 6eee255..c79b874 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -120,6 +120,7 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		ei->i_flags = flags;
 
 		ext4_set_inode_flags(inode);
+		inode_inc_iversion(inode);
 		inode->i_ctime = ext4_current_time(inode);
 
 		err = ext4_mark_iloc_dirty(handle, inode, &iloc);
@@ -168,6 +169,7 @@ flags_out:
 		}
 		err = ext4_reserve_inode_write(handle, inode, &iloc);
 		if (err == 0) {
+			inode_inc_iversion(inode);
 			inode->i_ctime = ext4_current_time(inode);
 			inode->i_generation = generation;
 			err = ext4_mark_iloc_dirty(handle, inode, &iloc);
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 2043f48..9bb533a 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -1316,9 +1316,9 @@ static int add_dirent_to_buf(handle_t *handle, struct dentry *dentry,
 	 * happen is that the times are slightly out of date
 	 * and/or different from the directory change time.
 	 */
+	inode_inc_iversion(dir);
 	dir->i_mtime = dir->i_ctime = ext4_current_time(dir);
 	ext4_update_dx_flag(dir);
-	dir->i_version++;
 	ext4_mark_inode_dirty(handle, dir);
 	BUFFER_TRACE(bh, "call ext4_handle_dirty_metadata");
 	err = ext4_handle_dirty_metadata(handle, dir, bh);
@@ -1668,7 +1668,6 @@ static int ext4_delete_entry(handle_t *handle,
 					blocksize);
 			else
 				de->inode = 0;
-			dir->i_version++;
 			BUFFER_TRACE(bh, "call ext4_handle_dirty_metadata");
 			err = ext4_handle_dirty_metadata(handle, dir, bh);
 			if (unlikely(err)) {
@@ -2158,13 +2157,14 @@ static int ext4_rmdir(struct inode *dir, struct dentry *dentry)
 		ext4_warning(inode->i_sb,
 			     "empty directory has too many links (%d)",
 			     inode->i_nlink);
-	inode->i_version++;
 	clear_nlink(inode);
 	/* There's no need to set i_disksize: the fact that i_nlink is
 	 * zero will ensure that the right thing happens during any
 	 * recovery. */
 	inode->i_size = 0;
 	ext4_orphan_add(handle, inode);
+	inode_inc_iversion(inode);
+	inode_inc_iversion(dir);
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = ext4_current_time(inode);
 	ext4_mark_inode_dirty(handle, inode);
 	ext4_dec_count(handle, dir);
@@ -2218,12 +2218,14 @@ static int ext4_unlink(struct inode *dir, struct dentry *dentry)
 	retval = ext4_delete_entry(handle, dir, de, bh);
 	if (retval)
 		goto end_unlink;
+	inode_inc_iversion(dir);
 	dir->i_ctime = dir->i_mtime = ext4_current_time(dir);
 	ext4_update_dx_flag(dir);
 	ext4_mark_inode_dirty(handle, dir);
 	drop_nlink(inode);
 	if (!inode->i_nlink)
 		ext4_orphan_add(handle, inode);
+	inode_inc_iversion(inode);
 	inode->i_ctime = ext4_current_time(inode);
 	ext4_mark_inode_dirty(handle, inode);
 	retval = 0;
@@ -2363,6 +2365,7 @@ retry:
 	if (IS_DIRSYNC(dir))
 		ext4_handle_sync(handle);
 
+	inode_inc_iversion(inode);
 	inode->i_ctime = ext4_current_time(inode);
 	ext4_inc_count(handle, inode);
 	ihold(inode);
@@ -2470,7 +2473,7 @@ static int ext4_rename(struct inode *old_dir, struct dentry *old_dentry,
 		if (EXT4_HAS_INCOMPAT_FEATURE(new_dir->i_sb,
 					      EXT4_FEATURE_INCOMPAT_FILETYPE))
 			new_de->file_type = old_de->file_type;
-		new_dir->i_version++;
+		inode_inc_iversion(new_dir);
 		new_dir->i_ctime = new_dir->i_mtime =
 					ext4_current_time(new_dir);
 		ext4_mark_inode_dirty(handle, new_dir);
@@ -2488,6 +2491,7 @@ static int ext4_rename(struct inode *old_dir, struct dentry *old_dentry,
 	 * Like most other Unix systems, set the ctime for inodes on a
 	 * rename.
 	 */
+	inode_inc_iversion(old_inode);
 	old_inode->i_ctime = ext4_current_time(old_inode);
 	ext4_mark_inode_dirty(handle, old_inode);
 
@@ -2521,8 +2525,10 @@ static int ext4_rename(struct inode *old_dir, struct dentry *old_dentry,
 
 	if (new_inode) {
 		ext4_dec_count(handle, new_inode);
+		inode_inc_iversion(new_inode);
 		new_inode->i_ctime = ext4_current_time(new_inode);
 	}
+	inode_inc_iversion(old_dir);
 	old_dir->i_ctime = old_dir->i_mtime = ext4_current_time(old_dir);
 	ext4_update_dx_flag(old_dir);
 	if (dir_bh) {
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 502c61f..5866d38 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1813,8 +1813,7 @@ set_qf_format:
 				 "Ignoring deprecated bh option");
 			break;
 		case Opt_i_version:
-			set_opt(sb, I_VERSION);
-			sb->s_flags |= MS_I_VERSION;
+			/* On by default now */
 			break;
 		case Opt_nodelalloc:
 			clear_opt(sb, DELALLOC);
@@ -3132,6 +3131,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		goto out_free_orig;
 	}
 	sb->s_fs_info = sbi;
+	sb->s_flags |= MS_I_VERSION;
 	sbi->s_mount_opt = 0;
 	sbi->s_resuid = EXT4_DEF_RESUID;
 	sbi->s_resgid = EXT4_DEF_RESGID;
@@ -4831,6 +4831,7 @@ static int ext4_quota_off(struct super_block *sb, int type)
 	handle = ext4_journal_start(inode, 1);
 	if (IS_ERR(handle))
 		goto out;
+	inode_inc_iversion(inode);
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 	ext4_mark_inode_dirty(handle, inode);
 	ext4_journal_stop(handle);
diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
index 93a00d8..48a3412 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -1048,6 +1048,7 @@ ext4_xattr_set_handle(handle_t *handle, struct inode *inode, int name_index,
 	}
 	if (!error) {
 		ext4_xattr_update_super_block(handle, inode->i_sb);
+		inode_inc_iversion(inode);
 		inode->i_ctime = ext4_current_time(inode);
 		if (!value)
 			ext4_clear_inode_state(inode, EXT4_STATE_NO_EXPAND);
-- 
1.7.7.6

