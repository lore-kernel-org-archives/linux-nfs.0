From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 08/10] NFS: Client implementation of Labeled-NFS
Date: Wed,  7 Jul 2010 10:31:24 -0400
Message-ID: <1278513086-23964-9-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch implements the client transport and handling support for labeled
NFS. The patch adds two functions to encode and decode the security label
recommended attribute which makes use of the LSM hooks added earlier. It also
adds code to grab the label from the file attribute structures and encode the
label to be sent back to the server.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 fs/nfs/client.c           |    2 +-
 fs/nfs/dir.c              |   67 ++++--
 fs/nfs/getroot.c          |   32 +++-
 fs/nfs/inode.c            |   95 ++++++--
 fs/nfs/namespace.c        |    2 +-
 fs/nfs/nfs3acl.c          |    4 +-
 fs/nfs/nfs3proc.c         |   37 ++--
 fs/nfs/nfs4proc.c         |  591 +++++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfs4xdr.c          |  133 ++++++++---
 fs/nfs/proc.c             |   15 +-
 fs/nfs/super.c            |   13 +-
 include/linux/nfs_fs.h    |   10 +-
 include/linux/nfs_fs_sb.h |    6 +
 include/linux/nfs_xdr.h   |    5 +-
 security/selinux/hooks.c  |    4 +
 15 files changed, 841 insertions(+), 175 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index acc9c49..aa27229 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1078,7 +1078,7 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 	}
 
 	if (!(fattr.valid & NFS_ATTR_FATTR)) {
-		error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr);
+		error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr, NULL);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a7bb5c6..d8590d6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -557,6 +557,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	my_entry.fh = &fh;
 	my_entry.fattr = &fattr;
 	nfs_fattr_init(&fattr);
+
 	desc->entry = &my_entry;
 
 	nfs_block_sillyrename(dentry);
@@ -776,9 +777,10 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	struct inode *dir;
 	struct inode *inode;
 	struct dentry *parent;
-	int error;
+	int error = 0;
 	struct nfs_fh fhandle;
 	struct nfs_fattr fattr;
+	struct nfs4_label *label = NULL;
 
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
@@ -811,13 +813,26 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	if (NFS_STALE(inode))
 		goto out_bad;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		label = nfs4_label_alloc(GFP_NOWAIT);
+		if (label == NULL)
+			goto out_bad;
+	}
+#endif
+
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr, label);
 	if (error)
-		goto out_bad;
+		goto out_bad_free;
 	if (nfs_compare_fh(NFS_FH(inode), &fhandle))
-		goto out_bad;
-	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
-		goto out_bad;
+		goto out_bad_free;
+	if ((error = nfs_refresh_inode(inode, &fattr, label)) != 0)
+		goto out_bad_free;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
 
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
@@ -829,7 +844,7 @@ out_set_verifier:
 	return 1;
 out_zap_parent:
 	nfs_zap_caches(dir);
- out_bad:
+out_bad:
 	nfs_mark_for_revalidate(dir);
 	if (inode && S_ISDIR(inode->i_mode)) {
 		/* Purge readdir caches. */
@@ -847,6 +862,13 @@ out_zap_parent:
 			__func__, dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 	return 0;
+
+out_bad_free:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
+	goto out_bad;
 }
 
 /*
@@ -911,9 +933,10 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	struct dentry *res;
 	struct dentry *parent;
 	struct inode *inode = NULL;
-	int error;
+	int error = 0;
 	struct nfs_fh fhandle;
 	struct nfs_fattr fattr;
+	struct nfs4_label *label = NULL;
 
 	dfprintk(VFS, "NFS: lookup(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
@@ -936,17 +959,26 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 		goto out;
 	}
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		label = nfs4_label_alloc(GFP_NOWAIT);
+		if (label == NULL)
+			goto out;
+	}
+	/* XXX: should this move inside of nfs4_lookup() ? */
+#endif
+
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr, label);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
 		res = ERR_PTR(error);
 		goto out_unblock_sillyrename;
 	}
-	inode = nfs_fhget(dentry->d_sb, &fhandle, &fattr);
+	inode = nfs_fhget(dentry->d_sb, &fhandle, &fattr, label);
 	res = (struct dentry *)inode;
 	if (IS_ERR(res))
 		goto out_unblock_sillyrename;
@@ -961,6 +993,10 @@ no_entry:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
 out:
 	return res;
 }
@@ -1149,7 +1185,7 @@ static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc)
 	if (dentry == NULL)
 		return NULL;
 	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
-	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr);
+	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr, NULL);
 	if (IS_ERR(inode)) {
 		dput(dentry);
 		return NULL;
@@ -1172,7 +1208,8 @@ out_renew:
  * Code common to create, mkdir, and mknod.
  */
 int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
-				struct nfs_fattr *fattr)
+				struct nfs_fattr *fattr,
+				struct nfs4_label *label)
 {
 	struct dentry *parent = dget_parent(dentry);
 	struct inode *dir = parent->d_inode;
@@ -1185,18 +1222,18 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
 	if (dentry->d_inode)
 		goto out;
 	if (fhandle->size == 0) {
-		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, NULL);
 		if (error)
 			goto out_error;
 	}
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
 		struct nfs_server *server = NFS_SB(dentry->d_sb);
-		error = server->nfs_client->rpc_ops->getattr(server, fhandle, fattr);
+		error = server->nfs_client->rpc_ops->getattr(server, fhandle, fattr, NULL);
 		if (error < 0)
 			goto out_error;
 	}
-	inode = nfs_fhget(dentry->d_sb, fhandle, fattr);
+	inode = nfs_fhget(dentry->d_sb, fhandle, fattr, label);
 	error = PTR_ERR(inode);
 	if (IS_ERR(inode))
 		goto out_error;
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b35d2a6..7604f71 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -30,7 +30,6 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/namei.h>
-#include <linux/security.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -92,7 +91,7 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 		return ERR_PTR(error);
 	}
 
-	inode = nfs_fhget(sb, mntfh, fsinfo.fattr);
+	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, NULL);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
 		return ERR_CAST(inode);
@@ -242,6 +241,7 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 	struct nfs_fattr fattr;
 	struct dentry *mntroot;
 	struct inode *inode;
+	struct nfs4_label *label = NULL;
 	int error;
 
 	dprintk("--> nfs4_get_root()\n");
@@ -254,19 +254,43 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 		return ERR_PTR(error);
 	}
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		label = nfs4_label_alloc(GFP_KERNEL);
+		if (label == NULL) {
+			dprintk("nfs_get_root: nfs4_label_alloc error = %d\n",
+					error);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
+#endif
+
 	/* get the actual root for this mount */
-	error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr);
+	error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr, label);
 	if (error < 0) {
 		dprintk("nfs_get_root: getattr error = %d\n", -error);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (server->caps & NFS_CAP_SECURITY_LABEL)
+			nfs4_label_free(label);
+#endif
 		return ERR_PTR(error);
 	}
 
-	inode = nfs_fhget(sb, mntfh, &fattr);
+	inode = nfs_fhget(sb, mntfh, &fattr, label);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (server->caps & NFS_CAP_SECURITY_LABEL)
+			nfs4_label_free(label);
+#endif
 		return ERR_CAST(inode);
 	}
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(label);
+#endif
+
 	error = nfs_superblock_set_dummy_root(sb, inode);
 	if (error != 0)
 		return ERR_PTR(error);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 50a56ed..88971d9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -57,7 +57,7 @@
 static int enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
 
 static void nfs_invalidate_inode(struct inode *);
-static int nfs_update_inode(struct inode *, struct nfs_fattr *);
+static int nfs_update_inode(struct inode *, struct nfs_fattr *, struct nfs4_label *);
 
 static struct kmem_cache * nfs_inode_cachep;
 
@@ -138,10 +138,13 @@ static void nfs_zap_caches_locked(struct inode *inode)
 	nfsi->attrtimeo_timestamp = jiffies;
 
 	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
+	nfsi->cache_validity |= NFS_INO_INVALID_ATTR| \
+				NFS_INO_INVALID_LABEL| \
+				NFS_INO_INVALID_ACCESS| \
+				NFS_INO_INVALID_ACL| \
+				NFS_INO_REVAL_PAGECACHE;
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
-	else
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
+		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 }
 
 void nfs_zap_caches(struct inode *inode)
