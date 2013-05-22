Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659Ab3EVQu7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 12:50:59 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 09/13] NFS:Add labels to client function prototypes
Date: Wed, 22 May 2013 12:50:42 -0400
Message-Id: <1369241446-7680-10-git-send-email-SteveD@redhat.com>
In-Reply-To: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
References: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

>From David Quigley <dpquigl@davequigley.com>

After looking at all of the nfsv4 operations the label structure has been added
to the prototypes of the functions which can transmit label data.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/client.c         |  2 +-
 fs/nfs/dir.c            | 19 +++++-----
 fs/nfs/getroot.c        |  2 +-
 fs/nfs/inode.c          |  5 +--
 fs/nfs/namespace.c      |  2 +-
 fs/nfs/nfs3proc.c       |  7 ++--
 fs/nfs/nfs4proc.c       | 94 ++++++++++++++++++++++++++++++++-----------------
 fs/nfs/proc.c           | 13 +++----
 include/linux/nfs_fs.h  |  5 +--
 include/linux/nfs_xdr.h |  5 +--
 10 files changed, 95 insertions(+), 59 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c513b0c..c426528 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1076,7 +1076,7 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	}
 
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
-		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr);
+		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr, NULL);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..e9ab2cd 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -460,7 +460,7 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 	if (dentry == NULL)
 		return;
 
-	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr);
+	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr, entry->label);
 	if (IS_ERR(inode))
 		goto out;
 
@@ -1040,6 +1040,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	struct dentry *parent;
 	struct nfs_fh *fhandle = NULL;
 	struct nfs_fattr *fattr = NULL;
+	struct nfs4_label *label = NULL;
 	int error;
 
 	if (flags & LOOKUP_RCU)
@@ -1082,7 +1083,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
 	if (error)
 		goto out_bad;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
@@ -1256,6 +1257,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	struct inode *inode = NULL;
 	struct nfs_fh *fhandle = NULL;
 	struct nfs_fattr *fattr = NULL;
+	struct nfs4_label *label = NULL;
 	int error;
 
 	dfprintk(VFS, "NFS: lookup(%s/%s)\n",
@@ -1285,14 +1287,14 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
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
@@ -1528,7 +1530,8 @@ no_open:
  * Code common to create, mkdir, and mknod.
  */
 int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
-				struct nfs_fattr *fattr)
+				struct nfs_fattr *fattr,
+				struct nfs4_label *label)
 {
 	struct dentry *parent = dget_parent(dentry);
 	struct inode *dir = parent->d_inode;
@@ -1541,18 +1544,18 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
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
index 44efaa8..66984a9 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -95,7 +95,7 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 		goto out;
 	}
 
-	inode = nfs_fhget(sb, mntfh, fsinfo.fattr);
+	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, NULL);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
 		ret = ERR_CAST(inode);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 07fcf0b..58e7bf8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -290,7 +290,7 @@ EXPORT_SYMBOL_GPL(nfs4_label_alloc);
  * instead of inode number.
  */
 struct inode *
-nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
+nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_find_desc desc = {
 		.fh	= fh,
@@ -818,6 +818,7 @@ int
 __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
 	int		 status = -ESTALE;
+	struct nfs4_label *label = NULL;
 	struct nfs_fattr *fattr = NULL;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -835,7 +836,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
-	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr);
+	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
 			 inode->i_sb->s_id,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index fc8dc20..348b535 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -280,7 +280,7 @@ struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
 	struct dentry *parent = dget_parent(dentry);
 
 	/* Look it up again to get its attributes */
