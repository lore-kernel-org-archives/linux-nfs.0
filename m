Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab2LQPnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:43:18 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/13] NFS:Add labels to client function prototypes
Date: Mon, 17 Dec 2012 10:43:07 -0500
Message-Id: <1355758991-30049-10-git-send-email-steved@redhat.com>
In-Reply-To: <1355758991-30049-1-git-send-email-steved@redhat.com>
References: <1355758991-30049-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dave Quigley <dpquigl@taiga.selinuxproject.org>

>From David Quigley <dpquigl@davequigley.com>

After looking at all of the nfsv4 operations the label structure has been added
to the prototypes of the functions which can transmit label data.


Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/client.c         |   2 +-
 fs/nfs/dir.c            |  23 ++++++----
 fs/nfs/getroot.c        |   3 +-
 fs/nfs/inode.c          |  33 +++++++-------
 fs/nfs/namespace.c      |   2 +-
 fs/nfs/nfs3acl.c        |   4 +-
 fs/nfs/nfs3proc.c       |  41 +++++++++--------
 fs/nfs/nfs4_fs.h        |   2 +-
 fs/nfs/nfs4namespace.c  |   2 +-
 fs/nfs/nfs4proc.c       | 118 +++++++++++++++++++++++++++++++-----------------
 fs/nfs/proc.c           |  15 +++---
 include/linux/nfs_fs.h  |   9 ++--
 include/linux/nfs_xdr.h |   5 +-
 13 files changed, 151 insertions(+), 108 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b39a42..ecc7419 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1080,7 +1080,7 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	}
 
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
-		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr);
+		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr, NULL);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce8cb92..1339e44 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -447,7 +447,7 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 	dentry = d_lookup(parent, &filename);
 	if (dentry != NULL) {
 		if (nfs_same_file(dentry, entry)) {
-			nfs_refresh_inode(dentry->d_inode, entry->fattr);
+			nfs_refresh_inode(dentry->d_inode, entry->fattr, entry->label);
 			goto out;
 		} else {
 			d_drop(dentry);
@@ -459,7 +459,7 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 	if (dentry == NULL)
 		return;
 
-	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr);
+	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr, entry->label);
 	if (IS_ERR(inode))
 		goto out;
 
@@ -1034,6 +1034,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	struct dentry *parent;
 	struct nfs_fh *fhandle = NULL;
 	struct nfs_fattr *fattr = NULL;
+	struct nfs4_label *label = NULL;
 	int error;
 
 	if (flags & LOOKUP_RCU)
@@ -1076,12 +1077,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
 	if (error)
 		goto out_bad;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
 		goto out_bad;
-	if ((error = nfs_refresh_inode(inode, fattr)) != 0)
+	if ((error = nfs_refresh_inode(inode, fattr, label)) != 0)
 		goto out_bad;
 
 	nfs_free_fattr(fattr);
@@ -1207,6 +1208,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	struct inode *inode = NULL;
 	struct nfs_fh *fhandle = NULL;
 	struct nfs_fattr *fattr = NULL;
+	struct nfs4_label *label = NULL;
 	int error;
 
 	dfprintk(VFS, "NFS: lookup(%s/%s)\n",
@@ -1236,14 +1238,14 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
 		res = ERR_PTR(error);
 		goto out_unblock_sillyrename;
 	}
-	inode = nfs_fhget(dentry->d_sb, fhandle, fattr);
+	inode = nfs_fhget(dentry->d_sb, fhandle, fattr, label);
 	res = ERR_CAST(inode);
 	if (IS_ERR(res))
 		goto out_unblock_sillyrename;
@@ -1477,7 +1479,8 @@ no_open:
  * Code common to create, mkdir, and mknod.
  */
 int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