@@ -230,12 +233,36 @@ nfs_init_locked(struct inode *inode, void *opaque)
 /* Don't use READDIRPLUS on directories that we believe are too large */
 #define NFS_LIMIT_READDIRPLUS (8*PAGE_SIZE)
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
+{
+	int error;
+
+/*	BUG_ON(!mutex_is_locked(&inode->i_mutex)); */
+
+	if ((fattr->valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL) &&
+		label && inode->i_security) {
+		error = security_inode_notifysecctx(inode, label->label,
+						   label->len);
+		if (error)
+			printk(KERN_ERR "%s() %s %d "
+				"security_inode_notifysecctx() %d\n",
+				__func__,
+				(char *)label->label, label->len, error);
+	}
+}
+#else
+void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
+{
+}
+#endif
+
 /*
  * This is our front-end to iget that looks up inodes by file handle
  * instead of inode number.
  */
 struct inode *
-nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
+nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_find_desc desc = {
 		.fh	= fh,
@@ -365,6 +392,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 			 */
 			inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
 		}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		nfs_setsecurity(inode, fattr, label);
+#endif
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
 		nfsi->access_cache = RB_ROOT;
@@ -373,7 +403,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 
 		unlock_new_inode(inode);
 	} else
-		nfs_refresh_inode(inode, fattr);
+		nfs_refresh_inode(inode, fattr, label);
 	dprintk("NFS: nfs_fhget(%s/%Ld ct=%d)\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
@@ -394,7 +424,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct nfs_fattr fattr;
-	int error;
+	int error = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
 
@@ -424,7 +454,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		nfs_inode_return_delegation(inode);
 	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
 	if (error == 0)
-		nfs_refresh_inode(inode, &fattr);
+		nfs_refresh_inode(inode, &fattr, NULL);
 	return error;
 }
 
@@ -682,6 +712,7 @@ int
 __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
 	int		 status = -ESTALE;
+	struct nfs4_label *label = NULL;
 	struct nfs_fattr fattr;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -694,7 +725,17 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
-	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), &fattr);
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
+		label = nfs4_label_alloc(GFP_KERNEL);
+		if (label == NULL) {
+			status = -ENOMEM;
+			goto out;
+		}
+	}
+#endif
+	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), &fattr, label);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
 			 inode->i_sb->s_id,
@@ -707,7 +748,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 	}
 
-	status = nfs_refresh_inode(inode, &fattr);
+	status = nfs_refresh_inode(inode, &fattr, label);
 	if (status) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
@@ -723,6 +764,10 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		(long long)NFS_FILEID(inode));
 
  out:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
 	return status;
 }
 
@@ -744,7 +789,7 @@ int nfs_attribute_timeout(struct inode *inode)
  */
 int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
-	if (!(NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATTR)
+	if (!(NFS_I(inode)->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
 			&& !nfs_attribute_timeout(inode))
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
@@ -945,10 +990,10 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 		((long)nfsi->attr_gencount - (long)nfs_read_attr_generation_counter() > 0);
 }
 
-static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	if (nfs_inode_attrs_need_update(inode, fattr))
-		return nfs_update_inode(inode, fattr);
+		return nfs_update_inode(inode, fattr, label);
 	return nfs_check_inode_attributes(inode, fattr);
 }
 
@@ -962,20 +1007,20 @@ static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr
  * safe to do a full update of the inode attributes, or whether just to
  * call nfs_check_inode_attributes.
  */
-int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
+int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	int status;
 
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
 	spin_lock(&inode->i_lock);
-	status = nfs_refresh_inode_locked(inode, fattr);
+	status = nfs_refresh_inode_locked(inode, fattr, label);
 	spin_unlock(&inode->i_lock);
 
 	return status;
 }
 
-static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -984,7 +1029,7 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
 		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
-	return nfs_refresh_inode_locked(inode, fattr);
+	return nfs_refresh_inode_locked(inode, fattr, label);
 }
 
 /**
@@ -1001,12 +1046,12 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
  * are expected to change one or more attributes, to avoid
  * unnecessary NFS requests and trips through nfs_update_inode().
  */
-int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
+int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	int status;
 
 	spin_lock(&inode->i_lock);
-	status = nfs_post_op_update_inode_locked(inode, fattr);
+	status = nfs_post_op_update_inode_locked(inode, fattr, label);
 	spin_unlock(&inode->i_lock);
 	return status;
 }
@@ -1057,7 +1102,7 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 		fattr->valid |= NFS_ATTR_FATTR_PRESIZE;
 	}
 out_noforce:
-	status = nfs_post_op_update_inode_locked(inode, fattr);
+	status = nfs_post_op_update_inode_locked(inode, fattr, NULL);
 	spin_unlock(&inode->i_lock);
 	return status;
 }
@@ -1074,7 +1119,7 @@ out_noforce:
  *
  * A very similar scenario holds for the dir cache.
  */
-static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_server *server;
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1226,6 +1271,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label)
+		nfs_setsecurity(inode, fattr, label);
+#endif
+
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
 			invalid |= NFS_INO_INVALID_ATTR;
@@ -1247,7 +1297,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		inode->i_blocks = fattr->du.nfs2.blocks;
 
 	/* Update attrtimeo value if we're out of the unstable period */
-	if (invalid & NFS_INO_INVALID_ATTR) {
+	if (invalid & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL)) {
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
@@ -1260,6 +1310,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		}
 	}
 	invalid &= ~NFS_INO_INVALID_ATTR;
+	invalid &= ~NFS_INO_INVALID_LABEL;
 	/* Don't invalidate the data if we were to blame */
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 7888cf3..252a764 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -123,7 +123,7 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	parent = dget_parent(nd->path.dentry);
 	err = server->nfs_client->rpc_ops->lookup(parent->d_inode,
 						  &nd->path.dentry->d_name,
-						  &fh, &fattr);
+						  &fh, &fattr, NULL);
 	dput(parent);
 	if (err != 0)
 		goto out_err;
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index d150ae0..20b44bf 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -238,7 +238,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 
 	switch (status) {
 		case 0:
-			status = nfs_refresh_inode(inode, &fattr);
+			status = nfs_refresh_inode(inode, &fattr, NULL);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
@@ -344,7 +344,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 
 	switch (status) {
 		case 0:
-			status = nfs_refresh_inode(inode, &fattr);
+			status = nfs_refresh_inode(inode, &fattr, NULL);
 			nfs3_cache_acls(inode, acl, dfacl);
 			break;
 		case -EPFNOSUPPORT:
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index e701002..f58ce23 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -97,7 +97,7 @@ nfs3_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs3_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_GETATTR],
@@ -142,7 +142,8 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int
 nfs3_proc_lookup(struct inode *dir, struct qstr *name,
-		 struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+		 struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		 struct nfs4_label *label)
 {
 	struct nfs_fattr	dir_attr;
 	struct nfs3_diropargs	arg = {
@@ -166,7 +167,7 @@ nfs3_proc_lookup(struct inode *dir, struct qstr *name,
 	nfs_fattr_init(&dir_attr);
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_refresh_inode(dir, &dir_attr);
+	nfs_refresh_inode(dir, &dir_attr, NULL);
 	if (status >= 0 && !(fattr->valid & NFS_ATTR_FATTR)) {
 		msg.rpc_proc = &nfs3_procedures[NFS3PROC_GETATTR];
 		msg.rpc_argp = fhandle;
@@ -212,7 +213,7 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 	}
 	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_refresh_inode(inode, &fattr);
+	nfs_refresh_inode(inode, &fattr, NULL);
 	if (status == 0) {
 		entry->mask = 0;
 		if (res.access & NFS3_ACCESS_READ)
@@ -246,7 +247,7 @@ static int nfs3_proc_readlink(struct inode *inode, struct page *page,
 	dprintk("NFS call  readlink\n");
 	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_refresh_inode(inode, &fattr);
+	nfs_refresh_inode(inode, &fattr, NULL);
 	dprintk("NFS reply readlink: %d\n", status);
 	return status;
 }
@@ -287,9 +288,9 @@ static int nfs3_do_create(struct inode *dir, struct dentry *dentry, struct nfs3_
 	int status;
 
 	status = rpc_call_sync(NFS_CLIENT(dir), &data->msg, 0);
-	nfs_post_op_update_inode(dir, data->res.dir_attr);
+	nfs_post_op_update_inode(dir, data->res.dir_attr, NULL);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	return status;
 }
 
@@ -370,7 +371,7 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		 * not sure this buys us anything (and I'd have
 		 * to revamp the NFSv3 XDR code) */
 		status = nfs3_proc_setattr(dentry, data->res.fattr, sattr);
-		nfs_post_op_update_inode(dentry->d_inode, data->res.fattr);
+		nfs_post_op_update_inode(dentry->d_inode, data->res.fattr, NULL);
 		dprintk("NFS reply setattr (post-create): %d\n", status);
 		if (status != 0)
 			goto out;
@@ -401,7 +402,7 @@ nfs3_proc_remove(struct inode *dir, struct qstr *name)
 	dprintk("NFS call  remove %s\n", name->name);
 	nfs_fattr_init(&res.dir_attr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, &res.dir_attr);
+	nfs_post_op_update_inode(dir, &res.dir_attr, NULL);
 	dprintk("NFS reply remove: %d\n", status);
 	return status;
 }
@@ -419,7 +420,7 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs3_async_handle_jukebox(task, dir))
 		return 0;
 	res = task->tk_msg.rpc_resp;
-	nfs_post_op_update_inode(dir, &res->dir_attr);
+	nfs_post_op_update_inode(dir, &res->dir_attr, NULL);
 	return 1;
 }
 
@@ -451,8 +452,8 @@ nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	nfs_fattr_init(&old_dir_attr);
 	nfs_fattr_init(&new_dir_attr);
 	status = rpc_call_sync(NFS_CLIENT(old_dir), &msg, 0);
-	nfs_post_op_update_inode(old_dir, &old_dir_attr);
-	nfs_post_op_update_inode(new_dir, &new_dir_attr);
+	nfs_post_op_update_inode(old_dir, &old_dir_attr, NULL);
+	nfs_post_op_update_inode(new_dir, &new_dir_attr, NULL);
 	dprintk("NFS reply rename: %d\n", status);
 	return status;
 }
@@ -482,8 +483,8 @@ nfs3_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 	nfs_fattr_init(&dir_attr);
 	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_post_op_update_inode(dir, &dir_attr);
-	nfs_post_op_update_inode(inode, &fattr);
+	nfs_post_op_update_inode(dir, &dir_attr, NULL);
+	nfs_post_op_update_inode(inode, &fattr, NULL);
 	dprintk("NFS reply link: %d\n", status);
 	return status;
 }
