Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744Ab1CPUyX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 16:54:23 -0400
Message-ID: <4D812377.8030908@netapp.com>
Date: Wed, 16 Mar 2011 16:54:15 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 4/5] NFS: use secinfo when crossing mountpoints
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


A submount may use different security than the parent
mount does.  We should figure out what sec flavor the
submount uses at mount time.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/inode.c                        |    8 ++-
 fs/nfs/internal.h                     |    7 ++
 fs/nfs/namespace.c                    |  102 ++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c                     |   14 +++++
 fs/nfs/nfs4xdr.c                      |   11 ++--
 include/linux/nfs_xdr.h               |    1 +
 net/sunrpc/auth_gss/gss_mech_switch.c |   22 +++++++
 7 files changed, 154 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 01768e5..058d7d6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -254,7 +254,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 	struct inode *inode = ERR_PTR(-ENOENT);
 	unsigned long hash;
 
-	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0)
+	nfs_attr_check_mountpoint(sb, fattr);
+
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0 && (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0)
 		goto out_no_inode;
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
 		goto out_no_inode;
@@ -298,8 +300,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
-			if ((fattr->valid & NFS_ATTR_FATTR_FSID)
-					&& !nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
+			if (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT ||
+					fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
 				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
 					inode->i_op = &nfs_referral_inode_operations;
 				else
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7141095..dc34224 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -39,6 +39,12 @@ static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
 	return 0;
 }
 
+static inline void nfs_attr_check_mountpoint(struct super_block *parent, struct nfs_fattr *fattr)
+{
+	if (!nfs_fsid_equal(&NFS_SB(parent)->fsid, &fattr->fsid))
+		fattr->valid |= NFS_ATTR_FATTR_MOUNTPOINT;
+}
+
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
@@ -214,6 +220,7 @@ extern const u32 nfs41_maxwrite_overhead;
 /* nfs4proc.c */
 #ifdef CONFIG_NFS_V4
 extern struct rpc_procinfo nfs4_procedures[];
+void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);
 #endif
 
 extern int nfs4_init_ds_session(struct nfs_client *clp);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 0bd5c6b..122ad8f 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -15,6 +15,7 @@
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/vfs.h>
+#include <linux/sunrpc/gss_api.h>
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -28,7 +29,8 @@ int nfs_mountpoint_expiry_timeout = 500 * HZ;
 static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
 					const struct dentry *dentry,
 					struct nfs_fh *fh,
