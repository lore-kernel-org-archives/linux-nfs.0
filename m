Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:59215 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab1IER27 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:28:59 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 26/26] ext4: Add temporary richacl mount option for ext4
Date: Mon,  5 Sep 2011 22:55:48 +0530
Message-Id: <1315243548-18664-27-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This helps in easy testing of the patchset. The mount
option will be later removed in favour of a feature flag.

***Should be folded before merging***

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/ext4/super.c |   51 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 99d72cf..71241b0 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1071,6 +1071,10 @@ static int ext4_show_options(struct seq_file *seq, struct vfsmount *vfs)
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
@@ -1320,6 +1324,7 @@ enum {
 	Opt_dioread_nolock, Opt_dioread_lock,
 	Opt_discard, Opt_nodiscard,
 	Opt_init_inode_table, Opt_noinit_inode_table,
+	Opt_richacl,
 };
 
 static const match_table_t tokens = {
@@ -1395,6 +1400,7 @@ static const match_table_t tokens = {
 	{Opt_init_inode_table, "init_itable=%u"},
 	{Opt_init_inode_table, "init_itable"},
 	{Opt_noinit_inode_table, "noinit_itable"},
+	{Opt_richacl, "richacl"},
 	{Opt_err, NULL},
 };
 
@@ -1421,6 +1427,36 @@ static ext4_fsblk_t get_sb_block(void **data)
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
+	sb->s_flags &= ~MS_POSIXACL;
+	return;
+}
+
 #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
 static char deprecated_msg[] = "Mount option \"%s\" will be removed by %s\n"
 	"Contact linux-ext4@vger.kernel.org if you think we should keep it.\n";
@@ -1585,19 +1621,12 @@ static int parse_options(char *options, struct super_block *sb,
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
@@ -1884,6 +1913,8 @@ set_qf_format:
 			break;
 		case Opt_noinit_inode_table:
 			clear_opt(sb, INIT_INODE_TABLE);
+		case Opt_richacl:
+			enable_richacl(sb);
 			break;
 		default:
 			ext4_msg(sb, KERN_ERR,
@@ -3170,7 +3201,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	set_opt(sb, XATTR_USER);
 #endif
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
-	sb->s_flags |= MS_POSIXACL;
+	enable_acl(sb);
 #endif
 	set_opt(sb, MBLK_IO_SUBMIT);
 	if ((def_mount_opts & EXT4_DEFM_JMODE) == EXT4_DEFM_JMODE_DATA)
-- 
1.7.4.1

