Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60449 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761467Ab2EJTIA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:08:00 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 11/14] NFS: Create a single function for text mount data
Date: Thu, 10 May 2012 15:07:40 -0400
Message-Id: <1336676863-9698-12-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
References: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The v2/3 and v4 cases were very similar, with just a few parameters
changed.  This makes it easy to share code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h |    1 +
 fs/nfs/super.c    |  151 +++++++++++++++++++++++++----------------------------
 2 files changed, 71 insertions(+), 81 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4cf76e9..bf64095 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -103,6 +103,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		version;
 	unsigned int		minorversion;
 	char			*fscache_uniq;
+	bool			need_mount;
 
 	struct {
 		struct sockaddr_storage	address;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c69c806..db636d7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -66,6 +66,7 @@
 #include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
+#define NFS_TEXT_DATA		1
 
 #ifdef CONFIG_NFS_V3
 #define NFS_DEFAULT_VERSION 3
@@ -333,8 +334,7 @@ static const struct super_operations nfs_sops = {
 };
 
 #ifdef CONFIG_NFS_V4
-static int nfs4_validate_text_mount_data(void *options,
-	struct nfs_parsed_mount_data *args, const char *dev_name);
+static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
 static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	struct nfs_parsed_mount_data *data);
 static struct dentry *nfs4_mount(struct file_system_type *fs_type,
@@ -964,6 +964,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 		data->auth_flavors[0]	= RPC_AUTH_UNIX;
 		data->auth_flavor_len	= 1;
 		data->minorversion	= 0;
+		data->need_mount	= true;
 		data->net		= current->nsproxy->net_ns;
 		security_init_mnt_opts(&data->lsm_opts);
 	}
@@ -1754,9 +1755,11 @@ static struct dentry *nfs_try_mount(int flags, const char *dev_name,
 	int status;
 	struct nfs_server *server;
 
-	status = nfs_request_mount(mount_info->parsed, mntfh);
-	if (status)
-		return ERR_PTR(status);
+	if (mount_info->parsed->need_mount) {
+		status = nfs_request_mount(mount_info->parsed, mntfh);
+		if (status)
+			return ERR_PTR(status);
+	}
 
 	/* Get a volume representation */
 	server = nfs_create_server(mount_info->parsed, mntfh);
@@ -1911,6 +1914,7 @@ static int nfs_validate_mount_data(void *options,
 		args->acregmax		= data->acregmax;
 		args->acdirmin		= data->acdirmin;
 		args->acdirmax		= data->acdirmax;
+		args->need_mount	= false;
 
 		memcpy(sap, &data->addr, sizeof(data->addr));
 		args->nfs_server.addrlen = sizeof(data->addr);
@@ -1962,38 +1966,8 @@ static int nfs_validate_mount_data(void *options,
 		}
 
 		break;
-	default: {
-		int status;
-
-		if (nfs_parse_mount_options((char *)options, args) == 0)
-			return -EINVAL;
-
-		if (!nfs_verify_server_address(sap))
-			goto out_no_address;
-
-		if (args->version == 4)
-#ifdef CONFIG_NFS_V4
-			return nfs4_validate_text_mount_data(options,
-							     args, dev_name);
-#else
-			goto out_v4_not_compiled;
-#endif
-
-		nfs_set_port(sap, &args->nfs_server.port, 0);
-
-		nfs_set_mount_transport_protocol(args);
-
-		status = nfs_parse_devname(dev_name,
-					   &args->nfs_server.hostname,
-					   PAGE_SIZE,
-					   &args->nfs_server.export_path,
-					   NFS_MAXPATHLEN);
-
-		if (status)
-			return status;
-
-		break;
-		}
+	default:
+		return NFS_TEXT_DATA;
 	}
 
 #ifndef CONFIG_NFS_V3
@@ -2022,12 +1996,6 @@ out_v3_not_compiled:
 	return -EPROTONOSUPPORT;
 #endif /* !CONFIG_NFS_V3 */
 
-#ifndef CONFIG_NFS_V4
-out_v4_not_compiled:
-	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
-	return -EPROTONOSUPPORT;
-#endif /* !CONFIG_NFS_V4 */
-
 out_nomem:
 	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
 	return -ENOMEM;
@@ -2041,6 +2009,60 @@ out_invalid_fh:
 	return -EINVAL;
 }
 
