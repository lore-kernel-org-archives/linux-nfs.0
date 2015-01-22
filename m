Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38196 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbbAVXgw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:36:52 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so293944pab.5
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:36:52 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 08/51] nfsv3: introduce nfs3_set_ds_client
Date: Thu, 22 Jan 2015 15:35:40 -0800
Message-Id: <1421969783-92997-9-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

The flexfiles layout wants to create DS connection over NFSv3.
Add nfs3_set_ds_client to allow that to happen.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/internal.h         |  4 ++++
 fs/nfs/nfs3_fs.h          |  2 ++
 fs/nfs/nfs3client.c       | 34 ++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3super.c        |  2 +-
 include/linux/nfs_fs_sb.h |  9 +++++----
 5 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7d7c36f..7332ba1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -193,6 +193,10 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     rpc_authflavor_t au_flavor);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
+extern struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
+			const struct sockaddr *ds_addr, int ds_addrlen,
+			int ds_proto, unsigned int ds_timeo,
+			unsigned int ds_retrans, rpc_authflavor_t au_flavor);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
index 333ae40..e134d65 100644
--- a/fs/nfs/nfs3_fs.h
+++ b/fs/nfs/nfs3_fs.h
@@ -30,5 +30,7 @@ struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subver
 struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
 				     struct nfs_fattr *, rpc_authflavor_t);
 
+/* nfs3super.c */
+extern struct nfs_subversion nfs_v3;
 
 #endif /* __LINUX_FS_NFS_NFS3_FS_H */
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 8c1b437..52e2344 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -64,3 +64,37 @@ struct nfs_server *nfs3_clone_server(struct nfs_server *source,
 		nfs_init_server_aclclient(server);
 	return server;
 }
+
+/*
+ * Set up a pNFS Data Server client over NFSv3.
+ *
+ * Return any existing nfs_client that matches server address,port,version
+ * and minorversion.
+ *
+ * For a new nfs_client, use a soft mount (default), a low retrans and a
+ * low timeout interval so that if a connection is lost, we retry through
+ * the MDS.
+ */
+struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
+		const struct sockaddr *ds_addr, int ds_addrlen,
+		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
+		rpc_authflavor_t au_flavor)
+{
+	struct nfs_client_initdata cl_init = {
+		.addr = ds_addr,
+		.addrlen = ds_addrlen,
+		.nfs_mod = &nfs_v3,
+		.proto = ds_proto,
+		.net = mds_clp->cl_net,
+	};
+	struct rpc_timeout ds_timeout;
+	struct nfs_client *clp;
+
+	/* Use the MDS nfs_client cl_ipaddr. */
+	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
+	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
+			     au_flavor);
+
+	return clp;
+}
+EXPORT_SYMBOL_GPL(nfs3_set_ds_client);
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 6af29c2..5c4394e 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -7,7 +7,7 @@
 #include "nfs3_fs.h"
 #include "nfs.h"
 
-static struct nfs_subversion nfs_v3 = {
+struct nfs_subversion nfs_v3 = {
 	.owner = THIS_MODULE,
 	.nfs_fs   = &nfs_fs_type,
 	.rpc_vers = &nfs_version3,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ddea982..5e1273d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -77,10 +77,6 @@ struct nfs_client {
 	/* Client owner identifier */
 	const char *		cl_owner_id;
 
-	/* Our own IP address, as a null-terminated string.
-	 * This is used to generate the mv0 callback address.
-	 */
-	char			cl_ipaddr[48];
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 	unsigned long		cl_mig_gen;
@@ -108,6 +104,11 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_COMMIT   6	/* COMMIT */
 #endif /* CONFIG_NFS_V4 */
 
+	/* Our own IP address, as a null-terminated string.
+	 * This is used to generate the mv0 callback address.
+	 */
+	char			cl_ipaddr[48];
+
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
-- 
1.9.3

