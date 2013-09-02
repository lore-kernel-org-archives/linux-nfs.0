Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:42494 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681Ab3IBSRH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 03/17] SUNRPC: Cleanup rpc_setup_pipedir
Date: Mon, 2 Sep 2013 14:16:46 -0400
Message-ID: <1378145820-29990-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The directory name is _always_ clnt->cl_program->pipe_dir_name.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a327cc7..79d4bc2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -123,10 +123,10 @@ static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 }
 
 static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
-				    struct rpc_clnt *clnt,
-				    const char *dir_name)
+				    struct rpc_clnt *clnt)
 {
 	static uint32_t clntid;
+	const char *dir_name = clnt->cl_program->pipe_dir_name;
 	char name[15];
 	struct dentry *dir, *dentry;
 
@@ -153,23 +153,26 @@ static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
 }
 
 static int
-rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name,
-		  struct super_block *pipefs_sb)
+rpc_setup_pipedir(struct super_block *pipefs_sb, struct rpc_clnt *clnt)
 {
 	struct dentry *dentry;
 
+	if (clnt->cl_program->pipe_dir_name == NULL)
+		goto out;
 	clnt->cl_dentry = NULL;
-	if (dir_name == NULL)
-		return 0;
-	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
+	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 	clnt->cl_dentry = dentry;
+out:
 	return 0;
 }
 
-static inline int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event)
+static int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event)
 {
+	if (clnt->cl_program->pipe_dir_name == NULL)
+		return 1;
+
 	if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
 	    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
 		return 1;
@@ -186,8 +189,7 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 
 	switch (event) {
 	case RPC_PIPEFS_MOUNT:
-		dentry = rpc_setup_pipedir_sb(sb, clnt,
-					      clnt->cl_program->pipe_dir_name);
+		dentry = rpc_setup_pipedir_sb(sb, clnt);
 		if (!dentry)
 			return -ENOENT;
 		if (IS_ERR(dentry))
@@ -230,8 +232,6 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 
 	spin_lock(&sn->rpc_client_lock);
 	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
-		if (clnt->cl_program->pipe_dir_name == NULL)
-			continue;
 		if (rpc_clnt_skip_event(clnt, event))
 			continue;
 		spin_unlock(&sn->rpc_client_lock);
@@ -282,7 +282,6 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 static int rpc_client_register(const struct rpc_create_args *args,
 			       struct rpc_clnt *clnt)
 {
-	const struct rpc_program *program = args->program;
 	struct rpc_auth *auth;
 	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
@@ -290,7 +289,7 @@ static int rpc_client_register(const struct rpc_create_args *args,
 
 	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
-		err = rpc_setup_pipedir(clnt, program->pipe_dir_name, pipefs_sb);
+		err = rpc_setup_pipedir(pipefs_sb, clnt);
 		if (err)
 			goto out;
 	}
-- 
1.8.3.1

