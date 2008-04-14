From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/24] SUNRPC: Use the new rpcb_v4_register() API in
	svc_unregister()
Date: Mon, 14 Apr 2008 12:29:20 -0400
Message-ID: <20080414162920.12741.9487.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:54722 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759749AbYDNQ3u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:29:50 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unregister both AF_INET and AF_INET6 capabilities for a service advertised
in the local rpcbind database.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   37 +++++++++++++++++++++++++++++++++----
 1 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 576efa7..42f83b4 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -28,6 +28,18 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
+#ifdef CONFIG_SUNRPC_REGISTER_V4
+static const struct sockaddr_in svc_inaddr_any = {
+	.sin_family		= AF_INET,
+	.sin_addr.s_addr	= htonl(INADDR_ANY),
+};
+
+static const struct sockaddr_in6 svc_in6addr_any = {
+	.sin6_family		= AF_INET6,
+	.sin6_addr		= IN6ADDR_ANY_INIT,
+};
+#endif
+
 #define svc_serv_is_pooled(serv)    ((serv)->sv_function)
 
 /*
@@ -800,20 +812,37 @@ static void __svc_unregister(struct svc_program *program, u32 version)
 {
 	int error, boolean = 0;
 
+#ifdef CONFIG_SUNRPC_REGISTER_V4
+	error = rpcb_v4_register(program->pg_prog, version,
+				 (struct sockaddr *)&svc_inaddr_any,
+				 "", &boolean);
+	dprintk("svc: svc_unregister(%sv%u, AF_INET), error %d, %s\n",
+			program->pg_name, version, error,
+			(boolean ? "succeeded" : "failed"));
+
+	boolean = 0;
+	error = rpcb_v4_register(program->pg_prog, version,
+				 (struct sockaddr *)&svc_in6addr_any,
+				 "", &boolean);
+	dprintk("svc: svc_unregister(%sv%u, AF_INET6), error %d, %s\n",
+			program->pg_name, version, error,
+			(boolean ? "succeeded" : "failed"));
+#else
 	error = rpcb_register(program->pg_prog, version, 0, 0, &boolean);
 	dprintk("svc: svc_unregister(%sv%u), error %d, %s\n",
 			program->pg_name, version, error,
 			(boolean ? "succeeded" : "failed"));
+#endif
 }
 
 /**
  * svc_unregister - remove an RPC server from the local rpcbind database
  * @serv: svc_serv struct for the service to register
  *
- * All transport protocols and ports for this service are removed from
- * the local rpcbind database.  The result of unregistration is reported
- * via dprintk for those who want verification of the result, but is
- * otherwise not important.
+ * All address families, transport protocols, and ports for this service
+ * are removed from the local rpcbind database.  The result of unregis-
+ * tration is reported via dprintk for those who want verification of the
+ * result, but is otherwise not important.
  */
 void svc_unregister(const struct svc_serv *serv)
 {