-	err = server->nfs_client->rpc_ops->lookup(parent->d_inode, &dentry->d_name, fh, fattr);
+	err = server->nfs_client->rpc_ops->lookup(parent->d_inode, &dentry->d_name, fh, fattr, NULL);
 	dput(parent);
 	if (err != 0)
 		return ERR_PTR(err);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 43ea96c..39c185b 100644
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
@@ -300,7 +301,7 @@ static int nfs3_do_create(struct inode *dir, struct dentry *dentry, struct nfs3_
 	status = rpc_call_sync(NFS_CLIENT(dir), &data->msg, 0);
 	nfs_post_op_update_inode(dir, data->res.dir_attr);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	return status;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bcf60f1..004de20 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -77,11 +77,12 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
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
@@ -762,6 +763,7 @@ struct nfs4_opendata {
 	struct nfs4_string owner_name;
 	struct nfs4_string group_name;
 	struct nfs_fattr f_attr;
+	struct nfs4_label *f_label;
 	struct dentry *dir;
 	struct dentry *dentry;
 	struct nfs4_state_owner *owner;
@@ -807,6 +809,7 @@ nfs4_map_atomic_open_claim(struct nfs_server *server,
 static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 {
 	p->o_res.f_attr = &p->f_attr;
+	p->o_res.f_label = p->f_label;
 	p->o_res.seqid = p->o_arg.seqid;
 	p->c_res.seqid = p->c_arg.seqid;
 	p->o_res.server = p->o_arg.server;
@@ -818,6 +821,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 		struct nfs4_state_owner *sp, fmode_t fmode, int flags,
 		const struct iattr *attrs,
+		struct nfs4_label *label,
 		enum open_claim_type4 claim,
 		gfp_t gfp_mask)
 {
@@ -854,6 +858,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
+	p->o_arg.label = label;
 	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
 	switch (p->o_arg.claim) {
 	case NFS4_OPEN_CLAIM_NULL:
@@ -1205,7 +1210,7 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 	ret = -EAGAIN;
 	if (!(data->f_attr.valid & NFS_ATTR_FATTR))
 		goto err;
-	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr);
+	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr, data->f_label);
 	ret = PTR_ERR(inode);
 	if (IS_ERR(inode))
 		goto err;
@@ -1258,7 +1263,7 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 	struct nfs4_opendata *opendata;
 
 	opendata = nfs4_opendata_alloc(ctx->dentry, state->owner, 0, 0,
-			NULL, claim, GFP_NOFS);
+			NULL, NULL, claim, GFP_NOFS);
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
@@ -1784,7 +1789,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 			return status;
 	}
 	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
-		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr);
+		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
 	return 0;
 }
 
@@ -1982,6 +1987,7 @@ static int _nfs4_do_open(struct inode *dir,
 			fmode_t fmode,
 			int flags,
 			struct iattr *sattr,
+			struct nfs4_label *label,
 			struct rpc_cred *cred,
 			struct nfs4_state **res,
 			struct nfs4_threshold **ctx_th)
@@ -1991,6 +1997,7 @@ static int _nfs4_do_open(struct inode *dir,
 	struct nfs_server       *server = NFS_SERVER(dir);
 	struct nfs4_opendata *opendata;
 	enum open_claim_type4 claim = NFS4_OPEN_CLAIM_NULL;
+	struct nfs4_label *olabel = NULL;
 	int status;
 
 	/* Protect against reboot recovery conflicts */
@@ -2009,7 +2016,7 @@ static int _nfs4_do_open(struct inode *dir,
 	if (dentry->d_inode)
 		claim = NFS4_OPEN_CLAIM_FH;
 	opendata = nfs4_opendata_alloc(dentry, sp, fmode, flags, sattr,
-			claim, GFP_KERNEL);
+			label, claim, GFP_KERNEL);
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
@@ -2033,10 +2040,11 @@ static int _nfs4_do_open(struct inode *dir,
 		nfs_fattr_init(opendata->o_res.f_attr);
 		status = nfs4_do_setattr(state->inode, cred,
 				opendata->o_res.f_attr, sattr,
-				state);
-		if (status == 0)
+				state, label, olabel);
+		if (status == 0) {
 			nfs_setattr_update_inode(state->inode, sattr);
-		nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
+			nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr);
+		}
 	}
 
 	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server))
