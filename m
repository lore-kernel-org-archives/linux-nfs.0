Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60344 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752586AbdFNPRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:17:46 -0400
Subject: [PATCH 16/27] proc: Add fs_context support to procfs [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:17:43 +0100
Message-ID: <149745346349.10897.1390410969617844911.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add fs_context support to procfs.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/proc/inode.c    |    2 -
 fs/proc/internal.h |    2 -
 fs/proc/root.c     |  175 ++++++++++++++++++++++++++++++++++------------------
 3 files changed, 116 insertions(+), 63 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index a4bf66af0ba9..a642bee67a53 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -118,7 +118,7 @@ const struct super_operations proc_sops = {
 	.drop_inode	= generic_delete_inode,
 	.evict_inode	= proc_evict_inode,
 	.statfs		= simple_statfs,
-	.remount_fs	= proc_remount,
+	.remount_fs_fc	= proc_remount,
 	.show_options	= proc_show_options,
 };
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index b681533f59dd..78d1e4ff5f76 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -262,7 +262,7 @@ static inline void proc_tty_init(void) {}
 extern struct proc_dir_entry proc_root;
 
 extern void proc_self_init(void);
-extern int proc_remount(struct super_block *, int *, char *);
+extern int proc_remount(struct super_block *, struct fs_context *);
 
 /*
  * task_[no]mmu.c
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 3dd3838d9e08..22d8e8f20c38 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -18,14 +18,23 @@
 #include <linux/module.h>
 #include <linux/bitops.h>
 #include <linux/user_namespace.h>
-#include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/pid_namespace.h>
 #include <linux/parser.h>
 #include <linux/cred.h>
 #include <linux/magic.h>
+#include <linux/slab.h>
 
 #include "internal.h"
 
+struct proc_fs_context {
+	struct fs_context	fc;
+	struct pid_namespace	*pid_ns;
+	unsigned long		mask;
+	int			hidepid;
+	int			gid;
+};
+
 enum {
 	Opt_gid, Opt_hidepid, Opt_err,
 };
@@ -36,56 +45,60 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-static int proc_parse_options(char *options, struct pid_namespace *pid)
+static int proc_parse_mount_option(struct fs_context *fc, char *p)
 {
-	char *p;
+	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
 	substring_t args[MAX_OPT_ARGS];
-	int option;
-
-	if (!options)
-		return 1;
-
-	while ((p = strsep(&options, ",")) != NULL) {
-		int token;
-		if (!*p)
-			continue;
-
-		args[0].to = args[0].from = NULL;
-		token = match_token(p, tokens, args);
-		switch (token) {
-		case Opt_gid:
-			if (match_int(&args[0], &option))
-				return 0;
-			pid->pid_gid = make_kgid(current_user_ns(), option);
-			break;
-		case Opt_hidepid:
-			if (match_int(&args[0], &option))
-				return 0;
-			if (option < HIDEPID_OFF ||
-			    option > HIDEPID_INVISIBLE) {
-				pr_err("proc: hidepid value must be between 0 and 2.\n");
-				return 0;
-			}
-			pid->hide_pid = option;
-			break;
-		default:
-			pr_err("proc: unrecognized mount option \"%s\" "
-			       "or missing value\n", p);
-			return 0;
+	int token;
+
+	args[0].to = args[0].from = NULL;
+	token = match_token(p, tokens, args);
+	switch (token) {
+	case Opt_gid:
+		if (match_int(&args[0], &ctx->gid))
+			return invalf("procfs: Unparseable gid= argument");
+		break;
+
+	case Opt_hidepid:
+		if (match_int(&args[0], &ctx->hidepid))
+			return invalf("procfs: Unparseable hidepid= argument");
+		if (ctx->hidepid < HIDEPID_OFF ||
+		    ctx->hidepid > HIDEPID_INVISIBLE) {
+			pr_err("proc: hidepid value must be between 0 and 2.\n");
+			return invalf("procfs: Invalid hidepid= argument");
 		}
+		break;
+
+	default:
+		pr_err("proc: unrecognized mount option \"%s\" "
+		       "or missing value\n", p);
+		return invalf("procfs: Invalid mount option or missing value");
 	}
 
-	return 1;
+	ctx->mask |= 1 << token;
+	return 0;
+}
+
+static void proc_set_options(struct super_block *s,
+			     struct fs_context *fc,
+			     struct pid_namespace *pid_ns,
+			     struct user_namespace *user_ns)
+{
+	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
+
+	if (ctx->mask & (1 << Opt_gid))
+		pid_ns->pid_gid = make_kgid(user_ns, ctx->gid);
+	if (ctx->mask & (1 << Opt_hidepid))
+		pid_ns->hide_pid = ctx->hidepid;
 }
 
-static int proc_fill_super(struct super_block *s, void *data, int silent)
+static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 {
-	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
+	struct pid_namespace *pid_ns = get_pid_ns(s->s_fs_info);
 	struct inode *root_inode;
 	int ret;
 
-	if (!proc_parse_options(data, ns))
-		return -EINVAL;
+	proc_set_options(s, fc, pid_ns, current_user_ns());
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
@@ -102,7 +115,7 @@ static int proc_fill_super(struct super_block *s, void *data, int silent)
 	 * top of it
 	 */
 	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
-	
+
 	pde_get(&proc_root);
 	root_inode = proc_get_inode(s, &proc_root);
 	if (!root_inode) {
@@ -123,27 +136,45 @@ static int proc_fill_super(struct super_block *s, void *data, int silent)
 	return proc_setup_thread_self(s);
 }
 
-int proc_remount(struct super_block *sb, int *flags, char *data)
+int proc_remount(struct super_block *sb, struct fs_context *fc)
 {
 	struct pid_namespace *pid = sb->s_fs_info;
 
 	sync_filesystem(sb);
-	return !proc_parse_options(data, pid);
+
+	if (fc)
+		proc_set_options(sb, fc, pid, current_user_ns());
+	return 0;
 }
 
-static struct dentry *proc_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static int proc_get_tree(struct fs_context *fc)
 {
-	struct pid_namespace *ns;
+	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
 
-	if (flags & SB_KERNMOUNT) {
-		ns = data;
-		data = NULL;
-	} else {
-		ns = task_active_pid_ns(current);
-	}
+	return mount_ns_fc(fc, proc_fill_super, ctx->pid_ns);
+}
+
+static void proc_fs_context_free(struct fs_context *fc)
+{
+	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
 
-	return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super);
+	if (ctx->pid_ns)
+		put_pid_ns(ctx->pid_ns);
+}
+
+static const struct fs_context_operations proc_fs_context_ops = {
+	.free		= proc_fs_context_free,
+	.parse_option	= proc_parse_mount_option,
+	.get_tree	= proc_get_tree,
+};
+
+static int proc_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct proc_fs_context *ctx = container_of(fc, struct proc_fs_context, fc);
+
+	ctx->pid_ns = get_pid_ns(task_active_pid_ns(current));
+	ctx->fc.ops = &proc_fs_context_ops;
+	return 0;
 }
 
 static void proc_kill_sb(struct super_block *sb)
