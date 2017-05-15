Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56554 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965812AbdEOPUA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:20:00 -0400
Subject: [PATCH 11/21] proc: Add superblock config support to procfs [ver #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:19:48 +0100
Message-ID: <149486158822.23956.11177118518984651590.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add superblock config support to procfs.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/proc/inode.c    |    2 -
 fs/proc/internal.h |    2 -
 fs/proc/root.c     |  166 +++++++++++++++++++++++++++++++++-------------------
 3 files changed, 108 insertions(+), 62 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index a4bf66af0ba9..304e5c36b7ba 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -118,7 +118,7 @@ const struct super_operations proc_sops = {
 	.drop_inode	= generic_delete_inode,
 	.evict_inode	= proc_evict_inode,
 	.statfs		= simple_statfs,
-	.remount_fs	= proc_remount,
+	.remount_fs_sc	= proc_remount,
 	.show_options	= proc_show_options,
 };
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index b681533f59dd..4546372c2d13 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -262,7 +262,7 @@ static inline void proc_tty_init(void) {}
 extern struct proc_dir_entry proc_root;
 
 extern void proc_self_init(void);
-extern int proc_remount(struct super_block *, int *, char *);
+extern int proc_remount(struct super_block *, struct sb_config *);
 
 /*
  * task_[no]mmu.c
diff --git a/fs/proc/root.c b/fs/proc/root.c
index ee1937b37370..da5757d1c518 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -24,9 +24,18 @@
 #include <linux/parser.h>
 #include <linux/cred.h>
 #include <linux/magic.h>
+#include <linux/slab.h>
 
 #include "internal.h"
 
+struct proc_sb_config {
+	struct sb_config	sc;
+	struct pid_namespace	*pid_ns;
+	unsigned long		mask;
+	int			hidepid;
+	int			gid;
+};
+
 enum {
 	Opt_gid, Opt_hidepid, Opt_err,
 };
@@ -37,56 +46,60 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-static int proc_parse_options(char *options, struct pid_namespace *pid)
+static int proc_parse_mount_option(struct sb_config *sc, char *p)
 {
-	char *p;
+	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
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
+		if (match_int(&args[0], &cfg->gid))
+			return sb_cfg_inval(sc, "procfs: Unparseable gid= argument");
+		break;
+
+	case Opt_hidepid:
+		if (match_int(&args[0], &cfg->hidepid))
+			return sb_cfg_inval(sc, "procfs: Unparseable hidepid= argument");
+		if (cfg->hidepid < HIDEPID_OFF ||
+		    cfg->hidepid > HIDEPID_INVISIBLE) {
+			pr_err("proc: hidepid value must be between 0 and 2.\n");
+			return sb_cfg_inval(sc, "procfs: Invalid hidepid= argument");
 		}
+		break;
+
+	default:
+		pr_err("proc: unrecognized mount option \"%s\" "
+		       "or missing value\n", p);
+		return sb_cfg_inval(sc, "procfs: Invalid mount option or missing value");
 	}
 
-	return 1;
+	cfg->mask |= 1 << token;
+	return 0;
+}
+
+static void proc_set_options(struct super_block *s,
+			     struct sb_config *sc,
+			     struct pid_namespace *pid_ns,
+			     struct user_namespace *user_ns)
+{
+	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
+
+	if (cfg->mask & (1 << Opt_gid))
+		pid_ns->pid_gid = make_kgid(user_ns, cfg->gid);
+	if (cfg->mask & (1 << Opt_hidepid))
+		pid_ns->hide_pid = cfg->hidepid;
 }
 
-static int proc_fill_super(struct super_block *s, void *data, int silent)
+static int proc_fill_super(struct super_block *s, struct sb_config *sc)
 {
-	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
+	struct pid_namespace *pid_ns = get_pid_ns(s->s_fs_info);
 	struct inode *root_inode;
 	int ret;
 
-	if (!proc_parse_options(data, ns))
-		return -EINVAL;
+	proc_set_options(s, sc, pid_ns, current_user_ns());
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
@@ -103,7 +116,7 @@ static int proc_fill_super(struct super_block *s, void *data, int silent)
 	 * top of it
 	 */
 	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
-	
+
 	pde_get(&proc_root);
 	root_inode = proc_get_inode(s, &proc_root);
 	if (!root_inode) {
@@ -124,27 +137,45 @@ static int proc_fill_super(struct super_block *s, void *data, int silent)
 	return proc_setup_thread_self(s);
 }
 
-int proc_remount(struct super_block *sb, int *flags, char *data)
+int proc_remount(struct super_block *sb, struct sb_config *sc)
 {
 	struct pid_namespace *pid = sb->s_fs_info;
 
 	sync_filesystem(sb);
-	return !proc_parse_options(data, pid);
+
+	if (sc)
+		proc_set_options(sb, sc, pid, current_user_ns());
+	return 0;
 }
 
-static struct dentry *proc_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static struct dentry *proc_mount(struct sb_config *sc)
 {
-	struct pid_namespace *ns;
+	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
 
-	if (flags & MS_KERNMOUNT) {
-		ns = data;
-		data = NULL;
-	} else {
-		ns = task_active_pid_ns(current);
-	}
+	return mount_ns_sc(sc, proc_fill_super, cfg->pid_ns);
+}
 
-	return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super);
+static void proc_sb_config_free(struct sb_config *sc)
+{
+	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
+
+	if (cfg->pid_ns)
+		put_pid_ns(cfg->pid_ns);
+}
+
+static const struct sb_config_operations proc_sb_config_ops = {
+	.free		= proc_sb_config_free,
+	.parse_option	= proc_parse_mount_option,
+	.mount		= proc_mount,
+};
+
+static int proc_init_sb_config(struct sb_config *sc, struct super_block *src_sb)
+{
+	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
+
+	cfg->pid_ns = get_pid_ns(task_active_pid_ns(current));
+	cfg->sc.ops = &proc_sb_config_ops;
+	return 0;
 }
 
 static void proc_kill_sb(struct super_block *sb)
