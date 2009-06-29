From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/31] getport: Clear shared error fields before trying
	rpcbind queries
Date: Mon, 29 Jun 2009 13:36:32 -0400
Message-ID: <20090629173632.2076.6602.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35279 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999AbZF2Rg4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:36:56 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some RPC errors set fields in rpc_createerr.cf_error in addition
to cf_stat.  Be sure to clear _all_ error fields in rpc_createerr
each time through the rpcbind API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |    9 +++++++++
 support/nfs/getport.c    |   18 ++++++++++++++++++
 support/nfs/rpc_socket.c |    4 ++++
 utils/mount/network.c    |    3 +--
 4 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index da3b4df..b3cdb8c 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -49,6 +49,15 @@
 #define NSMPROG		((rpcprog_t)100024)
 #endif
 
+/**
+ * nfs_clear_rpc_createerr - zap all error reporting fields
+ *
+ */
+static inline void nfs_clear_rpc_createerr(void)
+{
+	memset(&rpc_createerr, 0, sizeof(rpc_createerr));
+}
+
 /*
  * Look up an RPC program name in /etc/rpc
  */
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 71f02f3..aa9c154 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -627,6 +627,8 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 	if (timeout != NULL)
 		tout = *timeout;
 
+	nfs_clear_rpc_createerr();
+
 	memcpy(saddr, sap, (size_t)salen);
 	client = nfs_get_rpcclient(saddr, salen, protocol,
 						program, version, &tout);
@@ -690,6 +692,8 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 	unsigned short port = 0;
 	CLIENT *client;
 
+	nfs_clear_rpc_createerr();
+
 	memcpy(saddr, sap, (size_t)salen);
 	client = nfs_gp_get_rpcbclient(saddr, salen, protocol,
 						default_rpcb_version, &timeout);
@@ -729,6 +733,8 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 	CLIENT *client;
 	int result = 0;
 	
+	nfs_clear_rpc_createerr();
+
 	client = nfs_gp_get_rpcbclient(sap, salen, protocol,
 						default_rpcb_version, &timeout);
 	if (client != NULL) {
@@ -745,6 +751,8 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 		memcpy(saddr, sap, (size_t)salen);
 		nfs_gp_set_port(saddr, htons(port));
 
+		nfs_clear_rpc_createerr();
+
 		client = nfs_get_rpcclient(saddr, salen, protocol,
 						program, version, &timeout);
 		if (client != NULL) {
@@ -803,6 +811,8 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 	CLIENT *client;
 	struct timeval timeout = { -1, 0 };
 
+	nfs_clear_rpc_createerr();
+
 	client = nfs_gp_get_rpcbclient(sap, salen, 0, RPCBVERS_4, &timeout);
 	if (client != NULL) {
 		struct rpcb parms;
@@ -817,6 +827,8 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 #endif	/* NFS_GP_LOCAL */
 
 	if (port == 0) {
+		nfs_clear_rpc_createerr();
+
 		if (nfs_gp_loopback_address(lb_addr, &lb_len)) {
 			port = nfs_getport(lb_addr, lb_len,
 						program, version, protocol);
@@ -878,6 +890,8 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 	if (timeout != NULL)
 		tout = *timeout;
 
+	nfs_clear_rpc_createerr();
+
 	memcpy(saddr, sap, (size_t)salen);
 	client = nfs_gp_get_rpcbclient(saddr, salen, transport,
 							RPCBVERS_4, &tout);
@@ -904,6 +918,8 @@ unsigned short nfs_rpcb_getaddr(__attribute__((unused)) const struct sockaddr *s
 				__attribute__((unused)) const unsigned short protocol,
 				__attribute__((unused)) const struct timeval *timeout)
 {
+	nfs_clear_rpc_createerr();
+
 	rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 	return 0;
 }
@@ -959,6 +975,8 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
 	if (timeout != NULL)
 		tout = *timeout;
 
+	nfs_clear_rpc_createerr();
+
 	memcpy(saddr, sin, sizeof(address));
 	client = nfs_gp_get_rpcbclient(saddr, (socklen_t)sizeof(*sin),
 					transport, PMAPVERS, &tout);
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index ac4e6d8..a080487 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -443,6 +443,8 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
+	nfs_clear_rpc_createerr();
+
 	switch (sap->sa_family) {
 	case AF_LOCAL:
 		return nfs_get_localclient(sap, salen, program,
@@ -506,6 +508,8 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
+	nfs_clear_rpc_createerr();
+
 	switch (sap->sa_family) {
 	case AF_LOCAL:
 		return nfs_get_localclient(sap, salen, program,
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 04a62ab..3080378 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -538,7 +538,6 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 	memcpy(saddr, sap, salen);
 	p_prot = prot ? &prot : protos;
 	p_vers = vers ? &vers : versions;
-	rpc_createerr.cf_stat = 0;
 
 	for (;;) {
 		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
@@ -581,7 +580,7 @@ out_ok:
 		pmap->pm_prot = *p_prot;
 	if (!port)
 		pmap->pm_port = p_port;
-	rpc_createerr.cf_stat = 0;
+	nfs_clear_rpc_createerr();
 	return 1;
 }
 

