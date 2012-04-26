Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25085 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759189Ab2DZU4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:56:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 7/9] NFS: Remove secinfo knowledge out of the generic  client
Date: Thu, 26 Apr 2012 16:56:10 -0400
Message-Id: <1335473772-4401-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
References: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

And also remove the unneeded rpc_op.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |    3 ---
 fs/nfs/namespace.c      |   29 -----------------------------
 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4namespace.c  |   29 +++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |    1 -
 include/linux/nfs_xdr.h |    1 -
 6 files changed, 30 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b777bda..a7e2497 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -280,9 +280,6 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
-#ifdef CONFIG_NFS_V4
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
-#endif
 
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index d51868e..2a9591b 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -119,35 +119,6 @@ Elong:
 }
 
 #ifdef CONFIG_NFS_V4
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
-{
-	struct gss_api_mech *mech;
-	struct xdr_netobj oid;
-	int i;
-	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
-
-	for (i = 0; i < flavors->num_flavors; i++) {
-		struct nfs4_secinfo_flavor *flavor;
-		flavor = &flavors->flavors[i];
-
-		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
-			pseudoflavor = flavor->flavor;
-			break;
-		} else if (flavor->flavor == RPC_AUTH_GSS) {
-			oid.len  = flavor->gss.sec_oid4.len;
-			oid.data = flavor->gss.sec_oid4.data;
-			mech = gss_mech_get_by_OID(&oid);
-			if (!mech)
-				continue;
-			pseudoflavor = gss_svc_to_pseudoflavor(mech, flavor->gss.service);
-			gss_mech_put(mech);
-			break;
-		}
-	}
-
-	return pseudoflavor;
-}
-
 static struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
 					      struct qstr *name,
 					      struct nfs_fh *fh,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8d75021..53a487e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -206,6 +206,7 @@ extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
 /* nfs4namespace.c */
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
 
 /* nfs4proc.c */
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 69ebe03..56427f1 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -108,6 +108,35 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 	return ret;
 }
 
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
+{
+	struct gss_api_mech *mech;
+	struct xdr_netobj oid;
+	int i;
+	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
+
+	for (i = 0; i < flavors->num_flavors; i++) {
+		struct nfs4_secinfo_flavor *flavor;
+		flavor = &flavors->flavors[i];
+
+		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
+			pseudoflavor = flavor->flavor;
+			break;
+		} else if (flavor->flavor == RPC_AUTH_GSS) {
+			oid.len  = flavor->gss.sec_oid4.len;
+			oid.data = flavor->gss.sec_oid4.data;
+			mech = gss_mech_get_by_OID(&oid);
+			if (!mech)
+				continue;
+			pseudoflavor = gss_svc_to_pseudoflavor(mech, flavor->gss.service);
+			gss_mech_put(mech);
+			break;
+		}
+	}
+
+	return pseudoflavor;
+}
+
 static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
 {
 	struct page *page;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 19c0c8d..ecbbf36 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6595,7 +6595,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
 	.init_client	= nfs4_init_client,
-	.secinfo	= nfs4_proc_secinfo,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7ba3551..6cba0a1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1289,7 +1289,6 @@ struct nfs_rpc_ops {
 				struct iattr *iattr);
 	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
-	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 };
 
 /*
-- 
1.7.10

