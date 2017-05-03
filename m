Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753312AbdECQFp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 12:05:45 -0400
Subject: [PATCH 8/9] proc: Support the mount context in procfs
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, dhowells@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Wed, 03 May 2017 17:05:38 +0100
Message-ID: <149382753822.30481.10825924363079302327.stgit@warthog.procyon.org.uk>
In-Reply-To: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---

 fs/proc/inode.c    |    2 -
 fs/proc/internal.h |    2 -
 fs/proc/root.c     |  158 ++++++++++++++++++++++++++++++++--------------------
 3 files changed, 100 insertions(+), 62 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 194fa2d13b7e..9ddaf60c6f93 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -118,7 +118,7 @@ const struct super_operations proc_sops = {
 	.drop_inode	= generic_delete_inode,
 	.evict_inode	= proc_evict_inode,
 	.statfs		= simple_statfs,
-	.remount_fs	= proc_remount,
+	.remount_fs_mc	= proc_remount,
 	.show_options	= proc_show_options,
 };
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index b681533f59dd..68b693478e7e 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -262,7 +262,7 @@ static inline void proc_tty_init(void) {}
 extern struct proc_dir_entry proc_root;
 
 extern void proc_self_init(void);
-extern int proc_remount(struct super_block *, int *, char *);
+extern int proc_remount(struct super_block *, struct mount_context *);
 
 /*
  * task_[no]mmu.c
diff --git a/fs/proc/root.c b/fs/proc/root.c
index ff2e810e9e64..132529a5e896 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -23,9 +23,17 @@
 #include <linux/parser.h>
 #include <linux/cred.h>
 #include <linux/magic.h>
+#include <linux/slab.h>
 
 #include "internal.h"
 
+struct proc_mount_context {
+	struct mount_context	mc;
+	unsigned long		mask;
+	int			hidepid;
+	int			gid;
+};
+
 enum {
 	Opt_gid, Opt_hidepid, Opt_err,
 };
@@ -36,56 +44,68 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-static int proc_parse_options(char *options, struct pid_namespace *pid)
+static int proc_mount_option(struct mount_context *mc, char *p)
 {
-	char *p;
+	struct proc_mount_context *ctx =
+		container_of(mc, struct proc_mount_context, mc);
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
+		if (match_int(&args[0], &ctx->gid)) {
+			mc->error = "procfs: Unparseable gid= argument";
+			return -EINVAL;
+		}
+		break;
+
+	case Opt_hidepid:
+		if (match_int(&args[0], &ctx->hidepid)) {
+			mc->error = "procfs: Unparseable hidepid= argument";
+			return -EINVAL;
 		}
+		if (ctx->hidepid < HIDEPID_OFF ||
+		    ctx->hidepid > HIDEPID_INVISIBLE) {
+			mc->error = "procfs: Invalid hidepid= argument";
+			pr_err("proc: hidepid value must be between 0 and 2.\n");
+			return -EINVAL;
+		}
+		break;
+
+	default:
+		pr_err("proc: unrecognized mount option \"%s\" "
+		       "or missing value\n", p);
+		mc->error = "procfs: Invalid mount option or missing value";
+		return -EINVAL;
 	}
 
-	return 1;
+	ctx->mask |= 1 << token;
+	return 0;
 }
 
-static int proc_fill_super(struct super_block *s, void *data, int silent)
+static void proc_set_options(struct super_block *s,
+			     struct mount_context *mc,
+			     struct pid_namespace *pid_ns,
+			     struct user_namespace *user_ns)
 {
-	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
+	struct proc_mount_context *ctx =
+		container_of(mc, struct proc_mount_context, mc);
+
+	if (ctx->mask & (1 << Opt_gid))
+		pid_ns->pid_gid = make_kgid(user_ns, ctx->gid);
+	if (ctx->mask & (1 << Opt_hidepid))
+		pid_ns->hide_pid = ctx->hidepid;
+}
+
+static int proc_fill_super(struct super_block *s, struct mount_context *mc)
+{
+	struct pid_namespace *pid_ns = get_pid_ns(s->s_fs_info);
 	struct inode *root_inode;
 	int ret;
 
-	if (!proc_parse_options(data, ns))
-		return -EINVAL;
+	proc_set_options(s, mc, pid_ns, current_user_ns());
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
@@ -102,7 +122,7 @@ static int proc_fill_super(struct super_block *s, void *data, int silent)
 	 * top of it
 	 */
 	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
-	
+
 	pde_get(&proc_root);
 	root_inode = proc_get_inode(s, &proc_root);
 	if (!root_inode) {
@@ -123,27 +143,32 @@ static int proc_fill_super(struct super_block *s, void *data, int silent)
 	return proc_setup_thread_self(s);
 }
 
-int proc_remount(struct super_block *sb, int *flags, char *data)
+int proc_remount(struct super_block *sb, struct mount_context *mc)
 {
 	struct pid_namespace *pid = sb->s_fs_info;
 
 	sync_filesystem(sb);
-	return !proc_parse_options(data, pid);
+
+	if (mc)
+		proc_set_options(sb, mc, pid, current_user_ns());
+	return 0;
 }
 
-static struct dentry *proc_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static struct dentry *proc_mount(struct mount_context *mc)
 {
-	struct pid_namespace *ns;
+	return mount_ns_mc(mc, mc->pid_ns);
+}
 
-	if (flags & MS_KERNMOUNT) {
-		ns = data;
-		data = NULL;
-	} else {
-		ns = task_active_pid_ns(current);
-	}
+static const struct mount_context_operations proc_mount_ctx_ops = {
+	.option		= proc_mount_option,
+	.mount		= proc_mount,
+	.fill_super	= proc_fill_super,
+};
 
-	return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super);
+static int proc_fsopen(struct mount_context *mc, struct super_block *src_sb)
+{
+	mc->ops = &proc_mount_ctx_ops;
+	return 0;
 }
 
 static void proc_kill_sb(struct super_block *sb)
@@ -161,7 +186,8 @@ static void proc_kill_sb(struct super_block *sb)
 
 static struct file_system_type proc_fs_type = {
 	.name		= "proc",
-	.mount		= proc_mount,
+	.fsopen		= proc_fsopen,
+	.mc_size	= sizeof(struct proc_mount_context),
 	.kill_sb	= proc_kill_sb,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
@@ -209,7 +235,7 @@ static struct dentry *proc_root_lookup(struct inode * dir, struct dentry * dentr
 {
 	if (!proc_pid_lookup(dir, dentry, flags))
 		return NULL;
-	
+
 	return proc_lookup(dir, dentry, flags);
 }
 
@@ -248,12 +274,12 @@ static const struct inode_operations proc_root_inode_operations = {
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
@@ -262,9 +288,21 @@ struct proc_dir_entry proc_root = {
 
 int pid_ns_prepare_proc(struct pid_namespace *ns)
 {
+	struct mount_context *mc;
 	struct vfsmount *mnt;
 
-	mnt = kern_mount_data(&proc_fs_type, ns);
+	mc = __vfs_fsopen(&proc_fs_type, NULL, 0, 0, MOUNT_TYPE_NEW);
+	if (IS_ERR(mc))
+		return PTR_ERR(mc);
+
+	if (mc->pid_ns != ns) {
+		put_pid_ns(mc->pid_ns);
+		get_pid_ns(ns);
+		mc->pid_ns = ns;
+	}
+
+	mnt = kern_mount_data_mc(mc);
+	put_mount_context(mc);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 