@@ -570,7 +571,7 @@ nfs3_proc_rmdir(struct inode *dir, struct qstr *name)
 	dprintk("NFS call  rmdir %s\n", name->name);
 	nfs_fattr_init(&dir_attr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, &dir_attr);
+	nfs_post_op_update_inode(dir, &dir_attr, NULL);
 	dprintk("NFS reply rmdir: %d\n", status);
 	return status;
 }
@@ -623,7 +624,7 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 
 	nfs_invalidate_atime(dir);
 
-	nfs_refresh_inode(dir, &dir_attr);
+	nfs_refresh_inode(dir, &dir_attr, NULL);
 	dprintk("NFS reply readdir: %d\n", status);
 	return status;
 }
@@ -756,7 +757,7 @@ static int nfs3_read_done(struct rpc_task *task, struct nfs_read_data *data)
 		return -EAGAIN;
 
 	nfs_invalidate_atime(data->inode);
-	nfs_refresh_inode(data->inode, &data->fattr);
+	nfs_refresh_inode(data->inode, &data->fattr, NULL);
 	return 0;
 }
 
@@ -783,7 +784,7 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
 		return -EAGAIN;
-	nfs_refresh_inode(data->inode, data->res.fattr);
+	nfs_refresh_inode(data->inode, data->res.fattr, NULL);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 71bb8da..e2b9010 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -68,8 +68,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
-static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
-static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -105,6 +105,9 @@ const u32 nfs4_fattr_bitmap[2] = {
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	| FATTR4_WORD1_SECURITY_LABEL
+#endif
 };
 
 const u32 nfs4_statfs_bitmap[2] = {
@@ -713,7 +716,9 @@ struct nfs4_opendata {
 	struct nfs_open_confirmargs c_arg;
 	struct nfs_open_confirmres c_res;
 	struct nfs_fattr f_attr;
+	struct nfs4_label *f_label;
 	struct nfs_fattr dir_attr;
+	struct nfs4_label *dir_label;
 	struct path path;
 	struct dentry *dir;
 	struct nfs4_state_owner *owner;
@@ -730,6 +735,8 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 {
 	p->o_res.f_attr = &p->f_attr;
 	p->o_res.dir_attr = &p->dir_attr;
+	p->o_res.f_label = p->f_label;
+	p->o_res.dir_label = p->dir_label;
 	p->o_res.seqid = p->o_arg.seqid;
 	p->c_res.seqid = p->c_arg.seqid;
 	p->o_res.server = p->o_arg.server;
@@ -740,7 +747,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 
 static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 		struct nfs4_state_owner *sp, fmode_t fmode, int flags,
-		const struct iattr *attrs)
+		const struct iattr *attrs, struct nfs4_label *label)
 {
 	struct dentry *parent = dget_parent(path->dentry);
 	struct inode *dir = parent->d_inode;
@@ -750,9 +757,21 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		goto err;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		p->f_label = nfs4_label_alloc(GFP_KERNEL);
+		if (p->f_label == NULL)
+			goto err_free_p;
+		p->dir_label = nfs4_label_alloc(GFP_KERNEL);
+		if (p->dir_label == NULL) {
+			nfs4_label_free(p->f_label);
+			goto err_free_p;
+		}
+	}
+#endif
 	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid);
 	if (p->o_arg.seqid == NULL)
-		goto err_free;
+		goto err_free_label;
 	path_get(path);
 	p->path = *path;
 	p->dir = parent;
@@ -767,6 +786,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
+	p->o_arg.label = label;
 	if (flags & O_EXCL) {
 		if (nfs4_has_persistent_session(server->nfs_client)) {
 			/* GUARDED */
@@ -787,7 +807,15 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	nfs4_init_opendata_res(p);
 	kref_init(&p->kref);
 	return p;
-err_free:
+
+err_free_label:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		nfs4_label_free(p->f_label);
+		nfs4_label_free(p->dir_label);
+	}
+#endif
+err_free_p:
 	kfree(p);
 err:
 	dput(parent);
@@ -803,6 +831,12 @@ static void nfs4_opendata_free(struct kref *kref)
 	if (p->state != NULL)
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (p->o_arg.server->caps & NFS_CAP_SECURITY_LABEL) {
+		nfs4_label_free(p->f_label);
+		nfs4_label_free(p->dir_label);
+	}
+#endif
 	dput(p->dir);
 	path_put(&p->path);
 	kfree(p);
@@ -1028,7 +1062,7 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 	ret = -EAGAIN;
 	if (!(data->f_attr.valid & NFS_ATTR_FATTR))
 		goto err;
-	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr);
+	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr, data->f_label);
 	ret = PTR_ERR(inode);
 	if (IS_ERR(inode))
 		goto err;
@@ -1086,7 +1120,7 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 {
 	struct nfs4_opendata *opendata;
 
-	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, 0, NULL);
+	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, 0, NULL, NULL);
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
@@ -1518,7 +1552,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 	if (status != 0 || !data->rpc_done)
 		return status;
 
-	nfs_refresh_inode(dir, o_res->dir_attr);
+	nfs_refresh_inode(dir, o_res->dir_attr, o_res->dir_label);
 
 	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
 		status = _nfs4_proc_open_confirm(data);
@@ -1546,9 +1580,9 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 
 	if (o_arg->open_flags & O_CREAT) {
 		update_changeattr(dir, &o_res->cinfo);
-		nfs_post_op_update_inode(dir, o_res->dir_attr);
+		nfs_post_op_update_inode(dir, o_res->dir_attr, o_res->dir_label);
 	} else
-		nfs_refresh_inode(dir, o_res->dir_attr);
+		nfs_refresh_inode(dir, o_res->dir_attr, o_res->dir_label);
 	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
 		server->caps &= ~NFS_CAP_POSIX_LOCK;
 	if(o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
@@ -1557,7 +1591,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 			return status;
 	}
 	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
-		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr);
+		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
 	return 0;
 }
 
@@ -1654,7 +1688,7 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct
 /*
  * Returns a referenced nfs4_state
  */
-static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred, struct nfs4_state **res)
+static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct nfs4_label *label, struct rpc_cred *cred, struct nfs4_state **res)
 {
 	struct nfs4_state_owner  *sp;
 	struct nfs4_state     *state = NULL;
@@ -1674,7 +1708,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 	if (path->dentry->d_inode != NULL)
 		nfs4_return_incompatible_delegation(path->dentry->d_inode, fmode);
 	status = -ENOMEM;
-	opendata = nfs4_opendata_alloc(path, sp, fmode, flags, sattr);
+	opendata = nfs4_opendata_alloc(path, sp, fmode, flags, sattr, label);
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
@@ -1708,14 +1742,14 @@ out_err:
 }
 
 
