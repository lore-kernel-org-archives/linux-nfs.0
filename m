From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] mount command: AF_INET6 support for probe_bothports()
Date: Tue, 02 Dec 2008 13:00:01 -0500
Message-ID: <20081202180001.5206.67977.stgit@ingres.1015granger.net>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:31521 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973AbYLBSA2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2008 13:00:28 -0500
In-Reply-To: <20081202175403.5206.91389.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce an AF_INET6 capable probe_bothports() API.  This means replacing
"struct sockaddr_in *" arguments with a "struct sockaddr *" and a socklen_t
arguments.

These functions often combine a "struct sockaddr_in" and a "struct pmap" into
a single "clnt_addr_t" argument.  Instead of modifying "clnt_addr_t" and all
the legacy code that uses it, I'm going to create a new probe_bothports() API
for the text-based mount command that takes a "struct sockaddr *" and
sockaddr length, and leave the existing probe_bothports() interface, which
takes "clnt_addr_t" arguments, for legacy use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   86 +++++++++++++++++++++++++++++++++++++------------
 utils/mount/network.h |    3 ++
 2 files changed, 68 insertions(+), 21 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 55b2cab..6a9a41a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -615,24 +615,49 @@ static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
 					probe_mnt1_first, probe_udp_only);
 }
 
-/**
- * probe_bothports - discover the RPC endpoints of mountd and NFS server
- * @mnt_server: pointer to address and pmap argument for mountd results
- * @nfs_server: pointer to address and pmap argument for NFS server
+/*
+ * Probe a server's mountd service to determine which versions and
+ * transport protocols are supported.  Invoked when the protocol
+ * version is already known for both the NFS and mountd service.
  *
- * Returns 1 if successful, otherwise zero if some error occurred.
- * Note that the arguments are both input and output arguments.
+ * Returns 1 and fills in both @pmap structs if the requested service
+ * ports are unambiguous and pingable.  Otherwise zero is returned;
+ * rpccreateerr.cf_stat is set to reflect the nature of the error.
+ */
+static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
+			const socklen_t mnt_salen,
+			struct pmap *mnt_pmap,
+			const struct sockaddr *nfs_saddr,
+			const socklen_t nfs_salen,
+			struct pmap *nfs_pmap)
+{
+	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
+		return 0;
+	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
+}
+
+/**
+ * nfs_probe_bothports - discover the RPC endpoints of mountd and NFS server
+ * @mnt_saddr:	pointer to socket address of mountd server
+ * @mnt_salen:	length of mountd server's address
+ * @mnt_pmap:	IN: partially filled-in mountd RPC service tuple;
+ *		OUT: fully filled-in mountd RPC service tuple
+ * @nfs_saddr:	pointer to socket address of NFS server
+ * @nfs_salen:	length of NFS server's address
+ * @nfs_pmap:	IN: partially filled-in NFS RPC service tuple;
+ *		OUT: fully filled-in NFS RPC service tuple
  *
- * A side effect of calling this function is that rpccreateerr is set.
+ * Returns 1 and fills in both @pmap structs if the requested service
+ * ports are unambiguous and pingable.  Otherwise zero is returned;
+ * rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
-int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
+			const socklen_t mnt_salen,
+			struct pmap *mnt_pmap,
+			const struct sockaddr *nfs_saddr,
+			const socklen_t nfs_salen,
+			struct pmap *nfs_pmap)
 {
-	struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_server->saddr;
-	socklen_t nfs_salen = sizeof(nfs_server->saddr);
-	struct sockaddr *mnt_saddr = (struct sockaddr *)&mnt_server->saddr;
-	socklen_t mnt_salen = sizeof(mnt_server->saddr);
-	struct pmap *nfs_pmap = &nfs_server->pmap;
-	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap save_nfs, save_mnt;
 	const unsigned long *probe_vers;
 
@@ -640,8 +665,10 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 		nfs_pmap->pm_vers = mntvers_to_nfs(mnt_pmap->pm_vers);
 	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers)
 		mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
+
 	if (nfs_pmap->pm_vers)
-		goto version_fixed;
+		return nfs_probe_version_fixed(mnt_saddr, mnt_salen, mnt_pmap,
+					       nfs_saddr, nfs_salen, nfs_pmap);
 
 	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
 	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
@@ -661,18 +688,35 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 		case RPC_PROGNOTREGISTERED:
 			break;
 		default:
-			goto out_bad;
+			return 0;
 		}
 		memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
 	}
 
-out_bad:
 	return 0;
+}
 
-version_fixed:
-	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
-		goto out_bad;
-	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
+/**
+ * probe_bothports - discover the RPC endpoints of mountd and NFS server
+ * @mnt_server: pointer to address and pmap argument for mountd results
+ * @nfs_server: pointer to address and pmap argument for NFS server
+ *
+ * This is the legacy API that takes "clnt_addr_t" for both servers,
+ * but supports only AF_INET addresses.
+ *
+ * Returns 1 and fills in the pmap field in both clnt_addr_t structs
+ * if the requested service ports are unambiguous and pingable.
+ * Otherwise zero is returned; rpccreateerr.cf_stat is set to reflect
+ * the nature of the error.
+ */
+int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+{
+	return nfs_probe_bothports((struct sockaddr *)&mnt_server->saddr,
+					sizeof(mnt_server->saddr),
+					&mnt_server->pmap,
+					(struct sockaddr *)&nfs_server->saddr,
+					sizeof(nfs_server->saddr),
+					&nfs_server->pmap);
 }
 
 static int nfs_probe_statd(void)
diff --git a/utils/mount/network.h b/utils/mount/network.h
index a4dba1b..075093d 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -40,6 +40,9 @@ static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
+int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
+			struct pmap *, const struct sockaddr *,
+			const socklen_t, struct pmap *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_name_to_address(const char *, const sa_family_t,
 		struct sockaddr *, socklen_t *);

