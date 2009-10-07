From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] SUNRPC: Use TCP for local rpcbind upcalls
Date: Wed, 07 Oct 2009 18:02:55 -0400
Message-ID: <20091007220255.1844.3965.stgit@matisse.1015granger.net>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:52169
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754773AbZJGWDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 18:03:32 -0400
Received: from matisse.1015granger.net (matisse.1015granger.net [127.0.0.1])
	by matisse.1015granger.net (8.14.3/8.14.3) with ESMTP id n97M2tAS001997
	for <linux-nfs@vger.kernel.org>; Wed, 7 Oct 2009 18:02:55 -0400
In-Reply-To: <20091007215019.1844.17414.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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
index a6fb65e..d2edcdf 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -170,7 +170,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 					  size_t addrlen, u32 version)
 {
 	struct rpc_create_args args = {
-		.protocol	= XPRT_TRANSPORT_UDP,
+		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= addr,
 		.addrsize	= addrlen,
 		.servername	= "localhost",
@@ -218,7 +218,7 @@ static int rpcb_register_call(struct rpc_clnt *clnt, struct rpc_message *msg)
 
 	msg->rpc_resp = &result;
 
-	error = rpc_call_sync(clnt, msg, 0);
+	error = rpc_call_sync(clnt, msg, RPC_TASK_SOFTCONN);
 	if (error < 0) {
 		dprintk("RPC:       failed to contact local rpcbind "
 				"server (errno %d).\n", -error);

