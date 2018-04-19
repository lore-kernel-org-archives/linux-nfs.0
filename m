Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43394 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753015AbeDSNbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:31:53 -0400
Subject: [PATCH 07/24] smack: Implement filesystem context security hooks
 [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>,
        linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:31:51 +0100
Message-ID: <152414471151.23902.13878490698594523635.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement filesystem context security hooks for the smack LSM.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Casey Schaufler <casey@schaufler-ca.com>
cc: linux-security-module@vger.kernel.org
---

 security/smack/smack_lsm.c |  309 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 309 insertions(+)

diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 0b414836bebd..549aaa46353b 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -42,6 +42,7 @@
 #include <linux/shm.h>
 #include <linux/binfmts.h>
 #include <linux/parser.h>
+#include <linux/fs_context.h>
 #include "smack.h"
 
 #define TRANS_TRUE	"TRUE"
@@ -521,6 +522,307 @@ static int smack_syslog(int typefrom_file)
 	return rc;
 }
 
+/*
+ * Mount context operations
+ */
+
+struct smack_fs_context {
+	union {
+		struct {
+			char		*fsdefault;
+			char		*fsfloor;
+			char		*fshat;
+			char		*fsroot;
+			char		*fstransmute;
+		};
+		char			*ptrs[5];
+
+	};
+	struct superblock_smack		*sbsp;
+	struct inode_smack		*isp;
+	bool				transmute;
+};
+
+/**
+ * smack_fs_context_free - Free the security data from a filesystem context
+ * @fc: The filesystem context to be cleaned up.
+ */
+static void smack_fs_context_free(struct fs_context *fc)
+{
+	struct smack_fs_context *ctx = fc->security;
+	int i;
+
+	if (ctx) {
+		for (i = 0; i < ARRAY_SIZE(ctx->ptrs); i++)
+			kfree(ctx->ptrs[i]);
+		kfree(ctx->isp);
+		kfree(ctx->sbsp);
+		kfree(ctx);
+		fc->security = NULL;
+	}
+}
+
+/**
+ * smack_fs_context_alloc - Allocate security data for a filesystem context
+ * @fc: The filesystem context.
+ * @src_sb: Reference superblock (automount/reconfigure) or NULL
+ *
+ * Returns 0 on success or -ENOMEM on error.
+ */
+static int smack_fs_context_alloc(struct fs_context *fc,
+				  struct super_block *src_sb)
+{
+	struct smack_fs_context *ctx;
+	struct superblock_smack *sbsp;
+	struct inode_smack *isp;
+	struct smack_known *skp;
+
+	ctx = kzalloc(sizeof(struct smack_fs_context), GFP_KERNEL);
+	if (!ctx)
+		goto nomem;
+	fc->security = ctx;
+
+	sbsp = kzalloc(sizeof(struct superblock_smack), GFP_KERNEL);
+	if (!sbsp)
+		goto nomem_free;
+	ctx->sbsp = sbsp;
+
+	isp = new_inode_smack(NULL);
+	if (!isp)
+		goto nomem_free;
+	ctx->isp = isp;
+
+	if (src_sb) {
+		if (src_sb->s_security)
+			memcpy(sbsp, src_sb->s_security, sizeof(*sbsp));
+	} else if (!smack_privileged(CAP_MAC_ADMIN)) {
+		/* Unprivileged mounts get root and default from the caller. */
+		skp = smk_of_current();
+		sbsp->smk_root = skp;
+		sbsp->smk_default = skp;
+	} else {
+		sbsp->smk_root = &smack_known_floor;
+		sbsp->smk_default = &smack_known_floor;
+		sbsp->smk_floor = &smack_known_floor;
+		sbsp->smk_hat = &smack_known_hat;
+		/* SMK_SB_INITIALIZED will be zero from kzalloc. */
+	}
+
+	return 0;
+
+nomem_free:
+	smack_fs_context_free(fc);
+nomem:
+	return -ENOMEM;
+}
+
+/**
+ * smack_fs_context_dup - Duplicate the security data on fs_context duplication
+ * @fc: The new filesystem context.
+ * @src_fc: The source filesystem context being duplicated.
+ *
+ * Returns 0 on success or -ENOMEM on error.
+ */
+static int smack_fs_context_dup(struct fs_context *fc,
+				struct fs_context *src_fc)
+{
+	struct smack_fs_context *dst, *src = src_fc->security;
+	int i;
+
+	dst = kzalloc(sizeof(struct smack_fs_context), GFP_KERNEL);
+	if (!dst)
+		goto nomem;
+	fc->security = dst;
+
+	dst->sbsp = kmemdup(src->sbsp, sizeof(struct superblock_smack),
+			    GFP_KERNEL);
+	if (!dst->sbsp)
+		goto nomem_free;
+
+	for (i = 0; i < ARRAY_SIZE(dst->ptrs); i++) {
+		if (src->ptrs[i]) {
+			dst->ptrs[i] = kstrdup(src->ptrs[i], GFP_KERNEL);
+			if (!dst->ptrs[i])
+				goto nomem_free;
+		}
+	}
+
+	return 0;
+
+nomem_free:
+	smack_fs_context_free(fc);
+nomem:
+	return -ENOMEM;
+}
+
+/**
+ * smack_fs_context_parse_option - Parse a single mount option
+ * @fc: The new filesystem context being constructed.
+ * @opt: The option text buffer.
+ * @len: The length of the text.
+ *
+ * Returns 0 on success or -ENOMEM on error.
+ */
+static int smack_fs_context_parse_option(struct fs_context *fc, char *p, size_t len)
+{
+	struct smack_fs_context *ctx = fc->security;
+	substring_t args[MAX_OPT_ARGS];
+	int rc = -ENOMEM;
+	int token;
+
+	/* Unprivileged mounts don't get to specify Smack values. */
+	if (!smack_privileged(CAP_MAC_ADMIN))
+		return -EPERM;
+
+	token = match_token(p, smk_mount_tokens, args);
+	switch (token) {
+	case Opt_fsdefault:
+		if (ctx->fsdefault)
+			goto error_dup;
+		ctx->fsdefault = match_strdup(&args[0]);
+		if (!ctx->fsdefault)
+			goto error;
+		break;
+	case Opt_fsfloor:
+		if (ctx->fsfloor)
+			goto error_dup;
+		ctx->fsfloor = match_strdup(&args[0]);
+		if (!ctx->fsfloor)
+			goto error;
+		break;
+	case Opt_fshat:
+		if (ctx->fshat)
+			goto error_dup;
+		ctx->fshat = match_strdup(&args[0]);
+		if (!ctx->fshat)
+			goto error;
+		break;
+	case Opt_fsroot:
+		if (ctx->fsroot)
+			goto error_dup;
+		ctx->fsroot = match_strdup(&args[0]);
+		if (!ctx->fsroot)
+			goto error;
+		break;
+	case Opt_fstransmute:
+		if (ctx->fstransmute)
+			goto error_dup;
+		ctx->fstransmute = match_strdup(&args[0]);
+		if (!ctx->fstransmute)
+			goto error;
+		break;
+	default:
+		pr_warn("Smack:  unknown mount option\n");
+		goto error_inval;
+	}
+
+	return 0;
+
+error_dup:
+	pr_warn("Smack: duplicate mount option\n");
+error_inval:
+	rc = -EINVAL;
+error:
+	return rc;
+}
+
+/**
+ * smack_fs_context_validate - Validate the filesystem context security data
+ * @fc: The filesystem context.
+ *
+ * Returns 0 on success or -ENOMEM on error.
+ */
+static int smack_fs_context_validate(struct fs_context *fc)
+{
+	struct smack_fs_context *ctx = fc->security;
+	struct superblock_smack *sbsp = ctx->sbsp;
+	struct inode_smack *isp = ctx->isp;
+	struct smack_known *skp;
+
+	if (ctx->fsdefault) {
+		skp = smk_import_entry(ctx->fsdefault, 0);
+		if (IS_ERR(skp))
+			return PTR_ERR(skp);
+		sbsp->smk_default = skp;
+	}
+
+	if (ctx->fsfloor) {
+		skp = smk_import_entry(ctx->fsfloor, 0);
+		if (IS_ERR(skp))
+			return PTR_ERR(skp);
+		sbsp->smk_floor = skp;
+	}
+
+	if (ctx->fshat) {
+		skp = smk_import_entry(ctx->fshat, 0);
+		if (IS_ERR(skp))
+			return PTR_ERR(skp);
+		sbsp->smk_hat = skp;
+	}
+
+	if (ctx->fsroot || ctx->fstransmute) {
+		skp = smk_import_entry(ctx->fstransmute ?: ctx->fsroot, 0);
+		if (IS_ERR(skp))
+			return PTR_ERR(skp);
+		sbsp->smk_root = skp;
+		ctx->transmute = !!ctx->fstransmute;
+	}
+
+	isp->smk_inode = sbsp->smk_root;
+	return 0;
+}
+
+/**
+ * smack_sb_get_tree - Assign the context to a newly created superblock
+ * @fc: The new filesystem context.
+ *
+ * Returns 0 on success or -ENOMEM on error.
+ */
+static int smack_sb_get_tree(struct fs_context *fc)
+{
+	struct smack_fs_context *ctx = fc->security;
+	struct superblock_smack *sbsp = ctx->sbsp;
+	struct dentry *root = fc->root;
+	struct inode *inode = d_backing_inode(root);
+	struct super_block *sb = root->d_sb;
+	struct inode_smack *isp;
+	bool transmute = ctx->transmute;
+
+	if (sb->s_security)
+		return 0;
+
+	if (!smack_privileged(CAP_MAC_ADMIN)) {
+		/*
+		 * For a handful of fs types with no user-controlled
+		 * backing store it's okay to trust security labels
+		 * in the filesystem. The rest are untrusted.
+		 */
+		if (fc->user_ns != &init_user_ns &&
+		    sb->s_magic != SYSFS_MAGIC && sb->s_magic != TMPFS_MAGIC &&
+		    sb->s_magic != RAMFS_MAGIC) {
+			transmute = true;
+			sbsp->smk_flags |= SMK_SB_UNTRUSTED;
+		}
+	}
+
+	sbsp->smk_flags |= SMK_SB_INITIALIZED;
+	sb->s_security = sbsp;
+	ctx->sbsp = NULL;
+
+	/* Initialize the root inode. */
+	isp = inode->i_security;
+	if (isp == NULL) {
+		isp = ctx->isp;
+		ctx->isp = NULL;
+		inode->i_security = isp;
+	} else
+		isp->smk_inode = sbsp->smk_root;
+
+	if (transmute)
+		isp->smk_flags |= SMK_INODE_TRANSMUTE;
+
+	return 0;
+}
 
 /*
  * Superblock Hooks.
@@ -4628,6 +4930,13 @@ static struct security_hook_list smack_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(ptrace_traceme, smack_ptrace_traceme),
 	LSM_HOOK_INIT(syslog, smack_syslog),
 
+	LSM_HOOK_INIT(fs_context_alloc, smack_fs_context_alloc),
+	LSM_HOOK_INIT(fs_context_dup, smack_fs_context_dup),
+	LSM_HOOK_INIT(fs_context_free, smack_fs_context_free),
+	LSM_HOOK_INIT(fs_context_parse_option, smack_fs_context_parse_option),
+	LSM_HOOK_INIT(fs_context_validate, smack_fs_context_validate),
+	LSM_HOOK_INIT(sb_get_tree, smack_sb_get_tree),
+
 	LSM_HOOK_INIT(sb_alloc_security, smack_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, smack_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, smack_sb_copy_data),