@@ -2065,6 +2073,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 					fmode_t fmode,
 					int flags,
 					struct iattr *sattr,
+					struct nfs4_label *label,
 					struct rpc_cred *cred,
 					struct nfs4_threshold **ctx_th)
 {
@@ -2075,7 +2084,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 
 	fmode &= FMODE_READ|FMODE_WRITE|FMODE_EXEC;
 	do {
-		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred,
+		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, label, cred,
 				       &res, ctx_th);
 		if (status == 0)
 			break;
@@ -2122,7 +2131,8 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 
 static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
-			    struct nfs4_state *state)
+			    struct nfs4_state *state, struct nfs4_label *ilabel,
+			    struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
         struct nfs_setattrargs  arg = {
@@ -2130,9 +2140,11 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
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
@@ -2172,7 +2184,8 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			   struct nfs_fattr *fattr, struct iattr *sattr,
-			   struct nfs4_state *state)
+			   struct nfs4_state *state, struct nfs4_label *ilabel,
+			   struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = {
@@ -2181,7 +2194,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	};
 	int err;
 	do {
-		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state);
+		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
 			if (!(sattr->ia_valid & ATTR_SIZE)) {
@@ -2426,9 +2439,10 @@ static struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
 	struct nfs4_state *state;
+	struct nfs4_label *label = NULL;
 
 	/* Protect against concurrent sillydeletes */
-	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr,
+	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr, label,
 			     ctx->cred, &ctx->mdsthreshold);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
@@ -2648,6 +2662,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 {
 	int error;
 	struct nfs_fattr *fattr = info->fattr;
+	struct nfs4_label *label = NULL;
 
 	error = nfs4_server_capabilities(server, mntfh);
 	if (error < 0) {
@@ -2655,7 +2670,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 		return error;
 	}
 
-	error = nfs4_proc_getattr(server, mntfh, fattr);
+	error = nfs4_proc_getattr(server, mntfh, fattr, label);
 	if (error < 0) {
 		dprintk("nfs4_get_root: getattr error = %d\n", -error);
 		return error;
@@ -2711,7 +2726,8 @@ out:
 	return status;
 }
 
-static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
+				struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs4_getattr_arg args = {
 		.fh = fhandle,
@@ -2719,6 +2735,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	struct nfs4_getattr_res res = {
 		.fattr = fattr,
+		.label = label,
 		.server = server,
 	};
 	struct rpc_message msg = {
@@ -2731,13 +2748,14 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
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
@@ -2793,7 +2811,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		}
 	}
 
-	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, NULL);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr);
 	return status;
@@ -2801,7 +2819,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 		const struct qstr *name, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	int		       status;
@@ -2839,13 +2857,13 @@ static void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr)
 
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
@@ -2879,12 +2897,13 @@ out:
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
@@ -2899,7 +2918,7 @@ nfs4_proc_lookup_mountpoint(struct inode *dir, struct qstr *name,
 	int status;
 	struct rpc_clnt *client = rpc_clone_client(NFS_CLIENT(dir));
 
-	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr);
+	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr, NULL);
 	if (status < 0) {
 		rpc_shutdown_client(client);
 		return ERR_PTR(status);
@@ -3029,6 +3048,7 @@ static int
 nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		 int flags)
 {
+	struct nfs4_label *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
 	int status = 0;
@@ -3039,7 +3059,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 
 	sattr->ia_mode &= ~current_umask();
 	state = nfs4_do_open(dir, dentry, ctx->mode,
-			flags, sattr, ctx->cred,
+			flags, sattr, ilabel, ctx->cred,
 			&ctx->mdsthreshold);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
@@ -3207,6 +3227,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	};
 	struct nfs4_link_res res = {
 		.server = server,
+		.label = NULL,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LINK],
@@ -3247,6 +3268,7 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
+	struct nfs4_label *label;
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -3270,6 +3292,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
+		data->res.label = data->label;
 		nfs_fattr_init(data->res.fattr);
 	}
 	return data;
