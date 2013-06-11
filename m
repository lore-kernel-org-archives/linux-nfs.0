Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:30876 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754355Ab3FKOja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 10:39:30 -0400
Subject: [PATCH v2 2/4] SUNRPC: fix races on PipeFS MOUNT notifications
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Tue, 11 Jun 2013 18:39:18 +0400
Message-ID: <20130611143917.16046.15791.stgit@localhost.localdomain>
In-Reply-To: <20130611143725.16046.17279.stgit@localhost.localdomain>
References: <20130611143725.16046.17279.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Below are races, when RPC client can be created without PiepFS dentries

CPU#0					CPU#1
-----------------------------		-----------------------------
rpc_new_client				rpc_fill_super
rpc_setup_pipedir
mutex_lock(&sn->pipefs_sb_lock)
rpc_get_sb_net == NULL
(no per-net PipeFS superblock)
					sn->pipefs_sb = sb;
					notifier_call_chain(MOUNT)
					(client is not in the list)
rpc_register_client
(client without pipes dentries)

To fix this patch:
1) makes PipeFS mount notification call with pipefs_sb_lock being held.
2) releases pipefs_sb_lock on new SUNRPC client creation only after
registration.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org
---
 net/sunrpc/clnt.c     |   24 +++++++++++++-----------
 net/sunrpc/rpc_pipe.c |    3 +++
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4bf2409..48888ee 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -157,20 +157,15 @@ static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
 }
 
 static int
-rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name)
+rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name,
+		  struct super_block *pipefs_sb)
 {
-	struct net *net = rpc_net_ns(clnt);
-	struct super_block *pipefs_sb;
 	struct dentry *dentry;
 
 	clnt->cl_dentry = NULL;
 	if (dir_name == NULL)
 		return 0;
-	pipefs_sb = rpc_get_sb_net(net);
-	if (!pipefs_sb)
-		return 0;
 	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
-	rpc_put_sb_net(net);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 	clnt->cl_dentry = dentry;
@@ -294,11 +289,16 @@ static int rpc_client_register(const struct rpc_create_args *args,
 {
 	const struct rpc_program *program = args->program;
 	struct rpc_auth *auth;
+	struct net *net = rpc_net_ns(clnt);
+	struct super_block *pipefs_sb;
 	int err = 0;
 
-	err = rpc_setup_pipedir(clnt, program->pipe_dir_name);
-	if (err < 0)
-		goto out;
+	pipefs_sb = rpc_get_sb_net(net);
+	if (pipefs_sb) {
+		err = rpc_setup_pipedir(clnt, program->pipe_dir_name, pipefs_sb);
+		if (err)
+			goto out;
+	}
 
 	auth = rpcauth_create(args->authflavor, clnt);
 	if (IS_ERR(auth)) {
@@ -310,10 +310,12 @@ static int rpc_client_register(const struct rpc_create_args *args,
 
 	rpc_register_client(clnt);
 out:
+	if (pipefs_sb)
+		rpc_put_sb_net(net);
 	return err;
 
 err_auth:
-	rpc_clnt_remove_pipedir(clnt);
+	__rpc_clnt_remove_pipedir(clnt);
 	goto out;
 }
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e7ce4b3..c512448 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1126,6 +1126,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		return -ENOMEM;
 	dprintk("RPC:       sending pipefs MOUNT notification for net %p%s\n",
 		net, NET_NAME(net));
+	mutex_lock(&sn->pipefs_sb_lock);
 	sn->pipefs_sb = sb;
 	err = blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
 					   RPC_PIPEFS_MOUNT,
@@ -1133,6 +1134,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	if (err)
 		goto err_depopulate;
 	sb->s_fs_info = get_net(net);
+	mutex_unlock(&sn->pipefs_sb_lock);
 	return 0;
 
 err_depopulate:
@@ -1141,6 +1143,7 @@ err_depopulate:
 					   sb);
 	sn->pipefs_sb = NULL;
 	__rpc_depopulate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF);
+	mutex_unlock(&sn->pipefs_sb_lock);
 	return err;
 }
 

