From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Set security flavor default for NFSv2/3 mounts like
	other defaults
Date: Tue, 24 Jun 2008 16:33:46 -0400
Message-ID: <20080624203345.3366.31456.stgit@ellison.1015granger.net>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53356 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbYFXUfp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 16:35:45 -0400
In-Reply-To: <20080624202913.3366.44867.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set the default security flavor when we set the other mount option default
values.  After this change, only the legacy user-space mount path needs to
set the NFS_MOUNT_SECFLAVOUR flag.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   22 +++++-----------------
 1 files changed, 5 insertions(+), 17 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 712b85f..19f3920 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -854,8 +854,7 @@ static void nfs_set_transport_defaults(struct nfs_parsed_mount_data *mnt)
 /*
  * Parse the value of the 'sec=' option.
  *
- * The flags setting is for v2/v3.  The flavor_len setting is for v4.
- * v2/v3 also need to know the difference between NULL and UNIX.
+ * The flavor_len setting is for v4 mounts.
  */
 static int nfs_parse_security_flavors(char *value,
 				      struct nfs_parsed_mount_data *mnt)
@@ -866,57 +865,46 @@ static int nfs_parse_security_flavors(char *value,
 
 	switch (match_token(value, nfs_secflavor_tokens, args)) {
 	case Opt_sec_none:
-		mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 0;
 		mnt->auth_flavors[0] = RPC_AUTH_NULL;
 		break;
 	case Opt_sec_sys:
-		mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 0;
 		mnt->auth_flavors[0] = RPC_AUTH_UNIX;
 		break;
 	case Opt_sec_krb5:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
 		break;
 	case Opt_sec_krb5i:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
 		break;
 	case Opt_sec_krb5p:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
 		break;
 	case Opt_sec_lkey:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
 		break;
 	case Opt_sec_lkeyi:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
 		break;
 	case Opt_sec_lkeyp:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
 		break;
 	case Opt_sec_spkm:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
 		break;
 	case Opt_sec_spkmi:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
 		break;
 	case Opt_sec_spkmp:
-		mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 		mnt->auth_flavor_len = 1;
 		mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
 		break;
@@ -1479,6 +1467,7 @@ static int nfs_validate_mount_data(void *options,
 	args->acdirmax		= NFS_DEF_ACDIRMAX;
 	args->mount_server.port	= 0;	/* autobind unless user sets port */
 	args->nfs_server.port	= 0;	/* autobind unless user sets port */
+	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 
 	switch (data->version) {
 	case 1:
@@ -1536,7 +1525,9 @@ static int nfs_validate_mount_data(void *options,
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
-		args->auth_flavors[0]	= data->pseudoflavor;
+
+		if (data->flags & NFS_MOUNT_SECFLAVOUR)
+			args->auth_flavors[0] = data->pseudoflavor;
 		if (!args->nfs_server.hostname)
 			goto out_nomem;
 
@@ -1600,9 +1591,6 @@ static int nfs_validate_mount_data(void *options,
 		}
 	}
 
-	if (!(args->flags & NFS_MOUNT_SECFLAVOUR))
-		args->auth_flavors[0] = RPC_AUTH_UNIX;
-
 #ifndef CONFIG_NFS_V3
 	if (args->flags & NFS_MOUNT_VER3)
 		goto out_v3_not_compiled;

