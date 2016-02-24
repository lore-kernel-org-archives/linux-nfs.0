Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:61755 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756250AbcBXR4x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:53 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/8] NFS parse multiple hostnames
Date: Wed, 24 Feb 2016 12:56:20 -0500
Message-ID: <1456336587-17374-2-git-send-email-andros@netapp.com>
In-Reply-To: <1456336587-17374-1-git-send-email-andros@netapp.com>
References: <1456336587-17374-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h | 17 +++++++++++++++++
 fs/nfs/nfs4_fs.h  |  9 +++++++++
 fs/nfs/super.c    | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9a547aa..0296476 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -75,6 +75,20 @@ struct nfs_client_initdata {
 	struct net *net;
 };
 
+/**
+ * NFS_MAXHOSTNAME of 255 limits the number of multiple hostnames on the
+ * mount stanza. 16 is a reasonable maximum number
+ */
+#define NFS_MAX_MULTIADDR       16
+
+
+/* hold multiple hostname info */
+struct multi_addr {
+	struct sockaddr_storage	addr;
+	size_t			addrlen;
+	char			*hostname;
+};
+
 /*
  * In-kernel mount arguments
  */
@@ -113,6 +127,9 @@ struct nfs_parsed_mount_data {
 		unsigned short		protocol;
 	} nfs_server;
 
+	unsigned int		num_multi;
+	struct multi_addr	*multiaddrs;
+
 	struct security_mnt_opts lsm_opts;
 	struct net		*net;
 };
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4afdee4..940a3f1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -214,6 +214,15 @@ struct nfs4_mig_recovery_ops {
 	int (*fsid_present)(struct inode *, struct rpc_cred *);
 };
 
+struct nfs4_add_xprt_data {
+	struct nfs_client	*clp;
+	struct rpc_cred		*cred;
+};
+extern int nfs4_test_session_trunk_and_add_xprt(struct rpc_clnt *clnt,
+					struct rpc_xprt_switch *xps,
+					struct rpc_xprt *xprt,
+					void *data);
+
 extern const struct dentry_operations nfs4_dentry_operations;
 
 /* dir.c */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f126828..70a4fda 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -107,6 +107,7 @@ enum {
 	Opt_nfsvers,
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_multiaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
 	Opt_local_lock,
@@ -178,6 +179,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_clientaddr, "clientaddr=%s" },
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
+	{ Opt_multiaddr, "multiaddr=%s" },
 
 	{ Opt_lookupcache, "lookupcache=%s" },
 	{ Opt_fscache_uniq, "fsc=%s" },
@@ -921,6 +923,12 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data) {
+		data->multiaddrs = kzalloc(sizeof(*data->multiaddrs) *
+				NFS_MAX_MULTIADDR, GFP_KERNEL);
+		if (!data->multiaddrs) {
+			kfree(data);
+			return NULL;
+		}
 		data->acregmin		= NFS_DEF_ACREGMIN;
 		data->acregmax		= NFS_DEF_ACREGMAX;
 		data->acdirmin		= NFS_DEF_ACDIRMIN;
@@ -939,12 +947,20 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 
 static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 {
+	struct multi_addr *multip = data->multiaddrs;
+	int i;
+
 	if (data) {
 		kfree(data->client_address);
 		kfree(data->mount_server.hostname);
 		kfree(data->nfs_server.export_path);
 		kfree(data->nfs_server.hostname);
 		kfree(data->fscache_uniq);
+		for (i = 0; i < data->num_multi; i++) {
+			kfree(multip->hostname);
+			multip++;
+		}
+		kfree(data->multiaddrs);
 		security_free_mnt_opts(&data->lsm_opts);
 		kfree(data);
 	}
@@ -1200,6 +1216,7 @@ static int nfs_parse_mount_options(char *raw,
 	int rc, sloppy = 0, invalid_option = 0;
 	unsigned short protofamily = AF_UNSPEC;
 	unsigned short mountfamily = AF_UNSPEC;
+	struct multi_addr *multip = mnt->multiaddrs;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -1589,6 +1606,25 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			};
 			break;
+		case Opt_multiaddr:
+			if (mnt->num_multi == NFS_MAX_MULTIADDR)
+				goto out_too_many_multiaddrs;
+
+			if (nfs_get_option_str(args, &multip->hostname))
+				goto out_nomem;
+
+			multip->addrlen = rpc_pton(mnt->net, multip->hostname,
+						strlen(multip->hostname),
+						(struct sockaddr *)
+						&multip->addr,
+						sizeof(multip->addr));
+
+			dfprintk(MOUNT, "NFS:   Added multiaddr %s\n",
+				multip->hostname);
+			mnt->num_multi++;
+			multip++;
+
+			break;
 
 		/*
 		 * Special options
@@ -1640,6 +1676,10 @@ static int nfs_parse_mount_options(char *raw,
 
 	return 1;
 
+out_too_many_multiaddrs:
+	printk(KERN_INFO "NFS: %d is too many multiple hostnames.\n",
+		mnt->num_multi);
+	return 0;
 out_mountproto_mismatch:
 	printk(KERN_INFO "NFS: mount server address does not match mountproto= "
 			 "option\n");
-- 
1.8.3.1

