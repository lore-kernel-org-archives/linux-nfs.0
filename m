From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/11] SUNRPC: Simplify synopsis of rpcb_local_clnt()
Date: Thu, 05 Nov 2009 13:23:12 -0500
Message-ID: <20091105182312.2796.59339.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:43329
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755171AbZKESXO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:23:14 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: At one point, rpcb_local_clnt() handled IPv6 loopback
addresses too, but it doesn't any more; only IPv4 loopback is used
now.  Get rid of the @addr and @addrlen arguments to
rpcb_local_clnt().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 830faf4..28f50da 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -163,13 +163,12 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
 	.sin_port		= htons(RPCBIND_PORT),
 };
 
-static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
-					  size_t addrlen, u32 version)
+static struct rpc_clnt *rpcb_create_local(u32 version)
 {
 	struct rpc_create_args args = {
 		.protocol	= XPRT_TRANSPORT_UDP,
-		.address	= addr,
-		.addrsize	= addrlen,
+		.address	= (struct sockaddr *)&rpcb_inaddr_loopback,
+		.addrsize	= sizeof(rpcb_inaddr_loopback),
 		.servername	= "localhost",
 		.program	= &rpcb_program,
 		.version	= version,
@@ -211,14 +210,12 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 
 static int rpcb_register_call(const u32 version, struct rpc_message *msg)
 {
-	struct sockaddr *addr = (struct sockaddr *)&rpcb_inaddr_loopback;
-	size_t addrlen = sizeof(rpcb_inaddr_loopback);
 	struct rpc_clnt *rpcb_clnt;
 	int result, error = 0;
 
 	msg->rpc_resp = &result;
 
-	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
+	rpcb_clnt = rpcb_create_local(version);
 	if (!IS_ERR(rpcb_clnt)) {
 		error = rpc_call_sync(rpcb_clnt, msg, 0);
 		rpc_shutdown_client(rpcb_clnt);

