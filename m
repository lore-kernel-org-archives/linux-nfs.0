Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965812AbdEOPTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:19:48 -0400
Subject: [PATCH 10/21] procfs: Move proc_fill_super() to fs/proc/root.c [ver
 #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:19:40 +0100
Message-ID: <149486158066.23956.7333028395069267218.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move proc_fill_super() to fs/proc/root.c as that's where the other
superblock stuff is.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/proc/inode.c    |   48 +-----------------------------------------------
 fs/proc/internal.h |    4 +---
 fs/proc/root.c     |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 49 insertions(+), 51 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index e250910cffc8..a4bf66af0ba9 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -22,7 +22,6 @@
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/mount.h>
-#include <linux/magic.h>
 
 #include <linux/uaccess.h>
 
@@ -113,7 +112,7 @@ static int proc_show_options(struct seq_file *seq, struct dentry *root)
 	return 0;
 }
 
-static const struct super_operations proc_sops = {
+const struct super_operations proc_sops = {
 	.alloc_inode	= proc_alloc_inode,
 	.destroy_inode	= proc_destroy_inode,
 	.drop_inode	= generic_delete_inode,
@@ -470,48 +469,3 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 	       pde_put(de);
 	return inode;
 }
-
-int proc_fill_super(struct super_block *s, void *data, int silent)
-{
-	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
-	struct inode *root_inode;
-	int ret;
-
-	if (!proc_parse_options(data, ns))
-		return -EINVAL;
-
-	/* User space would break if executables or devices appear on proc */
-	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
-	s->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
-	s->s_blocksize = 1024;
-	s->s_blocksize_bits = 10;
-	s->s_magic = PROC_SUPER_MAGIC;
-	s->s_op = &proc_sops;
-	s->s_time_gran = 1;
-
-	/*
-	 * procfs isn't actually a stacking filesystem; however, there is
-	 * too much magic going on inside it to permit stacking things on
-	 * top of it
-	 */
-	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
-	
-	pde_get(&proc_root);
-	root_inode = proc_get_inode(s, &proc_root);
-	if (!root_inode) {
-		pr_err("proc_fill_super: get root inode failed\n");
-		return -ENOMEM;
-	}
-
-	s->s_root = d_make_root(root_inode);
-	if (!s->s_root) {
-		pr_err("proc_fill_super: allocate dentry failed\n");
-		return -ENOMEM;
-	}
-
-	ret = proc_setup_self(s);
-	if (ret) {
-		return ret;
-	}
-	return proc_setup_thread_self(s);
-}
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index c5ae09b6c726..b681533f59dd 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -197,13 +197,12 @@ struct pde_opener {
 	struct completion *c;
 };
 extern const struct inode_operations proc_link_inode_operations;
-
 extern const struct inode_operations proc_pid_link_inode_operations;
+extern const struct super_operations proc_sops;
 
 extern void proc_init_inodecache(void);
 void set_proc_pid_nlink(void);
 extern struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
-extern int proc_fill_super(struct super_block *, void *data, int flags);
 extern void proc_entry_rundown(struct proc_dir_entry *);
 
 /*
@@ -261,7 +260,6 @@ static inline void proc_tty_init(void) {}
  * root.c
  */
 extern struct proc_dir_entry proc_root;
-extern int proc_parse_options(char *options, struct pid_namespace *pid);
 
 extern void proc_self_init(void);
 extern int proc_remount(struct super_block *, int *, char *);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 3c47399bd095..ee1937b37370 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -23,6 +23,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/parser.h>
 #include <linux/cred.h>
+#include <linux/magic.h>
 
 #include "internal.h"
 
@@ -36,7 +37,7 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-int proc_parse_options(char *options, struct pid_namespace *pid)
+static int proc_parse_options(char *options, struct pid_namespace *pid)
 {
 	char *p;
 	substring_t args[MAX_OPT_ARGS];
@@ -78,6 +79,51 @@ int proc_parse_options(char *options, struct pid_namespace *pid)
 	return 1;
 }
 
+static int proc_fill_super(struct super_block *s, void *data, int silent)
+{
+	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
+	struct inode *root_inode;
+	int ret;
+
+	if (!proc_parse_options(data, ns))
+		return -EINVAL;
+
+	/* User space would break if executables or devices appear on proc */
+	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
+	s->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
+	s->s_blocksize = 1024;
+	s->s_blocksize_bits = 10;
+	s->s_magic = PROC_SUPER_MAGIC;
+	s->s_op = &proc_sops;
+	s->s_time_gran = 1;
+
+	/*
+	 * procfs isn't actually a stacking filesystem; however, there is
+	 * too much magic going on inside it to permit stacking things on
+	 * top of it
+	 */
+	s->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
+	
+	pde_get(&proc_root);
+	root_inode = proc_get_inode(s, &proc_root);
+	if (!root_inode) {
+		pr_err("proc_fill_super: get root inode failed\n");
+		return -ENOMEM;
+	}
+
+	s->s_root = d_make_root(root_inode);
+	if (!s->s_root) {
+		pr_err("proc_fill_super: allocate dentry failed\n");
+		return -ENOMEM;
+	}
+
+	ret = proc_setup_self(s);
+	if (ret) {
+		return ret;
+	}
+	return proc_setup_thread_self(s);
+}
+
 int proc_remount(struct super_block *sb, int *flags, char *data)
 {
 	struct pid_namespace *pid = sb->s_fs_info;

