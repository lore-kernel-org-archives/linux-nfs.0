Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14924 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932111Ab1KHLN3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 06:13:29 -0500
Subject: [PATCH v2 2/7] SUNRPC: hold current network namespace while pipefs
	superblock is active
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 08 Nov 2011 15:12:29 +0300
Message-ID: <20111108111229.6206.8078.stgit@localhost6.localdomain6>
In-Reply-To: <20111108111056.6206.11410.stgit@localhost6.localdomain6>
References: <20111108111056.6206.11410.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to be sure that network namespace is still alive while we have pipefs
mounted.
This will be required later, when RPC pipefs will be mounting only from
user-space context.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpc_pipe.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index bb8a40b..ff41fef 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -27,6 +27,9 @@
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
+#include <linux/nsproxy.h>
+
+#include "netns.h"
 
 static struct vfsmount *rpc_mnt __read_mostly;
 static int rpc_mount_count;
@@ -1012,6 +1015,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	}
 	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		return -ENOMEM;
+	sb->s_fs_info = get_net(net);
 	return 0;
 }
 
@@ -1022,11 +1026,19 @@ rpc_mount(struct file_system_type *fs_type,
 	return mount_ns(fs_type, flags, current->nsproxy->net_ns, rpc_fill_super);
 }
 
+void rpc_kill_sb(struct super_block *sb)
+{
+	struct net *net = sb->s_fs_info;
+
+	put_net(net);
+	kill_litter_super(sb);
+}
+
 static struct file_system_type rpc_pipe_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "rpc_pipefs",
 	.mount		= rpc_mount,
-	.kill_sb	= kill_litter_super,
+	.kill_sb	= rpc_kill_sb,
 };
 
 static void

