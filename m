From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] SUNRPC: Support registering IPv6 interfaces with local
	rpcbind daemon
Date: Mon, 30 Jun 2008 18:39:31 -0400
Message-ID: <20080630223930.24534.90788.stgit@ellison.1015granger.net>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11378 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764283AbYF3Wjz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:39:55 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new API to register RPC services on IPv6 interfaces to allow
the NFS server and lockd to advertise on IPv6 networks.

Unlike rpcb_register(), the new rpcb_v4_register() function uses rpcbind
protocol version 4 to contact the local rpcbind daemon.  The version 4
SET/UNSET procedures allow services to register address families besides
AF_INET, register at specific network interfaces, and register transport
protocols besides UDP and TCP.  All of this functionality is exposed via
the new rpcb_v4_register() kernel API.

A user-space rpcbind daemon implementation that supports version 4 of the
rpcbind protocol is required in order to make use of this new API.

Note that rpcbind version 3 is sufficient to support the new rpcbind
facilities listed above, but most extant implementations use version 4.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    3 +
 net/sunrpc/rpcb_clnt.c      |  178 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 177 insertions(+), 4 deletions(-)


diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 764fd4c..e5bfe01 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -125,6 +125,9 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 
 int		rpcb_register(u32, u32, int, unsigned short, int *);
