Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60548 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751449AbeDSNch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:32:37 -0400
Subject: [PATCH 13/24] ipc: Convert mqueue fs to fs_context [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:32:35 +0100
Message-ID: <152414475508.23902.7607267381447716752.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert the mqueue filesystem to use the filesystem context stuff.

Notes:

 (1) The relevant ipc namespace is selected in when the context is
     initialised (and it defaults to the current task's ipc namespace).
     The caller can override this before calling vfs_get_tree().

 (2) Rather than simply calling kern_mount_data(), mq_init_ns() and
     mq_internal_mount() create a context, adjust it and then do the rest
     of the mount procedure.

 (3) The lazy mqueue mounting on creation of a new namespace is retained
     from a previous patch, but the avoidance of sget() if no superblock
     yet exists is reverted and the superblock is again keyed on the
     namespace pointer.

     Yes, there was a performance gain in not searching the superblock
     hash, but it's only paid once per ipc namespace - and only if someone
     uses mqueue within that namespace, so I'm not sure it's worth it,
     especially as calling sget() allows avoidance of recursion.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 ipc/mqueue.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 94 insertions(+), 22 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 910c3c7532e6..2f2e7d73b13d 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -18,6 +18,7 @@
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/namei.h>
 #include <linux/sysctl.h>
 #include <linux/poll.h>
@@ -42,6 +43,11 @@
 #include <net/sock.h>
 #include "util.h"
 
+struct mqueue_fs_context {
+	struct fs_context	fc;
+	struct ipc_namespace	*ipc_ns;
+};
+
 #define MQUEUE_MAGIC	0x19800202
 #define DIRENT_SIZE	20
 #define FILENT_SIZE	80
@@ -87,9 +93,11 @@ struct mqueue_inode_info {
 	unsigned long qsize; /* size of queue in memory (sum of all msgs) */
 };
 
+static struct file_system_type mqueue_fs_type;
 static const struct inode_operations mqueue_dir_inode_operations;
 static const struct file_operations mqueue_file_operations;
 static const struct super_operations mqueue_super_ops;
+static const struct fs_context_operations mqueue_fs_context_ops;
 static void remove_notification(struct mqueue_inode_info *info);
 
 static struct kmem_cache *mqueue_inode_cachep;
@@ -322,7 +330,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 	return ERR_PTR(ret);
 }
 
-static int mqueue_fill_super(struct super_block *sb, void *data, size_t data_size, int silent)
+static int mqueue_fill_super(struct super_block *sb, struct fs_context *fc)
 {
 	struct inode *inode;
 	struct ipc_namespace *ns = sb->s_fs_info;
@@ -343,19 +351,77 @@ static int mqueue_fill_super(struct super_block *sb, void *data, size_t data_siz
 	return 0;
 }
 
-static struct dentry *mqueue_mount(struct file_system_type *fs_type,
-			 int flags, const char *dev_name,
-			 void *data, size_t data_size)
+static int mqueue_get_tree(struct fs_context *fc)
 {
-	struct ipc_namespace *ns;
-	if (flags & SB_KERNMOUNT) {
-		ns = data;
-		data = NULL;
-	} else {
-		ns = current->nsproxy->ipc_ns;
+	struct mqueue_fs_context *ctx = container_of(fc, struct mqueue_fs_context, fc);
+
+	/* As a shortcut, if the namespace already has a superblock created,
+	 * use the root from that directly rather than invoking sget() again.
+	 */
+	spin_lock(&mq_lock);
+	if (ctx->ipc_ns->mq_mnt) {
+		fc->root = dget(ctx->ipc_ns->mq_mnt->mnt_sb->s_root);
+		atomic_inc(&fc->root->d_sb->s_active);
+	}
+	spin_unlock(&mq_lock);
+	if (fc->root) {
+		down_write(&fc->root->d_sb->s_umount);
+		return 0;
 	}
-	return mount_ns(fs_type, flags, data, data_size, ns, ns->user_ns,
-			mqueue_fill_super);
+
+	ctx->fc.s_fs_info = ctx->ipc_ns;
+	return vfs_get_super(fc, vfs_get_keyed_super, mqueue_fill_super);
+}
+
+static void mqueue_fs_context_free(struct fs_context *fc)
+{
+	struct mqueue_fs_context *ctx = container_of(fc, struct mqueue_fs_context, fc);
+
+	if (ctx->ipc_ns)
+		put_ipc_ns(ctx->ipc_ns);
+}
+
+static int mqueue_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct mqueue_fs_context *ctx = container_of(fc, struct mqueue_fs_context, fc);
+
+	ctx->ipc_ns = get_ipc_ns(current->nsproxy->ipc_ns);
+	ctx->fc.ops = &mqueue_fs_context_ops;
+	return 0;
+}
+
+static struct vfsmount *mq_create_mount(struct ipc_namespace *ns)
+{
+	struct mqueue_fs_context *ctx;
+	struct fs_context *fc;
+	struct vfsmount *mnt;
+	int ret;
+
+	fc = vfs_new_fs_context(&mqueue_fs_type, NULL, 0,
+				FS_CONTEXT_FOR_KERNEL_MOUNT);
+	if (IS_ERR(fc))
+		return ERR_CAST(fc);
+
+	ctx = container_of(fc, struct mqueue_fs_context, fc);
+	put_ipc_ns(ctx->ipc_ns);
+	ctx->ipc_ns = get_ipc_ns(ns);
+
+	ret = vfs_get_tree(fc);
+	if (ret < 0)
+		goto err_fc;
+
+	mnt = vfs_create_mount(fc);
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto err_fc;
+	}
+
+	put_fs_context(fc);
+	return mnt;
+
+err_fc:
+	put_fs_context(fc);
+	return ERR_PTR(ret);
 }
 
 static void init_once(void *foo)
@@ -1521,15 +1587,23 @@ static const struct super_operations mqueue_super_ops = {
 	.statfs = simple_statfs,
 };
 
+static const struct fs_context_operations mqueue_fs_context_ops = {
+	.free		= mqueue_fs_context_free,
+	.get_tree	= mqueue_get_tree,
+};
+
 static struct file_system_type mqueue_fs_type = {
-	.name = "mqueue",
-	.mount = mqueue_mount,
-	.kill_sb = kill_litter_super,
-	.fs_flags = FS_USERNS_MOUNT,
+	.name			= "mqueue",
+	.fs_context_size	= sizeof(struct mqueue_fs_context),
+	.init_fs_context	= mqueue_init_fs_context,
+	.kill_sb		= kill_litter_super,
+	.fs_flags		= FS_USERNS_MOUNT,
 };
 
 int mq_init_ns(struct ipc_namespace *ns)
 {
+	struct vfsmount *m;
+
 	ns->mq_queues_count  = 0;
 	ns->mq_queues_max    = DFLT_QUEUESMAX;
 	ns->mq_msg_max       = DFLT_MSGMAX;
@@ -1537,12 +1611,10 @@ int mq_init_ns(struct ipc_namespace *ns)
 	ns->mq_msg_default   = DFLT_MSG;
 	ns->mq_msgsize_default  = DFLT_MSGSIZE;
 
-	ns->mq_mnt = kern_mount_data(&mqueue_fs_type, ns, 0);
-	if (IS_ERR(ns->mq_mnt)) {
-		int err = PTR_ERR(ns->mq_mnt);
-		ns->mq_mnt = NULL;
-		return err;
-	}
+	m = mq_create_mount(&init_ipc_ns);
+	if (IS_ERR(m))
+		return PTR_ERR(ns->mq_mnt);
+	ns->mq_mnt = m;
 	return 0;
 }
 

