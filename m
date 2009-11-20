From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Use a cached RPC client and transport for rpcbind
	upcalls
Date: Fri, 20 Nov 2009 17:46:00 -0500
Message-ID: <20091120224437.3504.1598.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:41552
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753392AbZKTWuN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2009 17:50:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel's rpcbind client creates and deletes an rpc_clnt and its
underlying transport socket for every upcall to the local rpcbind
daemon.

When starting a typical NFS server on IPv4 and IPv6, the NFS service
itself does three upcalls (one per version) times two upcalls (one
per transport) times two upcalls (one per address family), making 12,
plus another one for the initial call to unregister previous NFS
services.  Starting the NLM service adds an additional 13 upcalls,
for similar reasons.

(Currently the NFS service doesn't start IPv6 listeners, but it will
soon enough).

Instead, let's create an rpc_clnt for rpcbind upcalls during the
first local rpcbind query, and cache it.  This saves the overhead of
creating and destroying an rpc_clnt and a socket for every upcall.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Trond-

Does this refresh address your concern?

 net/sunrpc/rpcb_clnt.c   |   79 +++++++++++++++++++++++++++++++++++++---------
 net/sunrpc/sunrpc_syms.c |    3 ++
 2 files changed, 66 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 28f50da..5194d9b 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -20,6 +20,7 @@
 #include <linux/in6.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/mutex.h>
 #include <net/ipv6.h>
 
 #include <linux/sunrpc/clnt.h>
@@ -110,6 +111,9 @@ static void			rpcb_getport_done(struct rpc_task *, void *);
 static void			rpcb_map_release(void *data);
 static struct rpc_program	rpcb_program;
 
+static struct rpc_clnt *	rpcb_local_clnt;
+static struct rpc_clnt *	rpcb_local_clnt4;
+
 struct rpcbind_args {
 	struct rpc_xprt *	r_xprt;
 
@@ -163,7 +167,9 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
 	.sin_port		= htons(RPCBIND_PORT),
 };
 
-static struct rpc_clnt *rpcb_create_local(u32 version)
+static DEFINE_MUTEX(rpcb_create_local_mutex);
+
+static int rpcb_create_local(void)
 {
 	struct rpc_create_args args = {
 		.protocol	= XPRT_TRANSPORT_UDP,
@@ -171,12 +177,36 @@ static struct rpc_clnt *rpcb_create_local(u32 version)
 		.addrsize	= sizeof(rpcb_inaddr_loopback),
 		.servername	= "localhost",
 		.program	= &rpcb_program,
-		.version	= version,
+		.version	= RPCBVERS_2,
 		.authflavor	= RPC_AUTH_UNIX,
 		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
+	struct rpc_clnt *clnt, *clnt4;
+	int result = 0;
 
-	return rpc_create(&args);
+	mutex_lock(&rpcb_create_local_mutex);
+	if (rpcb_local_clnt)
+		goto out;
+
+	clnt = rpc_create(&args);
+	if (IS_ERR(clnt)) {
+		result = -PTR_ERR(clnt);
+		goto out;
+	}
+
+	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
+	if (IS_ERR(clnt4)) {
+		result = -PTR_ERR(clnt4);
+		rpc_shutdown_client(clnt);
+		goto out;
+	}
+
+	rpcb_local_clnt = clnt;
+	rpcb_local_clnt4 = clnt4;
+
+out:
+	mutex_unlock(&rpcb_create_local_mutex);
+	return result;
 }
 
 static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
@@ -208,20 +238,13 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
-static int rpcb_register_call(const u32 version, struct rpc_message *msg)
+static int rpcb_register_call(struct rpc_clnt *clnt, struct rpc_message *msg)
 {
-	struct rpc_clnt *rpcb_clnt;
 	int result, error = 0;
 
 	msg->rpc_resp = &result;
 
-	rpcb_clnt = rpcb_create_local(version);
-	if (!IS_ERR(rpcb_clnt)) {
-		error = rpc_call_sync(rpcb_clnt, msg, 0);
-		rpc_shutdown_client(rpcb_clnt);
-	} else
-		error = PTR_ERR(rpcb_clnt);
-
+	error = rpc_call_sync(clnt, msg, 0);
 	if (error < 0) {
 		dprintk("RPC:       failed to contact local rpcbind "
 				"server (errno %d).\n", -error);
@@ -276,6 +299,13 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
+	int error;
+
+	if (rpcb_local_clnt == NULL) {
+		error = rpcb_create_local();
+		if (error)
+			return error;
+	}
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
 			"rpcbind\n", (port ? "" : "un"),
@@ -285,7 +315,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	if (port)
 		msg.rpc_proc = &rpcb_procedures2[RPCBPROC_SET];
 
-	return rpcb_register_call(RPCBVERS_2, &msg);
+	return rpcb_register_call(rpcb_local_clnt, &msg);
 }
 
 /*
@@ -310,7 +340,7 @@ static int rpcb_register_inet4(const struct sockaddr *sap,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	result = rpcb_register_call(RPCBVERS_4, msg);
+	result = rpcb_register_call(rpcb_local_clnt4, msg);
 	kfree(map->r_addr);
 	return result;
 }
@@ -337,7 +367,7 @@ static int rpcb_register_inet6(const struct sockaddr *sap,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	result = rpcb_register_call(RPCBVERS_4, msg);
+	result = rpcb_register_call(rpcb_local_clnt4, msg);
 	kfree(map->r_addr);
 	return result;
 }
@@ -353,7 +383,7 @@ static int rpcb_unregister_all_protofamilies(struct rpc_message *msg)
 	map->r_addr = "";
 	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
 
-	return rpcb_register_call(RPCBVERS_4, msg);
+	return rpcb_register_call(rpcb_local_clnt4, msg);
 }
 
 /**
@@ -411,6 +441,13 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
+	int error;
+
+	if (rpcb_local_clnt4 == NULL) {
+		error = rpcb_create_local();
+		if (error)
+			return error;
+	}
 
 	if (address == NULL)
 		return rpcb_unregister_all_protofamilies(&msg);
@@ -1024,3 +1061,13 @@ static struct rpc_program rpcb_program = {
 	.version	= rpcb_version,
 	.stats		= &rpcb_stats,
 };
+
+/**
+ * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
+ *
+ */
+void cleanup_rpcb_clnt(void)
+{
+	rpc_shutdown_client(rpcb_local_clnt4);
+	rpc_shutdown_client(rpcb_local_clnt);
+}
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 8cce921..f438347 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -24,6 +24,8 @@
 
 extern struct cache_detail ip_map_cache, unix_gid_cache;
 
+extern void cleanup_rpcb_clnt(void);
+
 static int __init
 init_sunrpc(void)
 {
@@ -53,6 +55,7 @@ out:
 static void __exit
 cleanup_sunrpc(void)
 {
+	cleanup_rpcb_clnt();
 	rpcauth_remove_module();
 	cleanup_socket_xprt();
 	svc_cleanup_xprt_sock();

