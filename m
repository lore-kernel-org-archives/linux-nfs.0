Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757305AbdEVPxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:53:05 -0400
Subject: [PATCH 08/23] VFS: Add LSM hooks for superblock configuration
 context [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:52:51 +0100
Message-ID: <149546837117.9289.16824999319457230279.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add LSM hooks for use by the superblock configuration context code.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/lsm_hooks.h |   39 ++++++++++
 include/linux/security.h  |   28 +++++++
 security/security.c       |   25 +++++++
 security/selinux/hooks.c  |  169 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 261 insertions(+)

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 080f34e66017..c2bbd9e92b0a 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -75,6 +75,34 @@
  *	should enable secure mode.
  *	@bprm contains the linux_binprm structure.
  *
+ * Security hooks for mount using fd context.
+ *
+ * @sb_config_alloc:
+ *	Allocate and attach a security structure to sc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@sc indicates the new superblock configuration context.
+ *	@src_sb indicates the source superblock of a submount.
+ * @sb_config_dup:
+ *	Allocate and attach a security structure to sc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@sc indicates the new superblock configuration context.
+ *	@src_sc indicates the original superblock configuration context.
+ * @sb_config_free:
+ *	Clean up a superblock configuration context.
+ *	@sc indicates the superblock configuration context.
+ * @sb_config_parse_option:
+ *	Userspace provided an option to configure a superblock.  The LSM may
+ *	reject it with an error and may use it for itself, in which case it
+ *	should return 1; otherwise it should return 0 to pass it on to the
+ *	filesystem.
+ *	@sc indicates the superblock configuration context.
+ *	@p indicates the option in "key[=val]" form.
+ * @sb_get_tree:
+ *	Assign the security to a newly created superblock.
+ *	@sc indicates the superblock configuration context.
+ *	@sc->root indicates the root that will be mounted.
+ *	@sc->root->d_sb points to the superblock.
+ *
  * Security hooks for filesystem operations.
  *
  * @sb_alloc_security:
@@ -1372,6 +1400,12 @@ union security_list_options {
 	void (*bprm_committing_creds)(struct linux_binprm *bprm);
 	void (*bprm_committed_creds)(struct linux_binprm *bprm);
 
+	int (*sb_config_alloc)(struct sb_config *sc, struct super_block *src_sb);
+	int (*sb_config_dup)(struct sb_config *sc, struct sb_config *src_sc);
+	void (*sb_config_free)(struct sb_config *sc);
+	int (*sb_config_parse_option)(struct sb_config *sc, char *opt);
+	int (*sb_get_tree)(struct sb_config *sc);
+
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
@@ -1683,6 +1717,11 @@ struct security_hook_heads {
 	struct list_head bprm_secureexec;
 	struct list_head bprm_committing_creds;
 	struct list_head bprm_committed_creds;
+	struct list_head sb_config_alloc;
+	struct list_head sb_config_dup;
+	struct list_head sb_config_free;
+	struct list_head sb_config_parse_option;
+	struct list_head sb_get_tree;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
diff --git a/include/linux/security.h b/include/linux/security.h
index af675b576645..d1dfb6abd4f7 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -55,6 +55,7 @@ struct msg_queue;
 struct xattr;
 struct xfrm_sec_ctx;
 struct mm_struct;
+struct sb_config;
 
 /* If capable should audit the security request */
 #define SECURITY_CAP_NOAUDIT 0
@@ -224,6 +225,11 @@ int security_bprm_check(struct linux_binprm *bprm);
 void security_bprm_committing_creds(struct linux_binprm *bprm);
 void security_bprm_committed_creds(struct linux_binprm *bprm);
 int security_bprm_secureexec(struct linux_binprm *bprm);
+int security_sb_config_alloc(struct sb_config *sc, struct super_block *sb);
+int security_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc);
+void security_sb_config_free(struct sb_config *sc);
+int security_sb_config_parse_option(struct sb_config *sc, char *opt);
+int security_sb_get_tree(struct sb_config *sc);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -520,6 +526,28 @@ static inline int security_bprm_secureexec(struct linux_binprm *bprm)
 	return cap_bprm_secureexec(bprm);
 }
 
+static inline int security_sb_config_alloc(struct sb_config *sc,
+					   struct super_block *src_sb)
+{
+	return 0;
+}
+static inline int security_sb_config_dup(struct sb_config *sc,
+					 struct sb_config *src_sc)
+{
+	return 0;
+}
+static inline void security_sb_config_free(struct sb_config *sc)
+{
+}
+static inline int security_sb_config_parse_option(struct sb_config *sc, char *opt)
+{
+	return 0;
+}
+static inline int security_sb_get_tree(struct sb_config *sc)
+{
+	return 0;
+}
+
 static inline int security_sb_alloc(struct super_block *sb)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index b9fea3999cf8..951f28487719 100644
--- a/security/security.c
+++ b/security/security.c
@@ -316,6 +316,31 @@ int security_bprm_secureexec(struct linux_binprm *bprm)
 	return call_int_hook(bprm_secureexec, 0, bprm);
 }
 
