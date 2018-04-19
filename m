Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43558 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752322AbeDSNdx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:33:53 -0400
Subject: [PATCH 23/24] afs: Implement namespacing [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:51 +0100
Message-ID: <152414483136.23902.14446781798566249159.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement namespacing within AFS, but don't yet let mounts occur outside
the init namespace.  An additional patch will be required propagate the
network namespace across automounts.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/cell.c     |    4 +-
 fs/afs/internal.h |   36 ++++++++++++---------
 fs/afs/main.c     |   33 ++++++++++++++++----
 fs/afs/proc.c     |   89 +++++++++++++++++++++++++++++++++++------------------
 fs/afs/super.c    |   58 +++++++++++++++++++++++++----------
 5 files changed, 149 insertions(+), 71 deletions(-)

diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index fdf4c36cff79..a98a8a3d5544 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -528,7 +528,7 @@ static int afs_activate_cell(struct afs_net *net, struct afs_cell *cell)
 					     NULL, 0,
 					     cell, 0, true);
 #endif
-	ret = afs_proc_cell_setup(net, cell);
+	ret = afs_proc_cell_setup(cell);
 	if (ret < 0)
 		return ret;
 	spin_lock(&net->proc_cells_lock);
@@ -544,7 +544,7 @@ static void afs_deactivate_cell(struct afs_net *net, struct afs_cell *cell)
 {
 	_enter("%s", cell->name);
 
-	afs_proc_cell_remove(net, cell);
+	afs_proc_cell_remove(cell);
 
 	spin_lock(&net->proc_cells_lock);
 	list_del_init(&cell->proc_link);
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 0266730b3ad7..a5161c0ae3ab 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -22,6 +22,8 @@
 #include <linux/backing-dev.h>
 #include <linux/uuid.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/sock.h>
 #include <net/af_rxrpc.h>
 
 #include "afs.h"
@@ -192,7 +194,7 @@ struct afs_read {
  * - there's one superblock per volume
  */
 struct afs_super_info {
-	struct afs_net		*net;		/* Network namespace */
+	struct net		*net_ns;	/* Network namespace */
 	struct afs_cell		*cell;		/* The cell in which the volume resides */
 	struct afs_volume	*volume;	/* volume record */
 	bool			dyn_root;	/* True if dynamic root */
@@ -221,6 +223,7 @@ struct afs_sysnames {
  * AFS network namespace record.
  */
 struct afs_net {
+	struct net		*net;		/* Backpointer to the owning net namespace */
 	struct afs_uuid		uuid;
 	bool			live;		/* F if this namespace is being removed */
 
@@ -283,7 +286,6 @@ struct afs_net {
 };
 
 extern const char afs_init_sysname[];
-extern struct afs_net __afs_net;// Dummy AFS network namespace; TODO: replace with real netns
 
 enum afs_cell_state {
 	AFS_CELL_UNSET,
@@ -790,34 +792,36 @@ extern int afs_drop_inode(struct inode *);
  * main.c
  */
 extern struct workqueue_struct *afs_wq;
+extern int afs_net_id;
 
-static inline struct afs_net *afs_d2net(struct dentry *dentry)
+static inline struct afs_net *afs_net(struct net *net)
 {
-	return &__afs_net;
+	return net_generic(net, afs_net_id);
 }
 
-static inline struct afs_net *afs_i2net(struct inode *inode)
+static inline struct afs_net *afs_sb2net(struct super_block *sb)
 {
-	return &__afs_net;
+	return afs_net(AFS_FS_S(sb)->net_ns);
 }
 
-static inline struct afs_net *afs_v2net(struct afs_vnode *vnode)
+static inline struct afs_net *afs_d2net(struct dentry *dentry)
 {
-	return &__afs_net;
+	return afs_sb2net(dentry->d_sb);
 }
 
-static inline struct afs_net *afs_sock2net(struct sock *sk)
+static inline struct afs_net *afs_i2net(struct inode *inode)
 {
-	return &__afs_net;
+	return afs_sb2net(inode->i_sb);
 }
 
-static inline struct afs_net *afs_get_net(struct afs_net *net)
+static inline struct afs_net *afs_v2net(struct afs_vnode *vnode)
 {
-	return net;
+	return afs_i2net(&vnode->vfs_inode);
 }
 
-static inline void afs_put_net(struct afs_net *net)
+static inline struct afs_net *afs_sock2net(struct sock *sk)
 {
+	return net_generic(sock_net(sk), afs_net_id);
 }
 
 static inline void __afs_stat(atomic_t *s)
@@ -852,8 +856,8 @@ extern int afs_get_ipv4_interfaces(struct afs_interface *, size_t, bool);
  */
 extern int __net_init afs_proc_init(struct afs_net *);
 extern void __net_exit afs_proc_cleanup(struct afs_net *);
-extern int afs_proc_cell_setup(struct afs_net *, struct afs_cell *);
-extern void afs_proc_cell_remove(struct afs_net *, struct afs_cell *);
+extern int afs_proc_cell_setup(struct afs_cell *);
+extern void afs_proc_cell_remove(struct afs_cell *);
 extern void afs_put_sysnames(struct afs_sysnames *);
 
 /*
@@ -986,7 +990,7 @@ extern bool afs_annotate_server_list(struct afs_server_list *, struct afs_server
  * super.c
  */
 extern int __init afs_fs_init(void);
-extern void __exit afs_fs_exit(void);
+extern void afs_fs_exit(void);
 
 /*
  * vlclient.c
diff --git a/fs/afs/main.c b/fs/afs/main.c
index d7560168b3bf..7d2c1354e2ca 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -15,6 +15,7 @@
 #include <linux/completion.h>
 #include <linux/sched.h>
 #include <linux/random.h>
+#include <linux/proc_fs.h>
 #define CREATE_TRACE_POINTS
 #include "internal.h"
 
@@ -32,7 +33,7 @@ module_param(rootcell, charp, 0);
 MODULE_PARM_DESC(rootcell, "root AFS cell name and VL server IP addr list");
 
 struct workqueue_struct *afs_wq;
-struct afs_net __afs_net;
+static struct proc_dir_entry *afs_proc_symlink;
 
 #if defined(CONFIG_ALPHA)
 const char afs_init_sysname[] = "alpha_linux26";
@@ -67,11 +68,13 @@ const char afs_init_sysname[] = "unknown_linux26";
 /*
  * Initialise an AFS network namespace record.
  */
-static int __net_init afs_net_init(struct afs_net *net)
+static int __net_init afs_net_init(struct net *net_ns)
 {
 	struct afs_sysnames *sysnames;
+	struct afs_net *net = afs_net(net_ns);
 	int ret;
 
+	net->net = net_ns;
 	net->live = true;
 	generate_random_uuid((unsigned char *)&net->uuid);
 
@@ -142,8 +145,10 @@ static int __net_init afs_net_init(struct afs_net *net)
 /*
  * Clean up and destroy an AFS network namespace record.
  */
-static void __net_exit afs_net_exit(struct afs_net *net)
+static void __net_exit afs_net_exit(struct net *net_ns)
 {
+	struct afs_net *net = afs_net(net_ns);
+
 	net->live = false;
 	afs_cell_purge(net);
 	afs_purge_servers(net);
@@ -152,6 +157,13 @@ static void __net_exit afs_net_exit(struct afs_net *net)
 	afs_put_sysnames(net->sysnames);
 }
 
+static struct pernet_operations afs_net_ops = {
+	.init	= afs_net_init,
+	.exit	= afs_net_exit,
+	.id	= &afs_net_id,
+	.size	= sizeof(struct afs_net),
+};
+
 /*
  * initialise the AFS client FS module
  */
@@ -178,7 +190,7 @@ static int __init afs_init(void)
 		goto error_cache;
 #endif
 
-	ret = afs_net_init(&__afs_net);
+	ret = register_pernet_subsys(&afs_net_ops);
 	if (ret < 0)
 		goto error_net;
 
@@ -187,10 +199,18 @@ static int __init afs_init(void)
 	if (ret < 0)
 		goto error_fs;
 
+	afs_proc_symlink = proc_symlink("fs/afs", NULL, "../self/net/afs");
+	if (IS_ERR(afs_proc_symlink)) {
+		ret = PTR_ERR(afs_proc_symlink);
+		goto error_proc;
+	}
+
 	return ret;
 
+error_proc:
+	afs_fs_exit();
 error_fs:
-	afs_net_exit(&__afs_net);
+	unregister_pernet_subsys(&afs_net_ops);
 error_net:
 #ifdef CONFIG_AFS_FSCACHE
 	fscache_unregister_netfs(&afs_cache_netfs);
@@ -219,8 +239,9 @@ static void __exit afs_exit(void)
 {
 	printk(KERN_INFO "kAFS: Red Hat AFS client v0.1 unregistering.\n");
 
+	proc_remove(afs_proc_symlink);
 	afs_fs_exit();
-	afs_net_exit(&__afs_net);
+	unregister_pernet_subsys(&afs_net_ops);
 #ifdef CONFIG_AFS_FSCACHE
 	fscache_unregister_netfs(&afs_cache_netfs);
 #endif
diff --git a/fs/afs/proc.c b/fs/afs/proc.c
index 839a22280606..cc7c48a5b743 100644
--- a/fs/afs/proc.c
+++ b/fs/afs/proc.c
@@ -17,14 +17,16 @@
 #include <linux/uaccess.h>
 #include "internal.h"
 
-static inline struct afs_net *afs_proc2net(struct file *f)
+static inline struct afs_net *afs_proc2net_get(struct file *f)
 {
-	return &__afs_net;
+	struct net *net_ns = get_proc_net(file_inode(f));
+
+	return net_ns ? afs_net(net_ns) : NULL;
 }
 
 static inline struct afs_net *afs_seq2net(struct seq_file *m)
 {
-	return &__afs_net; // TODO: use seq_file_net(m)
+	return afs_net(seq_file_net(m));
 }
 
 static int afs_proc_cells_open(struct inode *inode, struct file *file);
@@ -161,7 +163,7 @@ int afs_proc_init(struct afs_net *net)
 {
 	_enter("");
 
-	net->proc_afs = proc_mkdir("fs/afs", NULL);
+	net->proc_afs = proc_net_mkdir(net->net, "afs", net->net->proc_net);
 	if (!net->proc_afs)
 		goto error_dir;
 
@@ -196,16 +198,8 @@ void afs_proc_cleanup(struct afs_net *net)
  */
 static int afs_proc_cells_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *m;
-	int ret;
-
-	ret = seq_open(file, &afs_proc_cells_ops);
-	if (ret < 0)
-		return ret;
-
-	m = file->private_data;
-	m->private = PDE_DATA(inode);
-	return 0;
+	return seq_open_net(inode, file, &afs_proc_cells_ops,
+			    sizeof(struct seq_net_private));
 }
 
 /*
@@ -266,7 +260,8 @@ static int afs_proc_cells_show(struct seq_file *m, void *v)
 static ssize_t afs_proc_cells_write(struct file *file, const char __user *buf,
 				    size_t size, loff_t *_pos)
 {
-	struct afs_net *net = afs_proc2net(file);
+	struct afs_net *net;
+	struct net *net_ns = NULL;
 	char *kbuf, *name, *args;
 	int ret;
 
@@ -305,6 +300,12 @@ static ssize_t afs_proc_cells_write(struct file *file, const char __user *buf,
 	/* determine command to perform */
 	_debug("cmd=%s name=%s args=%s", kbuf, name, args);
 
+	ret = -ESTALE;
+	net_ns = get_proc_net(file_inode(file));
+	if (!net_ns)
+		goto done;
+	net = afs_net(net_ns);
+
 	if (strcmp(kbuf, "add") == 0) {
 		struct afs_cell *cell;
 
@@ -324,6 +325,7 @@ static ssize_t afs_proc_cells_write(struct file *file, const char __user *buf,
 	ret = size;
 
 done:
+	put_net(net_ns);
 	kfree(kbuf);
 	_leave(" = %d", ret);
 	return ret;
@@ -338,15 +340,24 @@ static ssize_t afs_proc_rootcell_read(struct file *file, char __user *buf,
 				      size_t size, loff_t *_pos)
 {
 	struct afs_cell *cell;
-	struct afs_net *net = afs_proc2net(file);
+	struct afs_net *net;
+	struct net *net_ns = NULL;
 	unsigned int seq = 0;
 	char name[AFS_MAXCELLNAME + 1];
 	int len;
 
 	if (*_pos > 0)
 		return 0;
-	if (!net->ws_cell)
-		return 0;
+
+	net_ns = get_proc_net(file_inode(file));
+	if (!net_ns)
+		return -ESTALE;
+	net = afs_net(net_ns);
+
+	if (!net->ws_cell) {
+		len = 0;
+		goto out;
+	}
 
 	rcu_read_lock();
 	do {
@@ -362,14 +373,18 @@ static ssize_t afs_proc_rootcell_read(struct file *file, char __user *buf,
 	rcu_read_unlock();
 
 	if (!len)
-		return 0;
+		goto out;
 
 	name[len++] = '\n';
 	if (len > size)
 		len = size;
-	if (copy_to_user(buf, name, len) != 0)
-		return -EFAULT;
+	if (copy_to_user(buf, name, len) != 0) {
+		len = -EFAULT;
+		goto out;
+	}
 	*_pos = 1;
+out:
+	put_net(net_ns);
 	return len;
 }
 
@@ -381,7 +396,8 @@ static ssize_t afs_proc_rootcell_write(struct file *file,
 				       const char __user *buf,
 				       size_t size, loff_t *_pos)
 {
-	struct afs_net *net = afs_proc2net(file);
+	struct afs_net *net;
+	struct net *net_ns = NULL;
 	char *kbuf, *s;
 	int ret;
 
@@ -407,6 +423,12 @@ static ssize_t afs_proc_rootcell_write(struct file *file,
 	/* determine command to perform */
 	_debug("rootcell=%s", kbuf);
 
+	ret = -ESTALE;
+	net_ns = get_proc_net(file_inode(file));
+	if (!net_ns)
+		goto out;
+	net = afs_net(net_ns);
+
 	ret = afs_cell_init(net, kbuf);
 	if (ret >= 0)
 		ret = size;	/* consume everything, always */
@@ -420,13 +442,14 @@ static ssize_t afs_proc_rootcell_write(struct file *file,
 /*
  * initialise /proc/fs/afs/<cell>/
  */
-int afs_proc_cell_setup(struct afs_net *net, struct afs_cell *cell)
+int afs_proc_cell_setup(struct afs_cell *cell)
 {
 	struct proc_dir_entry *dir;
+	struct afs_net *net = cell->net;
 
 	_enter("%p{%s},%p", cell, cell->name, net->proc_afs);
 
-	dir = proc_mkdir(cell->name, net->proc_afs);
+	dir = proc_net_mkdir(net->net, cell->name, net->proc_afs);
 	if (!dir)
 		goto error_dir;
 
@@ -449,12 +472,12 @@ int afs_proc_cell_setup(struct afs_net *net, struct afs_cell *cell)
 /*
  * remove /proc/fs/afs/<cell>/
  */
-void afs_proc_cell_remove(struct afs_net *net, struct afs_cell *cell)
+void afs_proc_cell_remove(struct afs_cell *cell)
 {
-	_enter("");
+	struct afs_net *net = cell->net;
 
+	_enter("");
 	remove_proc_subtree(cell->name, net->proc_afs);
-
 	_leave("");
 }
 
@@ -471,7 +494,8 @@ static int afs_proc_cell_volumes_open(struct inode *inode, struct file *file)
 	if (!cell)
 		return -ENOENT;
 
-	ret = seq_open(file, &afs_proc_cell_volumes_ops);
+	ret = seq_open_net(inode, file, &afs_proc_cell_volumes_ops,
+			   sizeof(struct seq_net_private));
 	if (ret < 0)
 		return ret;
 
@@ -560,7 +584,8 @@ static int afs_proc_cell_vlservers_open(struct inode *inode, struct file *file)
 	if (!cell)
 		return -ENOENT;
 
-	ret = seq_open(file, &afs_proc_cell_vlservers_ops);
+	ret = seq_open_net(inode, file, &afs_proc_cell_vlservers_ops,
+			   sizeof(struct seq_net_private));
 	if (ret<0)
 		return ret;
 
@@ -649,7 +674,8 @@ static int afs_proc_cell_vlservers_show(struct seq_file *m, void *v)
  */
 static int afs_proc_servers_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &afs_proc_servers_ops);
+	return seq_open_net(inode, file, &afs_proc_servers_ops,
+			    sizeof(struct seq_net_private));
 }
 
 /*
@@ -729,7 +755,8 @@ static int afs_proc_sysname_open(struct inode *inode, struct file *file)
 	struct seq_file *m;
 	int ret;
 
-	ret = seq_open(file, &afs_proc_sysname_ops);
+	ret = seq_open_net(inode, file, &afs_proc_sysname_ops,
+			   sizeof(struct seq_net_private));
 	if (ret < 0)
 		return ret;
 
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 6ab0b79e061e..f56070a9c606 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -48,6 +48,8 @@ struct file_system_type afs_fs_type = {
 };
 MODULE_ALIAS_FS("afs");
 
+int afs_net_id;
+
 static const struct super_operations afs_super_ops = {
 	.statfs		= afs_statfs,
 	.alloc_inode	= afs_alloc_inode,
@@ -117,7 +119,7 @@ int __init afs_fs_init(void)
 /*
  * clean up the filesystem
  */
-void __exit afs_fs_exit(void)
+void afs_fs_exit(void)
 {
 	_enter("");
 
@@ -391,7 +393,7 @@ static int afs_test_super(struct super_block *sb, struct fs_context *fc)
 	struct afs_fs_context *ctx = container_of(fc, struct afs_fs_context, fc);
 	struct afs_super_info *as = AFS_FS_S(sb);
 
-	return (as->net == ctx->net &&
+	return (as->net_ns == ctx->fc.net_ns &&
 		as->volume &&
 		as->volume->vid == ctx->volume->vid);
 }
@@ -477,7 +479,7 @@ static struct afs_super_info *afs_alloc_sbi(struct afs_fs_context *ctx)
 
 	as = kzalloc(sizeof(struct afs_super_info), GFP_KERNEL);
 	if (as) {
-		as->net = afs_get_net(ctx->net);
+		as->net_ns = get_net(ctx->fc.net_ns);
 		if (ctx->dyn_root) {
 			as->dyn_root = true;
 		} else {
@@ -492,8 +494,8 @@ static void afs_destroy_sbi(struct afs_super_info *as)
 {
 	if (as) {
 		afs_put_volume(as->cell, as->volume);
-		afs_put_cell(as->net, as->cell);
-		afs_put_net(as->net);
+		afs_put_cell(afs_net(as->net_ns), as->cell);
+		put_net(as->net_ns);
 		kfree(as);
 	}
 }
@@ -506,7 +508,8 @@ static void afs_kill_super(struct super_block *sb)
 	 * deactivating the superblock.
 	 */
 	if (as->volume)
-		afs_clear_callback_interests(as->net, as->volume->servers);
+		afs_clear_callback_interests(afs_net(as->net_ns),
+					     as->volume->servers);
 	kill_anon_super(sb);
 	if (as->volume)
 		afs_deactivate_volume(as->volume);
@@ -574,7 +577,6 @@ static void afs_free_fc(struct fs_context *fc)
 
 	afs_put_volume(ctx->cell, ctx->volume);
 	afs_put_cell(ctx->net, ctx->cell);
-	afs_put_net(ctx->net);
 	afs_destroy_sbi(ctx->as);
 	key_put(ctx->key);
 }
@@ -595,19 +597,19 @@ static int afs_init_fs_context(struct fs_context *fc, struct super_block *src_sb
 	struct afs_fs_context *ctx = container_of(fc, struct afs_fs_context, fc);
 	struct afs_super_info *src_as;
 	struct afs_cell *cell;
+	struct net *net_ns;
 
 	if (current->nsproxy->net_ns != &init_net)
 		return -EINVAL;
+	ctx->type = AFSVL_ROVOL;
 
-	if (src_sb) {
-		src_as = AFS_FS_S(src_sb);
-		if (src_as) {
-			ctx->net    = afs_get_net(src_as->net);
-			ctx->cell   = afs_get_cell(src_as->cell);
-			ctx->volume = __afs_get_volume(src_as->volume);
-		}
-	} else {
-		ctx->net = afs_get_net(&__afs_net);
+	switch (ctx->fc.purpose) {
+	case FS_CONTEXT_FOR_USER_MOUNT:
+	case FS_CONTEXT_FOR_KERNEL_MOUNT:
+		ctx->fc.net_ns = maybe_get_net(current->nsproxy->net_ns);
+		if (!ctx->fc.net_ns)
+			return -ESTALE;
+		ctx->net = afs_net(ctx->fc.net_ns);
 
 		/* Default to the workstation cell. */
 		rcu_read_lock();
@@ -616,6 +618,30 @@ static int afs_init_fs_context(struct fs_context *fc, struct super_block *src_sb
 		if (IS_ERR(cell))
 			cell = NULL;
 		ctx->cell = cell;
+		break;
+
+	case FS_CONTEXT_FOR_SUBMOUNT:
+		if (!src_sb)
+			return -EINVAL;
+
+		src_as = AFS_FS_S(src_sb);
+		ASSERT(src_as);
+
+		net_ns = maybe_get_net(src_as->net_ns);
+		if (!net_ns)
+			return -ESTALE;
+		ctx->fc.net_ns = net_ns;
+		ctx->net = afs_net(net_ns);
+		if (src_as->cell)
+			ctx->cell = afs_get_cell(src_as->cell);
+		if (src_as->volume && src_as->volume->type == AFSVL_RWVOL) {
+			ctx->type = AFSVL_RWVOL;
+			ctx->force = true;
+		}
+		break;
+
+	case FS_CONTEXT_FOR_RECONFIGURE:
+		break;
 	}
 
 	ctx->fc.ops = &afs_context_ops;

