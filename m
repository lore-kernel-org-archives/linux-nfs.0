From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/27] SUNRPC: RPC version numbers are u32
Date: Mon, 10 Dec 2007 14:56:38 -0500
Message-ID: <20071210195638.2823.26488.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:45657 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbXLJUHX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:07:23 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: use correct type for RPC version numbers in rpcbind client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 363106f..39844b7 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -162,7 +162,7 @@ static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, int version,
+				    size_t salen, int proto, u32 version,
 				    int privileged)
 {
 	struct rpc_create_args args = {
@@ -307,7 +307,7 @@ EXPORT_SYMBOL_GPL(rpcb_getport_sync);
 void rpcb_getport_async(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
-	int bind_version;
+	u32 bind_version;
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;