-				struct nfs_fattr *fattr)
+				struct nfs_fattr *fattr,
+				struct nfs4_label *label)
 {
 	struct dentry *parent = dget_parent(dentry);
 	struct inode *dir = parent->d_inode;
@@ -1490,18 +1493,18 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
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
index 033803c..3b68bb6 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -75,6 +75,7 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 	struct nfs_fsinfo fsinfo;
 	struct dentry *ret;
 	struct inode *inode;
+	struct nfs4_label *label = NULL;
 	void *name = kstrdup(devname, GFP_KERNEL);
 	int error;
 
@@ -95,7 +96,7 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 		goto out;
 	}
 
-	inode = nfs_fhget(sb, mntfh, fsinfo.fattr);
+	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, NULL);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
 		ret = ERR_CAST(inode);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0963ad9..daca08c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -61,7 +61,7 @@
 static bool enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
 
 static void nfs_invalidate_inode(struct inode *);
-static int nfs_update_inode(struct inode *, struct nfs_fattr *);
+static int nfs_update_inode(struct inode *, struct nfs_fattr *, struct nfs4_label *);
 
 static struct kmem_cache * nfs_inode_cachep;
 
@@ -291,7 +291,7 @@ EXPORT_SYMBOL_GPL(nfs4_label_free);
  * instead of inode number.
  */
 struct inode *
-nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
+nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_find_desc desc = {
 		.fh	= fh,
@@ -421,7 +421,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 
 		unlock_new_inode(inode);
 	} else
-		nfs_refresh_inode(inode, fattr);
+		nfs_refresh_inode(inode, fattr, label);
 	dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
@@ -478,7 +478,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		NFS_PROTO(inode)->return_delegation(inode);
 	error = NFS_PROTO(inode)->setattr(dentry, fattr, attr);
 	if (error == 0)
-		nfs_refresh_inode(inode, fattr);
+		nfs_refresh_inode(inode, fattr, NULL);
 	nfs_free_fattr(fattr);
 out:
 	return error;
@@ -817,6 +817,7 @@ int
 __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
 	int		 status = -ESTALE;
+	struct nfs4_label *label = NULL;
 	struct nfs_fattr *fattr = NULL;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -834,7 +835,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
-	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr);
+	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
 			 inode->i_sb->s_id,
@@ -847,7 +848,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 	}
 
-	status = nfs_refresh_inode(inode, fattr);
+	status = nfs_refresh_inode(inode, fattr, label);
 	if (status) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
@@ -1200,10 +1201,10 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
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
 
@@ -1217,21 +1218,21 @@ static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr
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
 EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
-static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -1240,7 +1241,7 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
 		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
-	return nfs_refresh_inode_locked(inode, fattr);
+	return nfs_refresh_inode_locked(inode, fattr, label);
 }
 
 /**
@@ -1257,12 +1258,12 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
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
@@ -1314,7 +1315,7 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 		fattr->valid |= NFS_ATTR_FATTR_PRESIZE;
 	}
 out_noforce:
-	status = nfs_post_op_update_inode_locked(inode, fattr);
+	status = nfs_post_op_update_inode_locked(inode, fattr, NULL);
 	spin_unlock(&inode->i_lock);
 	return status;
 }
@@ -1332,7 +1333,7 @@ EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
  *
  * A very similar scenario holds for the dir cache.
  */
-static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_server *server;
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 6559253..25747d2 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -251,7 +251,7 @@ struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
 	struct dentry *parent = dget_parent(dentry);
 
 	/* Look it up again to get its attributes */
