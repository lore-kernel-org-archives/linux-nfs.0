From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/27] SUNRPC: Fix socket address handling in rpcb_clnt
Date: Mon, 10 Dec 2007 14:56:31 -0500
Message-ID: <20071210195631.2823.97797.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:1546 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbXLJUQN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:16:13 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure rpcb_clnt passes the correct address length to rpc_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a05493a..363106f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -162,12 +162,13 @@ static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-					int proto, int version, int privileged)
+				    size_t salen, int proto, int version,
+				    int privileged)
 {
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= srvaddr,
-		.addrsize	= sizeof(struct sockaddr_in),
+		.addrsize	= salen,
 		.servername	= hostname,
 		.program	= &rpcb_program,
 		.version	= version,
@@ -230,7 +231,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 			prog, vers, prot, port);
 
 	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
-					XPRT_TRANSPORT_UDP, 2, 1);
+				sizeof(sin), XPRT_TRANSPORT_UDP, 2, 1);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -279,7 +280,8 @@ int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
-	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
+	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin,
+				sizeof(sin), prot, 2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -310,7 +312,9 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;
 	struct rpc_task	*child;
-	struct sockaddr addr;
+	struct sockaddr_storage addr;
+	struct sockaddr *sap = (struct sockaddr *)&addr;
+	size_t salen;
 	int status;
 	struct rpcb_info *info;
 
@@ -340,10 +344,10 @@ void rpcb_getport_async(struct rpc_task *task)
 		goto bailout_nofree;
 	}
 
-	rpc_peeraddr(clnt, (void *)&addr, sizeof(addr));
+	salen = rpc_peeraddr(clnt, sap, sizeof(addr));
 
 	/* Don't ever use rpcbind v2 for AF_INET6 requests */
-	switch (addr.sa_family) {
+	switch (sap->sa_family) {
 	case AF_INET:
 		info = rpcb_next_version;
 		break;
@@ -368,7 +372,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __FUNCTION__, bind_version);
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot,
+	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
 				bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);

