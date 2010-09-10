Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34515 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab0IJUEQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:04:16 -0400
Received: by gyd8 with SMTP id 8so1363707gyd.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:04:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] SUNRPC: Remove rpcb_getport_sync()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:04:12 -0400
Message-ID: <20100910200412.13167.6631.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
References: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: rpcb_getport_sync() has no more users, so remove it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 -
 net/sunrpc/rpcb_clnt.c      |   51 -------------------------------------------
 2 files changed, 0 insertions(+), 52 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 569dc72..a1a40f0 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -137,7 +137,6 @@ int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
 				 const char *netid);
-int		rpcb_getport_sync(struct sockaddr_in *, u32, u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_start(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index dac219a..c961094 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -475,57 +475,6 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	return -EAFNOSUPPORT;
 }
 
-/**
- * rpcb_getport_sync - obtain the port for an RPC service on a given host
- * @sin: address of remote peer
- * @prog: RPC program number to bind
- * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
- *
- * Return value is the requested advertised port number,
- * or a negative errno value.
- *
- * Called from outside the RPC client in a synchronous task context.
- * Uses default timeout parameters specified by underlying transport.
- *
- * XXX: Needs to support IPv6
- */
-int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
-{
-	struct rpcbind_args map = {
-		.r_prog		= prog,
-		.r_vers		= vers,
-		.r_prot		= prot,
-		.r_port		= 0,
-	};
-	struct rpc_message msg = {
-		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
-		.rpc_argp	= &map,
-		.rpc_resp	= &map,
-	};
-	struct rpc_clnt	*rpcb_clnt;
-	int status;
-
-	dprintk("RPC:       %s(%pI4, %u, %u, %d)\n",
-		__func__, &sin->sin_addr.s_addr, prog, vers, prot);
-
-	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
-				sizeof(*sin), prot, RPCBVERS_2);
-	if (IS_ERR(rpcb_clnt))
-		return PTR_ERR(rpcb_clnt);
-
-	status = rpc_call_sync(rpcb_clnt, &msg, 0);
-	rpc_shutdown_client(rpcb_clnt);
-
-	if (status >= 0) {
-		if (map.r_port != 0)
-			return map.r_port;
-		status = -EACCES;
-	}
-	return status;
-}
-EXPORT_SYMBOL_GPL(rpcb_getport_sync);
-
 static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbind_args *map, struct rpc_procinfo *proc)
 {
 	struct rpc_message msg = {

