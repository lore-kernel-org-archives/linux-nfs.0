Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26362 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192Ab2C0Rqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Mar 2012 13:46:38 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] SUNRPC: Use the already looked-up xprt in rpcb_getport_async()
Date: Tue, 27 Mar 2012 13:46:32 -0400
Message-Id: <1332870392-27949-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

rbcb_getport_async() was looking up the rpc_xprt (reference++) and then
later looking it up again (reference++) to pass through the
rpcbind_args.  The xprt would only be dereferenced once, when we were
done with the rpcbind_args (reference--).  This leaves an extra
reference to the transport that would never go away.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 net/sunrpc/rpcb_clnt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4f8af63..4cb71df 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -734,7 +734,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_vers = clnt->cl_vers;
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
-	map->r_xprt = xprt_get(xprt);
+	map->r_xprt = xprt;
 	map->r_status = -EIO;
 
 	switch (bind_version) {
-- 
1.7.9.4