-static struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct rpc_cred *cred)
+static struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, int flags, struct iattr *sattr, struct nfs4_label *label, struct rpc_cred *cred)
 {
 	struct nfs4_exception exception = { };
 	struct nfs4_state *res;
 	int status;
 
 	do {
-		status = _nfs4_do_open(dir, path, fmode, flags, sattr, cred, &res);
+		status = _nfs4_do_open(dir, path, fmode, flags, sattr, label, cred, &res);
 		if (status == 0)
 			break;
 		/* NOTE: BAD_SEQID means the server and client disagree about the
@@ -1759,17 +1793,20 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, fmo
 
 static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
-			    struct nfs4_state *state)
+			    struct nfs4_state *state, struct nfs4_label *ilabel,
+			    struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
         struct nfs_setattrargs  arg = {
                 .fh             = NFS_FH(inode),
                 .iap            = sattr,
 		.server		= server,
-		.bitmask = server->attr_bitmask,
+		.bitmask 	= server->attr_bitmask,
+		.label		= ilabel,
         };
         struct nfs_setattrres  res = {
 		.fattr		= fattr,
+		.label		= olabel,
 		.server		= server,
         };
         struct rpc_message msg = {
@@ -1781,6 +1818,11 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	unsigned long timestamp = jiffies;
 	int status;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (ilabel == NULL || olabel == NULL)
+		arg.bitmask = server->attr_bitmask_nl;
+#endif
+
 	nfs_fattr_init(fattr);
 
 	if (nfs4_copy_delegation_stateid(&arg.stateid, inode)) {
@@ -1797,15 +1839,16 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 }
 
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
-			   struct nfs_fattr *fattr, struct iattr *sattr,
-			   struct nfs4_state *state)
+			    struct nfs_fattr *fattr, struct iattr *sattr,
+			    struct nfs4_state *state, struct nfs4_label *ilabel,
+			    struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_do_setattr(inode, cred, fattr, sattr, state),
+				_nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -1875,7 +1918,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				rpc_restart_call_prepare(task);
 	}
 	nfs_release_seqid(calldata->arg.seqid);
-	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
+	nfs_refresh_inode(calldata->inode, calldata->res.fattr, NULL);
 }
 
 static void nfs4_close_prepare(struct rpc_task *task, void *data)
@@ -1969,9 +2012,9 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	/* Serialization for the sequence id */
 	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid);
 	if (calldata->arg.seqid == NULL)
-		goto out_free_calldata;
+		goto out_free;
 	calldata->arg.fmode = 0;
-	calldata->arg.bitmask = server->cache_consistency_bitmask;
+	calldata->arg.bitmask = server->cache_consistency_bitmask_nl;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
@@ -1990,7 +2033,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 		status = rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 	return status;
-out_free_calldata:
+out_free:
 	kfree(calldata);
 out:
 	nfs4_put_open_state(state);
@@ -2027,6 +2070,7 @@ out_close:
 struct dentry *
 nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 {
+	struct nfs4_label l, *label = NULL;
 	struct path path = {
 		.mnt = nd->path.mnt,
 		.dentry = dentry,
@@ -2043,6 +2087,15 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 		attr.ia_valid = ATTR_MODE;
 		if (!IS_POSIXACL(dir))
 			attr.ia_mode &= ~current_umask();
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+			int error;
+			error = security_dentry_init_security(dentry,
+					attr.ia_mode, &l.label, &l.len);
+			if (error == 0)
+				label = &l;
+		}
+#endif
 	} else {
 		attr.ia_valid = 0;
 		BUG_ON(nd->intent.open.flags & O_CREAT);
@@ -2054,8 +2107,12 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	state = nfs4_do_open(dir, &path, fmode, nd->intent.open.flags, &attr, cred);
+	state = nfs4_do_open(dir, &path, fmode, nd->intent.open.flags, &attr, label, cred);
 	put_rpccred(cred);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label)
+		security_release_secctx(l.label, l.len);
+#endif
 	if (IS_ERR(state)) {
 		if (PTR_ERR(state) == -ENOENT) {
 			d_add(dentry, NULL);
@@ -2087,7 +2144,7 @@ nfs4_open_revalidate(struct inode *dir, struct dentry *dentry, int openflags, st
 	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
-	state = nfs4_do_open(dir, &path, fmode, openflags, NULL, cred);
+	state = nfs4_do_open(dir, &path, fmode, openflags, NULL, NULL, cred);
 	put_rpccred(cred);
 	if (IS_ERR(state)) {
 		switch (PTR_ERR(state)) {
@@ -2145,6 +2202,17 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 				NFS_CAP_CTIME|NFS_CAP_MTIME);
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
 			server->caps |= NFS_CAP_ACLS;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (res.attr_bitmask[1] & FATTR4_WORD1_SECURITY_LABEL) {
+			server->caps |= NFS_CAP_SECURITY_LABEL;
+		} else
+#endif
+			server->attr_bitmask[1] &= ~FATTR4_WORD1_SECURITY_LABEL;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		memcpy(server->attr_bitmask_nl, res.attr_bitmask, sizeof(server->attr_bitmask));
+		server->attr_bitmask_nl[1] &= ~FATTR4_WORD1_SECURITY_LABEL;
+#endif
 		if (res.has_links != 0)
 			server->caps |= NFS_CAP_HARDLINKS;
 		if (res.has_symlinks != 0)
@@ -2168,7 +2236,12 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 
 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
-		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
+		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA |
+							FATTR4_WORD1_TIME_MODIFY |
+							FATTR4_WORD1_SECURITY_LABEL;
+		memcpy(server->cache_consistency_bitmask_nl, server->cache_consistency_bitmask,
+						sizeof(server->cache_consistency_bitmask_nl));
+		server->cache_consistency_bitmask_nl[1] &= ~FATTR4_WORD1_SECURITY_LABEL;
 		server->acl_bitmask = res.acl_bitmask;
 	}
 
@@ -2190,8 +2263,9 @@ int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		struct nfs_fsinfo *info)
 {
+	u32 bitmask[2];
 	struct nfs4_lookup_root_arg args = {
-		.bitmask = nfs4_fattr_bitmap,
+		.bitmask = bitmask,
 	};
 	struct nfs4_lookup_res res = {
 		.server = server,
@@ -2203,6 +2277,8 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	bitmask[0] = nfs4_fattr_bitmap[0];
+	bitmask[1] = nfs4_fattr_bitmap[1] & ~FATTR4_WORD1_SECURITY_LABEL;
 
 	nfs_fattr_init(info->fattr);
 	return nfs4_call_sync(server, &msg, &args, &res, 0);
@@ -2278,7 +2354,8 @@ out:
 	return status;
 }
 
-static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_getattr_arg args = {
 		.fh = fhandle,
@@ -2286,6 +2363,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	struct nfs4_getattr_res res = {
 		.fattr = fattr,
+		.label = label,
 		.server = server,
 	};
 	struct rpc_message msg = {
@@ -2293,18 +2371,23 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (!label)
+		args.bitmask = server->attr_bitmask_nl;
+#endif
 	nfs_fattr_init(fattr);
 	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
-static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_proc_getattr(server, fhandle, fattr),
+				_nfs4_proc_getattr(server, fhandle, fattr, label),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -2334,8 +2417,13 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct inode *inode = dentry->d_inode;
 	struct rpc_cred *cred = NULL;
 	struct nfs4_state *state = NULL;
+	struct nfs4_label *olabel;
 	int status;
 
+	olabel = nfs4_label_alloc(GFP_KERNEL);
+	if (olabel == NULL)
+		return -ENOMEM;
+
 	nfs_fattr_init(fattr);
 	
 	/* Search for an existing open(O_WRITE) file */
@@ -2349,15 +2437,16 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		}
 	}
 
-	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
-	if (status == 0)
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, NULL);
+	if (status == 0) {
 		nfs_setattr_update_inode(inode, sattr);
+	}
 	return status;
 }
 
 static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *dirfh,
 		const struct qstr *name, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	int		       status;
 	struct nfs4_lookup_arg args = {
@@ -2368,6 +2457,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	struct nfs4_lookup_res res = {
 		.server = server,
 		.fattr = fattr,
+		.label = label,
 		.fh = fhandle,
 	};
 	struct rpc_message msg = {
@@ -2376,6 +2466,11 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 		.rpc_resp = &res,
 	};
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label == NULL)
+		args.bitmask = server->attr_bitmask_nl;
+#endif
+
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookupfh %s\n", name->name);
@@ -2391,7 +2486,7 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs4_proc_lookupfh(server, dirfh, name, fhandle, fattr);
+		err = _nfs4_proc_lookupfh(server, dirfh, name, fhandle, fattr, NULL);
 		/* FIXME: !!!! */
 		if (err == -NFS4ERR_MOVED) {
 			err = -EREMOTE;
@@ -2403,25 +2498,27 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 }
 
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name,
-		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+		struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		struct nfs4_label *label)
 {
 	int status;
 	
 	dprintk("NFS call  lookup %s\n", name->name);
-	status = _nfs4_proc_lookupfh(NFS_SERVER(dir), NFS_FH(dir), name, fhandle, fattr);
+	status = _nfs4_proc_lookupfh(NFS_SERVER(dir), NFS_FH(dir), name, fhandle, fattr, label);
 	if (status == -NFS4ERR_MOVED)
 		status = nfs4_get_referral(dir, name, fattr, fhandle);
 	dprintk("NFS reply lookup: %d\n", status);
 	return status;
 }
 
-static int nfs4_proc_lookup(struct inode *dir, struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int nfs4_proc_lookup(struct inode *dir, struct qstr *name, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_lookup(dir, name, fhandle, fattr),
+				_nfs4_proc_lookup(dir, name, fhandle, fattr, label),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -2438,6 +2535,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	struct nfs4_accessres res = {
 		.server = server,
 		.fattr = &fattr,
+		.label = NULL,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
@@ -2446,7 +2544,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		.rpc_cred = entry->cred,
 	};
 	int mode = entry->mask;
-	int status;
+	int status = 0;
 
 	/*
 	 * Determine which access bits we want to ask for...
@@ -2464,6 +2562,13 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		if (mode & MAY_EXEC)
 			args.access |= NFS4_ACCESS_EXECUTE;
 	}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.label = nfs4_label_alloc(GFP_KERNEL);
+		if (res.label == NULL)
+			return -ENOMEM;
+	}
+#endif
 	nfs_fattr_init(&fattr);
 	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (!status) {
@@ -2474,8 +2579,12 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 			entry->mask |= MAY_WRITE;
 		if (res.access & (NFS4_ACCESS_LOOKUP|NFS4_ACCESS_EXECUTE))
 			entry->mask |= MAY_EXEC;
-		nfs_refresh_inode(inode, &fattr);
+		nfs_refresh_inode(inode, &fattr, res.label);
 	}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(res.label);
+#endif
 	return status;
 }
 
@@ -2566,6 +2675,7 @@ static int
 nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
                  int flags, struct nameidata *nd)
 {
+	struct nfs4_label l, *ilabel = NULL, *olabel = NULL;
 	struct path path = {
 		.mnt = nd->path.mnt,
 		.dentry = dentry,
@@ -2580,7 +2690,27 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = PTR_ERR(cred);
 		goto out;
 	}
-	state = nfs4_do_open(dir, &path, fmode, flags, sattr, cred);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (((nd->flags & LOOKUP_CREATE) != 0) &&
+			nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		status = security_dentry_init_security(dentry,
+				sattr->ia_mode, &l.label, &l.len);
+		/* XXX: should this be more fatal? */
+		if (status == 0)
+			ilabel = &l;
+	}
+
+	/* XXX: this conditional for the above too? */
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		olabel = nfs4_label_alloc(GFP_KERNEL);
+		if (olabel == NULL) {
+			status = -ENOMEM;
+			goto out;
+		}
+	}
+#endif
+
+	state = nfs4_do_open(dir, &path, fmode, flags, sattr, ilabel, cred);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
@@ -2590,10 +2720,12 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	if (flags & O_EXCL) {
 		struct nfs_fattr fattr;
-		status = nfs4_do_setattr(state->inode, cred, &fattr, sattr, state);
-		if (status == 0)
+		status = nfs4_do_setattr(state->inode, cred, &fattr, sattr, state, ilabel, olabel);
+		if (status == 0) {
 			nfs_setattr_update_inode(state->inode, sattr);
-		nfs_post_op_update_inode(state->inode, &fattr);
+			nfs_post_op_update_inode(state->inode, &fattr, olabel);
+			nfs_setsecurity(state->inode, &fattr, olabel);
+		}
 	}
 	if (status == 0 && (nd->flags & LOOKUP_OPEN) != 0)
 		status = nfs4_intent_set_file(nd, &path, state, fmode);
@@ -2602,6 +2734,12 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 out_putcred:
 	put_rpccred(cred);
 out:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (ilabel)
+		security_release_secctx(ilabel->label, ilabel->len);
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(olabel);
+#endif
 	return status;
 }
 
