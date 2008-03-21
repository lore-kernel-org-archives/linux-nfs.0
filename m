From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Set security flavor default for NFSv2/3 mounts like
	other defaults
Date: Fri, 21 Mar 2008 17:50:42 -0400
Message-ID: <20080321215042.13546.85805.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:12883 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbYCUVu7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 17:50:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set the default security flavor when we set the other mount option default
values.

After this change, the only path that needs to know the NFS_MOUNT_SECFLAVOUR
setting is the binary NFSv2/3 mount path; the flag is set only by user space
when passing in the legacy nfs_mount_data structure.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   23 +++++------------------
 1 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fad43d1..55b24c3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -743,9 +743,7 @@ static void nfs_parse_server_address(char *value,
 /*
  * Parse the value of the 'sec=' option.
  *
- * The flags setting is for v2/v3.  The flavor_len
- * setting is for v4.  v2/v3 also need to know the
- * difference between NULL and UNIX.
+ * The flavor_len setting is for v4 mounts.
  */
 static int nfs_parse_security_flavors(char *string,
 				      struct nfs_parsed_mount_data *mnt)
@@ -763,57 +761,46 @@ static int nfs_parse_security_flavors(char *string,
 
 	switch (token) {
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
@@ -1259,6 +1246,7 @@ static int nfs_validate_mount_data(void *options,
 	args->mount_server.protocol = XPRT_TRANSPORT_UDP;
 	args->nfs_server.port	= 0;	/* autobind unless user sets port */
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+	args->auth_flavors[0] = RPC_AUTH_UNIX;
 
 	switch (data->version) {
 	case 1:
@@ -1317,7 +1305,9 @@ static int nfs_validate_mount_data(void *options,
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
-		args->auth_flavors[0]	= data->pseudoflavor;
+
+		if (data->flags & NFS_MOUNT_SECFLAVOUR)
+			args->auth_flavors[0] = data->pseudoflavor;
 
 		/*
 		 * The legacy version 6 binary mount data from userspace has a
@@ -1378,9 +1368,6 @@ static int nfs_validate_mount_data(void *options,
 		}
 	}
 
-	if (!(args->flags & NFS_MOUNT_SECFLAVOUR))
-		args->auth_flavors[0] = RPC_AUTH_UNIX;
-
 #ifndef CONFIG_NFS_V3
 	if (args->flags & NFS_MOUNT_VER3)
 		goto out_v3_not_compiled;

