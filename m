From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] SUNRPC: maintain a single transport for rpcbind upcalls
Date: Wed, 07 Oct 2009 18:02:48 -0400
Message-ID: <20091007220247.1844.17281.stgit@matisse.1015granger.net>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:52167
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752968AbZJGWDY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 18:03:24 -0400
Received: from matisse.1015granger.net (matisse.1015granger.net [127.0.0.1])
	by matisse.1015granger.net (8.14.3/8.14.3) with ESMTP id n97M2maX001983
	for <linux-nfs@vger.kernel.org>; Wed, 7 Oct 2009 18:02:48 -0400
In-Reply-To: <20091007215019.1844.17414.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel's rpcbind client creates and deletes an rpc_clnt and its
underlying transport socket for every upcall to the local rpcbind
daemon.  Instead, let's create an rpc_clnt for rpcbind upcalls when
sunrpc.ko is loaded, and use it until sunrpc.ko is unloaded.  This
saves the overhead of creating and destroying an rpc_clnt and a socket
for every upcall.

When starting a typical NFS server on IPv4 and IPv6, this reduces the
number of rpcbind sockets created from one per upcall to just one.
The NFS service itself does three upcalls (one per version) times two
upcalls (one per transport) times two upcalls (one per address
family), making 12, plus another one for the initial call to unregister
previous NFS services.  Starting the NLM service adds an additional
13 upcalls, for similar reasons.

Note that at the moment, lockd supports IPv6, but the kernel's NFS
service does not, so the NFS service does only six registrations on
current systems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c   |   64 +++++++++++++++++++++++++++++++++++-----------
 net/sunrpc/sunrpc_syms.c |    5 ++++
 2 files changed, 54 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 830faf4..a6fb65e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -110,6 +110,9 @@ static void			rpcb_getport_done(struct rpc_task *, void *);
 static void			rpcb_map_release(void *data);
 static struct rpc_program	rpcb_program;
 
+static struct rpc_clnt *	rpcb_local_clnt;
+static struct rpc_clnt *	rpcb_local_clnt4;
+
 struct rpcbind_args {
 	struct rpc_xprt *	r_xprt;
 
@@ -209,22 +212,13 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
-static int rpcb_register_call(const u32 version, struct rpc_message *msg)
+static int rpcb_register_call(struct rpc_clnt *clnt, struct rpc_message *msg)
 {
-	struct sockaddr *addr = (struct sockaddr *)&rpcb_inaddr_loopback;
-	size_t addrlen = sizeof(rpcb_inaddr_loopback);
-	struct rpc_clnt *rpcb_clnt;
 	int result, error = 0;
 
 	msg->rpc_resp = &result;
 
-	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
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
@@ -288,7 +282,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	if (port)
 		msg.rpc_proc = &rpcb_procedures2[RPCBPROC_SET];
 
-	return rpcb_register_call(RPCBVERS_2, &msg);
+	return rpcb_register_call(rpcb_local_clnt, &msg);
 }
 
 /*
@@ -313,7 +307,7 @@ static int rpcb_register_inet4(const struct sockaddr *sap,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	result = rpcb_register_call(RPCBVERS_4, msg);
+	result = rpcb_register_call(rpcb_local_clnt4, msg);
 	kfree(map->r_addr);
 	return result;
 }
@@ -340,7 +334,7 @@ static int rpcb_register_inet6(const struct sockaddr *sap,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	result = rpcb_register_call(RPCBVERS_4, msg);
+	result = rpcb_register_call(rpcb_local_clnt4, msg);
 	kfree(map->r_addr);
 	return result;
 }
@@ -356,7 +350,7 @@ static int rpcb_unregister_all_protofamilies(struct rpc_message *msg)
 	map->r_addr = "";
 	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
 
-	return rpcb_register_call(RPCBVERS_4, msg);
+	return rpcb_register_call(rpcb_local_clnt4, msg);
 }
 
 /**
@@ -1027,3 +1021,43 @@ static struct rpc_program rpcb_program = {
 	.version	= rpcb_version,
 	.stats		= &rpcb_stats,
 };
+
+/**
+ * init_rpcb_clnt - set up kernel's rpcbind client
+ *
+ */
+int init_rpcb_clnt(void)
+{
+	struct sockaddr *addr = (struct sockaddr *)&rpcb_inaddr_loopback;
+	size_t addrlen = sizeof(rpcb_inaddr_loopback);
+
+	rpcb_local_clnt = rpcb_create_local(addr, addrlen, RPCBVERS_2);
+	if (IS_ERR(rpcb_local_clnt)) {
+		printk(KERN_ERR "failed to create local rpcbind "
+				"client (errno %ld).\n",
+					-PTR_ERR(rpcb_local_clnt));
+		return -1;
+	}
+	rpcb_local_clnt4 = rpc_bind_new_program(rpcb_local_clnt,
+						&rpcb_program,
+						RPCBVERS_4);
+	if (IS_ERR(rpcb_local_clnt4)) {
+		printk(KERN_ERR "failed to duplicate local rpcbind "
+				"client (errno %ld).\n",
+					-PTR_ERR(rpcb_local_clnt4));
+		rpc_shutdown_client(rpcb_local_clnt);
+		return -1;
+	}
+
+	return 0;
+}
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
index 8cce921..b836572 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -24,6 +24,9 @@
 
 extern struct cache_detail ip_map_cache, unix_gid_cache;
 
+extern int init_rpcb_clnt(void);
+extern void cleanup_rpcb_clnt(void);
+
 static int __init
 init_sunrpc(void)
 {
@@ -46,6 +49,7 @@ init_sunrpc(void)
 	svc_init_xprt_sock();	/* svc sock transport */
 	init_socket_xprt();	/* clnt sock transport */
 	rpcauth_init_module();
+	init_rpcb_clnt();
 out:
 	return err;
 }
@@ -53,6 +57,7 @@ out:
 static void __exit
 cleanup_sunrpc(void)
 {
+	cleanup_rpcb_clnt();
 	rpcauth_remove_module();
 	cleanup_socket_xprt();
 	svc_cleanup_xprt_sock();