@@ -2622,14 +2760,26 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int	status = 0;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.dir_label = nfs4_label_alloc(GFP_NOWAIT);
+		if (res.dir_label == NULL)
+			return -ENOMEM;
+	}
+#endif
 
 	nfs_fattr_init(&res.dir_attr);
 	status = nfs4_call_sync(server, &msg, &args, &res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, &res.dir_attr);
+		nfs_post_op_update_inode(dir, &res.dir_attr, res.dir_label);
 	}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(res.dir_label);
+#endif
 	return status;
 }
 
@@ -2651,9 +2801,22 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	struct nfs_removeargs *args = msg->rpc_argp;
 	struct nfs_removeres *res = msg->rpc_resp;
 
-	args->bitmask = server->cache_consistency_bitmask;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		res->dir_label = nfs4_label_alloc(GFP_NOWAIT);
+	else
+		res->dir_label = NULL;
+#endif
+
+	if (res->dir_label != NULL)
+		args->bitmask = server->cache_consistency_bitmask;
+	else
+		args->bitmask = server->cache_consistency_bitmask_nl;
+
 	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
+
+	nfs_fattr_init(&res->dir_attr);
 }
 
 static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
@@ -2664,7 +2827,11 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
-	nfs_post_op_update_inode(dir, &res->dir_attr);
+	nfs_post_op_update_inode(dir, &res->dir_attr, res->dir_label);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (res->server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(res->dir_label);
+#endif
 	return 1;
 }
 
@@ -2677,6 +2844,8 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_dir = NFS_FH(new_dir),
 		.old_name = old_name,
 		.new_name = new_name,
+		.old_label = NULL,
+		.new_label = NULL,
 		.bitmask = server->attr_bitmask,
 	};
 	struct nfs_fattr old_fattr, new_fattr;
@@ -2690,7 +2859,20 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int	status = 0;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.old_label = nfs4_label_alloc(GFP_NOWAIT);
+		if (res.old_label == NULL)
+			return -ENOMEM;
+		res.new_label = nfs4_label_alloc(GFP_NOWAIT);
+		if (res.new_label == NULL) {
+			nfs4_label_free(res.old_label);
+			return -ENOMEM;
+		}
+	}
+#endif
 	
 	nfs_fattr_init(res.old_fattr);
 	nfs_fattr_init(res.new_fattr);
@@ -2698,10 +2880,17 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
-		nfs_post_op_update_inode(old_dir, res.old_fattr);
+		nfs_post_op_update_inode(old_dir, res.old_fattr, res.old_label);
 		update_changeattr(new_dir, &res.new_cinfo);
-		nfs_post_op_update_inode(new_dir, res.new_fattr);
+		nfs_post_op_update_inode(new_dir, res.new_fattr, res.new_label);
+	}
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		nfs4_label_free(res.old_label);
+		nfs4_label_free(res.new_label);
 	}
+#endif
 	return status;
 }
 
@@ -2732,23 +2921,44 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	struct nfs4_link_res res = {
 		.server = server,
 		.fattr = &fattr,
+		.label = NULL,
 		.dir_attr = &dir_attr,
+		.dir_label = NULL,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LINK],
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
-	int			status;
+	int	status = 0;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.label = nfs4_label_alloc(GFP_KERNEL);
+		if (res.label == NULL)
+			return -ENOMEM;
+		res.dir_label = nfs4_label_alloc(GFP_KERNEL);
+		if (res.dir_label == NULL) {
+			nfs4_label_free(res.label);
+			return -ENOMEM;
+		}
+	}
+#endif
 	nfs_fattr_init(res.fattr);
 	nfs_fattr_init(res.dir_attr);
 	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, res.dir_attr);
-		nfs_post_op_update_inode(inode, res.fattr);
+		nfs_post_op_update_inode(dir, res.dir_attr, res.dir_label);
+		nfs_post_op_update_inode(inode, res.fattr, res.label);
+	}
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		nfs4_label_free(res.label);
+		nfs4_label_free(res.dir_label);
 	}
+#endif
 
 	return status;
 }
@@ -2771,7 +2981,9 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
+	struct nfs4_label *label;
 	struct nfs_fattr dir_fattr;