-	err = server->nfs_client->rpc_ops->lookup(parent->d_inode, &dentry->d_name, fh, fattr);
+	err = server->nfs_client->rpc_ops->lookup(parent->d_inode, &dentry->d_name, fh, fattr, NULL);
 	dput(parent);
 	if (err != 0)
 		return ERR_PTR(err);
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 4a1aafb..1a2f11b 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -240,7 +240,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 
 	switch (status) {
 		case 0:
-			status = nfs_refresh_inode(inode, res.fattr);
+			status = nfs_refresh_inode(inode, res.fattr, NULL);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
@@ -352,7 +352,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 
 	switch (status) {
 		case 0:
-			status = nfs_refresh_inode(inode, fattr);
+			status = nfs_refresh_inode(inode, fattr, NULL);
 			nfs3_cache_acls(inode, acl, dfacl);
 			break;
 		case -EPFNOSUPPORT:
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 6932209..c2aaca7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -98,7 +98,7 @@ nfs3_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs3_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_GETATTR],
@@ -143,7 +143,8 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int
 nfs3_proc_lookup(struct inode *dir, struct qstr *name,
-		 struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+		 struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		 struct nfs4_label *label)
 {
 	struct nfs3_diropargs	arg = {
 		.fh		= NFS_FH(dir),
@@ -168,7 +169,7 @@ nfs3_proc_lookup(struct inode *dir, struct qstr *name,
 
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_refresh_inode(dir, res.dir_attr);
+	nfs_refresh_inode(dir, res.dir_attr, NULL);
 	if (status >= 0 && !(fattr->valid & NFS_ATTR_FATTR)) {
 		msg.rpc_proc = &nfs3_procedures[NFS3PROC_GETATTR];
 		msg.rpc_argp = fhandle;
@@ -216,7 +217,7 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		goto out;
 
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_refresh_inode(inode, res.fattr);
+	nfs_refresh_inode(inode, res.fattr, NULL);
 	if (status == 0) {
 		entry->mask = 0;
 		if (res.access & NFS3_ACCESS_READ)
@@ -255,7 +256,7 @@ static int nfs3_proc_readlink(struct inode *inode, struct page *page,
 	msg.rpc_resp = fattr;
 
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_refresh_inode(inode, fattr);
+	nfs_refresh_inode(inode, fattr, NULL);
 	nfs_free_fattr(fattr);
 out:
 	dprintk("NFS reply readlink: %d\n", status);
@@ -298,9 +299,9 @@ static int nfs3_do_create(struct inode *dir, struct dentry *dentry, struct nfs3_
 	int status;
 
 	status = rpc_call_sync(NFS_CLIENT(dir), &data->msg, 0);
-	nfs_post_op_update_inode(dir, data->res.dir_attr);
+	nfs_post_op_update_inode(dir, data->res.dir_attr, NULL);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	return status;
 }
 
@@ -381,7 +382,7 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		 * not sure this buys us anything (and I'd have
 		 * to revamp the NFSv3 XDR code) */
 		status = nfs3_proc_setattr(dentry, data->res.fattr, sattr);
-		nfs_post_op_update_inode(dentry->d_inode, data->res.fattr);
+		nfs_post_op_update_inode(dentry->d_inode, data->res.fattr, NULL);
 		dprintk("NFS reply setattr (post-create): %d\n", status);
 		if (status != 0)
 			goto out;
@@ -414,7 +415,7 @@ nfs3_proc_remove(struct inode *dir, struct qstr *name)
 		goto out;
 
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, res.dir_attr);
+	nfs_post_op_update_inode(dir, res.dir_attr, NULL);
 	nfs_free_fattr(res.dir_attr);
 out:
 	dprintk("NFS reply remove: %d\n", status);
@@ -439,7 +440,7 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs3_async_handle_jukebox(task, dir))
 		return 0;
 	res = task->tk_msg.rpc_resp;
-	nfs_post_op_update_inode(dir, res->dir_attr);
+	nfs_post_op_update_inode(dir, res->dir_attr, NULL);
 	return 1;
 }
 
@@ -464,8 +465,8 @@ nfs3_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		return 0;
 	res = task->tk_msg.rpc_resp;
 
-	nfs_post_op_update_inode(old_dir, res->old_fattr);
-	nfs_post_op_update_inode(new_dir, res->new_fattr);
+	nfs_post_op_update_inode(old_dir, res->old_fattr, NULL);
+	nfs_post_op_update_inode(new_dir, res->new_fattr, NULL);
 	return 1;
 }
 
@@ -495,8 +496,8 @@ nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		goto out;
 
 	status = rpc_call_sync(NFS_CLIENT(old_dir), &msg, 0);
-	nfs_post_op_update_inode(old_dir, res.old_fattr);
-	nfs_post_op_update_inode(new_dir, res.new_fattr);
+	nfs_post_op_update_inode(old_dir, res.old_fattr, NULL);
+	nfs_post_op_update_inode(new_dir, res.new_fattr, NULL);
 out:
 	nfs_free_fattr(res.old_fattr);
 	nfs_free_fattr(res.new_fattr);
@@ -528,8 +529,8 @@ nfs3_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 		goto out;
 
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
-	nfs_post_op_update_inode(dir, res.dir_attr);
-	nfs_post_op_update_inode(inode, res.fattr);
+	nfs_post_op_update_inode(dir, res.dir_attr, NULL);
+	nfs_post_op_update_inode(inode, res.fattr, NULL);
 out:
 	nfs_free_fattr(res.dir_attr);
 	nfs_free_fattr(res.fattr);
@@ -622,7 +623,7 @@ nfs3_proc_rmdir(struct inode *dir, struct qstr *name)
 
 	msg.rpc_resp = dir_attr;
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, dir_attr);
+	nfs_post_op_update_inode(dir, dir_attr, NULL);
 	nfs_free_fattr(dir_attr);
 out:
 	dprintk("NFS reply rmdir: %d\n", status);
@@ -677,7 +678,7 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 
 	nfs_invalidate_atime(dir);
-	nfs_refresh_inode(dir, res.dir_attr);
+	nfs_refresh_inode(dir, res.dir_attr, NULL);
 
 	nfs_free_fattr(res.dir_attr);
 out:
@@ -816,7 +817,7 @@ static int nfs3_read_done(struct rpc_task *task, struct nfs_read_data *data)
 		return -EAGAIN;
 
 	nfs_invalidate_atime(inode);
-	nfs_refresh_inode(inode, &data->fattr);
+	nfs_refresh_inode(inode, &data->fattr, NULL);
 	return 0;
 }
 
@@ -860,7 +861,7 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
 		return -EAGAIN;
-	nfs_refresh_inode(data->inode, data->res.fattr);
+	nfs_refresh_inode(data->inode, data->res.fattr, NULL);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f15015a..c97c6837 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -230,7 +230,7 @@ extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fh
 extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
 				  struct nfs4_fs_locations *, struct page *);
 extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
