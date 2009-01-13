From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Clearer error message when user space is running
	portmap
Date: Tue, 13 Jan 2009 12:31:48 -0500
Message-ID: <20090113173148.6755.67348.stgit@ingres.1015granger.net>
References: <20090113172538.6755.83766.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53538 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbZAMRcP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2009 12:32:15 -0500
In-Reply-To: <20090113172538.6755.83766.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Detect the case where we sent an rpcbind v4 UNSET but user space
doesn't support rpcbind protocol version 4.

We down-shift to version 2 and print a warning once in this case.
Olaf says a v2 UNSET should properly clear all entries in the rpcbind
database.

As svc_unregister() is usually done first to clear old portmapper
entries before trying to set up new ones, a v4 UNSET call will almost
always be the first to detect an rpcbind protocol version mismatch
problem.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   51 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a278a82..e93bc55 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -721,6 +721,21 @@ EXPORT_SYMBOL_GPL(svc_exit_thread);
 
 #ifdef CONFIG_SUNRPC_REGISTER_V4
 
+static u32 __svc_register_version = 4;
+
+static void __svc_rpcb_prog_mismatch_error(void)
+{
+	if (__svc_register_version == 4) {
+		printk(KERN_WARNING
+			"svc: The kernel tried an rpcbind version 4 request, "
+			"but your portmapper\n"
+			"svc: does not support rpcbind version 4.  "
+			"Switching to rpcbind version 2.\n");
+
+		__svc_register_version = 2;
+	}
+}
+
 /*
  * Register an "inet" protocol family netid with the local
  * rpcbind daemon via an rpcbind v4 SET request.
@@ -896,10 +911,20 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 	return error;
 }
 
+static void __svc_v2_unregister(const u32 program, const u32 version,
+				const char *progname)
+{
+	int error;
+
+	error = rpcb_register(program, version, 0, 0);
+	dprintk("svc: %s(%sv%u), error %d\n",
+			__func__, progname, version, error);
+}
+
 #ifdef CONFIG_SUNRPC_REGISTER_V4
 
-static void __svc_unregister(const u32 program, const u32 version,
-			     const char *progname)
+static int __svc_v4_unregister(const u32 program, const u32 version,
+			       const char *progname)
 {
 	struct sockaddr_in6 sin6 = {
 		.sin6_family		= AF_INET6,
@@ -912,6 +937,22 @@ static void __svc_unregister(const u32 program, const u32 version,
 				(struct sockaddr *)&sin6, "");
 	dprintk("svc: %s(%sv%u), error %d\n",
 			__func__, progname, version, error);
+	return error;
+}
+
+static void __svc_unregister(const u32 program, const u32 version,
+			     const char *progname)
+{
+	if (__svc_register_version == 4) {
+		int error = __svc_v4_unregister(program, version, progname);
+		if (error != -EPROTONOSUPPORT)
+			return;
+	}
+
+	__svc_rpcb_prog_mismatch_error();
+
+	/* Olaf says a v2 UNSET _should_ wipe everything */
+	__svc_v2_unregister(program, version, progname);
 }
 
 #else	/* CONFIG_SUNRPC_REGISTER_V4 */
@@ -919,11 +960,7 @@ static void __svc_unregister(const u32 program, const u32 version,
 static void __svc_unregister(const u32 program, const u32 version,
 			     const char *progname)
 {
-	int error;
-
-	error = rpcb_register(program, version, 0, 0);
-	dprintk("svc: %s(%sv%u), error %d\n",
-			__func__, progname, version, error);
+	__svc_v2_unregister(program, version, progname);
 }
 
 #endif	/* CONFIG_SUNRPC_REGISTER_V4 */

