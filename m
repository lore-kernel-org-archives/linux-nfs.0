Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43059 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab2B0NtT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 08:49:19 -0500
Subject: [PATCH 1/4] SUNRPC: replace per-net client lock by rw mutex
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 27 Feb 2012 17:48:52 +0400
Message-ID: <20120227134852.13371.36733.stgit@localhost6.localdomain6>
In-Reply-To: <20120227134623.13371.61185.stgit@localhost6.localdomain6>
References: <20120227134623.13371.61185.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lockdep is sad otherwise, because inode mutex is taken on PipeFS dentry
creation, which can be called on mount notification, where this per-net client
lock is taken on clients list walk.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c        |   16 ++++++++--------
 net/sunrpc/netns.h       |    2 +-
 net/sunrpc/sunrpc_syms.c |    2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bb7ed2f3..2d3a547 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -83,18 +83,18 @@ static void rpc_register_client(struct rpc_clnt *clnt)
 {
 	struct sunrpc_net *sn = net_generic(clnt->cl_xprt->xprt_net, sunrpc_net_id);
 
-	spin_lock(&sn->rpc_client_lock);
+	down_write(&sn->rpc_client_lock);
 	list_add(&clnt->cl_clients, &sn->all_clients);
-	spin_unlock(&sn->rpc_client_lock);
+	up_write(&sn->rpc_client_lock);
 }
 
 static void rpc_unregister_client(struct rpc_clnt *clnt)
 {
 	struct sunrpc_net *sn = net_generic(clnt->cl_xprt->xprt_net, sunrpc_net_id);
 
-	spin_lock(&sn->rpc_client_lock);
+	down_write(&sn->rpc_client_lock);
 	list_del(&clnt->cl_clients);
-	spin_unlock(&sn->rpc_client_lock);
+	up_write(&sn->rpc_client_lock);
 }
 
 static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
@@ -212,13 +212,13 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
 	int error = 0;
 	struct sunrpc_net *sn = net_generic(sb->s_fs_info, sunrpc_net_id);
 
-	spin_lock(&sn->rpc_client_lock);
+	down_read(&sn->rpc_client_lock);
 	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
 		error = __rpc_pipefs_event(clnt, event, sb);
 		if (error)
 			break;
 	}
-	spin_unlock(&sn->rpc_client_lock);
+	up_read(&sn->rpc_client_lock);
 	return error;
 }
 
@@ -1947,7 +1947,7 @@ void rpc_show_tasks(struct net *net)
 	int header = 0;
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
-	spin_lock(&sn->rpc_client_lock);
+	down_read(&sn->rpc_client_lock);
 	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
 		spin_lock(&clnt->cl_lock);
 		list_for_each_entry(task, &clnt->cl_tasks, tk_task) {
@@ -1959,6 +1959,6 @@ void rpc_show_tasks(struct net *net)
 		}
 		spin_unlock(&clnt->cl_lock);
 	}
-	spin_unlock(&sn->rpc_client_lock);
+	up_read(&sn->rpc_client_lock);
 }
 #endif
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index ce7bd44..88f4b2e 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -17,7 +17,7 @@ struct sunrpc_net {
 	struct mutex pipefs_sb_lock;
 
 	struct list_head all_clients;
-	spinlock_t rpc_client_lock;
+	struct rw_semaphore rpc_client_lock;
 
 	struct rpc_clnt *rpcb_local_clnt;
 	struct rpc_clnt *rpcb_local_clnt4;
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 21d106e..57fa75f 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -49,7 +49,7 @@ static __net_init int sunrpc_init_net(struct net *net)
 
 	rpc_pipefs_init_net(net);
 	INIT_LIST_HEAD(&sn->all_clients);
-	spin_lock_init(&sn->rpc_client_lock);
+	init_rwsem(&sn->rpc_client_lock);
 	spin_lock_init(&sn->rpcb_clnt_lock);
 	return 0;
 

