Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:56816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753148AbeDSNcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:32:23 -0400
Subject: [PATCH 11/24] procfs: Move proc_fill_super() to fs/proc/root.c [ver
 #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:32:21 +0100
Message-ID: <152414474155.23902.13992159947703373267.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move proc_fill_super() to fs/proc/root.c as that's where the other
superblock stuff is.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/proc/inode.c    |   49 +------------------------------------------------
 fs/proc/internal.h |    4 +---
 fs/proc/root.c     |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 49 insertions(+), 52 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index df65431c00be..0b13cf6eb6d7 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -24,7 +24,6 @@
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/mount.h>
-#include <linux/magic.h>
 
 #include <linux/uaccess.h>
 
@@ -123,7 +122,7 @@ static int proc_show_options(struct seq_file *seq, struct dentry *root)
 	return 0;
 }
 
-static const struct super_operations proc_sops = {
+const struct super_operations proc_sops = {
 	.alloc_inode	= proc_alloc_inode,
 	.destroy_inode	= proc_destroy_inode,
 	.drop_inode	= generic_delete_inode,
@@ -489,49 +488,3 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 	       pde_put(de);
 	return inode;
 }
-
-int proc_fill_super(struct super_block *s, void *data, size_t data_size,
-		    int silent)
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
-	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
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
index 3362732fffa3..3182e1b636d3 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -189,13 +189,12 @@ struct pde_opener {
 	struct completion *c;
 } __randomize_layout;
 extern const struct inode_operations proc_link_inode_operations;
-
 extern const struct inode_operations proc_pid_link_inode_operations;
+extern const struct super_operations proc_sops;
 
 void proc_init_kmemcache(void);
 void set_proc_pid_nlink(void);
 extern struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
-extern int proc_fill_super(struct super_block *, void *, size_t, int);
 extern void proc_entry_rundown(struct proc_dir_entry *);
 
 /*
@@ -253,7 +252,6 @@ static inline void proc_tty_init(void) {}
  * root.c
  */
 extern struct proc_dir_entry proc_root;
-extern int proc_parse_options(char *options, struct pid_namespace *pid);
 
 extern void proc_self_init(void);
 extern int proc_remount(struct super_block *, int *, char *, size_t);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 99ce06c4e1a2..2fbc177f37a8 100644
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
 
+static int proc_fill_super(struct super_block *s, void *data, size_t data_size, int silent)
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
+	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
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
 int proc_remount(struct super_block *sb, int *flags,
 		 char *data, size_t data_size)
 {