-			    struct nfs_fh *, struct nfs_fattr *);
+			    struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *);
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 79fbb61..f40cf63 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -367,7 +367,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 	struct vfsmount *mnt;
 
 	/* Look it up again to get its attributes and sec flavor */
-	client = nfs4_proc_lookup_mountpoint(parent->d_inode, &dentry->d_name, fh, fattr);
+	client = nfs4_proc_lookup_mountpoint(parent->d_inode, &dentry->d_name, fh, fattr, NULL);
 	dput(parent);
 	if (IS_ERR(client))
 		return ERR_CAST(client);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3c49f3e..8e0378c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -78,11 +78,12 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
-static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
-			    struct nfs4_state *state);
+			    struct nfs4_state *state, struct nfs4_label *ilabel,
+			    struct nfs4_label *olabel);
 #ifdef CONFIG_NFS_V4_1
 static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *);
 static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *);
@@ -826,6 +827,7 @@ struct nfs4_opendata {
 	struct nfs4_string owner_name;
 	struct nfs4_string group_name;
 	struct nfs_fattr f_attr;
+	struct nfs4_label *f_label;
 	struct dentry *dir;
 	struct dentry *dentry;
 	struct nfs4_state_owner *owner;
@@ -841,6 +843,7 @@ struct nfs4_opendata {
 static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 {
 	p->o_res.f_attr = &p->f_attr;
+	p->o_res.f_label = p->f_label;
 	p->o_res.seqid = p->o_arg.seqid;
 	p->c_res.seqid = p->c_arg.seqid;
 	p->o_res.server = p->o_arg.server;
@@ -851,7 +854,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 
 static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 		struct nfs4_state_owner *sp, fmode_t fmode, int flags,
-		const struct iattr *attrs,
+		const struct iattr *attrs, struct nfs4_label *label,
 		gfp_t gfp_mask)
 {
 	struct dentry *parent = dget_parent(dentry);
@@ -889,6 +892,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
+	p->o_arg.label = label;
 	if (attrs != NULL && attrs->ia_valid != 0) {
 		__be32 verf[2];
 
@@ -1190,7 +1194,7 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 	if (state == NULL)
 		goto err;
 
-	ret = nfs_refresh_inode(inode, &data->f_attr);
+	ret = nfs_refresh_inode(inode, &data->f_attr, data->f_label);
 	if (ret)
 		goto err;
 
@@ -1220,7 +1224,7 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 	ret = -EAGAIN;
 	if (!(data->f_attr.valid & NFS_ATTR_FATTR))
 		goto err;
-	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr);
+	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr, data->f_label);
 	ret = PTR_ERR(inode);
 	if (IS_ERR(inode))
 		goto err;
@@ -1270,7 +1274,7 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 {
 	struct nfs4_opendata *opendata;
 
-	opendata = nfs4_opendata_alloc(ctx->dentry, state->owner, 0, 0, NULL, GFP_NOFS);
+	opendata = nfs4_opendata_alloc(ctx->dentry, state->owner, 0, 0, NULL, NULL, GFP_NOFS);
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
@@ -1788,7 +1792,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 			return status;
 	}
 	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
-		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr);
+		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
 	return 0;
 }
 
