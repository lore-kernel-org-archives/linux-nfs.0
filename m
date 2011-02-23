Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:53377 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932240Ab1BWNyc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:54:32 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH -V5 24/24] ext4: Add temporary richacl mount option for ext4
Date: Wed, 23 Feb 2011 19:22:11 +0530
Message-Id: <1298469131-16555-25-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This helps in easy testing of the patchset. The mount
option will be later removed in favour of a feature flag.

***Should be folded before merging***

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/ext4/super.c |   52 +++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index adc97b7..9f3fe61 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1011,6 +1011,10 @@ static int ext4_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	if (!(sb->s_flags & MS_POSIXACL) && (def_mount_opts & EXT4_DEFM_ACL))
 		seq_puts(seq, ",noacl");
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	if (sb->s_flags & MS_RICHACL)
+		seq_puts(seq, ",richacl");
+#endif
 	if (sbi->s_commit_interval != JBD2_DEFAULT_MAX_COMMIT_AGE*HZ) {
 		seq_printf(seq, ",commit=%u",
 			   (unsigned) (sbi->s_commit_interval / HZ));
@@ -1262,6 +1266,7 @@ enum {
 	Opt_dioread_nolock, Opt_dioread_lock,
 	Opt_discard, Opt_nodiscard,
 	Opt_init_inode_table, Opt_noinit_inode_table,
+	Opt_richacl,
 };
 
 static const match_table_t tokens = {
@@ -1337,6 +1342,7 @@ static const match_table_t tokens = {
 	{Opt_init_inode_table, "init_itable=%u"},
 	{Opt_init_inode_table, "init_itable"},
 	{Opt_noinit_inode_table, "noinit_itable"},
+	{Opt_richacl, "richacl"},
 	{Opt_err, NULL},
 };
 
@@ -1363,6 +1369,35 @@ static ext4_fsblk_t get_sb_block(void **data)
 	return sb_block;
 }
 
+static void enable_acl(struct super_block *sb)
+{
+#if !defined(CONFIG_EXT4_FS_POSIX_ACL)
+	ext4_msg(sb, KERN_ERR, "acl options not supported");
+	return;
+#endif
+	sb->s_flags |= MS_POSIXACL;
+}
+
+static void disable_acl(struct super_block *sb)
+{
+#if !defined(CONFIG_EXT4_FS_POSIX_ACL)
+	ext4_msg(sb, KERN_ERR, "acl options not supported");
+	return;
+#endif
+	sb->s_flags &= ~MS_POSIXACL;
+	return;
+}
+
+static void enable_richacl(struct super_block *sb)
+{
+#if !defined(CONFIG_EXT4_FS_RICHACL)
+	ext4_msg(sb, KERN_ERR, "richacl options not supported");
+	return;
+#endif
+	sb->s_flags |= MS_RICHACL;
+	return;
+}
+
 #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
 static char deprecated_msg[] = "Mount option \"%s\" will be removed by %s\n"
 	"Contact linux-ext4@vger.kernel.org if you think we should keep it.\n";
@@ -1527,19 +1562,12 @@ static int parse_options(char *options, struct super_block *sb,
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
@@ -1826,6 +1854,8 @@ set_qf_format:
 			break;
 		case Opt_noinit_inode_table:
 			clear_opt(sb, INIT_INODE_TABLE);
+		case Opt_richacl:
+			enable_richacl(sb);
 			break;
 		default:
 			ext4_msg(sb, KERN_ERR,
@@ -3099,9 +3129,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	if (def_mount_opts & EXT4_DEFM_XATTR_USER)
 		set_opt(sb, XATTR_USER);
 #endif
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
+#if defined(CONFIG_EXT4_FS_POSIX_ACL)
 	if (def_mount_opts & EXT4_DEFM_ACL)
-		sb->s_flags |= MS_POSIXACL;
+		enable_acl(sb);
 #endif
 	if ((def_mount_opts & EXT4_DEFM_JMODE) == EXT4_DEFM_JMODE_DATA)
 		set_opt(sb, JOURNAL_DATA);
-- 
1.7.1

