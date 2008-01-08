From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] SUNRPC: Support registering IPv6 interfaces with local
	rpcbind daemon
Date: Tue, 08 Jan 2008 11:31:03 -0500
Message-ID: <20080108163102.21088.6070.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:31721 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbYAHQbE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:31:04 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m08GV3IZ010363
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 08:31:03 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m08GV3a1021113
	for <linux-nfs@vger.kernel.org>; Tue, 8 Jan 2008 11:31:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new API to register RPC services on IPv6 interfaces to allow the
NFS server and lockd to advertise on IPv6 networks.

Unlike rpcb_register(), the new rpcb_register_v3() function uses rpcbind
protocol version 3 to contact the local rpcbind daemon.  The version 3
SET/UNSET procedures allow services to register address families besides
AF_INET, register at specific network interfaces, and register transport
protocols besides UDP and TCP.  All of this functionality is exposed via
the new rpcb_register_v3() kernel API.

A user-space rpcbind daemon implementation that supports version 3 of the
rpcbind protocol is required in order to make use of this new API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    3 +
 net/sunrpc/rpcb_clnt.c      |  154 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 153 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a4f6d04..3ffb7b3 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -123,6 +123,9 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 
 int		rpcb_register(u32, u32, int, unsigned short, int *);
+int		rpcb_v3_register(u32 program, u32 version,
+				 struct sockaddr *address,
+				 char *netid, int *result);
 int		rpcb_getport_sync(struct sockaddr_in *, u32, u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b309395..779b853 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -154,6 +154,148 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
+static int rpcb_register_call(struct sockaddr *rpcbind_server,
+			      size_t addrlen, struct rpc_message *msg,
+			      int unregister)
+{
+	struct rpcbind_args *map = msg->rpc_argp;
+	struct rpc_clnt *rpcb_clnt;
+	int error;
+
+	msg->rpc_proc = &rpcb_procedures3[RPCBPROC_SET];
+	if (unregister)
+		msg->rpc_proc = &rpcb_procedures3[RPCBPROC_UNSET];
+
+	rpcb_clnt = rpcb_create("localhost", rpcbind_server, addrlen,
+				XPRT_TRANSPORT_UDP, 3, 1);
+	if (IS_ERR(rpcb_clnt))
+		return PTR_ERR(rpcb_clnt);
+
+	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] "
+		"with local rpcbind\n", (unregister ? "un" : ""),
+			map->r_prog, map->r_vers,
+			map->r_addr, map->r_netid);
+
+	error = rpc_call_sync(rpcb_clnt, msg, 0);
+
+	rpc_shutdown_client(rpcb_clnt);
+
+	if (error < 0)
+		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+				"server (errno %d).\n", -error);
+
+	dprintk("RPC:       registration status %d/%d\n",
+			error, *((int *)msg->rpc_resp));
+	return error;
+}
+
+/*
+ * Fill in AF_INET family-specific arguments to register
+ */
+static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
+				struct rpc_message *msg)
+{
+	struct rpcbind_args *map = msg->rpc_argp;
+	struct sockaddr_in rpcbind_server = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
+	unsigned short port = ntohs(address_to_register->sin_port);
+
+	/* Construct a Universal Address string in r_addr */
+	snprintf(map->r_addr, sizeof(map->r_addr),
+			NIPQUAD_FMT".%u.%u",
+			NIPQUAD(address_to_register->sin_addr.s_addr),
+			port >> 8, port & 0xff);
+
+	return rpcb_register_call((struct sockaddr *)&rpcbind_server,
+				  sizeof(rpcbind_server), msg, port == 0);
+}
+
+/*
+ * Fill in AF_INET6 family-specific arguments to register
+ */
+static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
+				struct rpc_message *msg)
+{
+	struct rpcbind_args *map = msg->rpc_argp;
+	struct sockaddr_in6 rpcbind_server = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_LOOPBACK_INIT,
+	};
+	unsigned short port = ntohs(address_to_register->sin6_port);
+
+	/* Construct a Universal Address string in r_addr */
+	snprintf(map->r_addr, sizeof(map->r_addr),
+			NIP6_FMT".%u.%u",
+			NIP6(address_to_register->sin6_addr),
+			port >> 8, port & 0xff);
+
+	return rpcb_register_call((struct sockaddr *)&rpcbind_server,
+				  sizeof(rpcbind_server), msg, port == 0);
+}
+
+/**
+ * rpcb_register_v3 - set or unset a port registration with the local rpcbind
+ * @program: RPC program number of service to (un)register
+ * @version: RPC version number of service to (un)register
+ * @address: family, IP address, and port to (un)register
+ * @netid: netid of transport protocol to (un)register
+ * @result: result code from rpcbind RPC call
+ *
+ * Called by server-side RPC consumers to advertise an RPC-based service
+ * via the local rpcbind daemon.  Callers must call this routine once for
+ * each [program, version, address, netid] tuple they wish to advertise.
+ * A unique address family counts as a separate address, thus a service must
+ * register AF_INET and AF_INET6 support separately.
+ *
+ * Callers may also unregister their RPC service by setting the port
+ * number in the passed-in address to zero.  Callers can pass "" for
+ * @netid to unregister all transport netids associated with [program,
+ * version, address].
+ *
+ * Returns zero if the request was dispatched successfully.  The rpcbind
+ * daemon's result code is stored in *result.  Returns an error code and
+ * doesn't set *result if there was some problem that prevented the rpcbind
+ * request from being dispatched.
+ *
+ * This function uses rpcbind protocol version 3 to contact the local
+ * rpcbind daemon.  The version 3 SET/UNSET procedures allow services to
+ * register address families besides AF_INET, register at specific network
+ * interfaces, and register transport protocols besides UDP and TCP.
+ *
+ * The contents of @address determine the address family and the port to be
+ * registered.  The usual practice is to pass in INADDR_ANY as the raw
+ * address, but specifying a non-zero address is supported by this API if
+ * the caller wishes to advertise a service on a specific network interface.
+ */
+int rpcb_v3_register(u32 program, u32 version, struct sockaddr *address,
+		     char *netid, int *result)
+{
+	struct rpcbind_args map = {
+		.r_prog		= program,
+		.r_vers		= version,
+		.r_netid	= netid,
+		.r_owner	= RPCB_OWNER_STRING,
+	};
+	struct rpc_message msg = {
+		.rpc_argp	= &map,
+		.rpc_resp	= result,
+	};
+
+	switch (address->sa_family) {
+	case AF_INET:
+		return rpcb_register_netid4((struct sockaddr_in *)address,
+					    &msg);
+	case AF_INET6:
+		return rpcb_register_netid6((struct sockaddr_in6 *)address,
+					    &msg);
+	}
+
+	return -EAFNOSUPPORT;
+}
+EXPORT_SYMBOL_GPL(rpcb_v3_register);
+
 /**
  * rpcb_register - set or unset a port registration with the local rpcbind svc
  * @prog: RPC program number to bind
@@ -421,6 +563,10 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	rpcb_wake_rpcbind_waiters(xprt, status);
 }
 
+/*
+ * XDR functions for rpcbind
+ */
+
 static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
@@ -576,14 +722,14 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 };
 
 static struct rpc_procinfo rpcb_procedures3[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
+	PROC(SET,		getaddr,	set),
+	PROC(UNSET,		getaddr,	set),
 	PROC(GETADDR,		getaddr,	getaddr),
 };
 
 static struct rpc_procinfo rpcb_procedures4[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
+	PROC(SET,		getaddr,	set),
+	PROC(UNSET,		getaddr,	set),
 	PROC(GETVERSADDR,	getaddr,	getaddr),
 };
 

