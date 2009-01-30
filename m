From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] SUNRPC: rpcb_register() should handle errors silently
Date: Fri, 30 Jan 2009 15:11:19 -0500
Message-ID: <20090130201119.22301.77485.stgit@ingres.1015granger.net>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64626 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbZA3ULj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:11:39 -0500
In-Reply-To: <20090130200021.22301.22618.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move error reporting for RPC registration to rpcb_register's caller.

This way the caller can recover silently from certain errors, but
report errors it does not recognize.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    2 +-
 net/sunrpc/svc.c       |   22 +++++++++++++++-------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0e9150d..888c205 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -187,7 +187,7 @@ static int rpcb_register_call(u32 version, struct rpc_message *msg)
 		error = PTR_ERR(rpcb_clnt);
 
 	if (error < 0) {
-		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+		dprintk("RPC:       failed to contact local rpcbind "
 				"server (errno %d).\n", -error);
 		return error;
 	}
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3cf1b3c..5baac0a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -818,7 +818,8 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
  * Returns zero on success; a negative errno value is returned
  * if any error occurs.
  */
-static int __svc_register(const u32 program, const u32 version,
+static int __svc_register(const char *progname,
+			  const u32 program, const u32 version,
 			  const sa_family_t family,
 			  const unsigned short protocol,
 			  const unsigned short port)
@@ -827,13 +828,14 @@ static int __svc_register(const u32 program, const u32 version,
 
 	switch (family) {
 	case AF_INET:
-		return __svc_rpcb_register4(program, version,
+		error = __svc_rpcb_register4(program, version,
 						protocol, port);
+		break;
 	case AF_INET6:
 		error = __svc_rpcb_register6(program, version,
 						protocol, port);
 		if (error < 0)
-			return error;
+			break;
 
 		/*
 		 * Work around bug in some versions of Linux rpcbind
@@ -844,10 +846,15 @@ static int __svc_register(const u32 program, const u32 version,
 		 */
 		__svc_rpcb_register4(program, version,
 						protocol, port);
-		return 0;
+		break;
+	default:
+		error = -EAFNOSUPPORT;
 	}
 
-	return -EAFNOSUPPORT;
+	if (error < 0)
+		printk(KERN_WARNING "svc: failed to register %sv%u RPC "
+			"service (errno %d).\n", progname, version, -error);
+	return error;
 }
 
 /**
@@ -884,8 +891,9 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = __svc_register(progp->pg_prog, i,
-						serv->sv_family, proto, port);
+			error = __svc_register(progp->pg_name, progp->pg_prog,
+						i, serv->sv_family,
+						proto, port);
 			if (error < 0)
 				break;
 		}

