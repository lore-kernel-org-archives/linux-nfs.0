Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:53343 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932207Ab1BWNy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:54:27 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 21/24] ext4: Use IS_POSIXACL() to check for POSIX ACL support
Date: Wed, 23 Feb 2011 19:22:08 +0530
Message-Id: <1298469131-16555-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use IS_POSIXACL() instead of a file system specific mount flag since we
have IS_POSIXACL() in the vfs already, anyway.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
---
 fs/ext4/acl.c   |   16 ++++++++--------
 fs/ext4/ext4.h  |    1 -
 fs/ext4/super.c |   16 +++++-----------
 3 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index e0270d1..364514c 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -139,7 +139,7 @@ ext4_get_acl(struct inode *inode, int type)
 	struct posix_acl *acl;
 	int retval;
 
-	if (!test_opt(inode->i_sb, POSIX_ACL))
+	if (!IS_POSIXACL(inode))
 		return NULL;
 
 	acl = get_cached_acl(inode, type);
@@ -273,7 +273,7 @@ ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 	int error = 0;
 
 	if (!S_ISLNK(inode->i_mode)) {
-		if (test_opt(dir->i_sb, POSIX_ACL)) {
+		if (IS_POSIXACL(inode)) {
 			acl = ext4_get_acl(dir, ACL_TYPE_DEFAULT);
 			if (IS_ERR(acl))
 				return PTR_ERR(acl);
@@ -281,7 +281,7 @@ ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 		if (!acl)
 			inode->i_mode &= ~current_umask();
 	}
-	if (test_opt(inode->i_sb, POSIX_ACL) && acl) {
+	if (IS_POSIXACL(inode) && acl) {
 		struct posix_acl *clone;
 		mode_t mode;
 
@@ -335,7 +335,7 @@ ext4_acl_chmod(struct inode *inode)
 
 	if (S_ISLNK(inode->i_mode))
 		return -EOPNOTSUPP;
-	if (!test_opt(inode->i_sb, POSIX_ACL))
+	if (!IS_POSIXACL(inode))
 		return 0;
 	acl = ext4_get_acl(inode, ACL_TYPE_ACCESS);
 	if (IS_ERR(acl) || !acl)
@@ -377,7 +377,7 @@ ext4_xattr_list_acl_access(struct dentry *dentry, char *list, size_t list_len,
 {
 	const size_t size = sizeof(POSIX_ACL_XATTR_ACCESS);
 
-	if (!test_opt(dentry->d_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return 0;
 	if (list && size <= list_len)
 		memcpy(list, POSIX_ACL_XATTR_ACCESS, size);
@@ -390,7 +390,7 @@ ext4_xattr_list_acl_default(struct dentry *dentry, char *list, size_t list_len,
 {
 	const size_t size = sizeof(POSIX_ACL_XATTR_DEFAULT);
 
-	if (!test_opt(dentry->d_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return 0;
 	if (list && size <= list_len)
 		memcpy(list, POSIX_ACL_XATTR_DEFAULT, size);
@@ -406,7 +406,7 @@ ext4_xattr_get_acl(struct dentry *dentry, const char *name, void *buffer,
 
 	if (strcmp(name, "") != 0)
 		return -EINVAL;
-	if (!test_opt(dentry->d_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return -EOPNOTSUPP;
 
 	acl = ext4_get_acl(dentry->d_inode, type);
@@ -431,7 +431,7 @@ ext4_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 
 	if (strcmp(name, "") != 0)
 		return -EINVAL;
-	if (!test_opt(inode->i_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return -EOPNOTSUPP;
 	if (!is_owner_or_cap(inode))
 		return -EPERM;
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 3aa0b72..5d1f56a 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -892,7 +892,6 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_UPDATE_JOURNAL	0x01000	/* Update the journal format */
 #define EXT4_MOUNT_NO_UID32		0x02000  /* Disable 32-bit UIDs */
 #define EXT4_MOUNT_XATTR_USER		0x04000	/* Extended user attributes */
-#define EXT4_MOUNT_POSIX_ACL		0x08000	/* POSIX Access Control Lists */
 #define EXT4_MOUNT_NO_AUTO_DA_ALLOC	0x10000	/* No auto delalloc mapping */
 #define EXT4_MOUNT_BARRIER		0x20000 /* Use block barriers */
 #define EXT4_MOUNT_QUOTA		0x80000 /* Some quota option set */
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index f6a318f..adc97b7 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1006,9 +1006,9 @@ static int ext4_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	}
 #endif
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
-	if (test_opt(sb, POSIX_ACL) && !(def_mount_opts & EXT4_DEFM_ACL))
+	if ((sb->s_flags & MS_POSIXACL) && !(def_mount_opts & EXT4_DEFM_ACL))
 		seq_puts(seq, ",acl");
-	if (!test_opt(sb, POSIX_ACL) && (def_mount_opts & EXT4_DEFM_ACL))
+	if (!(sb->s_flags & MS_POSIXACL) && (def_mount_opts & EXT4_DEFM_ACL))
 		seq_puts(seq, ",noacl");
 #endif
 	if (sbi->s_commit_interval != JBD2_DEFAULT_MAX_COMMIT_AGE*HZ) {
@@ -1529,10 +1529,10 @@ static int parse_options(char *options, struct super_block *sb,
 #endif
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
 		case Opt_acl:
-			set_opt(sb, POSIX_ACL);
+			sb->s_flags |= MS_POSIXACL;
 			break;
 		case Opt_noacl:
-			clear_opt(sb, POSIX_ACL);
+			sb->s_flags &= ~MS_POSIXACL;
 			break;
 #else
 		case Opt_acl:
@@ -3101,7 +3101,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 #endif
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
 	if (def_mount_opts & EXT4_DEFM_ACL)
-		set_opt(sb, POSIX_ACL);
+		sb->s_flags |= MS_POSIXACL;
 #endif
 	if ((def_mount_opts & EXT4_DEFM_JMODE) == EXT4_DEFM_JMODE_DATA)
 		set_opt(sb, JOURNAL_DATA);
@@ -3148,9 +3148,6 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			   &journal_ioprio, NULL, 0))
 		goto failed_mount;
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
-
 	if (le32_to_cpu(es->s_rev_level) == EXT4_GOOD_OLD_REV &&
 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
 	     EXT4_HAS_RO_COMPAT_FEATURE(sb, ~0U) ||
@@ -4235,9 +4232,6 @@ static int ext4_remount(struct super_block *sb, int *flags, char *data)
 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
 		ext4_abort(sb, "Abort forced by user");
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
-
 	es = sbi->s_es;
 
 	if (sbi->s_journal) {
-- 
1.7.1

