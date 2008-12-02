From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] mount command: full support for AF_INET6 addresses in
	probe_port()
Date: Tue, 02 Dec 2008 12:59:50 -0500
Message-ID: <20081202175950.5206.21529.stgit@ingres.1015granger.net>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19464 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbYLBSAc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2008 13:00:32 -0500
In-Reply-To: <20081202175403.5206.91389.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that probe_port() uses an AF_INET6-capable rpcbind query and RPC ping,
finish updating probe_port() to support AF_INET6 addresses fully.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   54 ++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 0c68993..e50bc28 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -160,6 +160,21 @@ static const unsigned long probe_mnt3_first[] = {
 	0,
 };
 
+static void nfs_set_port(struct sockaddr *sap, const unsigned short port)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)sap)->sin_port = htons(port);
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
+		break;
+	default:
+		nfs_error(_("%s: unrecognized address family in %s"),
+			progname, __func__);
+	}
+}
+
 /**
  * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
  * @hostname: pointer to C string containing DNS hostname to resolve
@@ -474,27 +489,38 @@ static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
  * Use the portmapper to discover whether or not the service we want is
  * available. The lists 'versions' and 'protos' define ordered sequences
  * of service versions and udp/tcp protocols to probe for.
+ *
+ * Returns 1 if the requested service port is unambiguous and pingable;
+ * @pmap is filled in with the version, port, and transport protocol used
+ * during the successful ping.  Note that if a port is already specified
+ * in @pmap and it matches the rpcbind query result, nfs_probe_port() does
+ * not perform an RPC ping.
+ * 
+ * If an error occurs or the requested service isn't available, zero is
+ * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
-static int probe_port(clnt_addr_t *server, const unsigned long *versions,
-			const unsigned int *protos)
+static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
+			  struct pmap *pmap, const unsigned long *versions,
+			  const unsigned int *protos)
 {
-	const struct sockaddr *saddr = (struct sockaddr *)&server->saddr;
-	const socklen_t salen = sizeof(server->saddr);
-	struct pmap *pmap = &server->pmap;
+	struct sockaddr_storage address;
+	struct sockaddr *saddr = (struct sockaddr *)&address;
 	const unsigned long prog = pmap->pm_prog, *p_vers;
 	const unsigned int prot = (u_int)pmap->pm_prot, *p_prot;
 	const u_short port = (u_short) pmap->pm_port;
 	unsigned long vers = pmap->pm_vers;
 	unsigned short p_port;
 
+	memcpy(saddr, sap, salen);
 	p_prot = prot ? &prot : protos;
 	p_vers = vers ? &vers : versions;
 	rpc_createerr.cf_stat = 0;
+
 	for (;;) {
 		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
 		if (p_port) {
 			if (!port || port == p_port) {
-				server->saddr.sin_port = htons(p_port);
+				nfs_set_port(saddr, p_port);
 				nfs_pp_debug(saddr, salen, prog, *p_vers,
 						*p_prot, p_port);
 				if (nfs_rpc_ping(saddr, salen, prog,
@@ -537,28 +563,36 @@ out_ok:
 
 static int probe_nfsport(clnt_addr_t *nfs_server)
 {
+	struct sockaddr *sap = (struct sockaddr *)&nfs_server->saddr;
+	socklen_t salen = sizeof(nfs_server->saddr);
 	struct pmap *pmap = &nfs_server->pmap;
 
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
-		return probe_port(nfs_server, probe_nfs3_first, probe_tcp_first);
+		return nfs_probe_port(sap, salen, pmap,
+					probe_nfs3_first, probe_tcp_first);
 	else
-		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only);
+		return nfs_probe_port(sap, salen, pmap,
+					probe_nfs2_only, probe_udp_only);
 }
 
 static int probe_mntport(clnt_addr_t *mnt_server)
 {
+	struct sockaddr *sap = (struct sockaddr *)&mnt_server->saddr;
+	socklen_t salen = sizeof(mnt_server->saddr);
 	struct pmap *pmap = &mnt_server->pmap;
 
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
-		return probe_port(mnt_server, probe_mnt3_first, probe_udp_first);
+		return nfs_probe_port(sap, salen, pmap,
+					probe_mnt3_first, probe_udp_first);
 	else
-		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
+		return nfs_probe_port(sap, salen, pmap,
+					probe_mnt1_first, probe_udp_only);
 }
 
 /**

