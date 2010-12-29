Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:33591 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731Ab0L2NOe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 08:14:34 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v2 10/12] sunrpc: introduce get_rpc_pipefs()
Date: Wed, 29 Dec 2010 15:14:28 +0200
Message-Id: <1293628470-28386-11-git-send-email-kas@openvz.org>
In-Reply-To: <1293628470-28386-1-git-send-email-kas@openvz.org>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Get rpc_pipefs mount point by path.

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/rpc_pipe.c              |   38 ++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index b09bfa5..922057c 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -46,6 +46,8 @@ RPC_I(struct inode *inode)
 
 extern struct vfsmount *init_rpc_pipefs;
 
+struct vfsmount *get_rpc_pipefs(const char *path);
+
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b1e299b..fec6b2d 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,7 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/nsproxy.h>
 
 #include <asm/ioctls.h>
 #include <linux/fs.h>
@@ -931,6 +932,43 @@ static const struct super_operations s_ops = {
 
 #define RPCAUTH_GSSMAGIC 0x67596969
 
+struct vfsmount *get_rpc_pipefs(const char *p)
+{
+	int error;
+	struct vfsmount *rpcmount;
+	struct path path;
+
+	if (!p) {
+		/* Try to get with default rpcmount mount point */
+		rpcmount = get_rpc_pipefs("/var/lib/nfs/rpc_pipefs");
+
+		/*
+		 * If nothing was found at default mount point and init's
+		 * mount namespace is in use, use init_rpc_pipefs
+		 */
+		if (IS_ERR(rpcmount) &&	(current->nsproxy->mnt_ns ==
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
+	if (path.mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC) {
+		path_put(&path);
+		return ERR_PTR(-EINVAL);
+	}
+
+	rpcmount = mntget(path.mnt);
+	path_put(&path);
+
+	return rpcmount;
+}
+EXPORT_SYMBOL_GPL(get_rpc_pipefs);
+
 /*
  * We have a single directory with 1 node in it.
  */
-- 
1.7.3.4

