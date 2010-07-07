From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 04/10] SELinux: Add new labeling type native labels
Date: Wed,  7 Jul 2010 10:31:20 -0400
Message-ID: <1278513086-23964-5-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There currently doesn't exist a labeling type that is adequate for use with
labeled NFS. Since NFS doesn't really support xattrs we can't use the use xattr
labeling behavior. For this we developed a new labeling type. The native
labeling type is used solely by NFS to ensure NFS inodes are labeled at runtime
by the NFS code instead of relying on the SELinux security server on the client
end.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 include/linux/security.h            |    3 +++
 security/selinux/hooks.c            |   30 +++++++++++++++++++++---------
 security/selinux/include/security.h |    2 ++
 security/selinux/ss/policydb.c      |    5 ++++-
 4 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 4bb5db7..d67c5d6 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -43,6 +43,9 @@
 #define SECURITY_CAP_NOAUDIT 0
 #define SECURITY_CAP_AUDIT 1
 
+/* LSM Agnostic defines for sb_set_mnt_opts */
+#define SECURITY_LSM_NATIVE_LABELS	1
+
 struct ctl_table;
 struct audit_krule;
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index d150fb4..01edf80 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -77,6 +77,7 @@
 #include <linux/mutex.h>
 #include <linux/posix-timers.h>
 #include <linux/syslog.h>
+#include <linux/security.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -323,13 +324,14 @@ extern int ss_initialized;
 
 /* The file system's label must be initialized prior to use. */
 
-static char *labeling_behaviors[6] = {
+static char *labeling_behaviors[7] = {
 	"uses xattr",
 	"uses transition SIDs",
 	"uses task SIDs",
 	"uses genfs_contexts",
 	"not configured for labeling",
 	"uses mountpoint labeling",
+	"uses native labeling",
 };
 
 static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dentry);
@@ -721,14 +723,16 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	if (strcmp(sb->s_type->name, "proc") == 0)
 		sbsec->flags |= SE_SBPROC;
 
-	/* Determine the labeling behavior to use for this filesystem type. */
-	rc = security_fs_use((sbsec->flags & SE_SBPROC) ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);
-	if (rc) {
-		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
-		       __func__, sb->s_type->name, rc);
-		goto out;
+	if (!sbsec->behavior) {
+		/* Determine the labeling behavior to use for this filesystem type. */
+		rc = security_fs_use((sbsec->flags & SE_SBPROC) ? "proc" : sb->s_type->name, 
+					&sbsec->behavior, &sbsec->sid);
+		if (rc) {
+			printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
+					__func__, sb->s_type->name, rc);
+			goto out;
+		}
 	}
-
 	/* sets the context of the superblock for the fs being mounted. */
 	if (fscontext_sid) {
 		rc = may_context_mount_sb_relabel(fscontext_sid, sbsec, cred);
@@ -743,6 +747,11 @@ static int selinux_set_mnt_opts(struct super_block *sb,
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
@@ -774,7 +783,8 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	}
 
 	if (defcontext_sid) {
-		if (sbsec->behavior != SECURITY_FS_USE_XATTR) {
+		if (sbsec->behavior != SECURITY_FS_USE_XATTR &&
+			sbsec->behavior != SECURITY_FS_USE_NATIVE) {
 			rc = -EINVAL;
 			printk(KERN_WARNING "SELinux: defcontext option is "
 			       "invalid for this filesystem type\n");
@@ -1251,6 +1261,8 @@ static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dent
 	}
 
 	switch (sbsec->behavior) {
+	case SECURITY_FS_USE_NATIVE:
+		break;
 	case SECURITY_FS_USE_XATTR:
 		if (!inode->i_op->getxattr) {
 			isec->sid = sbsec->def_sid;
diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
index 1f7c249..e4c5bd0 100644
--- a/security/selinux/include/security.h
+++ b/security/selinux/include/security.h
@@ -161,6 +161,8 @@ int security_get_allow_unknown(void);
 #define SECURITY_FS_USE_GENFS		4 /* use the genfs support */
 #define SECURITY_FS_USE_NONE		5 /* no labeling support */
 #define SECURITY_FS_USE_MNTPOINT	6 /* use mountpoint labeling */
+#define SECURITY_FS_USE_NATIVE		7 /* use native label support */
+#define SECURITY_FS_USE_MAX		7 /* Highest SECURITY_FS_USE_XXX */
 
 int security_fs_use(const char *fstype, unsigned int *behavior,
 	u32 *sid);
diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/policydb.c
index 23c6e53..35e2b47 100644
--- a/security/selinux/ss/policydb.c
+++ b/security/selinux/ss/policydb.c
@@ -1996,7 +1996,10 @@ int policydb_read(struct policydb *p, void *fp)
 				if (rc < 0)
 					goto bad;
 				c->v.behavior = le32_to_cpu(buf[0]);
-				if (c->v.behavior > SECURITY_FS_USE_NONE)
+				/* Determined at runtime, not in policy DB. */
+				if (c->v.behavior == SECURITY_FS_USE_MNTPOINT)
+					goto bad;
+				if (c->v.behavior > SECURITY_FS_USE_MAX)
 					goto bad;
 				len = le32_to_cpu(buf[1]);
 				c->u.name = kmalloc(len + 1, GFP_KERNEL);
-- 
1.6.2.5

