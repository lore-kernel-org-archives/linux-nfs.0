From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 079/112] SUNRPC: cleanup for rpc_new_client()
Date: Fri, 25 Jan 2008 11:37:51 -0500
Message-ID: <20080125163751.31887.60476.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14407 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756312AbYAYRAW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:22 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmc010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:21 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no reason why we shouldn't just pass the rpc_create_args.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 3af35ab..6a6b96e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -122,8 +122,9 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	}
 }
 
-static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, struct rpc_program *program, u32 vers, rpc_authflavor_t flavor)
+static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
 {
+	struct rpc_program	*program = args->program;
 	struct rpc_version	*version;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
@@ -132,13 +133,13 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 
 	/* sanity check the name before trying to print it */
 	err = -EINVAL;
-	len = strlen(servname);
+	len = strlen(args->servername);
 	if (len > RPC_MAXNETNAMELEN)
 		goto out_no_rpciod;
 	len++;
 
 	dprintk("RPC:       creating %s client for %s (xprt %p)\n",
-			program->name, servname, xprt);
+			program->name, args->servername, xprt);
 
 	err = rpciod_up();
 	if (err)
@@ -146,7 +147,11 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	err = -EINVAL;
 	if (!xprt)
 		goto out_no_xprt;
-	if (vers >= program->nrvers || !(version = program->version[vers]))
+
+	if (args->version >= program->nrvers)
+		goto out_err;
+	version = program->version[args->version];
+	if (version == NULL)
 		goto out_err;
 
 	err = -ENOMEM;
@@ -158,12 +163,12 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	clnt->cl_server = clnt->cl_inline_name;
 	if (len > sizeof(clnt->cl_inline_name)) {
 		char *buf = kmalloc(len, GFP_KERNEL);
-		if (buf != 0)
+		if (buf != NULL)
 			clnt->cl_server = buf;
 		else
 			len = sizeof(clnt->cl_inline_name);
 	}
-	strlcpy(clnt->cl_server, servname, len);
+	strlcpy(clnt->cl_server, args->servername, len);
 
 	clnt->cl_xprt     = xprt;
 	clnt->cl_procinfo = version->procs;
@@ -192,10 +197,10 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	if (err < 0)
 		goto out_no_path;
 
-	auth = rpcauth_create(flavor, clnt);
+	auth = rpcauth_create(args->authflavor, clnt);
 	if (IS_ERR(auth)) {
 		printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
-				flavor);
+				args->authflavor);
 		err = PTR_ERR(auth);
 		goto out_no_auth;
 	}
@@ -297,8 +302,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
-	clnt = rpc_new_client(xprt, args->servername, args->program,
-				args->version, args->authflavor);
+	clnt = rpc_new_client(args, xprt);
 	if (IS_ERR(clnt))
 		return clnt;
 
