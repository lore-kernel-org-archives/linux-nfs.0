Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752749AbeDSNbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:31:32 -0400
Subject: [PATCH 04/24] VFS: Add LSM hooks for filesystem context [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:31:30 +0100
Message-ID: <152414469006.23902.8132059438921850399.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add LSM hooks for use by the filesystem context code.  This includes:

 (1) Hooks to handle allocation, duplication and freeing of the security
     record attached to a filesystem context.

 (2) A hook to snoop a mount options in key[=val] form.  If the LSM decides
     it wants to handle it, it can suppress the option being passed to the
     filesystem.  Note that 'val' may include commas and binary data with
     the fsopen patch.

 (3) A hook to transfer the security from the context to a newly created
     superblock.

 (4) A hook to rule on whether a path point can be used as a mountpoint.

These are intended to replace:

	security_sb_copy_data
	security_sb_kern_mount
	security_sb_mount
	security_sb_set_mnt_opts
	security_sb_clone_mnt_opts
	security_sb_parse_opts_str

Signed-off-by: David Howells <dhowells@redhat.com>
cc: linux-security-module@vger.kernel.org
---

 include/linux/lsm_hooks.h |   62 +++++++++++
 include/linux/security.h  |   44 ++++++++
 security/security.c       |   41 +++++++
 security/selinux/hooks.c  |  262 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 409 insertions(+)

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 9d0b286f3dba..da20f90d40bb 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -76,6 +76,50 @@
  *	changes on the process such as clearing out non-inheritable signal
  *	state.  This is called immediately after commit_creds().
  *
+ * Security hooks for mount using fd context.
+ *
+ * @fs_context_alloc:
+ *	Allocate and attach a security structure to sc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@fc indicates the new filesystem context.
+ *	@src_sb indicates the source superblock of a submount.
+ * @fs_context_dup:
+ *	Allocate and attach a security structure to sc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@fc indicates the new filesystem context.
+ *	@src_fc indicates the original filesystem context.
+ * @fs_context_free:
+ *	Clean up a filesystem context.
+ *	@fc indicates the filesystem context.
+ * @fs_context_parse_option:
+ *	Userspace provided an option to configure a superblock.  The LSM may
+ *	reject it with an error and may use it for itself, in which case it
+ *	should return 1; otherwise it should return 0 to pass it on to the
+ *	filesystem.
+ *	@fc indicates the filesystem context.
+ *	@opt indicates the option in "key[=val]" form.  It is NUL-terminated,
+ *	but val may be binary data.
+ *	@len indicates the size of the option.
+ * @fs_context_validate:
+ *	Validate the filesystem context preparatory to applying it.  This is
+ *	done after all the options have been parsed.
+ *	@fc indicates the filesystem context.
+ * @sb_get_tree:
+ *	Assign the security to a newly created superblock.
+ *	@fc indicates the filesystem context.
+ *	@fc->root indicates the root that will be mounted.
+ *	@fc->root->d_sb points to the superblock.
+ * @sb_reconfigure:
+ *	Apply reconfiguration to the security on a superblock.
+ *	@fc indicates the filesystem context.
+ *	@fc->root indicates a dentry in the mount.
+ *	@fc->root->d_sb points to the superblock.
+ * @sb_mountpoint:
+ *	Equivalent of sb_mount, but with an fs_context.
+ *	@fc indicates the filesystem context.
+ *	@mountpoint indicates the path on which the mount will take place.
+ *	@mnt_flags indicates the MNT_* flags specified.
+ *
  * Security hooks for filesystem operations.
  *
  * @sb_alloc_security:
@@ -1450,6 +1494,16 @@ union security_list_options {
 	void (*bprm_committing_creds)(struct linux_binprm *bprm);
 	void (*bprm_committed_creds)(struct linux_binprm *bprm);
 
+	int (*fs_context_alloc)(struct fs_context *fc, struct super_block *src_sb);
+	int (*fs_context_dup)(struct fs_context *fc, struct fs_context *src_sc);
+	void (*fs_context_free)(struct fs_context *fc);
+	int (*fs_context_parse_option)(struct fs_context *fc, char *opt, size_t len);
+	int (*fs_context_validate)(struct fs_context *fc);
+	int (*sb_get_tree)(struct fs_context *fc);
+	void (*sb_reconfigure)(struct fs_context *fc);
+	int (*sb_mountpoint)(struct fs_context *fc, struct path *mountpoint,
+			     unsigned int mnt_flags);
+
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
@@ -1787,6 +1841,14 @@ struct security_hook_heads {
 	struct hlist_head bprm_check_security;
 	struct hlist_head bprm_committing_creds;
 	struct hlist_head bprm_committed_creds;
+	struct hlist_head fs_context_alloc;
+	struct hlist_head fs_context_dup;
+	struct hlist_head fs_context_free;
+	struct hlist_head fs_context_parse_option;
+	struct hlist_head fs_context_validate;
+	struct hlist_head sb_get_tree;
+	struct hlist_head sb_reconfigure;
+	struct hlist_head sb_mountpoint;
 	struct hlist_head sb_alloc_security;
 	struct hlist_head sb_free_security;
 	struct hlist_head sb_copy_data;
diff --git a/include/linux/security.h b/include/linux/security.h
index 200920f521a1..60a85bd9dfef 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -53,6 +53,7 @@ struct msg_msg;
 struct xattr;
 struct xfrm_sec_ctx;
 struct mm_struct;
+struct fs_context;
 
 /* If capable should audit the security request */
 #define SECURITY_CAP_NOAUDIT 0
@@ -231,6 +232,15 @@ int security_bprm_set_creds(struct linux_binprm *bprm);
 int security_bprm_check(struct linux_binprm *bprm);
 void security_bprm_committing_creds(struct linux_binprm *bprm);
 void security_bprm_committed_creds(struct linux_binprm *bprm);
+int security_fs_context_alloc(struct fs_context *fc, struct super_block *sb);
+int security_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc);
+void security_fs_context_free(struct fs_context *fc);
+int security_fs_context_parse_option(struct fs_context *fc, char *opt, size_t len);
+int security_fs_context_validate(struct fs_context *fc);
+int security_sb_get_tree(struct fs_context *fc);
+void security_sb_reconfigure(struct fs_context *fc);
+int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint,
+			   unsigned int mnt_flags);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -539,6 +549,40 @@ static inline void security_bprm_committed_creds(struct linux_binprm *bprm)
 {
 }
 
+static inline int security_fs_context_alloc(struct fs_context *fc,
+					    struct super_block *src_sb)
+{
+	return 0;
+}
+static inline int security_fs_context_dup(struct fs_context *fc,
+					  struct fs_context *src_fc)
+{
+	return 0;
+}
+static inline void security_fs_context_free(struct fs_context *fc)
+{
+}
+static inline int security_fs_context_parse_option(struct fs_context *fc, char *opt, size_t len)
+{
+	return 0;
+}
+static inline int security_fs_context_validate(struct fs_context *fc)
+{
+	return 0;
+}
+static inline int security_sb_get_tree(struct fs_context *fc)
+{
+	return 0;
+}
+static inline void security_sb_reconfigure(struct fs_context *fc)
+{
+}
+static inline int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint,
+					 unsigned int mnt_flags)
+{
+	return 0;
+}
+
 static inline int security_sb_alloc(struct super_block *sb)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index 7bc2fde023a7..42e4ea19b61c 100644
