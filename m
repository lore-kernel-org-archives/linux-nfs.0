Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:34955 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab1LZLkV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 06:40:21 -0500
Subject: [PATCH v3 7/7] SUNRPC: added debug messages to RPC pipefs
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 26 Dec 2011 15:39:47 +0300
Message-ID: <20111226113947.13216.91503.stgit@localhost6.localdomain6>
In-Reply-To: <20111226113504.13216.19798.stgit@localhost6.localdomain6>
References: <20111226113504.13216.19798.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds debug messages for notification events.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpc_pipe.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e40ec55..0cafd59 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -33,6 +33,10 @@
 #include "netns.h"
 #include "sunrpc.h"
 
+#define RPCDBG_FACILITY RPCDBG_DEBUG
+
+#define NET_NAME(net)	((net == &init_net) ? " (init_net)" : "")
+
 static struct vfsmount *rpc_mnt __read_mostly;
 static int rpc_mount_count;
 
@@ -1083,6 +1087,8 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	}
 	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		return -ENOMEM;
+	dprintk("RPC:	sending pipefs MOUNT notification for net %p%s\n", net,
+								NET_NAME(net));
 	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_MOUNT,
 					   sb);
@@ -1116,6 +1122,8 @@ void rpc_kill_sb(struct super_block *sb)
 	sn->pipefs_sb = NULL;
 	mutex_unlock(&sn->pipefs_sb_lock);
 	put_net(net);
+	dprintk("RPC:	sending pipefs UMOUNT notification for net %p%s\n", net,
+								NET_NAME(net));
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);

