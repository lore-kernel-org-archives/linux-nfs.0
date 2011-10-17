Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40325 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026Ab1JQMK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 08:10:56 -0400
Subject: [RFC PATCH 2/5] SUNRPC: send notification events on pipefs sb
	creation and destruction
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Mon, 17 Oct 2011 16:10:35 +0300
Message-ID: <20111017121035.4541.92821.stgit@localhost6.localdomain6>
In-Reply-To: <20111017120629.4541.67395.stgit@localhost6.localdomain6>
References: <20111017120629.4541.67395.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It will be used to notify subscribers about pipefs superblock creation and
destruction.
Cubcriders have to create their dentries on passed superblock on mount event
and destroy otherwise.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/rpc_pipe_fs.h |    8 ++++++++
 net/sunrpc/rpc_pipe.c              |   27 +++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index cf14db9..c1cdb2f 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -44,6 +44,14 @@ RPC_I(struct inode *inode)
 	return container_of(inode, struct rpc_inode, vfs_inode);
 }
 
+extern int rpc_pipefs_notifier_register(struct notifier_block *);
+extern void rpc_pipefs_notifier_unregister(struct notifier_block *);
+
+enum {
+	RPC_PIPEFS_MOUNT,
+	RPC_PIPEFS_UMOUNT,
+};
+
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8322080..c90a7e0 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -28,6 +28,7 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/nsproxy.h>
+#include <linux/notifier.h>
 
 #include "netns.h"
 
@@ -41,6 +42,18 @@ static struct kmem_cache *rpc_inode_cachep __read_mostly;
 
 #define RPC_UPCALL_TIMEOUT (30*HZ)
 
+static BLOCKING_NOTIFIER_HEAD(rpc_pipefs_notifier_list);
+
+int rpc_pipefs_notifier_register(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_cond_register(&rpc_pipefs_notifier_list, nb);
+}
+
+void rpc_pipefs_notifier_unregister(struct notifier_block *nb)
+{
+	blocking_notifier_chain_unregister(&rpc_pipefs_notifier_list, nb);
+}
+
 static void rpc_purge_list(struct rpc_inode *rpci, struct list_head *head,
 		void (*destroy_msg)(struct rpc_pipe_msg *), int err)
 {
@@ -1010,6 +1023,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	struct inode *inode;
 	struct dentry *root;
 	struct net *net = current->nsproxy->net_ns;
+	int err;
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
@@ -1027,8 +1041,18 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	}
 	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		return -ENOMEM;
+	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
+					   RPC_PIPEFS_MOUNT,
+					   sb);
+	if (err)
+		goto err_depopulate;
 	sb->s_fs_info = get_net(net);
 	return 0;
+
+err_depopulate:
+	/* TODO: check if we need to send RPC_PIPEFS_UMOUNT notification. */
+	__rpc_depopulate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF);
+	return err;
 }
 
 static struct dentry *
@@ -1043,6 +1067,9 @@ void rpc_kill_sb(struct super_block *sb)
 	struct net *net = sb->s_fs_info;
 
 	put_net(net);
+	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
+					   RPC_PIPEFS_UMOUNT,
+					   sb);
 	kill_litter_super(sb);
 }
 

