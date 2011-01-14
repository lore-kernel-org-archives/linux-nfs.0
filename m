Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:53349 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757554Ab1ANNtk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 08:49:40 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Rob Landley <rlandley@parallels.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        containers@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v3 12/16] sunrpc: introduce get_rpc_pipefs()
Date: Fri, 14 Jan 2011 15:49:10 +0200
Message-Id: <1295012954-7769-13-git-send-email-kas@openvz.org>
In-Reply-To: <1295012954-7769-1-git-send-email-kas@openvz.org>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Get rpc_pipefs mount point by path. If path is NULL, we use first
rpc_pipefs from mount table visible from current root directory.

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
Acked-by: Rob Landley <rlandley@parallels.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    1 +
 net/sunrpc/rpc_pipe.c              |   51 ++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index f5216f1..4a8830a 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -46,6 +46,7 @@ RPC_I(struct inode *inode)
 
 extern struct vfsmount *init_rpc_pipefs;
 
+extern struct vfsmount *get_rpc_pipefs(const char *path);
 extern int rpc_pipefs_add_destroy_cb(struct super_block *sb,
 		void (*destroy_cb)(void *data), void *data);
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 39511e3..b72cb01 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,9 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include <linux/fs_struct.h>
 
 #include <asm/ioctls.h>
 #include <linux/fs.h>
@@ -939,6 +942,54 @@ static const struct super_operations s_ops = {
 
 #define RPCAUTH_GSSMAGIC 0x67596969
 
+static int check_rpc_pipefs(struct vfsmount *mnt, void *arg)
+{
+	struct vfsmount **rpcmount = arg;
+	struct path path = {
+		.mnt = mnt,
+		.dentry = mnt->mnt_root,
+	};
+
+	if (!mnt->mnt_sb)
+		return 0;
+	if (mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC)
+		return 0;
+
+	if (!path_is_under(&path, &current->fs->root))
+		return 0;
+
+	*rpcmount = mntget(mnt);
+	return 1;
+}
+
+struct vfsmount *get_rpc_pipefs(const char *p)
+{
+	int error;
+	struct vfsmount *rpcmount = ERR_PTR(-EINVAL);
+	struct path path;
+
+	if (!p) {
+		iterate_mounts(check_rpc_pipefs, &rpcmount,
+				current->nsproxy->mnt_ns->root);
+
+		if (IS_ERR(rpcmount) && (current->nsproxy->mnt_ns ==
+					init_task.nsproxy->mnt_ns))
+			return mntget(init_rpc_pipefs);
+
+		return rpcmount;
+	}
+
+	error = kern_path(p, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
+	if (error)
+		return ERR_PTR(error);
+
+	check_rpc_pipefs(path.mnt, &rpcmount);
+	path_put(&path);
+
+	return rpcmount;
+}
+EXPORT_SYMBOL_GPL(get_rpc_pipefs);
+
 struct destroy_cb {
 	struct list_head list;
 	void (*callback)(void *data);
-- 
1.7.3.4

