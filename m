From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Refactor NFSv4 text-based mount option validation
Date: Tue, 01 Sep 2009 10:21:17 -0400
Message-ID: <20090901142116.3700.55866.stgit@matisse.1015granger.net>
References: <20090901141615.3700.41738.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:51786
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754935AbZIAOVU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:21:20 -0400
In-Reply-To: <20090901141615.3700.41738.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor the part of nfs4_validate_mount_options() that
handles text-based options, so we can call it from the NFSv2/v3
option validation function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   63 +++++++++++++++++++++++++++++++-------------------------
 1 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0554433..599e8c5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -272,6 +272,8 @@ static const struct super_operations nfs_sops = {
 };
 
 #ifdef CONFIG_NFS_V4
+static int nfs4_validate_text_mount_data(void *options,
+	struct nfs_parsed_mount_data *args, const char *dev_name);
 static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static int nfs4_remote_get_sb(struct file_system_type *fs_type,
@@ -2262,6 +2264,37 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3);
 }
 
+static int nfs4_validate_text_mount_data(void *options,
+					 struct nfs_parsed_mount_data *args,
+					 const char *dev_name)
+{
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+
+	nfs_set_default_port(sap, args->nfs_server.port, NFS_PORT);
+
+	nfs_validate_transport_protocol(args);
+
+	nfs4_validate_mount_flags(args);
+
+	if (args->auth_flavor_len > 1) {
+		dfprintk(MOUNT,
+			 "NFS4: Too many RPC auth flavours specified\n");
+		return -EINVAL;
+	}
+
+	if (args->client_address == NULL) {
+		dfprintk(MOUNT,
+			 "NFS4: mount program didn't pass callback address\n");
+		return -EINVAL;
+	}
+
+	return nfs_parse_devname(dev_name,
+				   &args->nfs_server.hostname,
+				   NFS4_MAXNAMLEN,
+				   &args->nfs_server.export_path,
+				   NFS4_MAXPATHLEN);
+}
+
 /*
  * Validate NFSv4 mount options
  */
@@ -2342,36 +2375,14 @@ static int nfs4_validate_mount_data(void *options,
 		nfs_validate_transport_protocol(args);
 
 		break;
-	default: {
-		int status;
-
+	default:
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
 		if (!nfs_verify_server_address(sap))
 			return -EINVAL;
-		nfs_set_default_port(sap, args->nfs_server.port, NFS_PORT);
-
-		nfs_validate_transport_protocol(args);
-
-		nfs4_validate_mount_flags(args);
-
-		if (args->auth_flavor_len > 1)
-			goto out_inval_auth;
-
-		if (args->client_address == NULL)
-			goto out_no_client_address;
-
-		status = nfs_parse_devname(dev_name,
-					   &args->nfs_server.hostname,
-					   NFS4_MAXNAMLEN,
-					   &args->nfs_server.export_path,
-					   NFS4_MAXPATHLEN);
-		if (status < 0)
-			return status;
 
-		break;
-		}
+		return nfs4_validate_text_mount_data(options, args, dev_name);
 	}
 
 	return 0;
@@ -2388,10 +2399,6 @@ out_inval_auth:
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;
-
-out_no_client_address:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass callback address\n");
-	return -EINVAL;
 }
 
 /*

