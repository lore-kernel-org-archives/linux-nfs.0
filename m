From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/27] NFS: Set default port for NFSv4,
	with support for AF_INET6
Date: Mon, 10 Dec 2007 14:58:00 -0500
Message-ID: <20071210195800.2823.55444.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:34026 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbXLJUCk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:02:40 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a helper function to set the default NFS port for NFSv4 mount
points.  The helper supports both AF_INET and AF_INET6 family addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 71eb5bc..62ba379 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1572,6 +1572,28 @@ static void nfs4_fill_super(struct super_block *sb)
 }
 
 /*
+ * If the user didn't specify a port, set the port number to
+ * the NFS version 4 default port.
+ */
+static void nfs4_default_port(struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+		if (ap->sin_port == 0)
+			ap->sin_port = htons(NFS_PORT);
+		break;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+		if (ap->sin6_port == 0)
+			ap->sin6_port = htons(NFS_PORT);
+		break;
+	}
+	}
+}
+
+/*
  * Validate NFSv4 mount options
  */
 static int nfs4_validate_mount_data(void *options,
@@ -1604,12 +1626,13 @@ static int nfs4_validate_mount_data(void *options,
 				   data->host_addr,
 				   sizeof(args->nfs_server.address)))
 			return -EFAULT;
-		if (args->nfs_server.address.sin_port == 0)
-			args->nfs_server.address.sin_port = htons(NFS_PORT);
 		if (!nfs_verify_server_address((struct sockaddr *)
 						&args->nfs_server.address))
 			goto out_no_address;
 
+		nfs4_default_port((struct sockaddr *)
+				  &args->nfs_server.address);
+
 		switch (data->auth_flavourlen) {
 		case 0:
 			args->auth_flavors[0] = RPC_AUTH_UNIX;
@@ -1663,12 +1686,13 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (args->nfs_server.address.sin_port == 0)
-			args->nfs_server.address.sin_port = htons(NFS_PORT);
 		if (!nfs_verify_server_address((struct sockaddr *)
 						&args->nfs_server.address))
 			return -EINVAL;
 
+		nfs4_default_port((struct sockaddr *)
+				  &args->nfs_server.address);
+
 		switch (args->auth_flavor_len) {
 		case 0:
 			args->auth_flavors[0] = RPC_AUTH_UNIX;

