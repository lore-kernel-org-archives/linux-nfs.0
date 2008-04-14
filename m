From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/24] SUNRPC: None of rpcb_create's callers wants a
	privileged ephemeral port
Date: Mon, 14 Apr 2008 12:28:36 -0400
Message-ID: <20080414162836.12741.3220.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:51601 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758222AbYDNQ2t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:28:49 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Now that rpcb_register has it's own rpcb_create routine, none
of rpcb_create's current callers needs a privileged ephemeral port.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 9a92baa..8590f4a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -136,8 +136,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, u32 version,
-				    int privileged)
+				    size_t salen, int proto, u32 version)
 {
 	struct rpc_create_args args = {
 		.protocol	= proto,
@@ -147,7 +146,8 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= RPC_CLNT_CREATE_NOPING,
+		.flags		= (RPC_CLNT_CREATE_NOPING |
+					RPC_CLNT_CREATE_NONPRIVPORT),
 	};
 
 	switch (srvaddr->sa_family) {
@@ -161,8 +161,6 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		return NULL;
 	}
 
-	if (!privileged)
-		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 	return rpc_create(&args);
 }
 
@@ -251,7 +249,7 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
-				sizeof(*sin), prot, RPCBVERS_2, 0);
+				sizeof(*sin), prot, RPCBVERS_2);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
 
@@ -361,7 +359,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		task->tk_pid, __FUNCTION__, bind_version);
 
 	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
-				bind_version, 0);
+				bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
 		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",

