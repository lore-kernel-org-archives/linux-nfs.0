From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/23] SUNRPC: rpcb_register() should handle errors silently
Date: Wed, 18 Mar 2009 20:47:44 -0400
Message-ID: <20090319004743.32404.66023.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50867 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbZCSAsl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:48:41 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move error reporting for RPC registration to rpcb_register's caller.

This way the caller can choose to recover silently from certain
errors, but report errors it does not recognize.  Error reporting
for kernel RPC service registration is now handled in one place.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    2 +-
 net/sunrpc/svc.c       |   18 +++++++++++-------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8ea8907..beee6da 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -194,7 +194,7 @@ static int rpcb_register_call(const u32 version, struct rpc_message *msg)
 		error = PTR_ERR(rpcb_clnt);
 
 	if (error < 0) {
-		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+		dprintk("RPC:       failed to contact local rpcbind "
 				"server (errno %d).\n", -error);
 		return error;
 	}
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 142f647..8ba654b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -818,26 +818,30 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
  * Returns zero on success; a negative errno value is returned
  * if any error occurs.
  */
-static int __svc_register(const u32 program, const u32 version,
+static int __svc_register(const char *progname,
+			  const u32 program, const u32 version,
 			  const int family,
 			  const unsigned short protocol,
 			  const unsigned short port)
 {
-	int error;
+	int error = -EAFNOSUPPORT;
 
 	switch (family) {
 	case PF_INET:
-		return __svc_rpcb_register4(program, version,
+		error = __svc_rpcb_register4(program, version,
 						protocol, port);
 		break;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case PF_INET6:
-		return__svc_rpcb_register6(program, version,
+		error = __svc_rpcb_register6(program, version,
 						protocol, port);
 #endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	}
 
-	return -EAFNOSUPPORT;
+	if (error < 0)
+		printk(KERN_WARNING "svc: failed to register %sv%u RPC "
+			"service (errno %d).\n", progname, version, -error);
+	return error;
 }
 
 /**
@@ -875,8 +879,8 @@ int svc_register(const struct svc_serv *serv, const int family,
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = __svc_register(progp->pg_prog, i,
-						family, proto, port);
+			error = __svc_register(progp->pg_name, progp->pg_prog,
+						i, family, proto, port);
 			if (error < 0)
 				break;
 		}

