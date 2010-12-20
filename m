Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:38466 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757348Ab0LTLyn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 06:54:43 -0500
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 07/12] sunrpc: get rpc_pipefs mount point for rpcb_create_local from callers
Date: Mon, 20 Dec 2010 13:54:33 +0200
Message-Id: <1292846078-31793-8-git-send-email-kirill@shutemov.name>
In-Reply-To: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Kirill A. Shutemov <kirill@shutemov.name>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/sunrpc/clnt.h |    4 ++--
 net/sunrpc/rpcb_clnt.c      |   15 ++++++++-------
 net/sunrpc/svc.c            |   34 +++++++++++++++++++++-------------
 3 files changed, 31 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index f052712..59eda38 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -135,10 +135,10 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
 
-int		rpcb_register(u32, u32, int, unsigned short);
+int		rpcb_register(u32, u32, int, unsigned short, struct vfsmount *);
 int		rpcb_v4_register(const u32 program, const u32 version,
 				 const struct sockaddr *address,
-				 const char *netid);
+				 const char *netid, struct vfsmount *rpcmount);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_start(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 732adef..eb29dfa 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -27,7 +27,6 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xprtsock.h>
-#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_BIND
@@ -175,7 +174,7 @@ static DEFINE_MUTEX(rpcb_create_local_mutex);
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-static int rpcb_create_local(void)
+static int rpcb_create_local(struct vfsmount *rpcmount)
 {
 	struct rpc_create_args args = {
 		.net		= &init_net,
@@ -187,7 +186,7 @@ static int rpcb_create_local(void)
 		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= RPC_CLNT_CREATE_NOPING,
-		.rpcmount	= init_rpc_pipefs,
+		.rpcmount	= rpcmount,
 	};
 	struct rpc_clnt *clnt, *clnt4;
 	int result = 0;
@@ -308,7 +307,8 @@ static int rpcb_register_call(struct rpc_clnt *clnt, struct rpc_message *msg)
  * IN6ADDR_ANY (ie available for all AF_INET and AF_INET6
  * addresses).
  */
-int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
+int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port,
+		struct vfsmount *rpcmount)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
@@ -321,7 +321,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	};
 	int error;
 
-	error = rpcb_create_local();
+	error = rpcb_create_local(rpcmount);
 	if (error)
 		return error;
 
@@ -448,7 +448,8 @@ static int rpcb_unregister_all_protofamilies(struct rpc_message *msg)
  * advertises the service on all IPv4 and IPv6 addresses.
  */
 int rpcb_v4_register(const u32 program, const u32 version,
-		     const struct sockaddr *address, const char *netid)
+		     const struct sockaddr *address, const char *netid,
+		     struct vfsmount *rpcmount)
 {
 	struct rpcbind_args map = {
 		.r_prog		= program,
@@ -461,7 +462,7 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	};
 	int error;
 
-	error = rpcb_create_local();
+	error = rpcb_create_local(rpcmount);
 	if (error)
 		return error;
 	if (rpcb_local_clnt4 == NULL)
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 0bd6088..e0ae040 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -743,7 +743,8 @@ EXPORT_SYMBOL_GPL(svc_exit_thread);
  */
 static int __svc_rpcb_register4(const u32 program, const u32 version,
 				const unsigned short protocol,
-				const unsigned short port)
+				const unsigned short port,
+				struct vfsmount *rpcmount)
 {
 	const struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
@@ -765,14 +766,16 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 	}
 
 	error = rpcb_v4_register(program, version,
-					(const struct sockaddr *)&sin, netid);
+					(const struct sockaddr *)&sin, netid,
+					rpcmount);
 
 	/*
 	 * User space didn't support rpcbind v4, so retry this
 	 * registration request with the legacy rpcbind v2 protocol.
 	 */
 	if (error == -EPROTONOSUPPORT)
-		error = rpcb_register(program, version, protocol, port);
+		error = rpcb_register(program, version, protocol, port,
+				rpcmount);
 
 	return error;
 }
@@ -790,7 +793,8 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
  */
 static int __svc_rpcb_register6(const u32 program, const u32 version,
 				const unsigned short protocol,
-				const unsigned short port)
+				const unsigned short port,
+				struct vfsmount *rpcmount)
 {
 	const struct sockaddr_in6 sin6 = {
 		.sin6_family		= AF_INET6,
@@ -812,7 +816,8 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 	}
 
 	error = rpcb_v4_register(program, version,
-					(const struct sockaddr *)&sin6, netid);
+					(const struct sockaddr *)&sin6, netid,
+					rpcmount);
 
 	/*
 	 * User space didn't support rpcbind version 4, so we won't
@@ -835,19 +840,20 @@ static int __svc_register(const char *progname,
 			  const u32 program, const u32 version,
 			  const int family,
 			  const unsigned short protocol,
-			  const unsigned short port)
+			  const unsigned short port,
+			  struct vfsmount *rpcmount)
 {
 	int error = -EAFNOSUPPORT;
 
 	switch (family) {
 	case PF_INET:
 		error = __svc_rpcb_register4(program, version,
-						protocol, port);
+						protocol, port, rpcmount);
 		break;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case PF_INET6:
 		error = __svc_rpcb_register6(program, version,
-						protocol, port);
+						protocol, port, rpcmount);
 #endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	}
 
@@ -893,7 +899,8 @@ int svc_register(const struct svc_serv *serv, const int family,
 				continue;
 
 			error = __svc_register(progp->pg_name, progp->pg_prog,
-						i, family, proto, port);
+						i, family, proto, port,
+						serv->sv_rpcmount);
 			if (error < 0)
 				break;
 		}
@@ -910,18 +917,18 @@ int svc_register(const struct svc_serv *serv, const int family,
  * in this case to clear all existing entries for [program, version].
  */
 static void __svc_unregister(const u32 program, const u32 version,
-			     const char *progname)
+			     const char *progname, struct vfsmount *rpcmount)
 {
 	int error;
 
-	error = rpcb_v4_register(program, version, NULL, "");
+	error = rpcb_v4_register(program, version, NULL, "", rpcmount);
 
 	/*
 	 * User space didn't support rpcbind v4, so retry this
 	 * request with the legacy rpcbind v2 protocol.
 	 */
 	if (error == -EPROTONOSUPPORT)
-		error = rpcb_register(program, version, 0, 0);
+		error = rpcb_register(program, version, 0, 0, rpcmount);
 
 	dprintk("svc: %s(%sv%u), error %d\n",
 			__func__, progname, version, error);
@@ -950,7 +957,8 @@ static void svc_unregister(const struct svc_serv *serv)
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			__svc_unregister(progp->pg_prog, i, progp->pg_name);
+			__svc_unregister(progp->pg_prog, i, progp->pg_name,
+					serv->sv_rpcmount);
 		}
 	}
 
-- 
1.7.3.4

