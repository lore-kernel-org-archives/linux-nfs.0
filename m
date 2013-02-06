Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f175.google.com ([209.85.210.175]:50472 "EHLO
	mail-ia0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988Ab3BFXaf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 18:30:35 -0500
Received: by mail-ia0-f175.google.com with SMTP id r4so2329192iaj.34
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2013 15:30:35 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 4/4] NFS: Use static list of security flavors during root
 FH lookup recovery
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Date: Wed, 06 Feb 2013 18:30:32 -0500
Message-ID: <20130206233032.1535.75730.stgit@seurat.1015granger.net>
In-Reply-To: <20130206230045.1535.48770.stgit@seurat.1015granger.net>
References: <20130206230045.1535.48770.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the Linux NFS client receives an NFS4ERR_WRONGSEC error while
trying to look up an NFS server's root file handle, it retries the
lookup operation with various security flavors to see what flavor
the NFS server will accept for pseudo-fs access.

The list of flavors the client uses during retry consists only of
flavors that are currently registered in the kernel RPC client.
This list may exclude the GSS pseudoflavors if auth_rpcgss.ko has
not yet been loaded.

Let's instead use a static list of security flavors that the NFS
standard requires the server to implement (RFC 3530bis, section
3.2.1).  The RPC client should now be able to load support for
these dynamically; if not, they are skipped.

Recovery behavior here is prescribed by RFC 3530bis, section
15.33.5:

> For LOOKUPP, PUTROOTFH and PUTPUBFH, the client will be unable to
> use the SECINFO operation since SECINFO requires a current
> filehandle and none exist for these two [sic] operations.  Therefore,
> the client must iterate through the security triples available at
> the client and reattempt the PUTROOTFH or PUTPUBFH operation.  In
> the unfortunate event none of the MANDATORY security triples are
> supported by the client and server, the client SHOULD try using
> others that support integrity.  Failing that, the client can try
> using AUTH_NONE, but because such forms lack integrity checks,
> this puts the client at risk.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---

 fs/nfs/nfs4proc.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6f1055b..e0fe351f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2416,27 +2416,35 @@ out:
 	return ret;
 }
 
+/*
+ * Retry pseudoroot lookup with various security flavors.  We do this when:
+ *
+ *   NFSv4.0: the PUTROOTFH operation returns NFS4ERR_WRONGSEC
+ *   NFSv4.1: the server does not support the SECINFO_NO_NAME operation
+ *
+ * Returns zero on success, or a negative NFS4ERR value, or a
+ * negative errno value.
+ */
 static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
-	int i, len, status = 0;
-	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS];
-
-	len = rpcauth_list_flavors(flav_array, ARRAY_SIZE(flav_array));
-	if (len < 0)
-		return len;
-
-	for (i = 0; i < len; i++) {
-		/* AUTH_UNIX is the default flavor if none was specified,
-		 * thus has already been tried. */
-		if (flav_array[i] == RPC_AUTH_UNIX)
-			continue;
+	/* Per 3530bis 15.33.5 */
+	static const rpc_authflavor_t flav_array[] = {
+		RPC_AUTH_GSS_KRB5P,
+		RPC_AUTH_GSS_KRB5I,
+		RPC_AUTH_GSS_KRB5,
+		RPC_AUTH_NULL,
+	};
+	int status = -EPERM;
+	size_t i;
 
+	for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
 		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
 			continue;
 		break;
 	}
+
 	/*
 	 * -EACCESS could mean that the user doesn't have correct permissions
 	 * to access the mount.  It could also mean that we tried to mount

