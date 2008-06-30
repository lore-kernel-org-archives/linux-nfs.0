From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] SUNRPC: Introduce a specific rpcb_create for contacting
	localhost
Date: Mon, 30 Jun 2008 18:38:51 -0400
Message-ID: <20080630223851.24534.81772.stgit@ellison.1015granger.net>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11348 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764018AbYF3Wjx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:39:53 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add rpcb_create_local() for use by rpcb_register() and upcoming IPv6
registration functions.

Ensure any errors encountered by rpcb_create_local() are properly
reported.

We can also use a statically allocated constant loopback socket address
instead of one allocated on the stack and initialized every time the
function is called.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   42 +++++++++++++++++++++++++++++++-----------
 1 files changed, 31 insertions(+), 11 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 756e4f0..7f48031 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -112,6 +112,29 @@ static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
 	rpc_wake_up_status(&xprt->binding, status);
 }
 
+static const struct sockaddr_in rpcb_inaddr_loopback = {
+	.sin_family		= AF_INET,
+	.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	.sin_port		= htons(RPCBIND_PORT),
+};
+
+static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
+					  size_t addrlen, u32 version)
+{
+	struct rpc_create_args args = {
+		.protocol	= XPRT_TRANSPORT_UDP,
+		.address	= addr,
+		.addrsize	= addrlen,
+		.servername	= "localhost",
+		.program	= &rpcb_program,
+		.version	= version,
+		.authflavor	= RPC_AUTH_UNIX,
+		.flags		= RPC_CLNT_CREATE_NOPING,
+	};
+
+	return rpc_create(&args);
+}
+
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 				    size_t salen, int proto, u32 version,
 				    int privileged)
@@ -157,10 +180,6 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
  */
 int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 {
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
-	};
 	struct rpcbind_args map = {
 		.r_prog		= prog,
 		.r_vers		= vers,
@@ -180,14 +199,15 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 			"rpcbind\n", (port ? "" : "un"),
 			prog, vers, prot, port);
 
-	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
-				sizeof(sin), XPRT_TRANSPORT_UDP, RPCBVERS_2, 1);
-	if (IS_ERR(rpcb_clnt))
-		return PTR_ERR(rpcb_clnt);
+	rpcb_clnt = rpcb_create_local((struct sockaddr *)&rpcb_inaddr_loopback,
+					sizeof(rpcb_inaddr_loopback),
+					RPCBVERS_2);
+	if (!IS_ERR(rpcb_clnt)) {
+		error = rpc_call_sync(rpcb_clnt, &msg, 0);
+		rpc_shutdown_client(rpcb_clnt);
+	} else
+		error = PTR_ERR(rpcb_clnt);
 
-	error = rpc_call_sync(rpcb_clnt, &msg, 0);
-
-	rpc_shutdown_client(rpcb_clnt);
 	if (error < 0)
 		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
 				"server (errno %d).\n", -error);

