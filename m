Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:41027 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab1IER1n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:27:43 -0400
Received: from /spool/local
	by in.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 5 Sep 2011 22:57:41 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 24/26] ext4: Use IS_POSIXACL() to check for POSIX ACL support
Date: Mon,  5 Sep 2011 22:55:46 +0530
Message-Id: <1315243548-18664-25-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use IS_POSIXACL() instead of a file system specific mount flag since we
have IS_POSIXACL() in the vfs already, anyway.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/ext4/acl.c   |   16 ++++++++--------
 fs/ext4/ext4.h  |    1 -
 fs/ext4/super.c |   16 +++++-----------
 3 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index a5c29bb..525bbc3 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -139,7 +139,7 @@ ext4_get_acl(struct inode *inode, int type)
 	struct posix_acl *acl;
 	int retval;
 
-	if (!test_opt(inode->i_sb, POSIX_ACL))
+	if (!IS_POSIXACL(inode))
 		return NULL;
 
 	acl = get_cached_acl(inode, type);
@@ -248,7 +248,7 @@ ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 	int error = 0;
 
 	if (!S_ISLNK(inode->i_mode)) {
-		if (test_opt(dir->i_sb, POSIX_ACL)) {
+		if (IS_POSIXACL(inode)) {
 			acl = ext4_get_acl(dir, ACL_TYPE_DEFAULT);
 			if (IS_ERR(acl))
 				return PTR_ERR(acl);
@@ -256,7 +256,7 @@ ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 		if (!acl)
 			inode->i_mode &= ~current_umask();
 	}
-	if (test_opt(inode->i_sb, POSIX_ACL) && acl) {
+	if (IS_POSIXACL(inode) && acl) {
 		if (S_ISDIR(inode->i_mode)) {
 			error = ext4_set_acl(handle, inode,
 					     ACL_TYPE_DEFAULT, acl);
@@ -302,7 +302,7 @@ ext4_acl_chmod(struct inode *inode)
 
 	if (S_ISLNK(inode->i_mode))
 		return -EOPNOTSUPP;
-	if (!test_opt(inode->i_sb, POSIX_ACL))
+	if (!IS_POSIXACL(inode))
 		return 0;
 	acl = ext4_get_acl(inode, ACL_TYPE_ACCESS);
 	if (IS_ERR(acl) || !acl)
@@ -337,7 +337,7 @@ ext4_xattr_list_acl_access(struct dentry *dentry, char *list, size_t list_len,
 {
 	const size_t size = sizeof(POSIX_ACL_XATTR_ACCESS);
 
-	if (!test_opt(dentry->d_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return 0;
 	if (list && size <= list_len)
 		memcpy(list, POSIX_ACL_XATTR_ACCESS, size);
@@ -350,7 +350,7 @@ ext4_xattr_list_acl_default(struct dentry *dentry, char *list, size_t list_len,
 {
 	const size_t size = sizeof(POSIX_ACL_XATTR_DEFAULT);
 
-	if (!test_opt(dentry->d_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return 0;
 	if (list && size <= list_len)
 		memcpy(list, POSIX_ACL_XATTR_DEFAULT, size);
@@ -366,7 +366,7 @@ ext4_xattr_get_acl(struct dentry *dentry, const char *name, void *buffer,
 
 	if (strcmp(name, "") != 0)
 		return -EINVAL;
-	if (!test_opt(dentry->d_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return -EOPNOTSUPP;
 
 	acl = ext4_get_acl(dentry->d_inode, type);
@@ -391,7 +391,7 @@ ext4_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 
 	if (strcmp(name, "") != 0)
 		return -EINVAL;
-	if (!test_opt(inode->i_sb, POSIX_ACL))
+	if (!IS_POSIXACL(dentry->d_inode))
 		return -EOPNOTSUPP;
 	if (!inode_owner_or_capable(inode))
 		return -EPERM;
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index e717dfd..be229ac 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -900,7 +900,6 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_UPDATE_JOURNAL	0x01000	/* Update the journal format */
 #define EXT4_MOUNT_NO_UID32		0x02000  /* Disable 32-bit UIDs */
 #define EXT4_MOUNT_XATTR_USER		0x04000	/* Extended user attributes */
-#define EXT4_MOUNT_POSIX_ACL		0x08000	/* POSIX Access Control Lists */
 #define EXT4_MOUNT_NO_AUTO_DA_ALLOC	0x10000	/* No auto delalloc mapping */
 #define EXT4_MOUNT_BARRIER		0x20000 /* Use block barriers */
 #define EXT4_MOUNT_QUOTA		0x80000 /* Some quota option set */
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 44d0c8d..99d72cf 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1066,9 +1066,9 @@ static int ext4_show_options(struct seq_file *seq, struct vfsmount *vfs)
 		seq_puts(seq, ",nouser_xattr");
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
@@ -1587,10 +1587,10 @@ static int parse_options(char *options, struct super_block *sb,
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
@@ -3170,7 +3170,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	set_opt(sb, XATTR_USER);
 #endif
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
-	set_opt(sb, POSIX_ACL);
+	sb->s_flags |= MS_POSIXACL;
 #endif
 	set_opt(sb, MBLK_IO_SUBMIT);
 	if ((def_mount_opts & EXT4_DEFM_JMODE) == EXT4_DEFM_JMODE_DATA)
@@ -3224,9 +3224,6 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			   &journal_ioprio, NULL, 0))
 		goto failed_mount;
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
-
 	if (le32_to_cpu(es->s_rev_level) == EXT4_GOOD_OLD_REV &&
 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
 	     EXT4_HAS_RO_COMPAT_FEATURE(sb, ~0U) ||
@@ -4351,9 +4348,6 @@ static int ext4_remount(struct super_block *sb, int *flags, char *data)
 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
 		ext4_abort(sb, "Abort forced by user");
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
-
 	es = sbi->s_es;
 
 	if (sbi->s_journal) {
-- 
1.7.4.1

