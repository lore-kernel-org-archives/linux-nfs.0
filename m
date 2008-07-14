From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/5] SUNRPC: Introduce a specific rpcb_create for contacting localhost
Date: Mon, 14 Jul 2008 16:03:27 -0400
Message-ID: <1216065811-28559-2-git-send-email-bfields@citi.umich.edu>
References: <76bd70e30807111211m567e9f8cv38a975bbc9df5758@mail.gmail.com>
 <1216065811-28559-1-git-send-email-bfields@citi.umich.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	chucklever@gmail.com, Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43905 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756235AbYGNUDd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jul 2008 16:03:33 -0400
In-Reply-To: <1216065811-28559-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Add rpcb_create_local() for use by rpcb_register() and upcoming IPv6
registration functions.

Ensure any errors encountered by rpcb_create_local() are properly
reported.

We can also use a statically allocated constant loopback socket address
instead of one allocated on the stack and initialized every time the
function is called.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpcb_clnt.c |   42 +++++++++++++++++++++++++++++++-----------
 1 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0021fad..35c1ded 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -116,6 +116,29 @@ static void rpcb_map_release(void *data)
 	kfree(map);
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
@@ -161,10 +184,6 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
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
@@ -184,14 +203,15 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
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
-- 
1.5.5.rc1

