From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: Refactor NFSv4 text-based mount option validation
Date: Sun, 30 Aug 2009 12:34:47 -0400
Message-ID: <20090830163447.3652.34535.stgit@matisse.1015granger.net>
References: <20090830162211.3652.14638.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:49884
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753859AbZH3Qev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 12:34:51 -0400
In-Reply-To: <20090830162211.3652.14638.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the part of nfs4_validate_mount_options that handles text-based
options into a helper, so we can call it from other functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   69 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 34 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ea7aedc..9119f22 100644
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
@@ -2272,6 +2274,36 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3);
 }
 
+static int nfs4_validate_text_mount_data(void *options,
+					 struct nfs_parsed_mount_data *args,
+					 const char *dev_name)
+{
+	if (nfs_parse_mount_options((char *)options, args) == 0)
+		return -EINVAL;
+
+	if (!nfs_verify_server_address(nfs_server_address(args)))
+		return -EINVAL;
+
+	nfs_set_default_port(nfs_server_address(args),
+				args->nfs_server.port, NFS_PORT);
+
+	nfs_validate_transport_protocol(args);
+
+	nfs4_validate_mount_flags(args);
+
+	if (args->auth_flavor_len > 1)
+		return -EINVAL;
+
+	if (args->client_address == NULL)
+		return -EINVAL;
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
@@ -2353,37 +2385,8 @@ static int nfs4_validate_mount_data(void *options,
 		nfs_validate_transport_protocol(args);
 
 		break;
-	default: {
-		int status;
-
-		if (nfs_parse_mount_options((char *)options, args) == 0)
-			return -EINVAL;
-
-		if (!nfs_verify_server_address(nfs_server_address(args)))
-			return -EINVAL;
-		nfs_set_default_port(nfs_server_address(args),
-					args->nfs_server.port, NFS_PORT);
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
-
-		break;
-		}
+	default:
+		return nfs4_validate_text_mount_data(options, args, dev_name);
 	}
 
 	return 0;
@@ -2400,10 +2403,6 @@ out_inval_auth:
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;
-
-out_no_client_address:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass callback address\n");
-	return -EINVAL;
 }
 
 /*

