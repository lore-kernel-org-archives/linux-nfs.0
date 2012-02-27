Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:6056 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753829Ab2B0PvV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 10:51:21 -0500
Subject: [PATCH v2 1/4] SUNRPC: release per-net clients lock before calling
 PipeFS dentries creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Mon, 27 Feb 2012 19:50:55 +0400
Message-ID: <20120227155055.7941.18741.stgit@localhost6.localdomain6>
In-Reply-To: <20120227154713.7941.17963.stgit@localhost6.localdomain6>
References: <20120227154713.7941.17963.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lockdep is sad otherwise, because inode mutex is taken on PipeFS dentry
creation, which can be called on mount notification, where this per-net client
lock is taken on clients list walk.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bb7ed2f3..ddb5741 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -84,7 +84,7 @@ static void rpc_register_client(struct rpc_clnt *clnt)
 	struct sunrpc_net *sn = net_generic(clnt->cl_xprt->xprt_net, sunrpc_net_id);
 
 	spin_lock(&sn->rpc_client_lock);
-	list_add(&clnt->cl_clients, &sn->all_clients);
+	list_add_tail(&clnt->cl_clients, &sn->all_clients);
 	spin_unlock(&sn->rpc_client_lock);
 }
 
@@ -208,15 +208,19 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
 			    void *ptr)
 {
 	struct super_block *sb = ptr;
-	struct rpc_clnt *clnt;
+	struct rpc_clnt *clnt, *tmp;
 	int error = 0;
 	struct sunrpc_net *sn = net_generic(sb->s_fs_info, sunrpc_net_id);
 
 	spin_lock(&sn->rpc_client_lock);
-	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
+	list_for_each_entry_safe(clnt, tmp, &sn->all_clients, cl_clients) {
+		atomic_inc(&clnt->cl_count);
+		spin_unlock(&sn->rpc_client_lock);
 		error = __rpc_pipefs_event(clnt, event, sb);
+		rpc_release_client(clnt);
 		if (error)
 			break;
+		spin_lock(&sn->rpc_client_lock);
 	}
 	spin_unlock(&sn->rpc_client_lock);
 	return error;

