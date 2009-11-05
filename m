From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/11] SUNRPC: Use TCP for local rpcbind upcalls
Date: Thu, 05 Nov 2009 13:23:27 -0500
Message-ID: <20091105182327.2796.55525.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:43335
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755238AbZKESX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:23:29 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use TCP with the soft connect semantic for local rpcbind upcalls so
the kernel can detect immediately if the local rpcbind daemon is not
running.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 1ec4a1a..1698f50 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -170,7 +170,7 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
 static int rpcb_create_local(void)
 {
 	struct rpc_create_args args = {
-		.protocol	= XPRT_TRANSPORT_UDP,
+		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= (struct sockaddr *)&rpcb_inaddr_loopback,
 		.addrsize	= sizeof(rpcb_inaddr_loopback),
 		.servername	= "localhost",
@@ -243,7 +243,7 @@ static int rpcb_register_call(struct rpc_clnt *clnt, struct rpc_message *msg)
 
 	msg->rpc_resp = &result;
 
-	error = rpc_call_sync(clnt, msg, 0);
+	error = rpc_call_sync(clnt, msg, RPC_TASK_SOFTCONN);
 	if (error < 0) {
 		dprintk("RPC:       failed to contact local rpcbind "
 				"server (errno %d).\n", -error);

