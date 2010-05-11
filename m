From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] SUNRPC: Remove rpcb_getport_sync()
Date: Tue, 11 May 2010 13:17:11 -0400
Message-ID: <20100511171710.2167.90625.stgit@matisse.1015granger.net>
References: <20100511170754.2167.72681.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:60854 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245Ab0EKRRQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 13:17:16 -0400
Received: by mail-qy0-f183.google.com with SMTP id 13so8473395qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 10:17:15 -0700 (PDT)
In-Reply-To: <20100511170754.2167.72681.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rpcb_getport_sync() has no more users, so remove it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 -
 net/sunrpc/rpcb_clnt.c      |   51 -------------------------------------------
 2 files changed, 0 insertions(+), 52 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8ed9642..b9a2d4a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -136,7 +136,6 @@ int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
 				 const char *netid);
-int		rpcb_getport_sync(struct sockaddr_in *, u32, u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_start(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 1211053..4fd01f1 100644
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

