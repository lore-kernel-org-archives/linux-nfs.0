From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/40] SUNRPC: Simplify svc_unregister()
Date: Thu, 12 Mar 2009 12:08:52 -0400
Message-ID: <20090312160851.16019.22149.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:62894 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836AbZCLQJT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:09:19 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our initial implementation of svc_unregister() assumed that PMAP_UNSET
cleared all rpcbind registrations for a [program, version] tuple.
However, we now have evidence that PMAP_UNSET clears only "inet"
entries, and not "inet6" entries, in the rpcbind database.

For backwards compatibility with the legacy portmapper, the
svc_unregister() function also must work if user space doesn't support
rpcbind version 4 at all.

Thus we'll send an rpcbind v4 UNSET, and if that fails, we'll send a
PMAP_UNSET.

This simplifies the code in svc_unregister() and provides better
backwards compatibility with legacy user space that does not support
rpcbind version 4.  We can get rid of the conditional compilation in
here as well.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   35 ++++++++++++++---------------------
 1 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 17e0d72..bd0ee31 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -896,38 +896,31 @@ int svc_register(const struct svc_serv *serv, const int family,
 	return error;
 }
 
-#ifdef CONFIG_SUNRPC_REGISTER_V4
-
+/*
+ * If user space is running rpcbind, it should take the v4 UNSET
+ * and clear everything for this [program, version].  If user space
+ * is running portmap, it will reject the v4 UNSET, but won't have
+ * any "inet6" entries anyway.  So a PMAP_UNSET should be sufficient
+ * in this case to clear all existing entries for [program, version].
+ */
 static void __svc_unregister(const u32 program, const u32 version,
 			     const char *progname)
 {
-	struct sockaddr_in6 sin6 = {
-		.sin6_family		= AF_INET6,
-		.sin6_addr		= IN6ADDR_ANY_INIT,
-		.sin6_port		= 0,
-	};
 	int error;
 
-	error = rpcb_v4_register(program, version,
-				(struct sockaddr *)&sin6, "");
-	dprintk("svc: %s(%sv%u), error %d\n",
-			__func__, progname, version, error);
-}
-
-#else	/* CONFIG_SUNRPC_REGISTER_V4 */
+	error = rpcb_v4_register(program, version, NULL, "");
 
-static void __svc_unregister(const u32 program, const u32 version,
-			     const char *progname)
-{
-	int error;
+	/*
+	 * User space didn't support rpcbind v4, so retry this
+	 * request with the legacy rpcbind v2 protocol.
+	 */
+	if (error == -EPROTONOSUPPORT)
+		error = rpcb_register(program, version, 0, 0);
 
-	error = rpcb_register(program, version, 0, 0);
 	dprintk("svc: %s(%sv%u), error %d\n",
 			__func__, progname, version, error);
 }
 
-#endif	/* CONFIG_SUNRPC_REGISTER_V4 */
-
 /*
  * All netids, bind addresses and ports registered for [program, version]
  * are removed from the local rpcbind database (if the service is not

