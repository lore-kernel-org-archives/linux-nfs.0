From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] mount command: support AF_INET6 in probe_nfsport() and
	probe_mntport()
Date: Tue, 02 Dec 2008 12:59:56 -0500
Message-ID: <20081202175955.5206.85058.stgit@ingres.1015granger.net>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:41648 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932AbYLBSAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2008 13:00:24 -0500
In-Reply-To: <20081202175403.5206.91389.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Flesh out support for AF_INET6 in the intermediate helper functions
probe_nfsport() and probe_mntport().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   58 +++++++++++++++++++++++++++++++++++--------------
 1 files changed, 42 insertions(+), 16 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e50bc28..55b2cab 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -561,12 +561,22 @@ out_ok:
 	return 1;
 }
 
-static int probe_nfsport(clnt_addr_t *nfs_server)
+/*
+ * Probe a server's NFS service to determine which versions and
+ * transport protocols are supported.
+ *
+ * Returns 1 if the requested service port is unambiguous and pingable;
+ * @pmap is filled in with the version, port, and transport protocol used
+ * during the successful ping.  If all three are already specified, simply
+ * return success without an rpcbind query or RPC ping (we may be trying
+ * to mount an NFS service that is not advertised via rpcbind).
+ *
+ * If an error occurs or the requested service isn't available, zero is
+ * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
+ */
+static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
+				struct pmap *pmap)
 {
-	struct sockaddr *sap = (struct sockaddr *)&nfs_server->saddr;
-	socklen_t salen = sizeof(nfs_server->saddr);
-	struct pmap *pmap = &nfs_server->pmap;
-
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
@@ -578,12 +588,22 @@ static int probe_nfsport(clnt_addr_t *nfs_server)
 					probe_nfs2_only, probe_udp_only);
 }
 
-static int probe_mntport(clnt_addr_t *mnt_server)
+/*
+ * Probe a server's mountd service to determine which versions and
+ * transport protocols are supported.
+ *
+ * Returns 1 if the requested service port is unambiguous and pingable;
+ * @pmap is filled in with the version, port, and transport protocol used
+ * during the successful ping.  If all three are already specified, simply
+ * return success without an rpcbind query or RPC ping (we may be trying
+ * to mount an NFS service that is not advertised via rpcbind).
+ * 
+ * If an error occurs or the requested service isn't available, zero is
+ * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
+ */
+static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
+				struct pmap *pmap)
 {
-	struct sockaddr *sap = (struct sockaddr *)&mnt_server->saddr;
-	socklen_t salen = sizeof(mnt_server->saddr);
-	struct pmap *pmap = &mnt_server->pmap;
-
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
@@ -607,10 +627,13 @@ static int probe_mntport(clnt_addr_t *mnt_server)
  */
 int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 {
+	struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_server->saddr;
+	socklen_t nfs_salen = sizeof(nfs_server->saddr);
+	struct sockaddr *mnt_saddr = (struct sockaddr *)&mnt_server->saddr;
+	socklen_t mnt_salen = sizeof(mnt_server->saddr);
 	struct pmap *nfs_pmap = &nfs_server->pmap;
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap save_nfs, save_mnt;
-	int res;
 	const unsigned long *probe_vers;
 
 	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
@@ -627,9 +650,9 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 
 	for (; *probe_vers; probe_vers++) {
 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
-		if ((res = probe_nfsport(nfs_server) != 0)) {
+		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap) != 0) {
 			mnt_pmap->pm_vers = *probe_vers;
-			if ((res = probe_mntport(mnt_server)) != 0)
+			if (nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap) != 0)
 				return 1;
 			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
 		}
@@ -647,9 +670,9 @@ out_bad:
 	return 0;
 
 version_fixed:
-	if (!probe_nfsport(nfs_server))
+	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
 		goto out_bad;
-	return probe_mntport(mnt_server);
+	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
 }
 
 static int nfs_probe_statd(void)
@@ -716,11 +739,14 @@ int start_statd(void)
  */
 int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 {
+	struct sockaddr *sap = (struct sockaddr *)&mnt_server->saddr;
+	socklen_t salen = sizeof(mnt_server->saddr);
+	struct pmap *pmap = &mnt_server->pmap;
 	CLIENT *clnt;
 	enum clnt_stat res = 0;
 	int msock;
 
-	if (!probe_mntport(mnt_server))
+	if (!nfs_probe_mntport(sap, salen, pmap))
 		return 0;
 	clnt = mnt_openclnt(mnt_server, &msock);
 	if (!clnt)

