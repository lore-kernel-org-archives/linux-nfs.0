From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] mount command: Replace clnt_ping() and getport() calls in
	probe_port()
Date: Mon, 01 Dec 2008 13:48:51 -0500
Message-ID: <20081201184850.10436.47026.stgit@ingres.1015granger.net>
References: <20081201183616.10436.71066.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: steved@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:34609 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbYLAStd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:49:33 -0500
In-Reply-To: <20081201183616.10436.71066.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the mount command's probe_port() function to call the new shared
rpcbind query and RPC ping functions.  This provides immediate support for
rpcbind v3/v4 queries, and paves the way for supporting AF_INET6 in the
probe_bothports() path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   43 +++++++++++++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 2231210..8d96e12 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -521,6 +521,27 @@ static unsigned short getport(struct sockaddr_in *saddr,
 	return port;
 }
 
+static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
+			 const rpcprog_t program, const rpcvers_t version,
+			 const unsigned short protocol,
+			 const unsigned short port)
+{
+	char buf[NI_MAXHOST];
+
+	if (!verbose)
+		return;
+
+	if (nfs_present_sockaddr(sap, salen, buf, sizeof(buf)) == 0) {
+		buf[0] = '\0';
+		strcat(buf, "unknown host");
+	}
+
+	fprintf(stderr, _("%s: trying %s prog %ld vers %ld prot %s port %d\n"),
+			progname, buf, program, version,
+			(protocol == IPPROTO_UDP ? _("UDP") : _("TCP")),
+			port);
+}
+
 /*
  * Use the portmapper to discover whether or not the service we want is
  * available. The lists 'versions' and 'protos' define ordered sequences
@@ -529,7 +550,8 @@ static unsigned short getport(struct sockaddr_in *saddr,
 static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 			const unsigned int *protos)
 {
-	struct sockaddr_in *saddr = &server->saddr;
+	const struct sockaddr *saddr = (struct sockaddr *)&server->saddr;
+	const socklen_t salen = sizeof(server->saddr);
 	struct pmap *pmap = &server->pmap;
 	const unsigned long prog = pmap->pm_prog, *p_vers;
 	const unsigned int prot = (u_int)pmap->pm_prot, *p_prot;
@@ -541,21 +563,14 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 	p_vers = vers ? &vers : versions;
 	rpc_createerr.cf_stat = 0;
 	for (;;) {
-		p_port = getport(saddr, prog, *p_vers, *p_prot);
+		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
 		if (p_port) {
 			if (!port || port == p_port) {
-				saddr->sin_port = htons(p_port);
-				if (verbose) {
-					printf(_("%s: trying %s prog %ld vers "
-						"%ld prot %s port %d\n"),
-						progname,
-						inet_ntoa(saddr->sin_addr),
-						prog, *p_vers,
-						*p_prot == IPPROTO_UDP ?
-							_("UDP") : _("TCP"),
-						p_port);
-                                }
-				if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))
+				server->saddr.sin_port = htons(p_port);
+				nfs_pp_debug(saddr, salen, prog, *p_vers,
+						*p_prot, p_port);
+				if (nfs_rpc_ping(saddr, salen, prog,
+							*p_vers, *p_prot, NULL))
 					goto out_ok;
 			}
 		}

