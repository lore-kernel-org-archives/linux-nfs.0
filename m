From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Allow the "nfs" file system type to support NFSv4
Date: Wed, 02 Sep 2009 09:52:23 -0400
Message-ID: <20090902135222.3550.59986.stgit@matisse.1015granger.net>
References: <20090902135032.3550.23170.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:54765
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752173AbZIBNw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 09:52:26 -0400
In-Reply-To: <20090902135032.3550.23170.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When mounting an "nfs" type file system, recognize "v4," "vers=4," or
"nfsvers=4" mount options, and convert the file system to "nfs4" under
the covers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h    |    1 +
 fs/nfs/super.c       |   42 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs4.h |    1 +
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ffadffa..769582e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -68,6 +68,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		auth_flavor_len;
 	rpc_authflavor_t	auth_flavors[1];
 	char			*client_address;
+	unsigned int		version;
 	unsigned int		minorversion;
 	char			*fscache_uniq;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c105e12..bde444b 100644
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
@@ -934,10 +935,18 @@ static int nfs_parse_mount_options(char *raw,
 			break;
 		case Opt_v2:
 			mnt->flags &= ~NFS_MOUNT_VER3;
+			mnt->version = 2;
 			break;
 		case Opt_v3:
 			mnt->flags |= NFS_MOUNT_VER3;
+			mnt->version = 3;
 			break;
+#ifdef CONFIG_NFS_V4
+		case Opt_v4:
+			mnt->flags &= ~NFS_MOUNT_VER3;
+			mnt->version = 4;
+			break;
+#endif
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
@@ -1151,10 +1160,18 @@ static int nfs_parse_mount_options(char *raw,
 			switch (option) {
 			case NFS2_VERSION:
 				mnt->flags &= ~NFS_MOUNT_VER3;
+				mnt->version = 2;
 				break;
 			case NFS3_VERSION:
 				mnt->flags |= NFS_MOUNT_VER3;
+				mnt->version = 3;
+				break;
+#ifdef CONFIG_NFS_V4
+			case NFS4_VERSION:
+				mnt->flags &= ~NFS_MOUNT_VER3;
+				mnt->version = 4;
 				break;
+#endif
 			default:
 				goto out_invalid_value;
 			}
@@ -1629,6 +1646,7 @@ static int nfs_validate_mount_data(void *options,
 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
 	args->auth_flavor_len	= 1;
+	args->minorversion	= 0;
 
 	switch (data->version) {
 	case 1:
@@ -1726,6 +1744,14 @@ static int nfs_validate_mount_data(void *options,
 		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
+		if (args->version == 4)
+#ifdef CONFIG_NFS_V4
+			return nfs4_validate_text_mount_data(options,
+							     args, dev_name);
+#else
+			goto out_v4_not_compiled;
+#endif
+
 		nfs_set_default_port(sap, args->nfs_server.port, 0);
 
 		nfs_set_mount_transport_protocol(args);
@@ -1774,6 +1800,12 @@ out_v3_not_compiled:
 	return -EPROTONOSUPPORT;
 #endif /* !CONFIG_NFS_V3 */
 
+#ifndef CONFIG_NFS_V4
+out_v4_not_compiled:
+	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
+	return -EPROTONOSUPPORT;
+#endif /* !CONFIG_NFS_V4 */
+
 out_nomem:
 	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
 	return -ENOMEM;
@@ -2069,6 +2101,14 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	if (error < 0)
 		goto out;
 
+#ifdef CONFIG_NFS_V4
+	if (data->version == 4) {
+		error = nfs4_try_mount(flags, dev_name, data, mnt);
+		kfree(data->client_address);
+		goto out;
+	}
+#endif	/* CONFIG_NFS_V4 */
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

