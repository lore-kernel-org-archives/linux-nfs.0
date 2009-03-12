From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/40] SUNRPC: Allow callers to pass rpcb_v4_register a NULL
	address
Date: Thu, 12 Mar 2009 12:08:44 -0400
Message-ID: <20090312160844.16019.10332.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47868 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756817AbZCLQJW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:09:22 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The user space TI-RPC library uses an empty string for the universal
address when unregistering all target addresses for [program, version].
The kernel's rpcb client should behave the same way.

Here, we are switching between several registration methods based on
the protocol family of the incoming address.  Rename the other rpcbind
v4 registration functions to make it clear that they, as well, are
switched on protocol family.  In /etc/netconfig, this is either "inet"
or "inet6".

NB: The loopback protocol families are not supported in the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   38 ++++++++++++++++++++++++++++----------
 1 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4e86dfe..4a7a8ae 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -262,8 +262,8 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 /*
  * Fill in AF_INET family-specific arguments to register
  */
-static int rpcb_register_netid4(const struct sockaddr *sap,
-				struct rpc_message *msg)
+static int rpcb_register_inet4(const struct sockaddr *sap,
+			       struct rpc_message *msg)
 {
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
@@ -290,8 +290,8 @@ static int rpcb_register_netid4(const struct sockaddr *sap,
 /*
  * Fill in AF_INET6 family-specific arguments to register
  */
-static int rpcb_register_netid6(const struct sockaddr *sap,
-				struct rpc_message *msg)
+static int rpcb_register_inet6(const struct sockaddr *sap,
+			       struct rpc_message *msg)
 {
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
@@ -319,6 +319,20 @@ static int rpcb_register_netid6(const struct sockaddr *sap,
 	return rpcb_register_call(RPCBVERS_4, msg);
 }
 
+static int rpcb_unregister_all_protofamilies(struct rpc_message *msg)
+{
+	struct rpcbind_args *map = msg->rpc_argp;
+
+	dprintk("RPC:       unregistering [%u, %u, '%s'] with "
+		"local rpcbind\n",
+			map->r_prog, map->r_vers, map->r_netid);
+
+	map->r_addr = "";
+	msg->rpc_proc = &rpcb_procedures4[RPCBPROC_UNSET];
+
+	return rpcb_register_call(RPCBVERS_4, msg);
+}
+
 /**
  * rpcb_v4_register - set or unset a port registration with the local rpcbind
  * @program: RPC program number of service to (un)register
@@ -336,10 +350,11 @@ static int rpcb_register_netid6(const struct sockaddr *sap,
  * invoke this function once for each [program, version, address,
  * netid] tuple they wish to advertise.
  *
- * Callers may also unregister RPC services that are no longer
- * available by setting the port number in the passed-in address
- * to zero.  Callers pass a netid of "" to unregister all
- * transport netids associated with [program, version, address].
+ * Callers may also unregister RPC services that are registered at a
+ * specific address by setting the port number in @address to zero.
+ * They may unregister all registered protocol families at once for
+ * a service by passing a NULL @address argument.  If @netid is ""
+ * then all netids for [program, version, address] are unregistered.
  *
  * This function uses rpcbind protocol version 4 to contact the
  * local rpcbind daemon.  The local rpcbind daemon must support
@@ -374,11 +389,14 @@ int rpcb_v4_register(const u32 program, const u32 version,
 		.rpc_argp	= &map,
 	};
 
+	if (address == NULL)
+		return rpcb_unregister_all_protofamilies(&msg);
+
 	switch (address->sa_family) {
 	case AF_INET:
-		return rpcb_register_netid4(address, &msg);
+		return rpcb_register_inet4(address, &msg);
 	case AF_INET6:
-		return rpcb_register_netid6(address, &msg);
+		return rpcb_register_inet6(address, &msg);
 	}
 
 	return -EAFNOSUPPORT;