+static int nfs_validate_text_mount_data(void *options,
+					struct nfs_parsed_mount_data *args,
+					const char *dev_name)
+{
+	int port = 0;
+	int max_namelen = PAGE_SIZE;
+	int max_pathlen = NFS_MAXPATHLEN;
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+
+	if (nfs_parse_mount_options((char *)options, args) == 0)
+		return -EINVAL;
+
+	if (!nfs_verify_server_address(sap))
+		goto out_no_address;
+
+	if (args->version == 4) {
+#ifdef CONFIG_NFS_V4
+		port = NFS_PORT;
+		max_namelen = NFS4_MAXNAMLEN;
+		max_pathlen = NFS4_MAXPATHLEN;
+		nfs_validate_transport_protocol(args);
+		nfs4_validate_mount_flags(args);
+#else
+		goto out_v4_not_compiled;
+#endif /* CONFIG_NFS_V4 */
+	} else
+		nfs_set_mount_transport_protocol(args);
+
+	nfs_set_port(sap, &args->nfs_server.port, port);
+
+	if (args->auth_flavor_len > 1)
+		goto out_bad_auth;
+
+	return nfs_parse_devname(dev_name,
+				   &args->nfs_server.hostname,
+				   max_namelen,
+				   &args->nfs_server.export_path,
+				   max_pathlen);
+
+#ifndef CONFIG_NFS_V4
+out_v4_not_compiled:
+	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
+	return -EPROTONOSUPPORT;
+#endif /* !CONFIG_NFS_V4 */
+
+out_no_address:
+	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
+	return -EINVAL;
+
+out_bad_auth:
+	dfprintk(MOUNT, "NFS: Too many RPC auth flavours specified\n");
+	return -EINVAL;
+}
+
 static int
 nfs_compare_remount_data(struct nfs_server *nfss,
 			 struct nfs_parsed_mount_data *data)
@@ -2438,6 +2460,8 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
+	if (error == NFS_TEXT_DATA)
+		error = nfs_validate_text_mount_data(raw_data, data, dev_name);
 	if (error < 0) {
 		mntroot = ERR_PTR(error);
 		goto out;
@@ -2572,37 +2596,6 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
 }
 
-static int nfs4_validate_text_mount_data(void *options,
-					 struct nfs_parsed_mount_data *args,
-					 const char *dev_name)
-{
-	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
-
-	nfs_set_port(sap, &args->nfs_server.port, NFS_PORT);
-
-	nfs_validate_transport_protocol(args);
-
-	nfs4_validate_mount_flags(args);
-
-	if (args->version != 4) {
-		dfprintk(MOUNT,
-			 "NFS4: Illegal mount version\n");
-		return -EINVAL;
-	}
-
-	if (args->auth_flavor_len > 1) {
-		dfprintk(MOUNT,
-			 "NFS4: Too many RPC auth flavours specified\n");
-		return -EINVAL;
-	}
-
-	return nfs_parse_devname(dev_name,
-				   &args->nfs_server.hostname,
-				   NFS4_MAXNAMLEN,
-				   &args->nfs_server.export_path,
-				   NFS4_MAXPATHLEN);
-}
-
 /*
  * Validate NFSv4 mount options
  */
@@ -2673,13 +2666,7 @@ static int nfs4_validate_mount_data(void *options,
 
 		break;
 	default:
-		if (nfs_parse_mount_options((char *)options, args) == 0)
-			return -EINVAL;
-
-		if (!nfs_verify_server_address(sap))
-			return -EINVAL;
-
-		return nfs4_validate_text_mount_data(options, args, dev_name);
+		return NFS_TEXT_DATA;
 	}
 
 	return 0;
@@ -2880,6 +2867,8 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 
 	/* Validate the mount data */
 	error = nfs4_validate_mount_data(raw_data, data, dev_name);
+	if (error == NFS_TEXT_DATA)
+		error = nfs_validate_text_mount_data(raw_data, data, dev_name);
 	if (error < 0) {
 		res = ERR_PTR(error);
 		goto out;
-- 
1.7.10.1

