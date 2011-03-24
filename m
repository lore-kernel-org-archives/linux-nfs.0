Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32249 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933899Ab1CXRM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 13:12:26 -0400
Message-ID: <4D8B7B78.3030108@netapp.com>
Date: Thu, 24 Mar 2011 13:12:24 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 2/5] NFS: lookup supports alternate client
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


A later patch will need to perform a lookup using an
alternate client with a different security flavor.
This patch adds support for doing that on NFS v4.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c            |    6 ++--
 fs/nfs/internal.h       |    6 ++-
 fs/nfs/namespace.c      |    2 +-
 fs/nfs/nfs3proc.c       |    2 +-
 fs/nfs/nfs4_fs.h        |    3 +-
 fs/nfs/nfs4proc.c       |   86 +++++++++++++++++++++++++---------------------
 fs/nfs/proc.c           |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 8 files changed, 60 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 901e9c0..7237672 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1135,7 +1135,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
 	if (error)
 		goto out_bad;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
@@ -1291,7 +1291,7 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
@@ -1629,7 +1629,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
 	if (dentry->d_inode)
 		goto out;
 	if (fhandle->size == 0) {
-		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+		error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
 		if (error)
 			goto out_error;
 	}
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f9bd8bd..86e717b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -310,12 +310,14 @@ extern int nfs4_init_client(struct nfs_client *clp,
 			    rpc_authflavor_t authflavour,
 			    int noresvport);
 extern void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data);
