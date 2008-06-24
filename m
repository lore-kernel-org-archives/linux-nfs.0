From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS4: Set security flavor default for NFSv4 mounts like
	other defaults
Date: Tue, 24 Jun 2008 16:33:54 -0400
Message-ID: <20080624203353.3366.38324.stgit@ellison.1015granger.net>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53370 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbYFXUfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 16:35:48 -0400
In-Reply-To: <20080624202913.3366.44867.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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
index 19f3920..fa94851 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2044,6 +2044,8 @@ static int nfs4_validate_mount_data(void *options,
 	args->acdirmin		= NFS_DEF_ACDIRMIN;
 	args->acdirmax		= NFS_DEF_ACDIRMAX;
 	args->nfs_server.port	= NFS_PORT; /* 2049 unless user set port= */
+	args->auth_flavors[0]	= RPC_AUTH_UNIX;
+	args->auth_flavor_len	= 0;
 
 	switch (data->version) {
 	case 1:
@@ -2059,18 +2061,13 @@ static int nfs4_validate_mount_data(void *options,
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
@@ -2121,15 +2118,8 @@ static int nfs4_validate_mount_data(void *options,
 
 		nfs_set_transport_defaults(args);
 
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
 
 		if (args->client_address == NULL)
 			goto out_no_client_address;