+	struct nfs4_label *dir_label;
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -2783,6 +2995,16 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 	if (data != NULL) {
 		struct nfs_server *server = NFS_SERVER(dir);
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (server->caps & NFS_CAP_SECURITY_LABEL) {
+			data->label = nfs4_label_alloc(GFP_KERNEL);
+			if (data->label == NULL)
+				goto out_free;
+			data->dir_label = nfs4_label_alloc(GFP_KERNEL);
+			if (data->dir_label == NULL)
+				goto out_free;
+		}
+#endif
 		data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE];
 		data->msg.rpc_argp = &data->arg;
 		data->msg.rpc_resp = &data->res;
@@ -2795,11 +3017,17 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
+		data->res.label = data->label;
 		data->res.dir_fattr = &data->dir_fattr;
+		data->res.dir_label = data->dir_label;
 		nfs_fattr_init(data->res.fattr);
 		nfs_fattr_init(data->res.dir_fattr);
 	}
 	return data;
+out_free:
+	kfree(data);
+	return NULL;
+
 }
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
@@ -2808,19 +3036,26 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 				    &data->arg, &data->res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
-		nfs_post_op_update_inode(dir, data->res.dir_fattr);
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		nfs_post_op_update_inode(dir, data->res.dir_fattr, data->res.dir_label);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, data->res.label);
 	}
 	return status;
 }
 
 static void nfs4_free_createdata(struct nfs4_createdata *data)
 {
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (data->arg.server->caps & NFS_CAP_SECURITY_LABEL) {
+		nfs4_label_free(data->label);
+		nfs4_label_free(data->dir_label);
+	}
+#endif
 	kfree(data);
 }
 
 static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
-		struct page *page, unsigned int len, struct iattr *sattr)
+		struct page *page, unsigned int len, struct iattr *sattr,
+		struct nfs4_label *label)
 {
 	struct nfs4_createdata *data;
 	int status = -ENAMETOOLONG;
@@ -2836,6 +3071,7 @@ static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 	data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SYMLINK];
 	data->arg.u.symlink.pages = &page;
 	data->arg.u.symlink.len = len;
+	data->arg.label = label;
 	
 	status = nfs4_do_create(dir, dentry, data);
 
@@ -2848,18 +3084,33 @@ static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label l, *label = NULL;
 	int err;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		err = security_dentry_init_security(dentry,
+				sattr->ia_mode, &l.label, &l.len);
+		if (err == 0)
+			label = &l;
+	}
+#endif
+
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_symlink(dir, dentry, page,
-							len, sattr),
+							len, sattr, label),
 				&exception);
 	} while (exception.retry);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label)
+		security_release_secctx(l.label, l.len);
+#endif
 	return err;
 }
 
 static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
-		struct iattr *sattr)
+		struct iattr *sattr, struct nfs4_label *label)
 {
 	struct nfs4_createdata *data;
 	int status = -ENOMEM;
@@ -2868,6 +3119,7 @@ static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 	if (data == NULL)
 		goto out;
 
+	data->arg.label = label;
 	status = nfs4_do_create(dir, dentry, data);
 
 	nfs4_free_createdata(data);
@@ -2879,12 +3131,27 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label l, *label = NULL;
 	int err;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		err = security_dentry_init_security(dentry,
+				sattr->ia_mode, &l.label, &l.len);
+		if (err == 0)
+			label = &l;
+	}
+#endif
+
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mkdir(dir, dentry, sattr),
+				_nfs4_proc_mkdir(dir, dentry, sattr, label),
 				&exception);
 	} while (exception.retry);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label)
+		security_release_secctx(l.label, l.len);
+#endif
 	return err;
 }
 
@@ -2897,7 +3164,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.pages = &page,
 		.pgbase = 0,
 		.count = count,
-		.bitmask = NFS_SERVER(dentry->d_inode)->attr_bitmask,
+		.bitmask = NFS_SERVER(dentry->d_inode)->attr_bitmask_nl,
 	};
 	struct nfs4_readdir_res res;
 	struct rpc_message msg = {
@@ -2939,7 +3206,7 @@ static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 }
 
 static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
-		struct iattr *sattr, dev_t rdev)
+		struct iattr *sattr, struct nfs4_label *label, dev_t rdev)
 {
 	struct nfs4_createdata *data;
 	int mode = sattr->ia_mode;
@@ -2964,7 +3231,7 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		data->arg.u.device.specdata1 = MAJOR(rdev);
 		data->arg.u.device.specdata2 = MINOR(rdev);
 	}
-	
+	data->arg.label = label;
 	status = nfs4_do_create(dir, dentry, data);
 
 	nfs4_free_createdata(data);
@@ -2976,12 +3243,27 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label l, *label = NULL;
 	int err;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		err = security_dentry_init_security(dentry,
+				sattr->ia_mode, &l.label, &l.len);
+		if (err == 0)
+			label = &l;
+	}
+#endif
+
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mknod(dir, dentry, sattr, rdev),
+				_nfs4_proc_mknod(dir, dentry, sattr, label, rdev),
 				&exception);
 	} while (exception.retry);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label)
+		security_release_secctx(l.label, l.len);
+#endif
 	return err;
 }
 
@@ -3142,7 +3424,11 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	data->args.bitmask = server->cache_consistency_bitmask_nl;
+#else
 	data->args.bitmask = server->cache_consistency_bitmask;
+#endif
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
@@ -3159,7 +3445,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
-	nfs_refresh_inode(inode, data->res.fattr);
+	nfs_refresh_inode(inode, data->res.fattr, NULL);
 	return 0;
 }
 
@@ -3167,7 +3453,11 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 	
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	data->args.bitmask = server->cache_consistency_bitmask_nl;
+#else
 	data->args.bitmask = server->cache_consistency_bitmask;
