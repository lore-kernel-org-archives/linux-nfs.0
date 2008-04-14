From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/24] SUNRPC: Document some naked integers in rpcbind client
Date: Mon, 14 Apr 2008 12:28:14 -0400
Message-ID: <20080414162814.12741.20253.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:40697 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761040AbYDNRBM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:01:12 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace naked integers that represent rpcbind protocol versions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   49 +++++++++++++++++++++++++++++++++++-------------
 1 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 904b1f5..d852b2e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -32,6 +32,10 @@
 #define RPCBIND_PROGRAM		(100000u)
 #define RPCBIND_PORT		(111u)
 
+#define RPCBVERS_2		(2u)
+#define RPCBVERS_3		(3u)
+#define RPCBVERS_4		(4u)
+
 enum {
 	RPCBPROC_NULL,
 	RPCBPROC_SET,
@@ -82,7 +86,7 @@ static struct rpc_procinfo rpcb_procedures2[];
 static struct rpc_procinfo rpcb_procedures3[];
 
 struct rpcb_info {
-	int			rpc_vers;
+	u32			rpc_vers;
 	struct rpc_procinfo *	rpc_proc;
 };
 
@@ -177,7 +181,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 			prog, vers, prot, port);
 
 	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
-				sizeof(sin), XPRT_TRANSPORT_UDP, 2, 1);
+				sizeof(sin), XPRT_TRANSPORT_UDP, RPCBVERS_2, 1);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -227,7 +231,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
-				sizeof(*sin), prot, 2, 0);
+				sizeof(*sin), prot, RPCBVERS_2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -589,35 +593,54 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 
 static struct rpcb_info rpcb_next_version[] = {
 #ifdef CONFIG_SUNRPC_BIND34
-	{ 4, &rpcb_procedures4[RPCBPROC_GETVERSADDR] },
-	{ 3, &rpcb_procedures3[RPCBPROC_GETADDR] },
+	{
+		.rpc_vers	= RPCBVERS_4,
+		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETVERSADDR],
+	},
+	{
+		.rpc_vers	= RPCBVERS_3,
+		.rpc_proc	= &rpcb_procedures3[RPCBPROC_GETADDR],
+	},
 #endif
-	{ 2, &rpcb_procedures2[RPCBPROC_GETPORT] },
-	{ 0, NULL },
+	{
+		.rpc_vers	= RPCBVERS_2,
+		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
+	},
+	{
+		.rpc_proc	= NULL,
+	},
 };
 
 static struct rpcb_info rpcb_next_version6[] = {
 #ifdef CONFIG_SUNRPC_BIND34
-	{ 4, &rpcb_procedures4[RPCBPROC_GETVERSADDR] },
-	{ 3, &rpcb_procedures3[RPCBPROC_GETADDR] },
+	{
+		.rpc_vers	= RPCBVERS_4,
+		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETVERSADDR],
+	},
+	{
+		.rpc_vers	= RPCBVERS_3,
+		.rpc_proc	= &rpcb_procedures3[RPCBPROC_GETADDR],
+	},
 #endif
-	{ 0, NULL },
+	{
+		.rpc_proc	= NULL,
+	},
 };
 
 static struct rpc_version rpcb_version2 = {
-	.number		= 2,
+	.number		= RPCBVERS_2,
 	.nrprocs	= RPCB_HIGHPROC_2,
 	.procs		= rpcb_procedures2
 };
 
 static struct rpc_version rpcb_version3 = {
-	.number		= 3,
+	.number		= RPCBVERS_3,
 	.nrprocs	= RPCB_HIGHPROC_3,
 	.procs		= rpcb_procedures3
 };
 
 static struct rpc_version rpcb_version4 = {
-	.number		= 4,
+	.number		= RPCBVERS_4,
 	.nrprocs	= RPCB_HIGHPROC_4,
 	.procs		= rpcb_procedures4
 };

