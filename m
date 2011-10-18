Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:46879 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933011Ab1JRPfo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:35:44 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 26/26] ext4: Add Ext4 compat richacl feature flag
Date: Tue, 18 Oct 2011 21:03:01 +0530
Message-Id: <1318951981-5508-27-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This feature flag can be used to enable richacl on
the file system. Once enabled the "acl" mount option
will enable richacl instead of posix acl. The patch also
removes the richacl mount option.

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/ext4/ext4.h  |    1 +
 fs/ext4/super.c |   49 +++++++++++++++++++++++++++++++++++--------------
 2 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 6627cc8..c71d9fe 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1350,6 +1350,7 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 #define EXT4_FEATURE_COMPAT_EXT_ATTR		0x0008
 #define EXT4_FEATURE_COMPAT_RESIZE_INODE	0x0010
 #define EXT4_FEATURE_COMPAT_DIR_INDEX		0x0020
+#define EXT4_FEATURE_COMPAT_RICHACL		0x0200
 
 #define EXT4_FEATURE_RO_COMPAT_SPARSE_SUPER	0x0001
 #define EXT4_FEATURE_RO_COMPAT_LARGE_FILE	0x0002
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 99d72cf..4a3f0dd 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1065,10 +1065,12 @@ static int ext4_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	if (!test_opt(sb, XATTR_USER))
 		seq_puts(seq, ",nouser_xattr");
 #endif
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
-	if ((sb->s_flags & MS_POSIXACL) && !(def_mount_opts & EXT4_DEFM_ACL))
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+	if ((sb->s_flags & (MS_POSIXACL|MS_RICHACL)) &&
+	    !(def_mount_opts & EXT4_DEFM_ACL))
 		seq_puts(seq, ",acl");
-	if (!(sb->s_flags & MS_POSIXACL) && (def_mount_opts & EXT4_DEFM_ACL))
+	if (!(sb->s_flags & (MS_POSIXACL|MS_RICHACL)) &&
+	    (def_mount_opts & EXT4_DEFM_ACL))
 		seq_puts(seq, ",noacl");
 #endif
 	if (sbi->s_commit_interval != JBD2_DEFAULT_MAX_COMMIT_AGE*HZ) {
@@ -1421,6 +1423,32 @@ static ext4_fsblk_t get_sb_block(void **data)
 	return sb_block;
 }
 
+static void enable_acl(struct super_block *sb)
+{
+#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && !defined(CONFIG_EXT4_FS_RICHACL)
+	ext4_msg(sb, KERN_ERR, "acl options not supported");
+	return;
+#endif
+	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
+		sb->s_flags |= MS_RICHACL;
+		sb->s_flags &= ~MS_POSIXACL;
+	} else {
+		sb->s_flags |= MS_POSIXACL;
+		sb->s_flags &= ~MS_RICHACL;
+	}
+	return;
+}
+
+static void disable_acl(struct super_block *sb)
+{
+#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && !defined(CONFIG_EXT4_FS_RICHACL)
+	ext4_msg(sb, KERN_ERR, "acl options not supported");
+	return;
+#endif
+	sb->s_flags &= ~(MS_POSIXACL | MS_RICHACL);
+	return;
+}
+
 #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
 static char deprecated_msg[] = "Mount option \"%s\" will be removed by %s\n"
 	"Contact linux-ext4@vger.kernel.org if you think we should keep it.\n";
@@ -1585,19 +1613,12 @@ static int parse_options(char *options, struct super_block *sb,
 			ext4_msg(sb, KERN_ERR, "(no)user_xattr options not supported");
 			break;
 #endif
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
 		case Opt_acl:
-			sb->s_flags |= MS_POSIXACL;
+			enable_acl(sb);
 			break;
 		case Opt_noacl:
-			sb->s_flags &= ~MS_POSIXACL;
+			disable_acl(sb);
 			break;
-#else
-		case Opt_acl:
-		case Opt_noacl:
-			ext4_msg(sb, KERN_ERR, "(no)acl options not supported");
-			break;
-#endif
 		case Opt_journal_update:
 			/* @@@ FIXME */
 			/* Eventually we will want to be able to create
@@ -3169,8 +3190,8 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 #ifdef CONFIG_EXT4_FS_XATTR
 	set_opt(sb, XATTR_USER);
 #endif
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
-	sb->s_flags |= MS_POSIXACL;
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+		enable_acl(sb);
 #endif
 	set_opt(sb, MBLK_IO_SUBMIT);
 	if ((def_mount_opts & EXT4_DEFM_JMODE) == EXT4_DEFM_JMODE_DATA)
-- 
1.7.5.4

