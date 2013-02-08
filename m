Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946442Ab3BHMjb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 07:39:31 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 04/15] SELinux: Add new labeling type native labels
Date: Fri,  8 Feb 2013 07:39:12 -0500
Message-Id: <1360327163-20360-5-git-send-email-SteveD@redhat.com>
In-Reply-To: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

There currently doesn't exist a labeling type that is adequate for use with
labeled NFS. Since NFS doesn't really support xattrs we can't use the use xattr
labeling behavior. For this we developed a new labeling type. The native
labeling type is used solely by NFS to ensure NFS inodes are labeled at runtime
by the NFS code instead of relying on the SELinux security server on the client
end.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 include/linux/security.h            |  3 +++
 security/selinux/hooks.c            | 35 ++++++++++++++++++++++++++---------
 security/selinux/include/security.h |  2 ++
 security/selinux/ss/policydb.c      |  5 ++++-
 4 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 5c4179a..9dc244e 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -61,6 +61,9 @@ struct mm_struct;
 #define SECURITY_CAP_NOAUDIT 0
 #define SECURITY_CAP_AUDIT 1
 
+/* LSM Agnostic defines for sb_set_mnt_opts */
+#define SECURITY_LSM_NATIVE_LABELS	1
+
 struct ctl_table;
 struct audit_krule;
 struct user_namespace;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 972db08..dda436f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -80,6 +80,7 @@
 #include <linux/syslog.h>
 #include <linux/user_namespace.h>
 #include <linux/export.h>
+#include <linux/security.h>
 #include <linux/msg.h>
 #include <linux/shm.h>
 
@@ -283,13 +284,14 @@ static void superblock_free_security(struct super_block *sb)
 
 /* The file system's label must be initialized prior to use. */
 
-static const char *labeling_behaviors[6] = {
+static const char *labeling_behaviors[7] = {
 	"uses xattr",
 	"uses transition SIDs",
 	"uses task SIDs",
 	"uses genfs_contexts",
 	"not configured for labeling",
 	"uses mountpoint labeling",
+	"uses native labeling",
 };
 
 static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dentry);
@@ -677,14 +679,21 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	if (strcmp(sb->s_type->name, "proc") == 0)
 		sbsec->flags |= SE_SBPROC;
 
-	/* Determine the labeling behavior to use for this filesystem type. */
-	rc = security_fs_use((sbsec->flags & SE_SBPROC) ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);
-	if (rc) {
-		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
-		       __func__, sb->s_type->name, rc);
-		goto out;
+	if (!sbsec->behavior) {
+		/*
+		 * Determine the labeling behavior to use for this
+		 * filesystem type.
+		 */
+		rc = security_fs_use((sbsec->flags & SE_SBPROC) ?
+					"proc" : sb->s_type->name,
+					&sbsec->behavior, &sbsec->sid);
+		if (rc) {
+			printk(KERN_WARNING
+				"%s: security_fs_use(%s) returned %d\n",
+					__func__, sb->s_type->name, rc);
+			goto out;
+		}
 	}
-
 	/* sets the context of the superblock for the fs being mounted. */
 	if (fscontext_sid) {
 		rc = may_context_mount_sb_relabel(fscontext_sid, sbsec, cred);
@@ -699,6 +708,11 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	 * sets the label used on all file below the mountpoint, and will set
 	 * the superblock context if not already set.
 	 */
+	if (kern_flags & SECURITY_LSM_NATIVE_LABELS && !context_sid) {
+		sbsec->behavior = SECURITY_FS_USE_NATIVE;
+		*set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
+	}
+
 	if (context_sid) {
 		if (!fscontext_sid) {
 			rc = may_context_mount_sb_relabel(context_sid, sbsec,
@@ -730,7 +744,8 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	}
 
 	if (defcontext_sid) {
-		if (sbsec->behavior != SECURITY_FS_USE_XATTR) {
+		if (sbsec->behavior != SECURITY_FS_USE_XATTR &&
+			sbsec->behavior != SECURITY_FS_USE_NATIVE) {
 			rc = -EINVAL;
 			printk(KERN_WARNING "SELinux: defcontext option is "
 			       "invalid for this filesystem type\n");
@@ -1198,6 +1213,8 @@ static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dent
 	}
 
 	switch (sbsec->behavior) {
+	case SECURITY_FS_USE_NATIVE:
+		break;
 	case SECURITY_FS_USE_XATTR:
 		if (!inode->i_op->getxattr) {
 			isec->sid = sbsec->def_sid;
diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
index 6d38851..8fd8e18 100644
--- a/security/selinux/include/security.h
+++ b/security/selinux/include/security.h
@@ -169,6 +169,8 @@ int security_get_allow_unknown(void);
 #define SECURITY_FS_USE_GENFS		4 /* use the genfs support */
 #define SECURITY_FS_USE_NONE		5 /* no labeling support */
 #define SECURITY_FS_USE_MNTPOINT	6 /* use mountpoint labeling */
+#define SECURITY_FS_USE_NATIVE		7 /* use native label support */
+#define SECURITY_FS_USE_MAX		7 /* Highest SECURITY_FS_USE_XXX */
 
 int security_fs_use(const char *fstype, unsigned int *behavior,
 	u32 *sid);
diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/policydb.c
index 9cd9b7c..c8adde3 100644
--- a/security/selinux/ss/policydb.c
+++ b/security/selinux/ss/policydb.c
@@ -2168,7 +2168,10 @@ static int ocontext_read(struct policydb *p, struct policydb_compat_info *info,
 
 				rc = -EINVAL;
 				c->v.behavior = le32_to_cpu(buf[0]);
-				if (c->v.behavior > SECURITY_FS_USE_NONE)
+				/* Determined at runtime, not in policy DB. */
+				if (c->v.behavior == SECURITY_FS_USE_MNTPOINT)
+					goto out;
+				if (c->v.behavior > SECURITY_FS_USE_MAX)
 					goto out;
 
 				rc = -ENOMEM;
-- 
1.7.11.7

