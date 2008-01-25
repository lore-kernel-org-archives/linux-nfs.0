From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 065/112] NFS: Set default port for NFSv4, with support for
	AF_INET6
Date: Fri, 25 Jan 2008 11:37:45 -0500
Message-ID: <20080125163745.31887.83834.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731AbYAYRA0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:26 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09Ue010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:25 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Create a helper function to set the default NFS port for NFSv4 mount
points.  The helper supports both AF_INET and AF_INET6 family addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ef1aad7..a88697f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1596,6 +1596,28 @@ static void nfs4_fill_super(struct super_block *sb)
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
@@ -1628,12 +1650,13 @@ static int nfs4_validate_mount_data(void *options,
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
@@ -1687,12 +1710,13 @@ static int nfs4_validate_mount_data(void *options,
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
