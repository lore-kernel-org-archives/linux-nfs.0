From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 053/112] SUNRPC: Fix socket address handling in rpcb_clnt
Date: Fri, 25 Jan 2008 11:37:41 -0500
Message-ID: <20080125163740.31887.55928.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755056AbYAYQ74 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:56 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseS010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:55 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Make sure rpcb_clnt passes the correct address length to rpc_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpcb_clnt.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index f876e37..c1310f7 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -148,12 +148,13 @@ static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
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
@@ -216,7 +217,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 			prog, vers, prot, port);
 
 	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
-					XPRT_TRANSPORT_UDP, 2, 1);
+				sizeof(sin), XPRT_TRANSPORT_UDP, 2, 1);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -265,7 +266,8 @@ int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
-	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
+	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin,
+				sizeof(sin), prot, 2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -314,7 +316,9 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;
 	struct rpc_task	*child;
-	struct sockaddr addr;
+	struct sockaddr_storage addr;
+	struct sockaddr *sap = (struct sockaddr *)&addr;
+	size_t salen;
 	int status;
 	struct rpcb_info *info;
 
@@ -344,10 +348,10 @@ void rpcb_getport_async(struct rpc_task *task)
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
@@ -372,7 +376,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __FUNCTION__, bind_version);
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot,
+	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
 				bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
