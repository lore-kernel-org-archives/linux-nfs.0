Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15109 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdKHF5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 00:57:42 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 4/4] sunrpc: remove net pointer from messages
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <0eb54b2c-79f8-9ed3-72c4-9d6154a5c7be@virtuozzo.com>
Date: Wed, 8 Nov 2017 08:57:32 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Publishing of net pointer is not safe, use net->ns.inum as net ID
[  171.391947] RPC:       created new rpcb local clients
    (rpcb_local_clnt: ..., rpcb_local_clnt4: ...) for net f00001e7
[  171.767188] NFSD: starting 90-second grace period (net f00001e7)

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/rpc_pipe.c  | 8 ++++----
 net/sunrpc/rpcb_clnt.c | 6 +++---
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 61a504f..7803f3b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1410,8 +1410,8 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		return PTR_ERR(gssd_dentry);
 	}
 
-	dprintk("RPC:       sending pipefs MOUNT notification for net %p%s\n",
-		net, NET_NAME(net));
+	dprintk("RPC:       sending pipefs MOUNT notification for net %x%s\n",
+		net->ns.inum, NET_NAME(net));
 	mutex_lock(&sn->pipefs_sb_lock);
 	sn->pipefs_sb = sb;
 	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
@@ -1462,8 +1462,8 @@ static void rpc_kill_sb(struct super_block *sb)
 		goto out;
 	}
 	sn->pipefs_sb = NULL;
-	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
-		net, NET_NAME(net));
+	dprintk("RPC:       sending pipefs UMOUNT notification for net %x%s\n",
+		net->ns.inum, NET_NAME(net));
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_UMOUNT,
 					   sb);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index ea0676f..c526f8f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -216,9 +216,9 @@ static void rpcb_set_local(struct net *net, struct rpc_clnt *clnt,
 	smp_wmb(); 
 	sn->rpcb_users = 1;
 	dprintk("RPC:       created new rpcb local clients (rpcb_local_clnt: "
-			"%p, rpcb_local_clnt4: %p) for net %p%s\n",
-			sn->rpcb_local_clnt, sn->rpcb_local_clnt4,
-			net, (net == &init_net) ? " (init_net)" : "");
+		"%p, rpcb_local_clnt4: %p) for net %x%s\n",
+		sn->rpcb_local_clnt, sn->rpcb_local_clnt4,
+		net->ns.inum, (net == &init_net) ? " (init_net)" : "");
 }
 
 /*
-- 
2.7.4