-					struct nfs_fattr *fattr);
+					struct nfs_fattr *fattr,
+					rpc_authflavor_t authflavor);
 
 /*
  * nfs_path - reconstruct the path given an arbitrary dentry
@@ -96,6 +98,90 @@ Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
 
+static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors, struct inode *inode)
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
+static rpc_authflavor_t nfs_negotiate_security(const struct dentry *parent, const struct dentry *dentry)
+{
+	int status = 0;
+	struct page *page;
+	struct nfs4_secinfo_flavors *flavors;
+	int (*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
+	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
+
+	secinfo = NFS_PROTO(parent->d_inode)->secinfo;
+	if (secinfo != NULL) {
+		page = alloc_page(GFP_KERNEL);
+		if (!page) {
+			status = -ENOMEM;
+			goto out;
+		}
+		flavors = page_address(page);
+		status = secinfo(parent->d_inode, &dentry->d_name, flavors);
+		flavor = nfs_find_best_sec(flavors, dentry->d_inode);
+		put_page(page);
+	}
+
+	return flavor;
+
+out:
+	status = -ENOMEM;
+	return status;
+}
+
+static rpc_authflavor_t nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
+				     struct dentry *dentry, struct path *path,
+				     struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	rpc_authflavor_t flavor;
+	struct rpc_clnt *clone;
+	struct rpc_auth *auth;
+	int err;
+
+	flavor = nfs_negotiate_security(parent, path->dentry);
+	if (flavor < 0)
+		goto out;
+	clone  = rpc_clone_client(server->client);
+	auth   = rpcauth_create(flavor, clone);
+	if (!auth) {
+		flavor = -EIO;
+		goto out;
+	}
+	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
+						  &path->dentry->d_name,
+						  fh, fattr);
+	if (err < 0)
+		flavor = err;
+out:
+	return flavor;
+}
+
 /*
  * nfs_d_automount - Handle crossing a mountpoint on the server
  * @path - The mountpoint
@@ -116,6 +202,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
 	int err;
+	rpc_authflavor_t flavor = 1;
 
 	dprintk("--> nfs_d_automount()\n");
 
@@ -136,6 +223,13 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
 						  &path->dentry->d_name,
 						  fh, fattr);
+	if (err == -EPERM) {
+		flavor = nfs_lookup_with_sec(server, parent, path->dentry, path, fh, fattr);
+		if (flavor < 0)
+			err = flavor;
+		else
+			err = 0;
+	}
 	dput(parent);
 	if (err != 0) {
 		mnt = ERR_PTR(err);
@@ -145,7 +239,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
 		mnt = nfs_do_refmount(path->mnt, path->dentry);
 	else
-		mnt = nfs_do_submount(path->mnt, path->dentry, fh, fattr);
+		mnt = nfs_do_submount(path->mnt, path->dentry, fh, fattr, flavor);
 	if (IS_ERR(mnt))
 		goto out;
 
@@ -218,13 +312,15 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
 					const struct dentry *dentry,
 					struct nfs_fh *fh,
-					struct nfs_fattr *fattr)
+					struct nfs_fattr *fattr,
+					rpc_authflavor_t authflavor)
 {
 	struct nfs_clone_mount mountdata = {
 		.sb = mnt_parent->mnt_sb,
 		.dentry = dentry,
 		.fh = fh,
 		.fattr = fattr,
+		.authflavor = authflavor,
 	};
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	char *page = (char *) __get_free_page(GFP_USER);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0b8bae1..5634637 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -87,6 +87,8 @@ static int nfs4_map_errors(int err)
 	switch (err) {
 	case -NFS4ERR_RESOURCE:
 		return -EREMOTEIO;
+	case -NFS4ERR_WRONGSEC:
+		return -EPERM;
 	case -NFS4ERR_BADOWNER:
 	case -NFS4ERR_BADNAME:
 		return -EINVAL;
@@ -2383,6 +2385,16 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	return status;
 }
 
+void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
+{
+	memset(fh, 0, sizeof(struct nfs_fh));
+	fattr->fsid.major = 1;
+	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
+		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_FSID | NFS_ATTR_FATTR_MOUNTPOINT;
+	fattr->mode = S_IFDIR | S_IRUGO | S_IXUGO;
+	fattr->nlink = 2;
+}
+
 static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
 			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
@@ -2392,6 +2404,8 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_lookup(clnt, dir, name, fhandle, fattr),
 				&exception);
+		if (err == -EPERM)
+			nfs_fixup_secinfo_attributes(fattr, fhandle);
 	} while (exception.retry);
 	return err;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 98afcf9..21c3004 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -113,7 +113,7 @@ static int nfs4_stat_to_errno(int);
 #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
 #define decode_restorefh_maxsz  (op_decode_hdr_maxsz)
 #define encode_fsinfo_maxsz	(encode_getattr_maxsz)
-#define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 11)
+#define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 15)
 #define encode_renew_maxsz	(op_encode_hdr_maxsz + 3)
 #define decode_renew_maxsz	(op_decode_hdr_maxsz)
 #define encode_setclientid_maxsz \
@@ -2966,6 +2966,7 @@ static int decode_attr_error(struct xdr_stream *xdr, uint32_t *bitmap)
 		if (unlikely(!p))
 			goto out_overflow;
 		bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
+		return -be32_to_cpup(p);
 	}
 	return 0;
 out_overflow:
@@ -3953,6 +3954,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 	fattr->valid |= status;
 
 	status = decode_attr_error(xdr, bitmap);
+	if (status == -NFS4ERR_WRONGSEC) {
+		nfs_fixup_secinfo_attributes(fattr, fh);
+		status = 0;
+	}
 	if (status < 0)
 		goto xdr_error;
 
@@ -6314,10 +6319,6 @@ static struct {
 	{ NFS4ERR_SYMLINK,	-ELOOP		},
 	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
 	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
-	{ NFS4ERR_WRONGSEC,	-EPERM		}, /* FIXME: this needs
-						    * to be handled by a
-						    * middle-layer.
-						    */
 	{ -1,			-EIO		}
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8f3d7b2..02dd83e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -79,6 +79,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_CHANGE		(1U << 17)
 #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
 #define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
+#define NFS_ATTR_FATTR_MOUNTPOINT	(1U << 20)	/* Treat as mountpoint */
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 8b40610..6c844b0 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -160,6 +160,28 @@ gss_mech_get_by_name(const char *name)
 
 EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
 
+struct gss_api_mech *
+gss_mech_get_by_OID(struct xdr_netobj *obj)
+{
+	struct gss_api_mech	*pos, *gm = NULL;
+
+	spin_lock(&registered_mechs_lock);
+	list_for_each_entry(pos, &registered_mechs, gm_list) {
+		if (obj->len == pos->gm_oid.len) {
+			if (0 == memcmp(obj->data, pos->gm_oid.data, obj->len)) {
+				if (try_module_get(pos->gm_owner))
+					gm = pos;
+				break;
+			}
+		}
+	}
+	spin_unlock(&registered_mechs_lock);
+	return gm;
+
+}
+
+EXPORT_SYMBOL_GPL(gss_mech_get_by_OID);
+
 static inline int
 mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
 {
-- 
1.7.4.1