+#endif
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 }
@@ -3514,6 +3804,169 @@ do_state_recovery:
 	return -EAGAIN;
 }
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+static int _nfs4_get_security_label(struct inode *inode, void *buf, size_t buflen)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_fattr fattr;
+	struct nfs4_label label;
+	u32 bitmask[2] = { 0, FATTR4_WORD1_SECURITY_LABEL };
+	struct nfs4_getattr_arg args = {
+		.fh		= NFS_FH(inode),
+		.bitmask	= bitmask,
+	};
+	struct nfs4_getattr_res res = {
+		.fattr		= &fattr,
+		.label		= &label,
+		.server		= server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_GETATTR],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	int ret;
+
+	label.label = buf;
+	label.len = buflen;
+	nfs_fattr_init(&fattr);
+
+	ret = rpc_call_sync(server->client, &msg, 0);
+	if (ret)
+		return ret;
+	if (!(fattr.valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL))
+		return -ENOENT;
+	if (buflen < label.len)
+		return -ERANGE;
+	return 0;
+}
+
+static int nfs4_get_security_label(struct inode *inode, void *buf, size_t buflen)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
+		return -EOPNOTSUPP;
+
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(inode),
+				_nfs4_get_security_label(inode, buf, buflen),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int _nfs4_do_set_security_label(struct inode *inode,
+				      struct nfs4_label *ilabel,
+				      struct nfs_fattr *fattr,
+				      struct nfs4_label *olabel,
+				      struct nfs4_state *state)
+{
+
+	struct iattr sattr;
+	struct nfs_server *server = NFS_SERVER(inode);
+	const u32 bitmask[2] = { 0, FATTR4_WORD1_SECURITY_LABEL };
+	struct nfs_setattrargs args = {
+		.fh             = NFS_FH(inode),
+		.iap            = &sattr,
+		.server		= server,
+		.bitmask	= bitmask,
+		.label		= ilabel,
+	};
+	struct nfs_setattrres res = {
+		.fattr		= fattr,
+		.label		= olabel,
+		.server		= server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
+		.rpc_argp       = &args,
+		.rpc_resp       = &res,
+	};
+	unsigned long timestamp = jiffies;
+	int status;
+
+	memset(&sattr, 0, sizeof(struct iattr));
+
+	if (nfs4_copy_delegation_stateid(&args.stateid, inode)) {
+		/* Use that stateid */
+	} else if (state != NULL) {
+		msg.rpc_cred = state->owner->so_cred;
+		nfs4_copy_stateid(&args.stateid, state, current->files);
+	} else
+		memcpy(&args.stateid, &zero_stateid, sizeof(args.stateid));
+
+	status = rpc_call_sync(server->client, &msg, 0);
+	if (status == 0 && state != NULL)
+		renew_lease(server, timestamp);
+	return status;
+}
+
+static int nfs4_do_set_security_label(struct inode *inode,
+				     struct nfs4_label *ilabel,
+				     struct nfs_fattr *fattr,
+				     struct nfs4_label *olabel,
+				     struct nfs4_state *state)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(inode),
+			_nfs4_do_set_security_label(inode, ilabel, fattr, olabel, state),
+			&exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int
+nfs4_set_security_label(struct dentry *dentry, const void *buf, size_t buflen)
+{
+	struct nfs4_label ilabel, *olabel = NULL;
+	struct nfs_fattr fattr;
+	struct rpc_cred *cred;
+	struct nfs_open_context *ctx;
+	struct nfs4_state *state = NULL;
+	struct inode *inode = dentry->d_inode;
+	int status;
+
+	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
+		return -EOPNOTSUPP;
+
+	nfs_fattr_init(&fattr);
+
+	ilabel.label = (char *)buf;
+	ilabel.len = buflen;
+
+	cred = rpc_lookup_cred();
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+
+	olabel = nfs4_label_alloc(GFP_KERNEL);
+	if (olabel == NULL) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	/* Search for an existing open(O_WRITE) file */
+	ctx = nfs_find_open_context(inode, cred, FMODE_WRITE);
+	if (ctx != NULL)
+		state = ctx->state;
+
+	status = nfs4_do_set_security_label(inode, &ilabel, &fattr, olabel, state);
+	if (status == 0)
+		nfs_setsecurity(inode, &fattr, olabel);
+	if (ctx != NULL)
+		put_nfs_open_context(ctx);
+	nfs4_label_free(olabel);
+out:
+	put_rpccred(cred);
+	return status;
+}
+#endif	/* CONFIG_NFS_V4_SECURITY_LABEL */
+
+
 static int
 nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
 {
@@ -3698,7 +4151,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 		return -ENOMEM;
 	data->args.fhandle = &data->fh;
 	data->args.stateid = &data->stateid;
-	data->args.bitmask = server->attr_bitmask;
+	data->args.bitmask = server->attr_bitmask_nl;
 	nfs_copy_fh(&data->fh, NFS_FH(inode));
 	memcpy(&data->stateid, stateid, sizeof(data->stateid));
 	data->res.fattr = &data->fattr;
@@ -3722,7 +4175,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	status = data->rpc_status;
 	if (status != 0)
 		goto out;
-	nfs_refresh_inode(inode, &data->fattr);
+	nfs_refresh_inode(inode, &data->fattr, NULL);
 out:
 	rpc_put_task(task);
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 38f3b58..61e0b47 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -95,9 +95,14 @@ static int nfs4_stat_to_errno(int);
 #define nfs4_path_maxsz		(1 + ((3 + NFS4_MAXPATHLEN) >> 2))
 #define nfs4_owner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define nfs4_group_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+#define	nfs4_label_maxsz	(4 + 1 + XDR_QUADLEN(NFS4_MAXLABELLEN))
+#else
+#define	nfs4_label_maxsz	0
+#endif
 /* This is based on getfattr, which uses the most attributes: */
 #define nfs4_fattr_value_maxsz	(1 + (1 + 2 + 2 + 4 + 2 + 1 + 1 + 2 + 2 + \
-				3 + 3 + 3 + nfs4_owner_maxsz + nfs4_group_maxsz))
+				3 + 3 + 3 + nfs4_owner_maxsz + nfs4_group_maxsz + nfs4_label_maxsz))
 #define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
 				nfs4_fattr_value_maxsz)
 #define decode_getattr_maxsz    (op_decode_hdr_maxsz + nfs4_fattr_maxsz)
@@ -105,6 +110,7 @@ static int nfs4_stat_to_errno(int);
 				 1 + 2 + 1 + \
 				nfs4_owner_maxsz + \
 				nfs4_group_maxsz + \
+				nfs4_label_maxsz + \
 				4 + 4)
 #define encode_savefh_maxsz     (op_encode_hdr_maxsz)
 #define decode_savefh_maxsz     (op_decode_hdr_maxsz)
@@ -775,7 +781,7 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
 	xdr_encode_opaque_fixed(p, verf->data, NFS4_VERIFIER_SIZE);
 }
 
-static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
+static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs4_label *label, const struct nfs_server *server)
 {
 	char owner_name[IDMAP_NAMESZ];
 	char owner_group[IDMAP_NAMESZ];
@@ -824,6 +830,10 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		}
 		len += 4 + (XDR_QUADLEN(owner_grouplen) << 2);
 	}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label)
+		len += 4 + 4 + (XDR_QUADLEN(label->len) << 2);
+#endif
 	if (iap->ia_valid & ATTR_ATIME_SET)
 		len += 16;
 	else if (iap->ia_valid & ATTR_ATIME)
@@ -880,6 +890,14 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
 		*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label) {
+		bmval1 |= FATTR4_WORD1_SECURITY_LABEL;
+		*p++ = cpu_to_be32(label->lfs);
+		*p++ = cpu_to_be32(label->len);
+		p = xdr_encode_opaque_fixed(p, label->label, label->len);
+	}
+#endif
 
 	/*
 	 * Now we backfill the bitmap and the attribute buffer length.
@@ -961,7 +979,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
 
-	encode_attrs(xdr, create->attrs, create->server);
+	encode_attrs(xdr, create->attrs, create->label, create->server);
 }
 
 static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
@@ -1168,21 +1186,21 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	switch(arg->open_flags & O_EXCL) {
 	case 0:
 		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
-		encode_attrs(xdr, arg->u.attrs, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
 		break;
 	default:
 		clp = arg->server->nfs_client;
 		if (clp->cl_minorversion > 0) {
 			if (nfs4_has_persistent_session(clp)) {
 				*p = cpu_to_be32(NFS4_CREATE_GUARDED);
-				encode_attrs(xdr, arg->u.attrs, arg->server);
+				encode_attrs(xdr, arg->u.attrs,arg->label,  arg->server);
 			} else {
 				struct iattr dummy;
 
 				*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 				encode_nfs4_verifier(xdr, &arg->u.verifier);
 				dummy.ia_valid = 0;
-				encode_attrs(xdr, &dummy, arg->server);
+				encode_attrs(xdr, &dummy, arg->label, arg->server);
 			}
 		} else {
 			*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
@@ -1482,7 +1500,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 	xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setattr_maxsz;
-	encode_attrs(xdr, arg->iap, server);
+	encode_attrs(xdr, arg->iap, arg->label, server);
 }
 
 static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
@@ -3495,6 +3513,58 @@ static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, str
 	return status;
 }
 
+static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_label *label)
+{
+	uint32_t lfs;
+	__u32 len;
+	__be32 *p;
+	int status = 0;
+
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_SECURITY_LABEL - 1U)))
+		return -EIO;
+	if (likely(bitmap[1] & FATTR4_WORD1_SECURITY_LABEL)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		lfs = be32_to_cpup(p++);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		len = be32_to_cpup(p++);
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (len < XDR_MAX_NETOBJ) {
+			if (label) {
+				if (label->len < len) {
+					printk(KERN_ERR
+						"%s(): label->len %d < len %d\n",
+						__func__, label->len, len);
+				} else {
+					memcpy(label->label, p, len);
+					label->len = len;
+					label->lfs = lfs;
+					status = NFS_ATTR_FATTR_V4_SECURITY_LABEL;
+				}
+			} else {
+				printk("%s(): NULL label.\n", __func__);
+				dump_stack();
+			}
+			bitmap[1] &= ~FATTR4_WORD1_SECURITY_LABEL;
+		} else
+			printk(KERN_WARNING "%s: label too long (%u)!\n",
+					__FUNCTION__, len);
+	}
+	if(label && label->label)
+		dprintk("%s: label=%s, len=%d\n", __func__,
+				 label->label, label->len);
+	return status;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int verify_attr_len(struct xdr_stream *xdr, __be32 *savep, uint32_t attrlen)
 {
 	unsigned int attrwords = XDR_QUADLEN(attrlen);
@@ -3701,7 +3771,8 @@ xdr_error:
 }
 
 static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
-		const struct nfs_server *server, int may_sleep)
+		struct nfs4_label *label, const struct nfs_server *server,
+		int may_sleep)
 {
 	__be32 *savep;
 	uint32_t attrlen,
@@ -3817,6 +3888,10 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 		fattr->fileid = fileid;
 		fattr->valid |= status;
 	}
+	status = decode_attr_security_label(xdr, bitmap, label);
+	if (status < 0)
+		goto xdr_error;
+	fattr->valid |= status;
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
@@ -4708,7 +4783,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 	status = decode_open_downgrade(&xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4736,7 +4811,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 	status = decode_access(&xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4764,7 +4839,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) != 0)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server
+	status = decode_getfattr(&xdr, res->fattr, res->label, res->server
 			,!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4789,7 +4864,7 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if ((status = decode_putrootfh(&xdr)) != 0)
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) == 0)
-		status = decode_getfattr(&xdr, res->fattr, res->server,
+		status = decode_getfattr(&xdr, res->fattr, res->label, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4815,7 +4890,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
 		goto out;
-	decode_getfattr(&xdr, &res->dir_attr, res->server,
+	decode_getfattr(&xdr, &res->dir_attr, res->dir_label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4846,12 +4921,12 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 	if ((status = decode_rename(&xdr, &res->old_cinfo, &res->new_cinfo)) != 0)
 		goto out;
 	/* Current FH is target directory */