--- a/security/security.c
+++ b/security/security.c
@@ -358,6 +358,47 @@ void security_bprm_committed_creds(struct linux_binprm *bprm)
 	call_void_hook(bprm_committed_creds, bprm);
 }
 
+int security_fs_context_alloc(struct fs_context *fc, struct super_block *src_sb)
+{
+	return call_int_hook(fs_context_alloc, 0, fc, src_sb);
+}
+
+int security_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc)
+{
+	return call_int_hook(fs_context_dup, 0, fc, src_fc);
+}
+
+void security_fs_context_free(struct fs_context *fc)
+{
+	call_void_hook(fs_context_free, fc);
+}
+
+int security_fs_context_parse_option(struct fs_context *fc, char *opt, size_t len)
+{
+	return call_int_hook(fs_context_parse_option, 0, fc, opt, len);
+}
+
+int security_fs_context_validate(struct fs_context *fc)
+{
+	return call_int_hook(fs_context_validate, 0, fc);
+}
+
+int security_sb_get_tree(struct fs_context *fc)
+{
+	return call_int_hook(sb_get_tree, 0, fc);
+}
+
+void security_sb_reconfigure(struct fs_context *fc)
+{
+	call_void_hook(sb_reconfigure, fc);
+}
+
+int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint,
+			   unsigned int mnt_flags)
+{
+	return call_int_hook(sb_mountpoint, 0, fc, mountpoint, mnt_flags);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 1f0316bf7e29..969a2a0dc582 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -48,6 +48,7 @@
 #include <linux/fdtable.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/tty.h>
@@ -2960,6 +2961,259 @@ static int selinux_umount(struct vfsmount *mnt, int flags)
 				   FILESYSTEM__UNMOUNT, NULL);
 }
 
