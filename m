Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f178.google.com ([209.85.160.178]:34495 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933856Ab3HIQzz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:55:55 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so1278581ghb.23
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:55:55 -0700 (PDT)
Subject: [PATCH v2 16/33] SUNRPC: Modify synopsis of rpc_client_register()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date: Fri, 09 Aug 2013 12:50:05 -0400
Message-ID: <20130809165005.5362.34943.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc_client_register() helper was added in commit e73f4cc0,
"SUNRPC: split client creation routine into setup and registration,"
Mon Jun 24 11:52:52 2013.

I'd like to invoke rpc_client_register() from a context where a
struct rpc_create_args is not available.  There appear to be only
two fields of interest in struct rpc_create_args: .program and
.authflavor .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/clnt.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 74f6a70..f9e3926 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -279,10 +279,10 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
 }
 
-static int rpc_client_register(const struct rpc_create_args *args,
-			       struct rpc_clnt *clnt)
+static int rpc_client_register(struct rpc_clnt *clnt,
+			       rpc_authflavor_t pseudoflavor)
 {
-	const struct rpc_program *program = args->program;
+	const struct rpc_program *program = clnt->cl_program;
 	struct rpc_auth *auth;
 	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
@@ -299,10 +299,10 @@ static int rpc_client_register(const struct rpc_create_args *args,
 	if (pipefs_sb)
 		rpc_put_sb_net(net);
 
-	auth = rpcauth_create(args->authflavor, clnt);
+	auth = rpcauth_create(pseudoflavor, clnt);
 	if (IS_ERR(auth)) {
 		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
-				args->authflavor);
+				pseudoflavor);
 		err = PTR_ERR(auth);
 		goto err_auth;
 	}
@@ -384,7 +384,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	/* save the nodename */
 	rpc_clnt_set_nodename(clnt, utsname()->nodename);
 
-	err = rpc_client_register(args, clnt);
+	err = rpc_client_register(clnt, args->authflavor);
 	if (err)
 		goto out_no_path;
 	return clnt;