@@ -1965,6 +1969,7 @@ static int _nfs4_do_open(struct inode *dir,
 			fmode_t fmode,
 			int flags,
 			struct iattr *sattr,
+			struct nfs4_label *label,
 			struct rpc_cred *cred,
 			struct nfs4_state **res,
 			struct nfs4_threshold **ctx_th)
@@ -1973,6 +1978,7 @@ static int _nfs4_do_open(struct inode *dir,
 	struct nfs4_state     *state = NULL;
 	struct nfs_server       *server = NFS_SERVER(dir);
 	struct nfs4_opendata *opendata;
+	struct nfs4_label *olabel = NULL;
 	int status;
 
 	/* Protect against reboot recovery conflicts */
@@ -1988,7 +1994,7 @@ static int _nfs4_do_open(struct inode *dir,
 	if (dentry->d_inode != NULL)
 		nfs4_return_incompatible_delegation(dentry->d_inode, fmode);
 	status = -ENOMEM;
-	opendata = nfs4_opendata_alloc(dentry, sp, fmode, flags, sattr, GFP_KERNEL);
+	opendata = nfs4_opendata_alloc(dentry, sp, fmode, flags, sattr, label, GFP_KERNEL);
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
@@ -2022,10 +2028,11 @@ static int _nfs4_do_open(struct inode *dir,
 		nfs_fattr_init(opendata->o_res.f_attr);
 		status = nfs4_do_setattr(state->inode, cred,
 				opendata->o_res.f_attr, sattr,
-				state);
-		if (status == 0)
+				state, label, olabel);
+		if (status == 0) {
 			nfs_setattr_update_inode(state->inode, sattr);
-		nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
+			nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr, olabel);
+		}
 	}
 
 	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server))
@@ -2054,6 +2061,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 					fmode_t fmode,
 					int flags,
 					struct iattr *sattr,
