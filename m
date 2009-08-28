From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Support NFSv4 with the "nfs" file system type
Date: Fri, 28 Aug 2009 10:57:57 -0400
Message-ID: <20090828145632.4407.78239.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [72.240.62.6] ([72.240.62.6]:60685 "EHLO
	matisse.1015granger.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750921AbZH1Pqi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2009 11:46:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Completely untested -- for discussion only.

When mounting an "nfs" type file system, recognize "v4," "vers=4," or
"nfsvers=4" mount options, and send NFSv4 requests on the wire.  The
file system type remains an "nfs" file system after the mount(2) call
succeeds, and the "nfs4" file system is still fully supported and
unchanged.

This could be cleaner, and there are still a lot of little details to
work out.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Trond-

Was this what you were thinking?

 fs/nfs/internal.h    |    1 
 fs/nfs/super.c       |  115 +++++++++++++++++++++++++++++++++++++++++++-------
 include/linux/nfs4.h |    1 
 3 files changed, 102 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dabf345..8d42432 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -63,6 +63,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		auth_flavor_len;
 	rpc_authflavor_t	auth_flavors[1];
 	char			*client_address;
+	unsigned int		version;
 	unsigned int		minorversion;
 	char			*fscache_uniq;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f3a95df..e3e8992 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -73,7 +73,7 @@ enum {
 	Opt_cto, Opt_nocto,
 	Opt_ac, Opt_noac,
 	Opt_lock, Opt_nolock,
-	Opt_v2, Opt_v3,
+	Opt_v2, Opt_v3, Opt_v4,
 	Opt_udp, Opt_tcp, Opt_rdma,
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
@@ -127,6 +127,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_nolock, "nolock" },
 	{ Opt_v2, "v2" },
 	{ Opt_v3, "v3" },
+	{ Opt_v4, "v4" },
 	{ Opt_udp, "udp" },
 	{ Opt_tcp, "tcp" },
 	{ Opt_rdma, "rdma" },
@@ -272,6 +273,11 @@ static const struct super_operations nfs_sops = {
 };
 
 #ifdef CONFIG_NFS_V4
+static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args);
+static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
+		int flags, void *data, const char *hostname);
+static int nfs_follow_remote_path(struct vfsmount *root_mnt,
+		const char *export_path, struct vfsmount *mnt_target);
 static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static int nfs4_remote_get_sb(struct file_system_type *fs_type,
@@ -915,10 +921,18 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 		case Opt_v2:
 			mnt->flags &= ~NFS_MOUNT_VER3;
+			mnt->version = 2;
 			break;
 		case Opt_v3:
 			mnt->flags |= NFS_MOUNT_VER3;
+			mnt->version = 3;
+			break;
+#ifdef CONFIG_NFS_V4
+		case Opt_v4:
+			mnt->flags &= ~NFS_MOUNT_VER3;
+			mnt->version = 4;
 			break;
+#endif
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
@@ -1132,10 +1146,18 @@ static int nfs_parse_mount_options(char *raw,
 			switch (option) {
 			case NFS2_VERSION:
 				mnt->flags &= ~NFS_MOUNT_VER3;
+				mnt->version = 2;
 				break;
 			case NFS3_VERSION:
 				mnt->flags |= NFS_MOUNT_VER3;
+				mnt->version = 3;
 				break;
+#ifdef CONFIG_NFS_V4
+			case NFS4_VERSION:
+				mnt->flags &= ~NFS_MOUNT_VER3;
+				mnt->version = 4;
+				break;
+#endif
 			default:
 				goto out_invalid_value;
 			}
@@ -1713,24 +1735,50 @@ static int nfs_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
-		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
-				args->nfs_server.port);
+		if (args->version == 4) {
+			/*
+			 * XXX: Still need to set 2049 if user didn't specify a port
+			 */
+			rpc_set_port((struct sockaddr *)&args->nfs_server.address,
+					args->nfs_server.port);
 
-		nfs_set_mount_transport_protocol(args);
+			nfs_validate_transport_protocol(args);
 
-		status = nfs_parse_devname(dev_name,
-					   &args->nfs_server.hostname,
-					   PAGE_SIZE,
-					   &args->nfs_server.export_path,
-					   NFS_MAXPATHLEN);
-		if (!status)
-			status = nfs_try_mount(args, mntfh);
+			nfs4_validate_mount_flags(args);
 
-		kfree(args->nfs_server.export_path);
-		args->nfs_server.export_path = NULL;
+			if (args->auth_flavor_len > 1)
+				goto out_inval_auth;
 
-		if (status)
-			return status;
+			if (args->client_address == NULL)
+				goto out_no_client_address;
+
+			status = nfs_parse_devname(dev_name,
+						   &args->nfs_server.hostname,
+						   NFS4_MAXNAMLEN,
+						   &args->nfs_server.export_path,
+						   NFS4_MAXPATHLEN);
+			if (status < 0)
+				return status;
+		} else {
+			rpc_set_port((struct sockaddr *)&args->nfs_server.address,
+					args->nfs_server.port);
+
+			nfs_set_mount_transport_protocol(args);
+
+			status = nfs_parse_devname(dev_name,
+						   &args->nfs_server.hostname,
+						   PAGE_SIZE,
+						   &args->nfs_server.export_path,
+						   NFS_MAXPATHLEN);
+			if (!status)
+				status = nfs_try_mount(args, mntfh);
+
+			kfree(args->nfs_server.export_path);
+			args->nfs_server.export_path = NULL;
+
+			if (status)
+				return status;
+		}
 
 		break;
 		}
@@ -1773,6 +1821,16 @@ out_no_address:
 out_invalid_fh:
 	dfprintk(MOUNT, "NFS: invalid root filehandle\n");
 	return -EINVAL;
+
+#ifdef CONFIG_NFS_V4
+out_inval_auth:
+	dfprintk(MOUNT, "NFS: Invalid number of RPC auth flavours\n");
+	return -EINVAL;
+
+out_no_client_address:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass callback address\n");
+	return -EINVAL;
+#endif
 }
 
 static int
@@ -2057,6 +2115,33 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	if (error < 0)
 		goto out;
 
+	if (data->version == 4) {
+		char *export_path;
+		struct vfsmount *root_mnt;
+
+		export_path = data->nfs_server.export_path;
+		data->nfs_server.export_path = "/";
+		root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
+				data->nfs_server.hostname);
+		data->nfs_server.export_path = export_path;
+
+		error = PTR_ERR(root_mnt);
+		if (IS_ERR(root_mnt))
+			goto out_v4;
+
+		error = nfs_follow_remote_path(root_mnt, export_path, mnt);
+
+out_v4:
+		kfree(data->client_address);
+		kfree(data->nfs_server.export_path);
+		kfree(data->nfs_server.hostname);
+		kfree(data->fscache_uniq);
+		kfree(data);
+		dprintk("<-- nfs4_get_sb() = %d%s\n", error,
+			error != 0 ? " [error]" : "");
+		return error;
+	}
+
 	/* Get a volume representation */
 	server = nfs_create_server(data, mntfh);
 	if (IS_ERR(server)) {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index bd2eba5..33b2836 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -472,6 +472,7 @@ enum lock_type4 {
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
+#define NFS4_VERSION 4
 #define NFS4_MINOR_VERSION 0
 
 #if defined(CONFIG_NFS_V4_1)

