From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 01/10] Security: Add hook to calculate context based on a negative dentry.
Date: Wed,  7 Jul 2010 10:31:17 -0400
Message-ID: <1278513086-23964-2-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a time where we need to calculate a context without the
inode having been created yet. To do this we take the negative dentry and
calculate a context based on the process and the parent directory contexts.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 include/linux/security.h |   22 ++++++++++++++++++++++
 security/capability.c    |    6 ++++++
 security/security.c      |    7 +++++++
 security/selinux/hooks.c |   32 ++++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 3158dd9..4d01784 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -322,6 +322,14 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	Parse a string of security data filling in the opts structure
  *	@options string containing all mount options known by the LSM
  *	@opts binary data structure usable by the LSM
+ * @dentry_init_security:
+ *	Compute a context for a dentry as the inode is not yet available
+ * 	since NFSv4 has no label backed by an EA anyway.
+ * 	@dentry dentry to use in calculating the context.
+ * 	@mode mode used to determine resource type.
+ * 	@ctx pointer to place the pointer to the resulting context in.
+ * 	@ctxlen point to place the length of the resulting context.
+ *
  *
  * Security hooks for inode operations.
  *
@@ -1501,6 +1509,9 @@ struct security_operations {
 	void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
 				   struct super_block *newsb);
 	int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
+	int (*dentry_init_security) (struct dentry *dentry, int mode,
+				     void **ctx, u32 *ctxlen);
+
 
 #ifdef CONFIG_SECURITY_PATH
 	int (*path_unlink) (struct path *dir, struct dentry *dentry);
@@ -1795,6 +1806,8 @@ int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *o
 void security_sb_clone_mnt_opts(const struct super_block *oldsb,
 				struct super_block *newsb);
 int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
+int security_dentry_init_security (struct dentry *dentry, int mode,
+				   void **ctx, u32 *ctxlen);
 
 int security_inode_alloc(struct inode *inode);
 void security_inode_free(struct inode *inode);
@@ -2157,6 +2170,15 @@ static inline int security_inode_alloc(struct inode *inode)
 static inline void security_inode_free(struct inode *inode)
 { }
 
+static inline int security_dentry_init_security (struct dentry *dentry,
+						 int mode,
+						 void **ctx,
+						 u32 *ctxlen)
+{
+	return -EOPNOTSUPP;
+}
+
+
 static inline int security_inode_init_security(struct inode *inode,
 						struct inode *dir,
 						char **name,
diff --git a/security/capability.c b/security/capability.c
index 4875142..9ce1c2f 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -134,6 +134,11 @@ static int cap_sb_parse_opts_str(char *options, struct security_mnt_opts *opts)
 	return 0;
 }
 
+static int cap_dentry_init_security(struct dentry *dentry, int mode, void **ctx, u32 *ctxlen)
+{
+	return 0;
+}
+
 static int cap_inode_alloc_security(struct inode *inode)
 {
 	return 0;
@@ -952,6 +957,7 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, sb_set_mnt_opts);
 	set_to_cap_if_null(ops, sb_clone_mnt_opts);
 	set_to_cap_if_null(ops, sb_parse_opts_str);
+	set_to_cap_if_null(ops, dentry_init_security);
 	set_to_cap_if_null(ops, inode_alloc_security);
 	set_to_cap_if_null(ops, inode_free_security);
 	set_to_cap_if_null(ops, inode_init_security);
diff --git a/security/security.c b/security/security.c
index 687c6fd..c1b6847 100644
--- a/security/security.c
+++ b/security/security.c
@@ -386,6 +386,13 @@ void security_inode_free(struct inode *inode)
 	security_ops->inode_free_security(inode);
 }
 
+int security_dentry_init_security (struct dentry *dentry, int mode,
+				   void **ctx, u32 *ctxlen)
+{
+	return security_ops->dentry_init_security (dentry, mode, ctx, ctxlen);
+}
+EXPORT_SYMBOL(security_dentry_init_security);
+
 int security_inode_init_security(struct inode *inode, struct inode *dir,
 				  char **name, void **value, size_t *len)
 {
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5feecb4..435c51f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2577,6 +2577,37 @@ static void selinux_inode_free_security(struct inode *inode)
 	inode_free_security(inode);
 }
 
+static int selinux_dentry_init_security(struct dentry *dentry, int mode, void **ctx, u32 *ctxlen)
+{
+	struct cred *cred = current_cred();
+	struct task_security_struct *tsec;
+	struct inode_security_struct *dsec;
+	struct superblock_security_struct *sbsec;
+	struct inode *dir = dentry->d_parent->d_inode;
+	u32 newsid;
+	int rc;
+
+	tsec = cred->security;
+	dsec = dir->i_security;
+	sbsec = dir->i_sb->s_security;
+
+	if (tsec->create_sid && sbsec->behavior != SECURITY_FS_USE_MNTPOINT) {
+		newsid = tsec->create_sid;
+	} else {
+		rc = security_transition_sid(tsec->sid, dsec->sid,
+					     inode_mode_to_security_class(mode),
+					     &newsid);
+		if (rc) {
+			printk(KERN_WARNING "%s:  "
+			       "security_transition_sid failed, rc=%d\n",
+			       __FUNCTION__, -rc);
+			return rc;
+		}
+	}
+
+	return security_sid_to_context(newsid, (char **)ctx, ctxlen);
+}
+
 static int selinux_inode_init_security(struct inode *inode, struct inode *dir,
 				       char **name, void **value,
 				       size_t *len)
@@ -5484,6 +5515,7 @@ static struct security_operations selinux_ops = {
 	.sb_clone_mnt_opts =		selinux_sb_clone_mnt_opts,
 	.sb_parse_opts_str = 		selinux_parse_opts_str,
 
+	.dentry_init_security =		selinux_dentry_init_security,
 
 	.inode_alloc_security =		selinux_inode_alloc_security,
 	.inode_free_security =		selinux_inode_free_security,
-- 
1.6.2.5
