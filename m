From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] SUNRPC: None of rpcb_create's callers wants a privileged
	source port
Date: Mon, 30 Jun 2008 18:38:59 -0400
Message-ID: <20080630223858.24534.99447.stgit@ellison.1015granger.net>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:44408 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761662AbYF3Wjv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:39:51 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Callers that required a privileged source port now use
rpcb_create_local(), so we can remove the @privileged argument from
rpcb_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 7f48031..f106740 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -136,8 +136,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, u32 version,
-				    int privileged)
+				    size_t salen, int proto, u32 version)
 {
 	struct rpc_create_args args = {
 		.protocol	= proto,
@@ -147,7 +146,8 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= RPC_CLNT_CREATE_NOPING,
+		.flags		= (RPC_CLNT_CREATE_NOPING |
+					RPC_CLNT_CREATE_NONPRIVPORT),
 	};
 
 	switch (srvaddr->sa_family) {
@@ -161,8 +161,6 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		return NULL;
 	}
 
-	if (!privileged)
-		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 	return rpc_create(&args);
 }
 
@@ -251,7 +249,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 		__func__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
-				sizeof(*sin), prot, RPCBVERS_2, 0);
+				sizeof(*sin), prot, RPCBVERS_2);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -361,7 +359,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		task->tk_pid, __func__, bind_version);
 
 	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
-				bind_version, 0);
+				bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",

