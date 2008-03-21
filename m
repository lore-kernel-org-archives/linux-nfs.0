From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS4: Set security flavor default for NFSv4 mounts like
	other defaults
Date: Fri, 21 Mar 2008 17:50:49 -0400
Message-ID: <20080321215049.13546.58935.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:12977 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbYCUVvG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 17:51:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set the default security flavor when we set the other mount option
default values for NFSv4.  This cleans up the NFSv4 mount option parsing
path to look like the NFSv2/v3 one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 55b24c3..0869cf2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1806,6 +1806,8 @@ static int nfs4_validate_mount_data(void *options,
 	args->acdirmax		= 60;
 	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+	args->auth_flavors[0]	= RPC_AUTH_UNIX;
+	args->auth_flavor_len	= 0;
 
 	switch (data->version) {
 	case 1:
@@ -1821,18 +1823,13 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
-		switch (data->auth_flavourlen) {
-		case 0:
-			args->auth_flavors[0] = RPC_AUTH_UNIX;
-			break;
-		case 1:
+		if (data->auth_flavourlen) {
+			if (data->auth_flavourlen > 1)
+				goto out_inval_auth;
 			if (copy_from_user(&args->auth_flavors[0],
 					   data->auth_flavours,
 					   sizeof(args->auth_flavors[0])))
 				return -EFAULT;
-			break;
-		default:
-			goto out_inval_auth;
 		}
 
 		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
@@ -1878,15 +1875,8 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			return -EINVAL;
 
-		switch (args->auth_flavor_len) {
-		case 0:
-			args->auth_flavors[0] = RPC_AUTH_UNIX;
-			break;
-		case 1:
-			break;
-		default:
+		if (args->auth_flavor_len > 1)
 			goto out_inval_auth;
-		}
 
 		/*
 		 * Split "dev_name" into "hostname:mntpath".

