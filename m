Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36126 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973AbbC0QwK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:10 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 22/39] ext4: Add richacl feature flag
Date: Fri, 27 Mar 2015 17:50:20 +0100
Message-Id: <cd0f63669d8ddd93fee8f2debd98a63c6d4294e5.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This feature flag selects richacl instead of posix acl support on the file
system. In addition, the "acl" mount option is needed for enabling either of
the two kinds of acls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/ext4.h  |  6 ++++--
 fs/ext4/super.c | 41 ++++++++++++++++++++++++++++++++---------
 2 files changed, 36 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index f63c3d5..64187cd 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -978,7 +978,7 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_UPDATE_JOURNAL	0x01000	/* Update the journal format */
 #define EXT4_MOUNT_NO_UID32		0x02000  /* Disable 32-bit UIDs */
 #define EXT4_MOUNT_XATTR_USER		0x04000	/* Extended user attributes */
-#define EXT4_MOUNT_POSIX_ACL		0x08000	/* POSIX Access Control Lists */
+#define EXT4_MOUNT_ACL			0x08000	/* Access Control Lists */
 #define EXT4_MOUNT_NO_AUTO_DA_ALLOC	0x10000	/* No auto delalloc mapping */
 #define EXT4_MOUNT_BARRIER		0x20000 /* Use block barriers */
 #define EXT4_MOUNT_QUOTA		0x80000 /* Some quota option set */
@@ -1552,6 +1552,7 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 #define EXT4_FEATURE_INCOMPAT_LARGEDIR		0x4000 /* >2GB or 3-lvl htree */
 #define EXT4_FEATURE_INCOMPAT_INLINE_DATA	0x8000 /* data in inode */
 #define EXT4_FEATURE_INCOMPAT_ENCRYPT		0x10000
+#define EXT4_FEATURE_INCOMPAT_RICHACL		0x20000
 
 #define EXT2_FEATURE_COMPAT_SUPP	EXT4_FEATURE_COMPAT_EXT_ATTR
 #define EXT2_FEATURE_INCOMPAT_SUPP	(EXT4_FEATURE_INCOMPAT_FILETYPE| \
@@ -1576,7 +1577,8 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 					 EXT4_FEATURE_INCOMPAT_64BIT| \
 					 EXT4_FEATURE_INCOMPAT_FLEX_BG| \
 					 EXT4_FEATURE_INCOMPAT_MMP |	\
-					 EXT4_FEATURE_INCOMPAT_INLINE_DATA)
+					 EXT4_FEATURE_INCOMPAT_INLINE_DATA | \
+					 EXT4_FEATURE_INCOMPAT_RICHACL)
 #define EXT4_FEATURE_RO_COMPAT_SUPP	(EXT4_FEATURE_RO_COMPAT_SPARSE_SUPER| \
 					 EXT4_FEATURE_RO_COMPAT_LARGE_FILE| \
 					 EXT4_FEATURE_RO_COMPAT_GDT_CSUM| \
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index e061e66..4226898 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1242,6 +1242,27 @@ static ext4_fsblk_t get_sb_block(void **data)
 	return sb_block;
 }
 
+static int enable_acl(struct super_block *sb)
+{
+	sb->s_flags &= ~(MS_POSIXACL | MS_RICHACL);
+	if (test_opt(sb, ACL)) {
+		if (EXT4_HAS_INCOMPAT_FEATURE(sb, EXT4_FEATURE_INCOMPAT_RICHACL)) {
+#ifdef CONFIG_EXT4_FS_RICHACL
+			sb->s_flags |= MS_RICHACL;
+#else
+			return -EOPNOTSUPP;
+#endif
+		} else {
+#ifdef CONFIG_EXT4_FS_POSIX_ACL
+			sb->s_flags |= MS_POSIXACL;
+#else
+			return -EOPNOTSUPP;
+#endif
+		}
+	}
+	return 0;
+}
+
 #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
 static char deprecated_msg[] = "Mount option \"%s\" will be removed by %s\n"
 	"Contact linux-ext4@vger.kernel.org if you think we should keep it.\n";
@@ -1388,9 +1409,9 @@ static const struct mount_opts {
 	 MOPT_NO_EXT2 | MOPT_DATAJ},
 	{Opt_user_xattr, EXT4_MOUNT_XATTR_USER, MOPT_SET},
 	{Opt_nouser_xattr, EXT4_MOUNT_XATTR_USER, MOPT_CLEAR},
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
-	{Opt_acl, EXT4_MOUNT_POSIX_ACL, MOPT_SET},
-	{Opt_noacl, EXT4_MOUNT_POSIX_ACL, MOPT_CLEAR},
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+	{Opt_acl, EXT4_MOUNT_ACL, MOPT_SET},
+	{Opt_noacl, EXT4_MOUNT_ACL, MOPT_CLEAR},
 #else
 	{Opt_acl, 0, MOPT_NOSUPPORT},
 	{Opt_noacl, 0, MOPT_NOSUPPORT},
@@ -3538,8 +3559,8 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		set_opt(sb, NO_UID32);
 	/* xattr user namespace & acls are now defaulted on */
 	set_opt(sb, XATTR_USER);
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
-	set_opt(sb, POSIX_ACL);
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+	set_opt(sb, ACL);
 #endif
 	/* don't forget to enable journal_csum when metadata_csum is enabled. */
 	if (ext4_has_metadata_csum(sb))
@@ -3620,8 +3641,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			clear_opt(sb, DELALLOC);
 	}
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
+	err = enable_acl(sb);
+	if (err)
+		goto failed_mount;
 
 	if (le32_to_cpu(es->s_rev_level) == EXT4_GOOD_OLD_REV &&
 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
@@ -4913,8 +4935,9 @@ static int ext4_remount(struct super_block *sb, int *flags, char *data)
 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
 		ext4_abort(sb, "Abort forced by user");
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
+	err = enable_acl(sb);
+	if (err)
+		goto restore_opts;
 
 	es = sbi->s_es;
 
-- 
2.1.0

