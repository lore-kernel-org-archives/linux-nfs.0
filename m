From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/5] SUNRPC: None of rpcb_create's callers wants a privileged source port
Date: Mon, 14 Jul 2008 16:03:28 -0400
Message-ID: <1216065811-28559-3-git-send-email-bfields@citi.umich.edu>
References: <76bd70e30807111211m567e9f8cv38a975bbc9df5758@mail.gmail.com>
 <1216065811-28559-1-git-send-email-bfields@citi.umich.edu>
 <1216065811-28559-2-git-send-email-bfields@citi.umich.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	chucklever@gmail.com, Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43907 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756259AbYGNUDd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jul 2008 16:03:33 -0400
In-Reply-To: <1216065811-28559-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: Callers that required a privileged source port now use
rpcb_create_local(), so we can remove the @privileged argument from
rpcb_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpcb_clnt.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 35c1ded..691bd21 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -140,8 +140,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, u32 version,
-				    int privileged)
+				    size_t salen, int proto, u32 version)
 {
 	struct rpc_create_args args = {
 		.protocol	= proto,
@@ -151,7 +150,8 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= RPC_CLNT_CREATE_NOPING,
+		.flags		= (RPC_CLNT_CREATE_NOPING |
+					RPC_CLNT_CREATE_NONPRIVPORT),
 	};
 
 	switch (srvaddr->sa_family) {
@@ -165,8 +165,6 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		return NULL;
 	}
 
-	if (!privileged)
-		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 	return rpc_create(&args);
 }
 
@@ -255,7 +253,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 		__func__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
-				sizeof(*sin), prot, RPCBVERS_2, 0);
+				sizeof(*sin), prot, RPCBVERS_2);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -365,7 +363,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		task->tk_pid, __func__, bind_version);
 
 	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
-				bind_version, 0);
+				bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
-- 
1.5.5.rc1

