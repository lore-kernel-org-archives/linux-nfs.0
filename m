From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] SUNRPC: Refactor rpcb_register to make rpcbindv4 support
	easier
Date: Mon, 30 Jun 2008 18:39:07 -0400
Message-ID: <20080630223906.24534.93043.stgit@ellison.1015granger.net>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11392 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764347AbYF3Wj4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:39:56 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcbind version 4 registration will reuse part of rpcb_register, so just
split it out into a separate function now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   48 ++++++++++++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 18 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index f106740..f242c2d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -164,6 +164,30 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
+static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
+			      u32 version, struct rpc_message *msg,
+			      int *result)
+{
+	struct rpc_clnt *rpcb_clnt;
+	int error = 0;
+
+	*result = 0;
+
+	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
+	if (!IS_ERR(rpcb_clnt)) {
+		error = rpc_call_sync(rpcb_clnt, msg, 0);
+		rpc_shutdown_client(rpcb_clnt);
+	} else
+		error = PTR_ERR(rpcb_clnt);
+
+	if (error < 0)
+		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+				"server (errno %d).\n", -error);
+	dprintk("RPC:       registration status %d/%d\n", error, *result);
+
+	return error;
+}
+
 /**
  * rpcb_register - set or unset a port registration with the local rpcbind svc
  * @prog: RPC program number to bind
@@ -185,33 +209,21 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 		.r_port		= port,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= &rpcb_procedures2[port ?
-					RPCBPROC_SET : RPCBPROC_UNSET],
 		.rpc_argp	= &map,
 		.rpc_resp	= okay,
 	};
-	struct rpc_clnt *rpcb_clnt;
-	int error = 0;
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
 			"rpcbind\n", (port ? "" : "un"),
 			prog, vers, prot, port);
 
-	rpcb_clnt = rpcb_create_local((struct sockaddr *)&rpcb_inaddr_loopback,
-					sizeof(rpcb_inaddr_loopback),
-					RPCBVERS_2);
-	if (!IS_ERR(rpcb_clnt)) {
-		error = rpc_call_sync(rpcb_clnt, &msg, 0);
-		rpc_shutdown_client(rpcb_clnt);
-	} else
-		error = PTR_ERR(rpcb_clnt);
+	msg.rpc_proc = &rpcb_procedures2[RPCBPROC_UNSET];
+	if (port)
+		msg.rpc_proc = &rpcb_procedures2[RPCBPROC_SET];
 
-	if (error < 0)
-		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
-				"server (errno %d).\n", -error);
-	dprintk("RPC:       registration status %d/%d\n", error, *okay);
-
-	return error;
+	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
+					sizeof(rpcb_inaddr_loopback),
+					RPCBVERS_2, &msg, okay);
 }
 
 /**