@@ -162,7 +193,8 @@ static void proc_kill_sb(struct super_block *sb)
 
 static struct file_system_type proc_fs_type = {
 	.name		= "proc",
-	.mount		= proc_mount,
+	.sb_config_size	= sizeof(struct proc_sb_config),
+	.init_sb_config	= proc_init_sb_config,
 	.kill_sb	= proc_kill_sb,
 	.fs_flags	= FS_USERNS_MOUNT,
 };
@@ -210,7 +242,7 @@ static struct dentry *proc_root_lookup(struct inode * dir, struct dentry * dentr
 {
 	if (!proc_pid_lookup(dir, dentry, flags))
 		return NULL;
-	
+
 	return proc_lookup(dir, dentry, flags);
 }
 
@@ -249,12 +281,12 @@ static const struct inode_operations proc_root_inode_operations = {
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
@@ -263,9 +295,23 @@ struct proc_dir_entry proc_root = {
 
 int pid_ns_prepare_proc(struct pid_namespace *ns)
 {
+	struct proc_sb_config *cfg;
+	struct sb_config *sc;
 	struct vfsmount *mnt;
 
-	mnt = kern_mount_data(&proc_fs_type, ns);
+	sc = __vfs_new_sb_config(&proc_fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	if (IS_ERR(sc))
+		return PTR_ERR(sc);
+
+	cfg = container_of(sc, struct proc_sb_config, sc);
+	if (cfg->pid_ns != ns) {
+		put_pid_ns(cfg->pid_ns);
+		get_pid_ns(ns);
+		cfg->pid_ns = ns;
+	}
+
+	mnt = kern_mount_data_sc(sc);
+	put_sb_config(sc);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 

