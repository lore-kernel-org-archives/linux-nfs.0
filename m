From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] SUNRPC: Simplify svc_unregister()
Date: Fri, 30 Jan 2009 15:11:04 -0500
Message-ID: <20090130201104.22301.84592.stgit@ingres.1015granger.net>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45936 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949AbZA3ULY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:11:24 -0500
In-Reply-To: <20090130200021.22301.22618.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Olaf Kirch says a v2 UNSET should clear all rpcbind entries for an RPC
service, even those created with a rpcbind v4 SET.  Change
svc_unregister() to use a v2 UNSET unconditionally.

This simplifies the code in svc_unregister() and provides better
backwards compatibility with legacy user space that does not support
rpcbind version 4.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   26 ++++----------------------
 1 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a278a82..8dc4a1e 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -896,26 +896,10 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 	return error;
 }
 
-#ifdef CONFIG_SUNRPC_REGISTER_V4
-
-static void __svc_unregister(const u32 program, const u32 version,
-			     const char *progname)
-{
-	struct sockaddr_in6 sin6 = {
-		.sin6_family		= AF_INET6,
-		.sin6_addr		= IN6ADDR_ANY_INIT,
-		.sin6_port		= 0,
-	};
-	int error;
-
-	error = rpcb_v4_register(program, version,
-				(struct sockaddr *)&sin6, "");
-	dprintk("svc: %s(%sv%u), error %d\n",
-			__func__, progname, version, error);
-}
-
-#else	/* CONFIG_SUNRPC_REGISTER_V4 */
-
+/*
+ * Olaf says a v2 UNSET should clear _all_ entries, including any
+ * registered via a v4 SET
+ */
 static void __svc_unregister(const u32 program, const u32 version,
 			     const char *progname)
 {
@@ -926,8 +910,6 @@ static void __svc_unregister(const u32 program, const u32 version,
 			__func__, progname, version, error);
 }
 
-#endif	/* CONFIG_SUNRPC_REGISTER_V4 */
-
 /*
  * All netids, bind addresses and ports registered for [program, version]
  * are removed from the local rpcbind database (if the service is not