@@ -3281,7 +3304,7 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, data->res.label);
 	}
 	return status;
 }
@@ -3292,7 +3315,8 @@ static void nfs4_free_createdata(struct nfs4_createdata *data)
 }
 
 static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
-		struct page *page, unsigned int len, struct iattr *sattr)
+		struct page *page, unsigned int len, struct iattr *sattr,
+		struct nfs4_label *label)
 {
 	struct nfs4_createdata *data;
 	int status = -ENAMETOOLONG;
@@ -3308,6 +3332,7 @@ static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 	data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SYMLINK];
 	data->arg.u.symlink.pages = &page;
 	data->arg.u.symlink.len = len;
+	data->arg.label = label;
 	
 	status = nfs4_do_create(dir, dentry, data);
 
@@ -3320,18 +3345,19 @@ static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label *label = NULL;
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
@@ -3340,6 +3366,7 @@ static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 	if (data == NULL)
 		goto out;
 
+	data->arg.label = label;
 	status = nfs4_do_create(dir, dentry, data);
 
 	nfs4_free_createdata(data);
@@ -3351,12 +3378,13 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
+	struct nfs4_label *label = NULL;
 	int err;
 
 	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mkdir(dir, dentry, sattr),
+				_nfs4_proc_mkdir(dir, dentry, sattr, label),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -3441,7 +3469,7 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		status = -EINVAL;
 		goto out_free;
 	}
-	
+
 	status = nfs4_do_create(dir, dentry, data);
 out_free:
 	nfs4_free_createdata(data);
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index fc8de90..c041c41 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -98,7 +98,7 @@ nfs_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+		struct nfs_fattr *fattr, struct nfs4_label *label)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_GETATTR],
@@ -146,7 +146,8 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 static int
 nfs_proc_lookup(struct inode *dir, struct qstr *name,
-		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+		struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		struct nfs4_label *label)
 {
 	struct nfs_diropargs	arg = {
 		.fh		= NFS_FH(dir),
@@ -243,7 +244,7 @@ nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	nfs_free_createdata(data);
 out:
 	dprintk("NFS reply create: %d\n", status);
@@ -290,7 +291,7 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	}
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	nfs_free_createdata(data);
 out:
 	dprintk("NFS reply mknod: %d\n", status);
@@ -442,7 +443,7 @@ nfs_proc_symlink(struct inode *dir, struct dentry *dentry, struct page *page,
 	 * should fill in the data with a LOOKUP call on the wire.
 	 */
 	if (status == 0)
-		status = nfs_instantiate(dentry, fh, fattr);
+		status = nfs_instantiate(dentry, fh, fattr, NULL);
 
 out_free:
 	nfs_free_fattr(fattr);
@@ -471,7 +472,7 @@ nfs_proc_mkdir(struct inode *dir, struct dentry *dentry, struct iattr *sattr)
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 	if (status == 0)
-		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
+		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr, NULL);
 	nfs_free_createdata(data);
 out:
 	dprintk("NFS reply mkdir: %d\n", status);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 39b2404..3489015 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -336,7 +336,7 @@ extern void nfs_zap_mapping(struct inode *inode, struct address_space *mapping);
 extern void nfs_zap_caches(struct inode *);
 extern void nfs_invalidate_atime(struct inode *);
 extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
-				struct nfs_fattr *);
+				struct nfs_fattr *, struct nfs4_label *);
 extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
@@ -468,7 +468,8 @@ extern const struct file_operations nfs_dir_operations;
 extern const struct dentry_operations nfs_dentry_operations;
 
 extern void nfs_force_lookup_revalidate(struct inode *dir);
-extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh, struct nfs_fattr *fattr);
+extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh,
+			struct nfs_fattr *fattr, struct nfs4_label *label);
 extern int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags);
 extern void nfs_access_zap_cache(struct inode *inode);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a454d83..59a42db 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1379,11 +1379,12 @@ struct nfs_rpc_ops {
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
1.8.1.4

