Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2715 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755025Ab1ILOUQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Sep 2011 10:20:16 -0400
Subject: [PATCH 1/2] SUNRPC: make rpc pipefs mount per network namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Mon, 12 Sep 2011 18:19:42 +0400
Message-ID: <20110912141942.6261.87058.stgit@localhost6.localdomain6>
In-Reply-To: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
References: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is another part of RPC layer virtualization.
RPC pipefs inner data was attached to per-net sunrpc_net instance.
Network namespace counter is increased and decreased with every RPC mount
reference. This is not hardly requred from my pow, but it looks safer since we
relay on network namespace presence.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/rpc_pipe_fs.h |    4 ++--
 net/sunrpc/netns.h                 |    3 +++
 net/sunrpc/rpc_pipe.c              |   23 +++++++++++++++--------
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index cf14db9..0bdf178 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -60,8 +60,8 @@ extern void rpc_remove_cache_dir(struct dentry *);
 extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *,
 				 const struct rpc_pipe_ops *, int flags);
 extern int rpc_unlink(struct dentry *);
-extern struct vfsmount *rpc_get_mount(void);
-extern void rpc_put_mount(void);
+extern struct vfsmount *rpc_get_mount(struct net *net);
+extern void rpc_put_mount(struct net *net);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index d013bf2..e45fdf0 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -9,6 +9,9 @@ struct cache_detail;
 struct sunrpc_net {
 	struct proc_dir_entry *proc_net_rpc;
 	struct cache_detail *ip_map_cache;
+
+	struct vfsmount *rpc_mnt;
+	int rpc_mount_count;
 };
 
 extern int sunrpc_net_id;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b181e34..ebc5e1c 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -28,8 +28,7 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
 
-static struct vfsmount *rpc_mnt __read_mostly;
-static int rpc_mount_count;
+#include "netns.h"
 
 static struct file_system_type rpc_pipe_fs_type;
 
@@ -421,20 +420,28 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-struct vfsmount *rpc_get_mount(void)
+struct vfsmount *rpc_get_mount(struct net *net)
 {
 	int err;
+	struct sunrpc_net *sn;
 
-	err = simple_pin_fs(&rpc_pipe_fs_type, &rpc_mnt, &rpc_mount_count);
-	if (err != 0)
+	sn = net_generic(get_net(net), sunrpc_net_id);
+	err = simple_pin_fs(&rpc_pipe_fs_type, &sn->rpc_mnt, &sn->rpc_mount_count);
+	if (err != 0) {
+		put_net(net);
 		return ERR_PTR(err);
-	return rpc_mnt;
+	}
+	return sn->rpc_mnt;
 }
 EXPORT_SYMBOL_GPL(rpc_get_mount);
 
-void rpc_put_mount(void)
+void rpc_put_mount(struct net *net)
 {
-	simple_release_fs(&rpc_mnt, &rpc_mount_count);
+	struct sunrpc_net *sn;
+
+	sn = net_generic(net, sunrpc_net_id);
+	simple_release_fs(&sn->rpc_mnt, &sn->rpc_mount_count);
+	put_net(net);
 }
 EXPORT_SYMBOL_GPL(rpc_put_mount);
 

