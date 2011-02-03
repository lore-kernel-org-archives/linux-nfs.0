Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:57211 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420Ab1BCWKC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 17:10:02 -0500
Received: from [96.31.168.206] (helo=mail.parallels.com)
	by mx2.parallels.com with esmtps (TLSv1:AES128-SHA:128)
	(Exim 4.72)
	(envelope-from <rlandley@parallels.com>)
	id 1Pl7NJ-00022o-TI
	for linux-nfs@vger.kernel.org; Thu, 03 Feb 2011 17:10:02 -0500
Message-ID: <4D4B27B7.80604@parallels.com>
Date: Thu, 3 Feb 2011 16:09:59 -0600
From: Rob Landley <rlandley@parallels.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH] Cleanup: move some NFSv4-only code/data under CONFIG_NFS_V4.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Rob Landley <rlandley@parallels.com>

Move some NFSv4-only stuff under CONFIG_NFS_V4.

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

Space saved from NFSv3-only config on x86_64:

 function                                     old     new   delta
 static.T                                   46908   46905      -3
 nfs_start_lockd                              178     175      -3
 nfs_get_client                               930     903     -27
 nfs4_cb_match_client                         141       -    -141

 fs/nfs/client.c           |   88 ++++++++++++++++++------------------
 include/linux/nfs_fs_sb.h |    4 -
 2 files changed, 47 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 192f2f8..fa3685d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -383,25 +383,6 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
 
 /*
  * Test if two socket addresses represent the same actual socket,
- * by comparing (only) relevant fields, excluding the port number.
- */
-static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-				     const struct sockaddr *sa2)
-{
-	if (sa1->sa_family != sa2->sa_family)
-		return 0;
-
-	switch (sa1->sa_family) {
-	case AF_INET:
-		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
-	case AF_INET6:
-		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
-	}
-	return 0;
-}
-
-/*
- * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, including the port number.
  */
 static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
@@ -419,30 +400,6 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	return 0;
 }
 
-/* Common match routine for v4.0 and v4.1 callback services */
-bool
-nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
-		     u32 minorversion)
-{
-	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
-
-	/* Don't match clients that failed to initialise */
-	if (!(clp->cl_cons_state == NFS_CS_READY ||
-	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
-		return false;
-
-	/* Match the version and minorversion */
-	if (clp->rpc_ops->version != 4 ||
-	    clp->cl_minorversion != minorversion)
-		return false;
-
-	/* Match only the IP address, not the port number */
-	if (!nfs_sockaddr_match_ipaddr(addr, clap))
-		return false;
-
-	return true;
-}
-
 /*
  * Find an nfs_client on the list that matches the initialisation data
  * that is supplied.
@@ -464,9 +421,11 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 		if (clp->cl_proto != data->proto)
 			continue;
+#ifdef CONFIG_NFS_V4
 		/* Match nfsv4 minorversion */
 		if (clp->cl_minorversion != data->minorversion)
 			continue;
+#endif
 		/* Match the full socket address */
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
@@ -1156,6 +1115,49 @@ error:
 
 #ifdef CONFIG_NFS_V4
 /*
+ * Test if two socket addresses represent the same actual socket,
+ * by comparing (only) relevant fields, excluding the port number.
+ */
+static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
+				     const struct sockaddr *sa2)
+{
+	if (sa1->sa_family != sa2->sa_family)
+		return 0;
+
+	switch (sa1->sa_family) {
+	case AF_INET:
+		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
+	case AF_INET6:
+		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
+	}
+	return 0;
+}
+
+/* Common match routine for v4.0 and v4.1 callback services */
+bool
+nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
+		     u32 minorversion)
+{
+	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+
+	/* Don't match clients that failed to initialise */
+	if (!(clp->cl_cons_state == NFS_CS_READY ||
+	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
+		return false;
+
+	/* Match the version and minorversion */
+	if (clp->rpc_ops->version != 4 ||
+	    clp->cl_minorversion != minorversion)
+		return false;
+
+	/* Match only the IP address, not the port number */
+	if (!nfs_sockaddr_match_ipaddr(addr, clap))
+		return false;
+
+	return true;
+}
+
+/*
  * NFSv4.0 callback thread helper
  *
  * Find a client by IP address, protocol version, and minorversion
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b197563..38263f0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -23,6 +23,7 @@ struct nfs4_minor_version_ops;
 struct nfs_client {
 	atomic_t		cl_count;
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
+	int			cl_proto;	/* Network transport protocol */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
 #define NFS_CS_SESSION_INITING	2		/* busy initialising  session */
@@ -38,9 +39,7 @@ struct nfs_client {
 
 	struct rpc_clnt *	cl_rpcclient;
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS protocol vector */
-	int			cl_proto;	/* Network transport protocol */
 
-	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
 #ifdef CONFIG_NFS_V4
@@ -67,6 +66,7 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
+	u32			cl_minorversion;/* NFSv4 minorversion */
 	const struct nfs4_minor_version_ops *cl_mvops;
 #endif /* CONFIG_NFS_V4 */
 
