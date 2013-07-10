Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:1732 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754342Ab3GJUBF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jul 2013 16:01:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@netapp.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] SUNRPC: Fix a deadlock in rpc_client_register()
Date: Wed, 10 Jul 2013 16:00:59 -0400
Message-Id: <1373486459-18142-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 384816051ca9125cd54750e59c780c2a2655fa4f (SUNRPC: fix races on
PipeFS MOUNT notifications) introduces a regression when we call
rpc_setup_pipedir() with RPCSEC_GSS as the auth flavour.

By calling rpcauth_create() while holding the sn->pipefs_sb_lock, we
end up deadlocking in gss_pipes_dentries_create_net().
Fix is to register the client and release the mutex before calling
rpcauth_create().

Reported-by: Weston Andros Adamson <dros@netapp.com>
Tested-by: Weston Andros Adamson <dros@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: <stable@vger.kernel.org> # : 3848160: SUNRPC: fix races on PipeFS MOUNT
Cc: <stable@vger.kernel.org> # : e73f4cc: SUNRPC: split client creation
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f0339ae9..aa40156 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -290,7 +290,7 @@ static int rpc_client_register(const struct rpc_create_args *args,
 	struct rpc_auth *auth;
 	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
-	int err = 0;
+	int err;
 
 	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
@@ -299,6 +299,10 @@ static int rpc_client_register(const struct rpc_create_args *args,
 			goto out;
 	}
 
+	rpc_register_client(clnt);
+	if (pipefs_sb)
+		rpc_put_sb_net(net);
+
 	auth = rpcauth_create(args->authflavor, clnt);
 	if (IS_ERR(auth)) {
 		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
@@ -306,16 +310,14 @@ static int rpc_client_register(const struct rpc_create_args *args,
 		err = PTR_ERR(auth);
 		goto err_auth;
 	}
-
-	rpc_register_client(clnt);
+	return 0;
+err_auth:
+	pipefs_sb = rpc_get_sb_net(net);
+	__rpc_clnt_remove_pipedir(clnt);
 out:
 	if (pipefs_sb)
 		rpc_put_sb_net(net);
 	return err;
-
-err_auth:
-	__rpc_clnt_remove_pipedir(clnt);
-	goto out;
 }
 
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
-- 
1.8.3.1

