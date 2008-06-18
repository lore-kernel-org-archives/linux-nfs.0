From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: Add string length argument to
	nfs_parse_server_address
Date: Wed, 18 Jun 2008 18:32:13 -0400
Message-ID: <20080618223211.16006.8247.stgit@ellison.1015granger.net>
References: <20080618222951.16006.3679.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29766 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251AbYFRWcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 18:32:35 -0400
In-Reply-To: <20080618222951.16006.3679.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To make nfs_parse_server_address() more generally useful, allow it to
accept input strings that are not terminated with '\0'.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  107 ++++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 77 insertions(+), 30 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 98c8110..818bc1b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -62,6 +62,13 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+#ifndef INET_ADDRSTRLEN
+#define INET_ADDRSTRLEN		(16)
+#endif
+#ifndef INET6_ADDRSTRLEN
+#define INET6_ADDRSTRLEN	(48)
+#endif
+
 enum {
 	/* Mount options that take no arguments */
 	Opt_soft, Opt_hard,
@@ -702,38 +709,76 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 	return 0;
 }
 
-/*
- * Parse string addresses passed in via a mount option,
- * and construct a sockaddr based on the result.
- *
- * If address parsing fails, set the sockaddr's address
- * family to AF_UNSPEC to force nfs_verify_server_address()
- * to punt the mount.
- */
-static void nfs_parse_server_address(char *value,
-				     struct sockaddr *sap,
-				     size_t *len)
+static void nfs_parse_ipv4_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
 {
-	if (strchr(value, ':')) {
-		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
-		u8 *addr = (u8 *)&ap->sin6_addr.in6_u;
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	u8 *addr = (u8 *)&sin->sin_addr.s_addr;
+
+	if (str_len <= INET_ADDRSTRLEN) {
+		dfprintk(MOUNT, "NFS: parsing IPv4 address %*s\n",
+				(int)str_len, string);
 
-		ap->sin6_family = AF_INET6;
-		*len = sizeof(*ap);
-		if (in6_pton(value, -1, addr, '\0', NULL))
+		sin->sin_family = AF_INET;
+		*addr_len = sizeof(*sin);
+		if (in4_pton(string, str_len, addr, '\0', NULL))
 			return;
-	} else {
-		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-		u8 *addr = (u8 *)&ap->sin_addr.s_addr;
+	}
+
+	sap->sa_family = AF_UNSPEC;
+	*addr_len = 0;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void nfs_parse_ipv6_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
 
-		ap->sin_family = AF_INET;
-		*len = sizeof(*ap);
-		if (in4_pton(value, -1, addr, '\0', NULL))
+	if (str_len <= INET6_ADDRSTRLEN) {
+		dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
+				(int)str_len, string);
+
+		sin6->sin6_family = AF_INET6;
+		*addr_len = sizeof(*sin6);
+		if (in6_pton(string, str_len, addr, '\0', NULL))
 			return;
 	}
 
 	sap->sa_family = AF_UNSPEC;
-	*len = 0;
+	*addr_len = 0;
+}
+#else
+static void nfs_parse_ipv6_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
+{
+	sap->sa_family = AF_UNSPEC;
+	*addr_len = 0;
+}
+#endif
+
+/*
+ * Construct a sockaddr based on the contents of a string that contains
+ * an IP address in presentation format.
+ *
+ * If there is a problem constructing the new sockaddr, set the address
+ * family to AF_UNSPEC.
+ */
+static void nfs_parse_ip_address(char *string, size_t str_len,
+				 struct sockaddr *sap, size_t *addr_len)
+{
+	unsigned int i, colons;
+
+	colons = 0;
+	for (i = 0; i < str_len; i++)
+		if (string[i] == ':')
+			colons++;
+
+	if (colons >= 2)
+		nfs_parse_ipv6_address(string, str_len, sap, addr_len);
+	else
+		nfs_parse_ipv4_address(string, str_len, sap, addr_len);
 }
 
 /*
@@ -1093,9 +1138,10 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->nfs_server.address,
-						 &mnt->nfs_server.addrlen);
+			nfs_parse_ip_address(string, strlen(string),
+					     (struct sockaddr *)
+						&mnt->nfs_server.address,
+					     &mnt->nfs_server.addrlen);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -1116,9 +1162,10 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->mount_server.address,
-						 &mnt->mount_server.addrlen);
+			nfs_parse_ip_address(string, strlen(string),
+					     (struct sockaddr *)
+						&mnt->mount_server.address,
+					     &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
 

