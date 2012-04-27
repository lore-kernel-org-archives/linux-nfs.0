Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760638Ab2D0R14 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 13:27:56 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v5 3/9] NFS: Do secinfo as part of lookup
Date: Fri, 27 Apr 2012 13:27:40 -0400
Message-Id: <1335547666-28315-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
References: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Whenever lookup sees wrongsec do a secinfo and retry the lookup to find
attributes of the file or directory, such as "is this a referral
mountpoint?".  This also allows me to remove handling -NFS4ERR_WRONSEC
as part of getattr xdr decoding.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h      |    1 -
 fs/nfs/nfs4_fs.h       |    4 +++
 fs/nfs/nfs4namespace.c |   52 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c      |   64 +++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4xdr.c       |    2 --
 5 files changed, 103 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2476dc6..45966d9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -234,7 +234,6 @@ extern const u32 nfs41_maxwrite_overhead;
 /* nfs4proc.c */
 #ifdef CONFIG_NFS_V4
 extern struct rpc_procinfo nfs4_procedures[];
-void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);
 #endif
 
 extern int nfs4_init_ds_session(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b6db9e3..c82c2cd 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -205,6 +205,9 @@ struct nfs4_state_maintenance_ops {
 extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
+/* nfs4namespace.c */
+struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
+
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
@@ -215,6 +218,7 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, boo
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 7483a17..9f8681b 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -132,6 +132,58 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 	return ret;
 }
 
+static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
+{
+	struct page *page;
+	struct nfs4_secinfo_flavors *flavors;
+	rpc_authflavor_t flavor;
+	int err;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+	flavors = page_address(page);
+
+	err = nfs4_proc_secinfo(inode, name, flavors);
+	if (err < 0) {
+		flavor = err;
+		goto out;
+	}
+
+	flavor = nfs_find_best_sec(flavors);
+
+out:
+	put_page(page);
+	return flavor;
+}
+
+/*
+ * Please call rpc_shutdown_client() when you are done with this client.
+ */
+struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *inode,
+					struct qstr *name)
+{
+	struct rpc_clnt *clone;
+	struct rpc_auth *auth;
+	rpc_authflavor_t flavor;
+
+	flavor = nfs4_negotiate_security(inode, name);
+	if (flavor < 0)
+		return ERR_PTR(flavor);
+
+	clone = rpc_clone_client(clnt);
+	if (IS_ERR(clone))
+		return clone;
+
+	auth = rpcauth_create(flavor, clone);
+	if (!auth) {
+		rpc_shutdown_client(clone);
+		clone = ERR_PTR(-EIO);
+	}
+
+	return clone;
+}
+
 static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 				     char *page, char *page2,
 				     const struct nfs4_fs_location *location)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff7571f..3d92fe6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2528,39 +2528,69 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	return status;
 }
 
-void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
+static void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr)
 {
-	memset(fh, 0, sizeof(struct nfs_fh));
-	fattr->fsid.major = 1;
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
-		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_FSID | NFS_ATTR_FATTR_MOUNTPOINT;
+		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_MOUNTPOINT;
 	fattr->mode = S_IFDIR | S_IRUGO | S_IXUGO;
 	fattr->nlink = 2;
 }
 
-static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
-			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
+				   struct qstr *name, struct nfs_fh *fhandle,
+				   struct nfs_fattr *fattr)
 {
 	struct nfs4_exception exception = { };
+	struct rpc_clnt *client = *clnt;
 	int err;
 	do {
-		int status;
-
-		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
-		switch (status) {
+		err = _nfs4_proc_lookup(client, dir, name, fhandle, fattr);
+		switch (err) {
 		case -NFS4ERR_BADNAME:
-			return -ENOENT;
+			err = -ENOENT;
+			goto out;
 		case -NFS4ERR_MOVED:
-			return nfs4_get_referral(dir, name, fattr, fhandle);
+			err = nfs4_get_referral(dir, name, fattr, fhandle);
+			goto out;
 		case -NFS4ERR_WRONGSEC:
-			nfs_fixup_secinfo_attributes(fattr, fhandle);
+			err = -EPERM;
+			if (client != *clnt)
+				goto out;
+
+			client = nfs4_create_sec_client(client, dir, name);
+			if (IS_ERR(client))
+				return PTR_ERR(client);
+
+			exception.retry = 1;
+			break;
+		default:
+			err = nfs4_handle_exception(NFS_SERVER(dir), err, &exception);
 		}
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				status, &exception);
 	} while (exception.retry);
+
+out:
+	if (err == 0)
+		*clnt = client;
+	else if (client != *clnt)
+		rpc_shutdown_client(client);
+
 	return err;
 }
 
+static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+{
+	int status;
+	struct rpc_clnt *client = NFS_CLIENT(dir);
+
+	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr);
+	if (client != NFS_CLIENT(dir)) {
+		rpc_shutdown_client(client);
+		nfs_fixup_secinfo_attributes(fattr);
+	}
+	return status;
+}
+
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -4996,8 +5026,8 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 	return status;
 }
 
-static int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
-		struct nfs4_secinfo_flavors *flavors)
+int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
+		      struct nfs4_secinfo_flavors *flavors)
 {
 	struct nfs4_exception exception = { };
 	int err;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6cebcf3..805a008 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4258,8 +4258,6 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 	status = decode_attr_error(xdr, bitmap, &err);
 	if (status < 0)
 		goto xdr_error;
-	if (err == -NFS4ERR_WRONGSEC)
-		nfs_fixup_secinfo_attributes(fattr, fh);
 
 	status = decode_attr_filehandle(xdr, bitmap, fh);
 	if (status < 0)
-- 
1.7.10

