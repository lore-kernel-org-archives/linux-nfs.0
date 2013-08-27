Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15345 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141Ab3H0U67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:58:59 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH 03/15] SUNRPC: Cleanup rpc_setup_pipedir
Date: Tue, 27 Aug 2013 16:58:40 -0400
Message-ID: <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The directory name is _always_ clnt->cl_program->pipe_dir_name.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a327cc7..0cf4e09 100644
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
 
@@ -153,15 +153,12 @@ static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
 }
 
 static int
-rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name,
-		  struct super_block *pipefs_sb)
+rpc_setup_pipedir(struct super_block *pipefs_sb, struct rpc_clnt *clnt)
 {
 	struct dentry *dentry;
 
 	clnt->cl_dentry = NULL;
-	if (dir_name == NULL)
-		return 0;
-	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
+	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 	clnt->cl_dentry = dentry;
@@ -186,8 +183,7 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 
 	switch (event) {
 	case RPC_PIPEFS_MOUNT:
-		dentry = rpc_setup_pipedir_sb(sb, clnt,
-					      clnt->cl_program->pipe_dir_name);
+		dentry = rpc_setup_pipedir_sb(sb, clnt);
 		if (!dentry)
 			return -ENOENT;
 		if (IS_ERR(dentry))
@@ -282,7 +278,6 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 static int rpc_client_register(const struct rpc_create_args *args,
 			       struct rpc_clnt *clnt)
 {
-	const struct rpc_program *program = args->program;
 	struct rpc_auth *auth;
 	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
@@ -290,7 +285,7 @@ static int rpc_client_register(const struct rpc_create_args *args,
 
 	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
-		err = rpc_setup_pipedir(clnt, program->pipe_dir_name, pipefs_sb);
+		err = rpc_setup_pipedir(pipefs_sb, clnt);
 		if (err)
 			goto out;
 	}
-- 
1.8.3.1

