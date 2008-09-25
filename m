From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] SUNRPC: Fix up svc_unregister()
Date: Thu, 25 Sep 2008 11:56:57 -0400
Message-ID: <20080925155655.8353.87098.stgit@manray.1015granger.net>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21796 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbYIYP6j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 11:58:39 -0400
In-Reply-To: <20080925154814.8353.64762.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the new rpcbind code, a PMAP_UNSET will not have any effect on
services registered via rpcbind v3 or v4.

Implement a version of svc_unregister() that uses an RPCB_UNSET with
an empty netid string to make sure we have cleared *all* entries for
a kernel RPC service when shutting down, or before starting a fresh
instance of the service.

Use the new version only when CONFIG_SUNRPC_REGISTER_V4 is enabled;
otherwise, the legacy PMAP version is used to ensure complete
backwards-compatibility with the Linux portmapper daemon.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   58 +++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 38 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5089014..e626f01 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -897,31 +897,51 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 	return error;
 }
 
+#ifdef CONFIG_SUNRPC_REGISTER_V4
+
+static void __svc_unregister(const u32 program, const u32 version,
+			     const char *progname)
+{
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+		.sin6_port		= 0,
+	};
+	int error;
+
+	error = rpcb_v4_register(program, version,
+				(struct sockaddr *)&sin6, "");
+	dprintk("svc: %s(%sv%u), error %d\n",
+			__func__, progname, version, error);
+}
+
+#else	/* CONFIG_SUNRPC_REGISTER_V4 */
+
+static void __svc_unregister(const u32 program, const u32 version,
+			     const char *progname)
+{
+	int error;
+
+	error = rpcb_register(program, version, 0, 0);
+	dprintk("svc: %s(%sv%u), error %d\n",
+			__func__, progname, version, error);
+}
+
+#endif	/* CONFIG_SUNRPC_REGISTER_V4 */
+
 /*
- * All transport protocols and ports for this service are removed
- * from the local rpcbind database if the service is not hidden.
- *
- * The result of unregistration is reported via dprintk for those
- * who want verification of the result, but is otherwise not
- * important.
+ * All netids, bind addresses and ports registered for [program, version]
+ * are removed from the local rpcbind database (if the service is not
+ * hidden) to make way for a new instance of the service.
  *
- * The local rpcbind daemon listens on either only IPv6 or only
- * IPv4.  The kernel can't tell how it's configured.  However,
- * AF_INET addresses are mapped to AF_INET6 in IPv6-only config-
- * urations, so even an unregistration request on AF_INET will
- * get to a local rpcbind daemon listening only on AF_INET6.  So
- * we always unregister via AF_INET.
- *
- * At this point we don't need rpcbind version 4 for unregis-
- * tration:  A v2 UNSET request will clear all transports (netids),
- * addresses, and address families for [program, version].
+ * The result of unregistration is reported via dprintk for those who want
+ * verification of the result, but is otherwise not important.
  */
 static void svc_unregister(const struct svc_serv *serv)
 {
 	struct svc_program *progp;
 	unsigned long flags;
 	unsigned int i;
-	int error;
 
 	clear_thread_flag(TIF_SIGPENDING);
 
@@ -932,9 +952,7 @@ static void svc_unregister(const struct svc_serv *serv)
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = rpcb_register(progp->pg_prog, i, 0, 0);
-			dprintk("svc: svc_unregister(%sv%u), error %d\n",
-					progp->pg_name, i, error);
+			__svc_unregister(progp->pg_prog, i, progp->pg_name);
 		}
 	}
 

