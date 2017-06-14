Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59244 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751934AbdFNPTQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:19:16 -0400
Subject: [PATCH 25/27] ipc: Convert mqueue fs to fs_context [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:19:03 +0100
Message-ID: <149745354300.10897.4615400686590211820.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert the mqueue filesystem to use the filesystem context stuff.

Notes:

 (1) The relevant ipc namespace is selected in when the context is
     initialised (and it defaults to the current task's ipc namespace).
     The caller can override this before calling vfs_get_tree().

 (2) Rather than simply calling kern_mount_data(), mq_init_ns() creates a
     context, adjusts it and then does the rest of the mount procedure.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 ipc/mqueue.c |   90 ++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 68 insertions(+), 22 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 9e3a0aab4416..5a0594a79855 100644
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
@@ -90,6 +96,7 @@ struct mqueue_inode_info {
 static const struct inode_operations mqueue_dir_inode_operations;
 static const struct file_operations mqueue_file_operations;
 static const struct super_operations mqueue_super_ops;
+static const struct fs_context_operations mqueue_fs_context_ops;
 static void remove_notification(struct mqueue_inode_info *info);
 
 static struct kmem_cache *mqueue_inode_cachep;
@@ -305,7 +312,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 	return ERR_PTR(ret);
 }
 
-static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
+static int mqueue_fill_super(struct super_block *sb, struct fs_context *fc)
 {
 	struct inode *inode;
 	struct ipc_namespace *ns = sb->s_fs_info;
@@ -326,18 +333,28 @@ static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
 	return 0;
 }
 
-static struct dentry *mqueue_mount(struct file_system_type *fs_type,
-			 int flags, const char *dev_name,
-			 void *data)
+static int mqueue_get_tree(struct fs_context *fc)
 {
-	struct ipc_namespace *ns;
-	if (flags & SB_KERNMOUNT) {
-		ns = data;
-		data = NULL;
-	} else {
-		ns = current->nsproxy->ipc_ns;
-	}
-	return mount_ns(fs_type, flags, data, ns, ns->user_ns, mqueue_fill_super);
+	struct mqueue_fs_context *ctx = container_of(fc, struct mqueue_fs_context, fc);
+
+	return mount_ns_fc(fc, mqueue_fill_super, ctx->ipc_ns);
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
 }
 
 static void init_once(void *foo)
@@ -1399,15 +1416,26 @@ static const struct super_operations mqueue_super_ops = {
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
+	struct mqueue_fs_context *ctx;
+	struct fs_context *fc;
+	struct vfsmount *mnt;
+	int ret;
+
 	ns->mq_queues_count  = 0;
 	ns->mq_queues_max    = DFLT_QUEUESMAX;
 	ns->mq_msg_max       = DFLT_MSGMAX;
@@ -1415,13 +1443,31 @@ int mq_init_ns(struct ipc_namespace *ns)
 	ns->mq_msg_default   = DFLT_MSG;
 	ns->mq_msgsize_default  = DFLT_MSGSIZE;
 
-	ns->mq_mnt = kern_mount_data(&mqueue_fs_type, ns);
-	if (IS_ERR(ns->mq_mnt)) {
-		int err = PTR_ERR(ns->mq_mnt);
-		ns->mq_mnt = NULL;
-		return err;
+	fc = vfs_new_fs_context(&mqueue_fs_type, NULL, 0, FS_CONTEXT_FOR_NEW);
+	if (IS_ERR(fc))
+		return PTR_ERR(fc);
+
+	ctx = container_of(fc, struct mqueue_fs_context, fc);
+	if (ctx->ipc_ns != ns) {
+		put_ipc_ns(ctx->ipc_ns);
+		ctx->ipc_ns = get_ipc_ns(ns);
 	}
-	return 0;
+
+	ret = vfs_get_tree(fc);
+	if (ret < 0)
+		goto out_fc;
+
+	mnt = kern_mount_data_fc(fc);
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto out_fc;
+	}
+
+	ns->mq_mnt = mnt;
+	ret = 0;
+out_fc:
+	put_fs_context(fc);
+	return ret;
 }
 
 void mq_clear_sbinfo(struct ipc_namespace *ns)

