From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/17] SUNRPC: Clean up address type casts in
	rpcb_v4_register()
Date: Tue, 03 Mar 2009 17:33:17 -0500
Message-ID: <20090303223317.2933.97106.stgit@ingres.1015granger.net>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:31714 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbZCCWfL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:35:11 -0500
In-Reply-To: <20090303220539.2933.15015.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: move the details of the sockaddr type casting to the helper
functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0e9150d..317eb8a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -170,7 +170,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
-static int rpcb_register_call(u32 version, struct rpc_message *msg)
+static int rpcb_register_call(const u32 version, struct rpc_message *msg)
 {
 	struct sockaddr *addr = (struct sockaddr *)&rpcb_inaddr_loopback;
 	size_t addrlen = sizeof(rpcb_inaddr_loopback);
@@ -255,17 +255,17 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 /*
  * Fill in AF_INET family-specific arguments to register
  */
-static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
+static int rpcb_register_netid4(const struct sockaddr *sap,
 				struct rpc_message *msg)
 {
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
-	unsigned short port = ntohs(address_to_register->sin_port);
+	unsigned short port = ntohs(sin->sin_port);
 	char buf[32];
 
 	/* Construct AF_INET universal address */
 	snprintf(buf, sizeof(buf), "%pI4.%u.%u",
-		 &address_to_register->sin_addr.s_addr,
-		 port >> 8, port & 0xff);
+		 &sin->sin_addr.s_addr, port >> 8, port & 0xff);
 	map->r_addr = buf;
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
@@ -283,21 +283,21 @@ static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
 /*
  * Fill in AF_INET6 family-specific arguments to register
  */
-static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
+static int rpcb_register_netid6(const struct sockaddr *sap,
 				struct rpc_message *msg)
 {
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
-	unsigned short port = ntohs(address_to_register->sin6_port);
+	unsigned short port = ntohs(sin6->sin6_port);
 	char buf[64];
 
 	/* Construct AF_INET6 universal address */
-	if (ipv6_addr_any(&address_to_register->sin6_addr))
+	if (ipv6_addr_any(&sin6->sin6_addr))
 		snprintf(buf, sizeof(buf), "::.%u.%u",
 				port >> 8, port & 0xff);
 	else
 		snprintf(buf, sizeof(buf), "%pI6.%u.%u",
-			 &address_to_register->sin6_addr,
-			 port >> 8, port & 0xff);
+			 &sin6->sin6_addr, port >> 8, port & 0xff);
 	map->r_addr = buf;
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
@@ -369,11 +369,9 @@ int rpcb_v4_register(const u32 program, const u32 version,
 
 	switch (address->sa_family) {
 	case AF_INET:
-		return rpcb_register_netid4((struct sockaddr_in *)address,
-					    &msg);
+		return rpcb_register_netid4(address, &msg);
 	case AF_INET6:
-		return rpcb_register_netid6((struct sockaddr_in6 *)address,
-					    &msg);
+		return rpcb_register_netid6(address, &msg);
 	}
 
 	return -EAFNOSUPPORT;

