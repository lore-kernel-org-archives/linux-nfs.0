Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57450 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751980AbdFNPQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:16:50 -0400
Subject: [PATCH 09/27] VFS: Add LSM hooks for filesystem context [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:16:42 +0100
Message-ID: <149745340266.10897.16483928330820234773.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
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

 include/linux/lsm_hooks.h |   45 +++++++++++
 include/linux/security.h  |   33 ++++++++
 security/security.c       |   30 +++++++
 security/selinux/hooks.c  |  181 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 289 insertions(+)

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 080f34e66017..62500658cc9f 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -75,6 +75,38 @@
  *	should enable secure mode.
  *	@bprm contains the linux_binprm structure.
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
+ *	@p indicates the option in "key[=val]" form.
+ * @sb_get_tree:
+ *	Assign the security to a newly created superblock.
+ *	@fc indicates the filesystem context.
+ *	@fc->root indicates the root that will be mounted.
+ *	@fc->root->d_sb points to the superblock.
+ * @sb_mountpoint:
+ *	Equivalent of sb_mount, but with an fs_context.
+ *	@fc indicates the filesystem context.
+ *	@mountpoint indicates the path on which the mount will take place.
+ *
  * Security hooks for filesystem operations.
  *
  * @sb_alloc_security:
@@ -1372,6 +1404,13 @@ union security_list_options {
 	void (*bprm_committing_creds)(struct linux_binprm *bprm);
 	void (*bprm_committed_creds)(struct linux_binprm *bprm);
 
+	int (*fs_context_alloc)(struct fs_context *fc, struct super_block *src_sb);
+	int (*fs_context_dup)(struct fs_context *fc, struct fs_context *src_sc);
+	void (*fs_context_free)(struct fs_context *fc);
+	int (*fs_context_parse_option)(struct fs_context *fc, char *opt);
+	int (*sb_get_tree)(struct fs_context *fc);
+	int (*sb_mountpoint)(struct fs_context *fc, struct path *mountpoint);
+
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
@@ -1683,6 +1722,12 @@ struct security_hook_heads {
 	struct list_head bprm_secureexec;
 	struct list_head bprm_committing_creds;
 	struct list_head bprm_committed_creds;
+	struct list_head fs_context_alloc;
+	struct list_head fs_context_dup;
+	struct list_head fs_context_free;
+	struct list_head fs_context_parse_option;
+	struct list_head sb_get_tree;
+	struct list_head sb_mountpoint;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
diff --git a/include/linux/security.h b/include/linux/security.h
index af675b576645..e7c774fdffd9 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -55,6 +55,7 @@ struct msg_queue;
 struct xattr;
 struct xfrm_sec_ctx;
 struct mm_struct;
+struct fs_context;
 
 /* If capable should audit the security request */
 #define SECURITY_CAP_NOAUDIT 0
@@ -224,6 +225,12 @@ int security_bprm_check(struct linux_binprm *bprm);
 void security_bprm_committing_creds(struct linux_binprm *bprm);
 void security_bprm_committed_creds(struct linux_binprm *bprm);
 int security_bprm_secureexec(struct linux_binprm *bprm);
+int security_fs_context_alloc(struct fs_context *fc, struct super_block *sb);
+int security_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc);
+void security_fs_context_free(struct fs_context *fc);
+int security_fs_context_parse_option(struct fs_context *fc, char *opt);
+int security_sb_get_tree(struct fs_context *fc);
+int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -520,6 +527,32 @@ static inline int security_bprm_secureexec(struct linux_binprm *bprm)
 	return cap_bprm_secureexec(bprm);
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
+static inline int security_fs_context_parse_option(struct fs_context *fc, char *opt)
+{
+	return 0;
+}
+static inline int security_sb_get_tree(struct fs_context *fc)
+{
+	return 0;
+}
+static inline int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)
+{
+	return 0;
+}
+
 static inline int security_sb_alloc(struct super_block *sb)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index b9fea3999cf8..27b195966cad 100644
--- a/security/security.c
+++ b/security/security.c
@@ -316,6 +316,36 @@ int security_bprm_secureexec(struct linux_binprm *bprm)
 	return call_int_hook(bprm_secureexec, 0, bprm);
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
+int security_fs_context_parse_option(struct fs_context *fc, char *opt)
+{
+	return call_int_hook(fs_context_parse_option, 0, fc, opt);
+}
+
+int security_sb_get_tree(struct fs_context *fc)
+{
+	return call_int_hook(sb_get_tree, 0, fc);
+}
+
+int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)
+{
+	return call_int_hook(sb_mountpoint, 0, fc, mountpoint);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 7e498b16aed3..c93a21119fe3 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -47,6 +47,7 @@
 #include <linux/fdtable.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/tty.h>
@@ -2826,6 +2827,179 @@ static int selinux_umount(struct vfsmount *mnt, int flags)
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
+static int selinux_fs_context_parse_option(struct fs_context *fc, char *opt)
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
+		return invalf("SELinux: Duplicate mount options");
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
+		return invalf("SELinux: Unknown mount option");
+	}
+
+copy_context_string:
+	if (opts->num_mnt_opts > 3)
+		return invalf("SELinux: Too many options");
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
+	return invalf("SELinux: Incompatible mount options");
+}
+
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
+	if (fc->sb_flags & MS_KERNMOUNT)
+		return 0;
+
+	ad.type = LSM_AUDIT_DATA_DENTRY;
+	ad.u.dentry = fc->root;
+	rc = superblock_has_perm(cred, fc->root->d_sb, FILESYSTEM__MOUNT, &ad);
+	if (rc < 0)
+		errorf("SELinux: Mount of superblock not permitted");
+	return rc;
+}
+
+static int selinux_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)
+{
+	const struct cred *cred = current_cred();
+	int ret;
+
+	ret = path_has_perm(cred, mountpoint, FILE__MOUNTON);
+	if (ret < 0)
+		errorf("SELinux: Mount on mountpoint not permitted");
+	return ret;
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6154,6 +6328,13 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),
 	LSM_HOOK_INIT(bprm_secureexec, selinux_bprm_secureexec),
 
+	LSM_HOOK_INIT(fs_context_alloc, selinux_fs_context_alloc),
+	LSM_HOOK_INIT(fs_context_dup, selinux_fs_context_dup),
+	LSM_HOOK_INIT(fs_context_free, selinux_fs_context_free),
+	LSM_HOOK_INIT(fs_context_parse_option, selinux_fs_context_parse_option),
+	LSM_HOOK_INIT(sb_get_tree, selinux_sb_get_tree),
+	LSM_HOOK_INIT(sb_mountpoint, selinux_sb_mountpoint),
+
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),