+int		rpcb_v4_register(const u32 program, const u32 version,
+				 const struct sockaddr *address,
+				 const char *netid, int *result);
 int		rpcb_getport_sync(struct sockaddr_in *, u32, u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index c33345a..038dbb3 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -90,6 +90,7 @@ struct rpcbind_args {
 
 static struct rpc_procinfo rpcb_procedures2[];
 static struct rpc_procinfo rpcb_procedures3[];
+static struct rpc_procinfo rpcb_procedures4[];
 
 struct rpcb_info {
 	u32			rpc_vers;
@@ -124,6 +125,12 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
 	.sin_port		= htons(RPCBIND_PORT),
 };
 
+static const struct sockaddr_in6 rpcb_in6addr_loopback = {
+	.sin6_family		= AF_INET6,
+	.sin6_addr		= IN6ADDR_LOOPBACK_INIT,
+	.sin6_port		= htons(RPCBIND_PORT),
+};
+
 /*
  * TCP is always used to contact the local rpcbind daemon because we
  * get an immediate indication of whether there is a remote listener
@@ -210,13 +217,38 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
  * rpcb_register - set or unset a port registration with the local rpcbind svc
  * @prog: RPC program number to bind
  * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
+ * @prot: transport protocol to register
  * @port: port value to register
- * @okay: result code
+ * @okay: OUT: result code
+ *
+ * RPC services invoke this function to advertise their contact
+ * information via the system's rpcbind daemon.  RPC services
+ * invoke this function once for each [program, version, transport]
+ * tuple they wish to advertise.
+ *
+ * Callers may also unregister RPC services that are no longer
+ * available by setting the passed-in port to zero.  This removes
+ * all registered transports for [program, version] from the local
+ * rpcbind database.
+ *
+ * Returns zero if the registration request was dispatched
+ * successfully and a reply was received.  The rpcbind daemon's
+ * boolean result code is stored in *okay.
  *
- * port == 0 means unregister, port != 0 means register.
+ * Returns an errno value and sets *result to zero if there was
+ * some problem that prevented the rpcbind request from being
+ * dispatched, or if the rpcbind daemon did not respond within
+ * the timeout.
  *
- * This routine supports only rpcbind version 2.
+ * This function uses rpcbind protocol version 2 to contact the
+ * local rpcbind daemon.
+ *
+ * Registration works over both AF_INET and AF_INET6, and services
+ * registered via this function are advertised as available for any
+ * address.  If the local rpcbind daemon is listening on AF_INET6,
+ * services registered via this function will be advertised on
+ * IN6ADDR_ANY (ie available for all AF_INET and AF_INET6
+ * addresses).
  */
 int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 {
@@ -244,6 +276,144 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 					RPCBVERS_2, &msg, okay);
 }
 
+/*
+ * Fill in AF_INET family-specific arguments to register
+ */
+static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
+				struct rpc_message *msg)
+{
+	struct rpcbind_args *map = msg->rpc_argp;
+	unsigned short port = ntohs(address_to_register->sin_port);
+	char buf[32];
+
+	/* Construct AF_INET universal address */
+	snprintf(buf, sizeof(buf),
+			NIPQUAD_FMT".%u.%u",
+			NIPQUAD(address_to_register->sin_addr.s_addr),
+			port >> 8, port & 0xff);
+	map->r_addr = buf;
+
+	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
+		"local rpcbind\n", (port ? "" : "un"),
+			map->r_prog, map->r_vers,
+			map->r_addr, map->r_netid);
+
+	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
+	if (port)
+		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
+
+	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
+					sizeof(rpcb_inaddr_loopback),
+					RPCBVERS_4, msg, msg->rpc_resp);
+}
+
+/*
+ * Fill in AF_INET6 family-specific arguments to register
+ */
+static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
+				struct rpc_message *msg)
+{
+	struct rpcbind_args *map = msg->rpc_argp;
+	unsigned short port = ntohs(address_to_register->sin6_port);
+	char buf[64];
+
+	/* Construct AF_INET6 universal address */
+	snprintf(buf, sizeof(buf),
+			NIP6_FMT".%u.%u",
+			NIP6(address_to_register->sin6_addr),
+			port >> 8, port & 0xff);
+	map->r_addr = buf;
+
+	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
+		"local rpcbind\n", (port ? "" : "un"),
+			map->r_prog, map->r_vers,
+			map->r_addr, map->r_netid);
+
+	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
+	if (port)
+		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
+
+	return rpcb_register_call((struct sockaddr *)&rpcb_in6addr_loopback,
+					sizeof(rpcb_in6addr_loopback),
+					RPCBVERS_4, msg, msg->rpc_resp);
+}
+
+/**
+ * rpcb_v4_register - set or unset a port registration with the local rpcbind
+ * @program: RPC program number of service to (un)register
+ * @version: RPC version number of service to (un)register
+ * @address: address family, IP address, and port to (un)register
+ * @netid: netid of transport protocol to (un)register
+ * @result: result code from rpcbind RPC call
+ *
+ * RPC services invoke this function to advertise their contact
+ * information via the system's rpcbind daemon.  RPC services
+ * invoke this function once for each [program, version, address,
+ * netid] tuple they wish to advertise.
+ *
+ * Callers may also unregister RPC services that are no longer
+ * available by setting the port number in the passed-in address
+ * to zero.  Callers pass a netid of "" to unregister all
+ * transport netids associated with [program, version, address].
+ *
+ * Returns zero if the registration request was dispatched
+ * successfully and a reply was received.  The rpcbind daemon's
+ * result code is stored in *result.
+ *
+ * Returns an errno value and sets *result to zero if there was
+ * some problem that prevented the rpcbind request from being
+ * dispatched, or if the rpcbind daemon did not respond within
+ * the timeout.
+ *
+ * This function uses rpcbind protocol version 4 to contact the
+ * local rpcbind daemon.  The local rpcbind daemon must support
+ * version 4 of the rpcbind protocol in order for these functions
+ * to register a service successfully.
+ *
+ * Supported netids include "udp" and "tcp" for UDP and TCP over
+ * IPv4, and "udp6" and "tcp6" for UDP and TCP over IPv6,
+ * respectively.
+ *
+ * The contents of @address determine the address family and the
+ * port to be registered.  The usual practice is to pass INADDR_ANY
+ * as the raw address, but specifying a non-zero address is also
+ * supported by this API if the caller wishes to advertise an RPC
+ * service on a specific network interface.
+ *
+ * Note that passing in INADDR_ANY does not create the same service
+ * registration as IN6ADDR_ANY.  The former advertises an RPC
+ * service on any IPv4 address, but not on IPv6.  The latter
+ * advertises the service on all IPv4 and IPv6 addresses.
+ */
+int rpcb_v4_register(const u32 program, const u32 version,
+		     const struct sockaddr *address, const char *netid,
+		     int *result)
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
+	*result = 0;
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
+
 /**
  * rpcb_getport_sync - obtain the port for an RPC service on a given host
  * @sin: address of remote peer