+					struct nfs4_label *label,
 					struct rpc_cred *cred,
 					struct nfs4_threshold **ctx_th)
 {
@@ -2063,7 +2071,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 
 	fmode &= FMODE_READ|FMODE_WRITE|FMODE_EXEC;
 	do {
-		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred,
+		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, label, cred,
 				       &res, ctx_th);
 		if (status == 0)
 			break;
@@ -2108,7 +2116,8 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 
 static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
-			    struct nfs4_state *state)
+			    struct nfs4_state *state, struct nfs4_label *ilabel,
+			    struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
         struct nfs_setattrargs  arg = {
@@ -2116,9 +2125,11 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
                 .iap            = sattr,
 		.server		= server,
 		.bitmask = server->attr_bitmask,
+		.label		= ilabel,
         };
         struct nfs_setattrres  res = {
 		.fattr		= fattr,
+		.label		= olabel,
 		.server		= server,
         };
         struct rpc_message msg = {
@@ -2153,7 +2164,8 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			   struct nfs_fattr *fattr, struct iattr *sattr,
-			   struct nfs4_state *state)
+			   struct nfs4_state *state, struct nfs4_label *ilabel,
+			   struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = {
@@ -2162,7 +2174,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	};
 	int err;
 	do {
-		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state);
+		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
 			if (state && !(state->state & FMODE_WRITE)) {
@@ -2249,7 +2261,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				rpc_restart_call_prepare(task);
 	}
 	nfs_release_seqid(calldata->arg.seqid);
-	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
+	nfs_refresh_inode(calldata->inode, calldata->res.fattr, NULL);
 	dprintk("%s: done, ret = %d!\n", __func__, task->tk_status);
 }
 
@@ -2386,9 +2398,10 @@ static struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
 	struct nfs4_state *state;
+	struct nfs4_label l, *label = NULL;
 
 	/* Protect against concurrent sillydeletes */
-	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr,
+	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr, label,
 			     ctx->cred, &ctx->mdsthreshold);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
@@ -2586,6 +2599,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 {
 	int error;
 	struct nfs_fattr *fattr = info->fattr;
+	struct nfs4_label *label = NULL;
 
 	error = nfs4_server_capabilities(server, mntfh);
 	if (error < 0) {
@@ -2593,7 +2607,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 		return error;
 	}
 
-	error = nfs4_proc_getattr(server, mntfh, fattr);
+	error = nfs4_proc_getattr(server, mntfh, fattr, label);
 	if (error < 0) {
 		dprintk("nfs4_get_root: getattr error = %d\n", -error);
 		return error;
@@ -2649,7 +2663,8 @@ out:
 	return status;
 }
 
-static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_getattr_arg args = {
 		.fh = fhandle,
@@ -2657,6 +2672,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	struct nfs4_getattr_res res = {
 		.fattr = fattr,
+		.label = label,
 		.server = server,
 	};
 	struct rpc_message msg = {
@@ -2669,13 +2685,14 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
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
@@ -2705,6 +2722,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct inode *inode = dentry->d_inode;
 	struct rpc_cred *cred = NULL;
 	struct nfs4_state *state = NULL;
+	struct nfs4_label *olabel = NULL;
 	int status;
 
 	if (pnfs_ld_layoutret_on_setattr(inode))
@@ -2731,7 +2749,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		}
 	}
 
-	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, NULL);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr);
 	return status;
@@ -2739,7 +2757,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 		const struct qstr *name, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	int		       status;
@@ -2777,13 +2795,13 @@ static void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr)
 
 static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 				   struct qstr *name, struct nfs_fh *fhandle,
