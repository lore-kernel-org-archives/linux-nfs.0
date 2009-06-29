From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/31] getport: RPCB_GETADDR's r_addr should contain rpcbind
	port, not zero
Date: Mon, 29 Jun 2009 13:35:08 -0400
Message-ID: <20090629173507.2076.50205.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36291 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097AbZF2Rfb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:35:31 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Similar to a change made to the kernel's rpcbind client.  See
kernel commit 143b6c4008a7928de7e139c3a77a90e4cad8db2c.

The r_addr argument of RPCB_GETADDR procedures contains the
rpcbind server's address and port number.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 926bab8..2b80dce 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -201,7 +201,7 @@ static in_port_t nfs_gp_get_rpcb_port(const unsigned short protocol)
  * client.  Otherwise returns NULL, and rpc_createerr.cf_stat is set to
  * reflect the error.
  */
-static CLIENT *nfs_gp_get_rpcbclient(const struct sockaddr *sap,
+static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
 				     const socklen_t salen,
 				     const unsigned short transport,
 				     const rpcvers_t version,
@@ -214,14 +214,10 @@ static CLIENT *nfs_gp_get_rpcbclient(const struct sockaddr *sap,
 		"sunrpc",
 		NULL,
 	};
-	struct sockaddr_storage address;
-	struct sockaddr *saddr = (struct sockaddr *)&address;
 	rpcprog_t rpcb_prog = nfs_getrpcbyname(RPCBPROG, rpcb_pgmtbl);
 
-	memcpy(saddr, sap, (size_t)salen);
-	nfs_gp_set_port(saddr, nfs_gp_get_rpcb_port(transport));
-
-	return nfs_get_rpcclient(saddr, salen, transport, rpcb_prog,
+	nfs_gp_set_port(sap, nfs_gp_get_rpcb_port(transport));
+	return nfs_get_rpcclient(sap, salen, transport, rpcb_prog,
 					version, timeout);
 }
 
@@ -663,7 +659,7 @@ static unsigned short nfs_gp_getport(CLIENT *client,
 }
 
 /**
- * nfs_rcp_ping - Determine if RPC service is responding to requests
+ * nfs_rpc_ping - Determine if RPC service is responding to requests
  * @sap: pointer to address of server to query (port is already filled in)
  * @salen: length of server address
  * @program: requested RPC program number
@@ -678,6 +674,8 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 		 const rpcprog_t program, const rpcvers_t version,
 		 const unsigned short protocol, const struct timeval *timeout)
 {
+	struct sockaddr_storage address;
+	struct sockaddr *saddr = (struct sockaddr *)&address;
 	CLIENT *client;
 	struct timeval tout = { -1, 0 };
 	int result = 0;
@@ -685,7 +683,9 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 	if (timeout != NULL)
 		tout = *timeout;
 
-	client = nfs_get_rpcclient(sap, salen, protocol, program, version, &tout);
+	memcpy(saddr, sap, (size_t)salen);
+	client = nfs_get_rpcclient(saddr, salen, protocol,
+						program, version, &tout);
 	if (client != NULL) {
 		result = nfs_gp_ping(client, tout);
 		CLNT_DESTROY(client);
@@ -740,14 +740,17 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 			   const rpcvers_t version,
 			   const unsigned short protocol)
 {
+	struct sockaddr_storage address;
+	struct sockaddr *saddr = (struct sockaddr *)&address;
 	struct timeval timeout = { -1, 0 };
 	unsigned short port = 0;
 	CLIENT *client;
 
-	client = nfs_gp_get_rpcbclient(sap, salen, protocol,
+	memcpy(saddr, sap, (size_t)salen);
+	client = nfs_gp_get_rpcbclient(saddr, salen, protocol,
 						default_rpcb_version, &timeout);
 	if (client != NULL) {
-		port = nfs_gp_getport(client, sap, salen, program,
+		port = nfs_gp_getport(client, saddr, salen, program,
 					version, protocol, timeout);
 		CLNT_DESTROY(client);
 	}
@@ -930,6 +933,8 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 				const unsigned short protocol,
 				const struct timeval *timeout)
 {
+	struct sockaddr_storage address;
+	struct sockaddr *saddr = (struct sockaddr *)&address;
 	CLIENT *client;
 	struct rpcb parms;
 	struct timeval tout = { -1, 0 };
@@ -938,7 +943,9 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 	if (timeout != NULL)
 		tout = *timeout;
 
-	client = nfs_gp_get_rpcbclient(sap, salen, transport, RPCBVERS_4, &tout);
+	memcpy(saddr, sap, (size_t)salen);
+	client = nfs_gp_get_rpcbclient(saddr, salen, transport,
+							RPCBVERS_4, &tout);
 	if (client != NULL) {
 		if (nfs_gp_init_rpcb_parms(addr, addrlen, program, version,
 						protocol, &parms) != 0) {
@@ -1004,6 +1011,8 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
 			       const unsigned long protocol,
 			       const struct timeval *timeout)
 {
+	struct sockaddr_in address;
+	struct sockaddr *saddr = (struct sockaddr *)&address;
 	CLIENT *client;
 	struct pmap parms = {
 		.pm_prog	= program,
@@ -1016,8 +1025,8 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
 	if (timeout != NULL)
 		tout = *timeout;
 
-	client = nfs_gp_get_rpcbclient((struct sockaddr *)sin,
-					(socklen_t)sizeof(*sin),
+	memcpy(saddr, sin, sizeof(address));
+	client = nfs_gp_get_rpcbclient(saddr, (socklen_t)sizeof(*sin),
 					transport, PMAPVERS, &tout);
 	if (client != NULL) {
 		port = nfs_gp_pmap_getport(client, &parms, tout);