+/* fsopen mount context operations */
+
+static int selinux_fs_context_alloc(struct fs_context *fc,
+				    struct super_block *src_sb)
+{
+	struct security_mnt_opts *opts;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+
+	fc->security = opts;
+	return 0;
+}
+
+static int selinux_fs_context_dup(struct fs_context *fc,
+				  struct fs_context *src_fc)
+{
+	const struct security_mnt_opts *src = src_fc->security;
+	struct security_mnt_opts *opts;
+	int i, n;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+	fc->security = opts;
+
+	if (!src || !src->num_mnt_opts)
+		return 0;
+	n = opts->num_mnt_opts = src->num_mnt_opts;
+
+	if (src->mnt_opts) {
+		opts->mnt_opts = kcalloc(n, sizeof(char *), GFP_KERNEL);
+		if (!opts->mnt_opts)
+			return -ENOMEM;
+
+		for (i = 0; i < n; i++) {
+			if (src->mnt_opts[i]) {
+				opts->mnt_opts[i] = kstrdup(src->mnt_opts[i],
+							    GFP_KERNEL);
+				if (!opts->mnt_opts[i])
+					return -ENOMEM;
+			}
+		}
+	}
+
+	if (src->mnt_opts_flags) {
+		opts->mnt_opts_flags = kmemdup(src->mnt_opts_flags,
+					       n * sizeof(int), GFP_KERNEL);
+		if (!opts->mnt_opts_flags)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void selinux_fs_context_free(struct fs_context *fc)
+{
+	struct security_mnt_opts *opts = fc->security;
+
+	security_free_mnt_opts(opts);
+	fc->security = NULL;
+}
+
+static int selinux_fs_context_parse_option(struct fs_context *fc, char *opt, size_t len)
+{
+	struct security_mnt_opts *opts = fc->security;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int have;
+	char *c, **oo;
+	int token, ctx, i, *of;
+
+	token = match_token(opt, tokens, args);
+	if (token == Opt_error)
+		return 0; /* Doesn't belong to us. */
+
+	have = 0;
+	for (i = 0; i < opts->num_mnt_opts; i++)
+		have |= 1 << opts->mnt_opts_flags[i];
+	if (have & (1 << token))
+		return -EINVAL;
+
+	switch (token) {
+	case Opt_context:
+		if (have & (1 << Opt_defcontext))
+			goto incompatible;
+		ctx = CONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_fscontext:
+		ctx = FSCONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_rootcontext:
+		ctx = ROOTCONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_defcontext:
+		if (have & (1 << Opt_context))
+			goto incompatible;
+		ctx = DEFCONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_labelsupport:
+		return 1;
+
+	default:
+		return -EINVAL;
+	}
+
+copy_context_string:
+	if (opts->num_mnt_opts > 3)
+		return -EINVAL;
+
+	of = krealloc(opts->mnt_opts_flags,
+		      (opts->num_mnt_opts + 1) * sizeof(int), GFP_KERNEL);
+	if (!of)
+		return -ENOMEM;
+	of[opts->num_mnt_opts] = 0;
+	opts->mnt_opts_flags = of;
+
+	oo = krealloc(opts->mnt_opts,
+		      (opts->num_mnt_opts + 1) * sizeof(char *), GFP_KERNEL);
+	if (!oo)
+		return -ENOMEM;
+	oo[opts->num_mnt_opts] = NULL;
+	opts->mnt_opts = oo;
+
+	c = match_strdup(&args[0]);
+	if (!c)
+		return -ENOMEM;
+	opts->mnt_opts[opts->num_mnt_opts] = c;
+	opts->mnt_opts_flags[opts->num_mnt_opts] = ctx;
+	opts->num_mnt_opts++;
+	return 1;
+
+incompatible:
+	return -EINVAL;
+}
+
+/*
+ * Validate the security parameters supplied for a reconfiguration/remount
+ * event.
+ */
+static int selinux_validate_for_sb_reconfigure(struct fs_context *fc)
+{
+	struct super_block *sb = fc->root->d_sb;
+	struct superblock_security_struct *sbsec = sb->s_security;
+	struct security_mnt_opts *opts = fc->security;
+	int rc, i, *flags;
+	char **mount_options;
+
+	if (!(sbsec->flags & SE_SBINITIALIZED))
+		return 0;
+
+	mount_options = opts->mnt_opts;
+	flags = opts->mnt_opts_flags;
+
+	for (i = 0; i < opts->num_mnt_opts; i++) {
+		u32 sid;
+
+		if (flags[i] == SBLABEL_MNT)
+			continue;
+
+		rc = security_context_str_to_sid(&selinux_state, mount_options[i],
+						 &sid, GFP_KERNEL);
+		if (rc) {
+			pr_warn("SELinux: security_context_str_to_sid"
+				"(%s) failed for (dev %s, type %s) errno=%d\n",
+				mount_options[i], sb->s_id, sb->s_type->name, rc);
+			goto inval;
+		}
+
+		switch (flags[i]) {
+		case FSCONTEXT_MNT:
+			if (bad_option(sbsec, FSCONTEXT_MNT, sbsec->sid, sid))
+				goto bad_option;
+			break;
+		case CONTEXT_MNT:
+			if (bad_option(sbsec, CONTEXT_MNT, sbsec->mntpoint_sid, sid))
+				goto bad_option;
+			break;
+		case ROOTCONTEXT_MNT: {
+			struct inode_security_struct *root_isec;
+			root_isec = backing_inode_security(sb->s_root);
+
+			if (bad_option(sbsec, ROOTCONTEXT_MNT, root_isec->sid, sid))
+				goto bad_option;
+			break;
+		}
+		case DEFCONTEXT_MNT:
+			if (bad_option(sbsec, DEFCONTEXT_MNT, sbsec->def_sid, sid))
+				goto bad_option;
+			break;
+		default:
+			goto inval;
+		}
+	}
+
+	rc = 0;
+out:
+	return rc;
+
+bad_option:
+	pr_warn("SELinux: unable to change security options "
+		"during remount (dev %s, type=%s)\n",
+		sb->s_id, sb->s_type->name);
+inval:
+	rc = -EINVAL;
+	goto out;
+}
+
+/*
+ * Validate the security context assembled from the option data supplied to
+ * mount.
+ */
+static int selinux_fs_context_validate(struct fs_context *fc)
+{
+	if (fc->purpose == FS_CONTEXT_FOR_RECONFIGURE)
+		return selinux_validate_for_sb_reconfigure(fc);
+	return 0;
+}
+
+/*
+ * Set the security context on a superblock.
+ */
+static int selinux_sb_get_tree(struct fs_context *fc)
+{
+	const struct cred *cred = current_cred();
+	struct common_audit_data ad;
+	int rc;
+
+	rc = selinux_set_mnt_opts(fc->root->d_sb, fc->security, 0, NULL);
+	if (rc)
+		return rc;
+
+	/* Allow all mounts performed by the kernel */
+	if (fc->purpose == FS_CONTEXT_FOR_KERNEL_MOUNT)
+		return 0;
+
+	ad.type = LSM_AUDIT_DATA_DENTRY;
+	ad.u.dentry = fc->root;
+	return superblock_has_perm(cred, fc->root->d_sb, FILESYSTEM__MOUNT, &ad);
+}
+
+static int selinux_sb_mountpoint(struct fs_context *fc, struct path *mountpoint,
+				 unsigned int mnt_flags)
+{
+	const struct cred *cred = current_cred();
+
+	return path_has_perm(cred, mountpoint, FILE__MOUNTON);
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6871,6 +7125,14 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bprm_committing_creds, selinux_bprm_committing_creds),
 	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),
 
+	LSM_HOOK_INIT(fs_context_alloc, selinux_fs_context_alloc),
+	LSM_HOOK_INIT(fs_context_dup, selinux_fs_context_dup),
+	LSM_HOOK_INIT(fs_context_free, selinux_fs_context_free),
+	LSM_HOOK_INIT(fs_context_parse_option, selinux_fs_context_parse_option),
+	LSM_HOOK_INIT(fs_context_validate, selinux_fs_context_validate),
+	LSM_HOOK_INIT(sb_get_tree, selinux_sb_get_tree),
+	LSM_HOOK_INIT(sb_mountpoint, selinux_sb_mountpoint),
+
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),