-				   struct nfs_fattr *fattr)
+				   struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_exception exception = { };
 	struct rpc_clnt *client = *clnt;
 	int err;
 	do {
-		err = _nfs4_proc_lookup(client, dir, name, fhandle, fattr);
+		err = _nfs4_proc_lookup(client, dir, name, fhandle, fattr, label);
 		switch (err) {
 		case -NFS4ERR_BADNAME:
 			err = -ENOENT;
@@ -2817,12 +2835,13 @@ out:
 }
 
 static int nfs4_proc_lookup(struct inode *dir, struct qstr *name,
-			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+			    struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+			    struct nfs4_label *label)
 {
 	int status;
 	struct rpc_clnt *client = NFS_CLIENT(dir);
 
-	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr);
+	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr, label);
 	if (client != NFS_CLIENT(dir)) {
 		rpc_shutdown_client(client);
 		nfs_fixup_secinfo_attributes(fattr);
@@ -2832,12 +2851,13 @@ static int nfs4_proc_lookup(struct inode *dir, struct qstr *name,
 
 struct rpc_clnt *
 nfs4_proc_lookup_mountpoint(struct inode *dir, struct qstr *name,
-			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+			    struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+			    struct nfs4_label *label)
 {
 	int status;
 	struct rpc_clnt *client = rpc_clone_client(NFS_CLIENT(dir));
 
-	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr);
+	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr, label);
 	if (status < 0) {
 		rpc_shutdown_client(client);
 		return ERR_PTR(status);
@@ -2854,6 +2874,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	};
 	struct nfs4_accessres res = {
 		.server = server,
+		.label = NULL,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
@@ -2888,7 +2909,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		nfs_access_set_mask(entry, res.access);
-		nfs_refresh_inode(inode, res.fattr);
+		nfs_refresh_inode(inode, res.fattr, res.label);
 	}
 	nfs_free_fattr(res.fattr);
 	return status;
@@ -2967,6 +2988,7 @@ static int
 nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		 int flags)
 {
+	struct nfs4_label l, *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
 	int status = 0;
@@ -2977,7 +2999,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 
 	sattr->ia_mode &= ~current_umask();
 	state = nfs4_do_open(dir, dentry, ctx->mode,
-			flags, sattr, ctx->cred,
+			flags, sattr, ilabel, ctx->cred,
 			&ctx->mdsthreshold);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
@@ -3105,6 +3127,8 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_dir = NFS_FH(new_dir),
 		.old_name = old_name,
 		.new_name = new_name,
+		.old_label = NULL,
+		.new_label = NULL,
 	};
 	struct nfs_renameres res = {
 		.server = server,
@@ -3149,6 +3173,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	};
 	struct nfs4_link_res res = {
 		.server = server,
+		.label = NULL,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LINK],
@@ -3164,7 +3189,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(inode, res.fattr);
+		nfs_post_op_update_inode(inode, res.fattr, res.label);
 	}
 out:
 	nfs_free_fattr(res.fattr);
@@ -3189,6 +3214,7 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
+	struct nfs4_label *label;
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -3212,6 +3238,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
+		data->res.label = data->label;
 		nfs_fattr_init(data->res.fattr);
 	}
 	return data;
@@ -3223,7 +3250,7 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, data->res.label);
 	}
 	return status;
 }
@@ -3234,7 +3261,8 @@ static void nfs4_free_createdata(struct nfs4_createdata *data)
 }
 
 static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
-		struct page *page, unsigned int len, struct iattr *sattr)
+		struct page *page, unsigned int len, struct iattr *sattr,
+		struct nfs4_label *label)
 {
 	struct nfs4_createdata *data;
 	int status = -ENAMETOOLONG;
@@ -3250,6 +3278,7 @@ static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 	data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SYMLINK];
 	data->arg.u.symlink.pages = &page;
 	data->arg.u.symlink.len = len;
+	data->arg.label = label;
 	
 	status = nfs4_do_create(dir, dentry, data);
 
@@ -3262,18 +3291,19 @@ static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label l, *label = NULL;
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_symlink(dir, dentry, page,
-							len, sattr),
+							len, sattr, label),
 				&exception);
 	} while (exception.retry);
 	return err;
 }
 
 static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
-		struct iattr *sattr)
+		struct iattr *sattr, struct nfs4_label *label)
 {
 	struct nfs4_createdata *data;
 	int status = -ENOMEM;
@@ -3282,6 +3312,7 @@ static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 	if (data == NULL)
 		goto out;
 
+	data->arg.label = label;
 	status = nfs4_do_create(dir, dentry, data);
 
 	nfs4_free_createdata(data);
@@ -3293,12 +3324,13 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label l, *label = NULL;
 	int err;
 
 	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mkdir(dir, dentry, sattr),
+				_nfs4_proc_mkdir(dir, dentry, sattr, label),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -3358,7 +3390,7 @@ static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 }
 
 static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
