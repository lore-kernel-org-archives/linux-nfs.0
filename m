From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] SUNRPC: Use the new rpc_v3_register() API in
	svc_unregister()
Date: Tue, 08 Jan 2008 11:31:17 -0500
Message-ID: <20080108163117.21088.36441.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:32056 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbYAHQbT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:31:19 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m08GVHol010811
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 08:31:18 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m08GVHNS021126
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 11:31:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unregister both AF_INET and AF_INET6 capabilities for a service advertised
in the local rpcbind database.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index eb3bb24..1f4ec51 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -767,11 +767,21 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
  * svc_unregister - remove an RPC server from the local rpcbind database
  * @serv: svc_serv struct for the service to register
  *
- * All transport protocols, and ports for this service are removed from
- * the local rpcbind database.
+ * All address families, transport protocols, and ports for this service
+ * are removed from the local rpcbind database.
  */
 void svc_unregister(struct svc_serv *serv)
 {
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+		.sin_port		= 0,
+	};
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+		.sin6_port		= 0,
+	};
 	struct svc_program *progp;
 	unsigned long flags;
 	u32 version;
@@ -785,7 +795,10 @@ void svc_unregister(struct svc_serv *serv)
 				continue;
 			if (progp->pg_vers[version]->vs_hidden)
 				continue;
-			rpcb_register(progp->pg_prog, version, 0, 0, &dummy);
+			rpcb_v3_register(progp->pg_prog, version,
+					 (struct sockaddr *)&sin, &dummy, "");
+			rpcb_v3_register(progp->pg_prog, version,
+					 (struct sockaddr *)&sin6, &dummy, "");
 		}
 	}
 