-	if (decode_getfattr(&xdr, res->new_fattr, res->server,
+	if (decode_getfattr(&xdr, res->new_fattr, res->new_label, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->old_fattr, res->server,
+	decode_getfattr(&xdr, res->old_fattr, res->old_label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4885,12 +4960,12 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(&xdr, res->dir_attr, res->server,
+	if (decode_getfattr(&xdr, res->dir_attr, res->dir_label, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4920,12 +4995,12 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->fattr, res->server,
+	if (decode_getfattr(&xdr, res->fattr, res->label, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_fattr, res->server,
+	decode_getfattr(&xdr, res->dir_fattr, res->dir_label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -4958,7 +5033,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server,
+	status = decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5066,7 +5141,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 * 	an ESTALE error. Shouldn't be a problem,
 	 * 	though, since fattr->valid will remain unset.
 	 */
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5099,12 +5174,12 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	if (decode_getfh(&xdr, &res->fh) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->f_attr, res->server,
+	if (decode_getfattr(&xdr, res->f_attr, res->f_label, res->server,
 				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if (decode_restorefh(&xdr) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server,
+	decode_getfattr(&xdr, res->dir_attr, res->dir_label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5153,7 +5228,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_open(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->f_attr, res->server,
+	decode_getfattr(&xdr, res->f_attr, NULL, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5181,7 +5256,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_setattr(&xdr);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5356,7 +5431,7 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 	status = decode_write(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, NULL, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 	if (!status)
 		status = res->count;
@@ -5386,7 +5461,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 	status = decode_commit(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, NULL, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5553,7 +5628,7 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_delegreturn(&xdr);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
+	decode_getfattr(&xdr, res->fattr, res->label, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
@@ -5581,7 +5656,7 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
 	if ((status = decode_lookup(&xdr)) != 0)
 		goto out;
 	xdr_enter_page(&xdr, PAGE_SIZE);
-	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
+	status = decode_getfattr(&xdr, &res->fs_locations->fattr, NULL,
 				 res->fs_locations->server,
 				 !RPC_IS_ASYNC(req->rq_task));
 out:
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 0288be8..acdc92d 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -130,7 +130,7 @@ nfs_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_GETATTR],
@@ -178,7 +178,8 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int
 nfs_proc_lookup(struct inode *dir, struct qstr *name,
-		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+		struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		struct nfs4_label *label)
 {
 	struct nfs_diropargs	arg = {
 		.fh		= NFS_FH(dir),
@@ -252,7 +253,7 @@ nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, &fhandle, &fattr, NULL);
 	dprintk("NFS reply create: %d\n", status);
 	return status;
 }
@@ -304,7 +305,7 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	}
 	if (status == 0)
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, &fhandle, &fattr, NULL);
 	dprintk("NFS reply mknod: %d\n", status);
 	return status;
 }
@@ -430,7 +431,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	if (status == 0) {
 		nfs_fattr_init(&fattr);
 		fhandle.size = 0;
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, &fhandle, &fattr, NULL);
 	}
 
 	dprintk("NFS reply symlink: %d\n", status);
@@ -464,7 +465,7 @@ nfs_proc_mkdir(struct inode *dir, struct dentry *dentry, struct iattr *sattr)
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, &fhandle, &fattr);
+		status = nfs_instantiate(dentry, &fhandle, &fattr, NULL);
 	dprintk("NFS reply mkdir: %d\n", status);
 	return status;
 }
@@ -599,7 +600,7 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	nfs_invalidate_atime(data->inode);
 	if (task->tk_status >= 0) {
-		nfs_refresh_inode(data->inode, data->res.fattr);
+		nfs_refresh_inode(data->inode, data->res.fattr, data->res.label);
 		/* Emulate the eof flag, which isn't normally needed in NFSv2
 		 * as it is guaranteed to always return the file attributes
 		 */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 054bcaa..8135838 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2551,6 +2551,7 @@ static int nfs4_remote_get_sb(struct file_system_type *fs_type,
 	struct nfs_fh *mntfh;
 	struct dentry *mntroot;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
+	unsigned long kflags = 0, kflags_out = 0;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
@@ -2602,10 +2603,20 @@ static int nfs4_remote_get_sb(struct file_system_type *fs_type,
 		goto error_splat_super;
 	}
 
-	error = security_sb_set_mnt_opts(s, &data->lsm_opts, 0, NULL);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		kflags |= SECURITY_LSM_NATIVE_LABELS;
+#endif
+
+	error = security_sb_set_mnt_opts(s, &data->lsm_opts, kflags, &kflags_out);
 	if (error)
 		goto error_splat_root;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL && !(kflags_out & SECURITY_LSM_NATIVE_LABELS))
+		server->caps &= ~NFS_CAP_SECURITY_LABEL;
+#endif
+
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2813b71..753294d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -198,6 +198,7 @@ struct nfs_inode {
 #define NFS_INO_INVALID_ACL	0x0010		/* cached acls are invalid */
 #define NFS_INO_REVAL_PAGECACHE	0x0020		/* must revalidate pagecache */
 #define NFS_INO_REVAL_FORCED	0x0040		/* force revalidation ignoring a delegation */
+#define NFS_INO_INVALID_LABEL	0x0080		/* cached label is invalid */
 
 /*
  * Bit offsets in flags field
@@ -336,9 +337,9 @@ extern void nfs_zap_mapping(struct inode *inode, struct address_space *mapping);
 extern void nfs_zap_caches(struct inode *);
 extern void nfs_invalidate_atime(struct inode *);
 extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
-				struct nfs_fattr *);
-extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
-extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
+				struct nfs_fattr *, struct nfs4_label *);
+extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *, struct nfs4_label *);
+extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 extern int nfs_permission(struct inode *, int);
@@ -350,6 +351,7 @@ extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
+extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
@@ -425,7 +427,7 @@ extern const struct file_operations nfs_dir_operations;
 extern const struct dentry_operations nfs_dentry_operations;
 
 extern void nfs_force_lookup_revalidate(struct inode *dir);
-extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh, struct nfs_fattr *fattr);
+extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh, struct nfs_fattr *fattr, struct nfs4_label *label);
 extern int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags);
 extern void nfs_access_zap_cache(struct inode *inode);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index aa95a22..86895ee 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -140,11 +140,17 @@ struct nfs_server {
 	u32			attr_bitmask[2];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
+	u32			attr_bitmask_nl[2]; /* V4 bitmask representing the set
+							of attributes supported on this
+							filesystem excluding the label
+							support bit. */
 	u32			cache_consistency_bitmask[2];
 						/* V4 bitmask representing the subset
 						   of change attribute, size, ctime
 						   and mtime attributes supported by
 						   the server */
+	u32			cache_consistency_bitmask_nl[2];
+						/* As above, excluding label. */
 	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
 						   that are supported on this
 						   filesystem */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index dc505e4..bc87a58 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1034,11 +1034,12 @@ struct nfs_rpc_ops {
 			    struct qstr *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
-			    struct nfs_fattr *);
+			    struct nfs_fattr *, struct nfs4_label *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
 	int	(*lookup)  (struct inode *, struct qstr *,
-			    struct nfs_fh *, struct nfs_fattr *);
+			    struct nfs_fh *, struct nfs_fattr *,
+			    struct nfs4_label *);
 	int	(*access)  (struct inode *, struct nfs_access_entry *);
 	int	(*readlink)(struct inode *, struct page *, unsigned int,
 			    unsigned int);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 01edf80..6c1e2fa 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2883,7 +2883,10 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
 		return;
 	}
 
+	isec->sclass = inode_mode_to_security_class(inode->i_mode);
 	isec->sid = newsid;
+	isec->initialized = 1;
+
 	return;
 }
 
@@ -2971,6 +2974,7 @@ static int selinux_inode_setsecurity(struct inode *inode, const char *name,
 	if (rc)
 		return rc;
 
+	isec->sclass = inode_mode_to_security_class(inode->i_mode);
 	isec->sid = newsid;
 	isec->initialized = 1;
 	return 0;
-- 
1.6.2.5
