Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:47990 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759914Ab2D0JAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 05:00:37 -0400
Subject: [PATCH v2 2/3] SUNRPC: traverse clients tree on PipeFS event
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 27 Apr 2012 13:00:17 +0400
Message-ID: <20120427085959.4859.55386.stgit@localhost6.localdomain6>
In-Reply-To: <20120420141925.10848.90395.stgit@localhost6.localdomain6>
References: <20120420141925.10848.90395.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2: recursion was replaced by loop

If client is a clone, then it's parent can not be in the list.
But parent's Pipefs dentries have to be created and destroyed.

Note: event skip helper for clients introduced

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |   29 +++++++++++++++++++++++++----
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8a19849..d127bd7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -176,8 +176,16 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name)
 	return 0;
 }
 
-static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
-				struct super_block *sb)
+static inline int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event)
+{
+	if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
+	    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
+		return 1;
+	return 0;
+}
+
+static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
+				   struct super_block *sb)
 {
 	struct dentry *dentry;
 	int err = 0;
@@ -206,6 +214,20 @@ static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
 	return err;
 }
 
+static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
+				struct super_block *sb)
+{
+	int error = 0;
+
+	for (;; clnt = clnt->cl_parent) {
+		if (!rpc_clnt_skip_event(clnt, event))
+			error = __rpc_clnt_handle_event(clnt, event, sb);
+		if (error || clnt == clnt->cl_parent)
+			break;
+	}
+	return error;
+}
+
 static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
@@ -215,8 +237,7 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
 		if (clnt->cl_program->pipe_dir_name == NULL)
 			break;
-		if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
-		    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
+		if (rpc_clnt_skip_event(clnt, event))
 			continue;
 		if (atomic_inc_not_zero(&clnt->cl_count) == 0)
 			continue;