-extern int _nfs4_call_sync(struct nfs_server *server,
+extern int _nfs4_call_sync(struct rpc_clnt *clnt,
+			   struct nfs_server *server,
 			   struct rpc_message *msg,
 			   struct nfs4_sequence_args *args,
 			   struct nfs4_sequence_res *res,
 			   int cache_reply);
-extern int _nfs4_call_sync_session(struct nfs_server *server,
+extern int _nfs4_call_sync_session(struct rpc_clnt *clnt,
+				   struct nfs_server *server,
 				   struct rpc_message *msg,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index bf1c680..b027208 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -153,7 +153,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 
 	/* Look it up again to get its attributes */
 	parent = dget_parent(path->dentry);
-	err = server->nfs_client->rpc_ops->lookup(parent->d_inode,
+	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
 						  &path->dentry->d_name,
 						  fh, fattr);
 	dput(parent);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d0c80d8..38053d8 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -141,7 +141,7 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 }
 
 static int
-nfs3_proc_lookup(struct inode *dir, struct qstr *name,
+nfs3_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
 		 struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs3_diropargs	arg = {
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1e612d1..244c1bb 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -57,7 +57,8 @@ enum nfs4_session_state {
 struct nfs4_minor_version_ops {
 	u32	minor_version;
 
-	int	(*call_sync)(struct nfs_server *server,
+	int	(*call_sync)(struct rpc_clnt *clnt,
+			struct nfs_server *server,
 			struct rpc_message *msg,
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9acad79..ce3eff8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -71,7 +71,9 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
-static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int _nfs4_proc_lookup(struct rpc_clnt *client, struct inode *dir,
+			     const struct qstr *name, struct nfs_fh *fhandle,
+			     struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -657,7 +659,8 @@ struct rpc_call_ops nfs41_call_priv_sync_ops = {
 	.rpc_call_done = nfs41_call_sync_done,
 };
 
-static int nfs4_call_sync_sequence(struct nfs_server *server,
+static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
+				   struct nfs_server *server,
 				   struct rpc_message *msg,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
@@ -673,7 +676,7 @@ static int nfs4_call_sync_sequence(struct nfs_server *server,
 		.cache_reply = cache_reply,
 	};
 	struct rpc_task_setup task_setup = {
-		.rpc_client = server->client,
+		.rpc_client = clnt,
 		.rpc_message = msg,
 		.callback_ops = &nfs41_call_sync_ops,
 		.callback_data = &data
@@ -692,13 +695,14 @@ static int nfs4_call_sync_sequence(struct nfs_server *server,
 	return ret;
 }
 
-int _nfs4_call_sync_session(struct nfs_server *server,
+int _nfs4_call_sync_session(struct rpc_clnt *clnt,
+			    struct nfs_server *server,
 			    struct rpc_message *msg,
 			    struct nfs4_sequence_args *args,
 			    struct nfs4_sequence_res *res,
 			    int cache_reply)
 {
-	return nfs4_call_sync_sequence(server, msg, args, res, cache_reply, 0);
+	return nfs4_call_sync_sequence(clnt, server, msg, args, res, cache_reply, 0);
 }
 
 #else
@@ -709,25 +713,27 @@ static int nfs4_sequence_done(struct rpc_task *task,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-int _nfs4_call_sync(struct nfs_server *server,
+int _nfs4_call_sync(struct rpc_clnt *clnt,
+		    struct nfs_server *server,
 		    struct rpc_message *msg,
 		    struct nfs4_sequence_args *args,
 		    struct nfs4_sequence_res *res,
 		    int cache_reply)
 {
 	args->sa_session = res->sr_session = NULL;
-	return rpc_call_sync(server->client, msg, 0);
+	return rpc_call_sync(clnt, msg, 0);
 }
 
 static inline
-int nfs4_call_sync(struct nfs_server *server,
+int nfs4_call_sync(struct rpc_clnt *clnt,
+		   struct nfs_server *server,
 		   struct rpc_message *msg,
 		   struct nfs4_sequence_args *args,
 		   struct nfs4_sequence_res *res,
 		   int cache_reply)
 {
-	return server->nfs_client->cl_mvops->call_sync(server, msg, args,
-						res, cache_reply);
+	return server->nfs_client->cl_mvops->call_sync(clnt, server, msg,
+						args, res, cache_reply);
 }
 
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
@@ -1838,7 +1844,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	return status;
@@ -2097,7 +2103,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	};
 	int status;
 
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
@@ -2167,7 +2173,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(info->fattr);
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -2256,7 +2262,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	
 	nfs_fattr_init(fattr);
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
@@ -2316,9 +2322,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	return status;
 }
 
-static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *dirfh,
-		const struct qstr *name, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr)
+static int _nfs4_proc_lookupfh(struct rpc_clnt *clnt, struct nfs_server *server,
+		const struct nfs_fh *dirfh, const struct qstr *name,
+		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	int		       status;
 	struct nfs4_lookup_arg args = {
@@ -2340,7 +2346,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply lookupfh: %d\n", status);
 	return status;
 }
@@ -2352,7 +2358,7 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs4_proc_lookupfh(server, dirfh, name, fhandle, fattr);
+		err = _nfs4_proc_lookupfh(server->client, server, dirfh, name, fhandle, fattr);
 		/* FIXME: !!!! */
 		if (err == -NFS4ERR_MOVED) {
 			err = -EREMOTE;
@@ -2363,26 +2369,28 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 	return err;
 }
 
-static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name,
-		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
+		const struct qstr *name, struct nfs_fh *fhandle,
+		struct nfs_fattr *fattr)
 {
 	int status;
 	
 	dprintk("NFS call  lookup %s\n", name->name);
-	status = _nfs4_proc_lookupfh(NFS_SERVER(dir), NFS_FH(dir), name, fhandle, fattr);
+	status = _nfs4_proc_lookupfh(clnt, NFS_SERVER(dir), NFS_FH(dir), name, fhandle, fattr);
 	if (status == -NFS4ERR_MOVED)
 		status = nfs4_get_referral(dir, name, fattr, fhandle);
 	dprintk("NFS reply lookup: %d\n", status);
 	return status;
 }
 
-static int nfs4_proc_lookup(struct inode *dir, struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_lookup(dir, name, fhandle, fattr),
+				_nfs4_proc_lookup(clnt, dir, name, fhandle, fattr),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -2428,7 +2436,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	if (res.fattr == NULL)
 		return -ENOMEM;
 
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		entry->mask = 0;
 		if (res.access & NFS4_ACCESS_READ)
@@ -2495,7 +2503,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -2584,7 +2592,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	if (res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2685,7 +2693,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	if (res.old_fattr == NULL || res.new_fattr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		nfs_post_op_update_inode(old_dir, res.old_fattr);
@@ -2736,7 +2744,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	if (res.fattr == NULL || res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2799,7 +2807,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
-	int status = nfs4_call_sync(NFS_SERVER(dir), &data->msg,
+	int status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &data->msg,
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
@@ -2912,7 +2920,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			(unsigned long long)cookie);
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
-	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
 	if (status >= 0) {
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
 		status += args.pgbase;
@@ -3004,7 +3012,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
-	return  nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return  nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -3035,7 +3043,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -3080,7 +3088,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -3469,7 +3477,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
 	}
-	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
+	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 	if (ret)
 		goto out_free;
 	if (res.acl_len > args.acl_len)
@@ -3544,7 +3552,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	if (i < 0)
 		return i;
 	nfs_inode_return_delegation(inode);
-	ret = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
 	 * Free each page after tx, so the only ref left is
@@ -3907,7 +3915,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
 	arg.lock_owner.s_dev = server->s_dev;
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -4635,7 +4643,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
@@ -5603,7 +5611,7 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 	int status;
 
 	dprintk("--> %s\n", __func__);
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	return status;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b8ec170..ac40b85 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -177,7 +177,7 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 }
 
 static int
-nfs_proc_lookup(struct inode *dir, struct qstr *name,
+nfs_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
 		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs_diropargs	arg = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 84f3585..87106ea 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1095,7 +1095,7 @@ struct nfs_rpc_ops {
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
-	int	(*lookup)  (struct inode *, struct qstr *,
+	int	(*lookup)  (struct rpc_clnt *clnt, struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*access)  (struct inode *, struct nfs_access_entry *);
 	int	(*readlink)(struct inode *, struct page *, unsigned int,
-- 
1.7.4.1