+int security_sb_config_alloc(struct sb_config *sc, struct super_block *src_sb)
+{
+	return call_int_hook(sb_config_alloc, 0, sc, src_sb);
+}
+
+int security_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc)
+{
+	return call_int_hook(sb_config_dup, 0, sc, src_sc);
+}
+
+void security_sb_config_free(struct sb_config *sc)
+{
+	call_void_hook(sb_config_free, sc);
+}
+
+int security_sb_config_parse_option(struct sb_config *sc, char *opt)
+{
+	return call_int_hook(sb_config_parse_option, 0, sc, opt);
+}
+
+int security_sb_get_tree(struct sb_config *sc)
+{
+	return call_int_hook(sb_get_tree, 0, sc);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e67a526d1f30..420bfa955fb4 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -47,6 +47,7 @@
 #include <linux/fdtable.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/sb_config.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/tty.h>
@@ -2826,6 +2827,168 @@ static int selinux_umount(struct vfsmount *mnt, int flags)
 				   FILESYSTEM__UNMOUNT, NULL);
 }
 
+/* fsopen mount context operations */
+
+static int selinux_sb_config_alloc(struct sb_config *sc,
+				   struct super_block *src_sb)
+{
+	struct security_mnt_opts *opts;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+
+	sc->security = opts;
+	return 0;
+}
+
+static int selinux_sb_config_dup(struct sb_config *sc,
+				 struct sb_config *src_sc)
+{
+	const struct security_mnt_opts *src = src_sc->security;
+	struct security_mnt_opts *opts;
+	int i, n;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+	sc->security = opts;
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
+static void selinux_sb_config_free(struct sb_config *sc)
+{
+	struct security_mnt_opts *opts = sc->security;
+
+	security_free_mnt_opts(opts);
+	sc->security = NULL;
+}
+
+static int selinux_sb_config_parse_option(struct sb_config *sc, char *opt)
+{
+	struct security_mnt_opts *opts = sc->security;
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
+static int selinux_sb_get_tree(struct sb_config *sc)
+{
+	const struct cred *cred = current_cred();
+	struct common_audit_data ad;
+	int rc;
+
+	rc = selinux_set_mnt_opts(sc->root->d_sb, sc->security, 0, NULL);
+	if (rc)
+		return rc;
+
+	/* Allow all mounts performed by the kernel */
+	if (sc->ms_flags & MS_KERNMOUNT)
+		return 0;
+
+	ad.type = LSM_AUDIT_DATA_DENTRY;
+	ad.u.dentry = sc->root;
+	rc = superblock_has_perm(cred, sc->root->d_sb, FILESYSTEM__MOUNT, &ad);
+	if (rc < 0)
+		errorf("SELinux: Mount of superblock not permitted");
+	return rc;
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6154,6 +6317,12 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),
 	LSM_HOOK_INIT(bprm_secureexec, selinux_bprm_secureexec),
 
+	LSM_HOOK_INIT(sb_config_alloc, selinux_sb_config_alloc),
+	LSM_HOOK_INIT(sb_config_dup, selinux_sb_config_dup),
+	LSM_HOOK_INIT(sb_config_free, selinux_sb_config_free),
+	LSM_HOOK_INIT(sb_config_parse_option, selinux_sb_config_parse_option),
+	LSM_HOOK_INIT(sb_get_tree, selinux_sb_get_tree),
+
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),

