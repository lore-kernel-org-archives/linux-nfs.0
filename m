From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/5] SUNRPC: Refactor rpcb_register to make rpcbindv4 support easier
Date: Mon, 14 Jul 2008 16:03:29 -0400
Message-ID: <1216065811-28559-4-git-send-email-bfields@citi.umich.edu>
References: <76bd70e30807111211m567e9f8cv38a975bbc9df5758@mail.gmail.com>
 <1216065811-28559-1-git-send-email-bfields@citi.umich.edu>
 <1216065811-28559-2-git-send-email-bfields@citi.umich.edu>
 <1216065811-28559-3-git-send-email-bfields@citi.umich.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	chucklever@gmail.com, Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43909 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756527AbYGNUDd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jul 2008 16:03:33 -0400
In-Reply-To: <1216065811-28559-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

rpcbind version 4 registration will reuse part of rpcb_register, so just
split it out into a separate function now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpcb_clnt.c |   48 ++++++++++++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 691bd21..8b75c30 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -168,6 +168,30 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
+static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
+			      u32 version, struct rpc_message *msg,
+			      int *result)
+{
+	struct rpc_clnt *rpcb_clnt;
+	int error = 0;
+
+	*result = 0;
+
+	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
+	if (!IS_ERR(rpcb_clnt)) {
+		error = rpc_call_sync(rpcb_clnt, msg, 0);
+		rpc_shutdown_client(rpcb_clnt);
+	} else
+		error = PTR_ERR(rpcb_clnt);
+
+	if (error < 0)
+		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+				"server (errno %d).\n", -error);
+	dprintk("RPC:       registration status %d/%d\n", error, *result);
+
+	return error;
+}
+
 /**
  * rpcb_register - set or unset a port registration with the local rpcbind svc
  * @prog: RPC program number to bind
@@ -189,33 +213,21 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 		.r_port		= port,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= &rpcb_procedures2[port ?
-					RPCBPROC_SET : RPCBPROC_UNSET],
 		.rpc_argp	= &map,
 		.rpc_resp	= okay,
 	};
-	struct rpc_clnt *rpcb_clnt;
-	int error = 0;
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
 			"rpcbind\n", (port ? "" : "un"),
 			prog, vers, prot, port);
 
-	rpcb_clnt = rpcb_create_local((struct sockaddr *)&rpcb_inaddr_loopback,
-					sizeof(rpcb_inaddr_loopback),
-					RPCBVERS_2);
-	if (!IS_ERR(rpcb_clnt)) {
-		error = rpc_call_sync(rpcb_clnt, &msg, 0);
-		rpc_shutdown_client(rpcb_clnt);
-	} else
-		error = PTR_ERR(rpcb_clnt);
+	msg.rpc_proc = &rpcb_procedures2[RPCBPROC_UNSET];
+	if (port)
+		msg.rpc_proc = &rpcb_procedures2[RPCBPROC_SET];
 
-	if (error < 0)
-		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
-				"server (errno %d).\n", -error);
-	dprintk("RPC:       registration status %d/%d\n", error, *okay);
-
-	return error;
+	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
+					sizeof(rpcb_inaddr_loopback),
+					RPCBVERS_2, &msg, okay);
 }
 
 /**
-- 
1.5.5.rc1