-		struct iattr *sattr, dev_t rdev)
+		struct iattr *sattr, struct nfs4_label *label, dev_t rdev)
 {
 	struct nfs4_createdata *data;
 	int mode = sattr->ia_mode;
@@ -3383,7 +3415,8 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		data->arg.u.device.specdata1 = MAJOR(rdev);
 		data->arg.u.device.specdata2 = MINOR(rdev);
 	}
-	
+
+	data->arg.label = label;	
 	status = nfs4_do_create(dir, dentry, data);
 
 	nfs4_free_createdata(data);
@@ -3395,12 +3428,13 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label l, *label = NULL;
 	int err;
 
 	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mknod(dir, dentry, sattr, rdev),
+				_nfs4_proc_mknod(dir, dentry, sattr, label, rdev),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -4358,7 +4392,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	if (status == 0)
 		nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
 	else
-		nfs_refresh_inode(inode, &data->fattr);
+		nfs_refresh_inode(inode, &data->fattr, NULL);
 out:
 	rpc_put_task(task);
 	return status;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 50a88c3..b4ae668 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -131,7 +131,7 @@ nfs_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_GETATTR],
@@ -179,7 +179,8 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int
 nfs_proc_lookup(struct inode *dir, struct qstr *name,
-		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+		struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		struct nfs4_label *label)
 {
 	struct nfs_diropargs	arg = {
 		.fh		= NFS_FH(dir),
@@ -276,7 +277,7 @@ nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	nfs_free_createdata(data);
 out:
 	dprintk("NFS reply create: %d\n", status);
@@ -323,7 +324,7 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	}
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	nfs_free_createdata(data);
 out:
 	dprintk("NFS reply mknod: %d\n", status);
@@ -479,7 +480,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	 * should fill in the data with a LOOKUP call on the wire.
 	 */
 	if (status == 0)
-		status = nfs_instantiate(dentry, fh, fattr);
+		status = nfs_instantiate(dentry, fh, fattr, NULL);
 
 out_free:
 	nfs_free_fattr(fattr);
@@ -508,7 +509,7 @@ nfs_proc_mkdir(struct inode *dir, struct dentry *dentry, struct iattr *sattr)
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	nfs_free_createdata(data);
 out:
 	dprintk("NFS reply mkdir: %d\n", status);
@@ -647,7 +648,7 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	nfs_invalidate_atime(inode);
 	if (task->tk_status >= 0) {
-		nfs_refresh_inode(inode, data->res.fattr);
+		nfs_refresh_inode(inode, data->res.fattr, data->res.label);
 		/* Emulate the eof flag, which isn't normally needed in NFSv2
 		 * as it is guaranteed to always return the file attributes
 		 */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 37a862c..c8ace0d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -328,9 +328,9 @@ extern void nfs_zap_mapping(struct inode *inode, struct address_space *mapping);
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
 extern void nfs_access_add_cache(struct inode *, struct nfs_access_entry *);
@@ -460,7 +460,8 @@ extern const struct file_operations nfs_dir_operations;
 extern const struct dentry_operations nfs_dentry_operations;
 
 extern void nfs_force_lookup_revalidate(struct inode *dir);
-extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh, struct nfs_fattr *fattr);
+extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh,
+			struct nfs_fattr *fattr, struct nfs4_label *label);
 extern int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags);
 extern void nfs_access_zap_cache(struct inode *inode);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7e9347a..31268c0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1402,11 +1402,12 @@ struct nfs_rpc_ops {
 	struct dentry *(*try_mount) (int, const char *, struct nfs_mount_info *,
 				     struct nfs_subversion *);
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
-- 
1.7.11.7

