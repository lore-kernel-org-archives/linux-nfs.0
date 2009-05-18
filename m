From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] umount.nfs: Harden umount.nfs error reporting
Date: Mon, 18 May 2009 12:13:14 -0400
Message-ID: <20090518161310.12029.56383.stgit@seurat.1015granger.net>
References: <20090518161224.12029.86761.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29982 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758352AbZERQPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 12:15:17 -0400
In-Reply-To: <20090518161224.12029.86761.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add additional error reporting to nfs_advise_umount().  These messages can
be displayed if the "-v" option is specified with umount.nfs.  Normally
these messages do not appear.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c   |   19 ++++++++++++++-----
 utils/mount/nfsumount.c |   17 +++++++++--------
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d93e98d..04a62ab 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -819,17 +819,24 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 	CLIENT *client;
 	enum clnt_stat res = 0;
 
-	if (nfs_probe_mntport(sap, salen, &mnt_pmap) == 0)
-		return 0;
-
 	memcpy(saddr, sap, salen);
+	if (nfs_probe_mntport(saddr, salen, &mnt_pmap) == 0) {
+		if (verbose)
+			nfs_error(_("%s: Failed to discover mountd port%s"),
+				progname, clnt_spcreateerror(""));
+		return 0;
+	}
 	nfs_set_port(saddr, mnt_pmap.pm_port);
 
 	client = nfs_get_priv_rpcclient(saddr, salen, mnt_pmap.pm_prot,
 					mnt_pmap.pm_prog, mnt_pmap.pm_vers,
 					&timeout);
-	if (client == NULL)
+	if (client == NULL) {
+		if (verbose)
+			nfs_error(_("%s: Failed to create RPC client%s"),
+				progname, clnt_spcreateerror(""));
 		return 0;
+	}
 
 	client->cl_auth = authunix_create_default();
 
@@ -837,13 +844,15 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 			(xdrproc_t)xdr_dirpath, (caddr_t)argp,
 			(xdrproc_t)xdr_void, NULL,
 			timeout);
+	if (verbose && res != RPC_SUCCESS)
+		nfs_error(_("%s: UMNT call failed: %s"),
+			progname, clnt_sperrno(res));
 
 	auth_destroy(client->cl_auth);
 	CLNT_DESTROY(client);
 
 	if (res != RPC_SUCCESS)
 		return 0;
-
 	return 1;
 }
 
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 4b2e530..9b48cc9 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -182,14 +182,15 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 		return EX_FAIL;
 	}
 
-	if (nfs_name_to_address(*hostname, sap, &salen)) {
-		if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) != 0)
-			return EX_SUCCESS;
-		else
-			nfs_error(_("%s: Server failed to unmount '%s:%s'"),
-					progname, *hostname, *dirname);
-	}
-	return EX_FAIL;
+	if (nfs_name_to_address(*hostname, sap, &salen) == 0)
+		/* nfs_name_to_address reports any errors */
+		return EX_FAIL;
+
+	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) == 0)
+		/* nfs_advise_umount reports any errors */
+		return EX_FAIL;
+
+	return EX_SUCCESS;
 }
 
 /*