@@ -161,7 +192,8 @@ static void proc_kill_sb(struct super_block *sb)
 
 static struct file_system_type proc_fs_type = {
 	.name		= "proc",
-	.mount		= proc_mount,
+	.fs_context_size	= sizeof(struct proc_fs_context),
+	.init_fs_context	= proc_init_fs_context,
 	.kill_sb	= proc_kill_sb,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
@@ -209,7 +241,7 @@ static struct dentry *proc_root_lookup(struct inode * dir, struct dentry * dentr
 {
 	if (!proc_pid_lookup(dir, dentry, flags))
 		return NULL;
-	
+
 	return proc_lookup(dir, dentry, flags);
 }
 
@@ -248,12 +280,12 @@ static const struct inode_operations proc_root_inode_operations = {
  * This is the root "inode" in the /proc tree..
  */
 struct proc_dir_entry proc_root = {
-	.low_ino	= PROC_ROOT_INO, 
-	.namelen	= 5, 
-	.mode		= S_IFDIR | S_IRUGO | S_IXUGO, 
-	.nlink		= 2, 
+	.low_ino	= PROC_ROOT_INO,
+	.namelen	= 5,
+	.mode		= S_IFDIR | S_IRUGO | S_IXUGO,
+	.nlink		= 2,
 	.count		= ATOMIC_INIT(1),
-	.proc_iops	= &proc_root_inode_operations, 
+	.proc_iops	= &proc_root_inode_operations,
 	.proc_fops	= &proc_root_operations,
 	.parent		= &proc_root,
 	.subdir		= RB_ROOT,
@@ -262,9 +294,30 @@ struct proc_dir_entry proc_root = {
 
 int pid_ns_prepare_proc(struct pid_namespace *ns)
 {
+	struct proc_fs_context *ctx;
+	struct fs_context *fc;
 	struct vfsmount *mnt;
+	int ret;
+
+	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0, FS_CONTEXT_FOR_NEW);
+	if (IS_ERR(fc))
+		return PTR_ERR(fc);
+
+	ctx = container_of(fc, struct proc_fs_context, fc);
+	if (ctx->pid_ns != ns) {
+		put_pid_ns(ctx->pid_ns);
+		get_pid_ns(ns);
+		ctx->pid_ns = ns;
+	}
+
+	ret = vfs_get_tree(fc);
+	if (ret < 0) {
+		put_fs_context(fc);
+		return ret;
+	}
 
-	mnt = kern_mount_data(&proc_fs_type, ns);
+	mnt = kern_mount_data_fc(fc);
+	put_fs_context(fc);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 

