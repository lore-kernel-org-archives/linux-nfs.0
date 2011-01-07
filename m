Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42012 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136Ab1AGSwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Jan 2011 13:52:14 -0500
Message-ID: <4D2760DC.3090006@netapp.com>
Date: Fri, 07 Jan 2011 13:52:12 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH v4 2/5] NFS: lookup supports alternate client
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
 fs/nfs/nfs4proc.c       |   85 ++++++++++++++++++++++++++---------------------
 fs/nfs/proc.c           |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 8 files changed, 60 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 65d5cb4..3330c9c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1067,7 +1067,7 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
 	if (error)
 		goto out_bad;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
@@ -1212,7 +1212,7 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
@@ -1545,7 +1545,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
 	if (dentry->d_inode)
 		goto out;
 	if (fhandle->size == 0) {
-		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
+		error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
 		if (error)
 			goto out_error;
 	}
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index bfa3a34..367d898 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -274,7 +274,8 @@ extern int nfs_migrate_page(struct address_space *,
 #endif
 
 /* nfs4proc.c */
-extern int _nfs4_call_sync(struct nfs_server *server,
+extern int _nfs4_call_sync(struct rpc_clnt *clnt,
+			   struct nfs_server *server,
 			   struct rpc_message *msg,
 			   struct nfs4_sequence_args *args,
 			   struct nfs4_sequence_res *res,
@@ -283,7 +284,8 @@ extern int _nfs4_call_sync_session(struct nfs_server *server,
 				   struct rpc_message *msg,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
-				   int cache_reply);
+				   int cache_reply,
+				   struct rpc_clnt *alt_clnt);
 
 /*
  * Determine the device name as a string
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index db6aa36..3c361f8 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -127,7 +127,7 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 
 	/* Look it up again */
 	parent = dget_parent(nd->path.dentry);
-	err = server->nfs_client->rpc_ops->lookup(parent->d_inode,
+	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
 						  &nd->path.dentry->d_name,
 						  fh, fattr);
 	dput(parent);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index ce939c0..2b0e7c8 100644
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
index 7a74740..700c780 100644
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
index 41f0a06..53254f9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,7 +70,9 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
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
@@ -639,7 +641,8 @@ struct rpc_call_ops nfs41_call_priv_sync_ops = {
 	.rpc_call_done = nfs41_call_sync_done,
 };
 
-static int nfs4_call_sync_sequence(struct nfs_server *server,
+static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
+				   struct nfs_server *server,
 				   struct rpc_message *msg,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
@@ -655,7 +658,7 @@ static int nfs4_call_sync_sequence(struct nfs_server *server,
 		.cache_reply = cache_reply,
 	};
 	struct rpc_task_setup task_setup = {
-		.rpc_client = server->client,
+		.rpc_client = clnt,
 		.rpc_message = msg,
 		.callback_ops = &nfs41_call_sync_ops,
 		.callback_data = &data
@@ -664,6 +667,7 @@ static int nfs4_call_sync_sequence(struct nfs_server *server,
 	res->sr_slot = NULL;
 	if (privileged)
 		task_setup.callback_ops = &nfs41_call_priv_sync_ops;
+	task_setup.rpc_client = alt_clnt;
 	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
@@ -674,13 +678,14 @@ static int nfs4_call_sync_sequence(struct nfs_server *server,
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
+	return nfs4_call_sync_sequence(server, msg, args, res, cache_reply, 0, clnt);
 }
 
 #else
@@ -691,25 +696,27 @@ static int nfs4_sequence_done(struct rpc_task *task,
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
@@ -1817,7 +1824,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	return status;
@@ -2076,7 +2083,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	};
 	int status;
 
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
@@ -2146,7 +2153,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(info->fattr);
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -2235,7 +2242,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	
 	nfs_fattr_init(fattr);
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
@@ -2295,9 +2302,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
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
@@ -2319,7 +2326,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply lookupfh: %d\n", status);
 	return status;
 }
@@ -2331,7 +2338,7 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs4_proc_lookupfh(server, dirfh, name, fhandle, fattr);
+		err = _nfs4_proc_lookupfh(server->client, server, dirfh, name, fhandle, fattr);
 		/* FIXME: !!!! */
 		if (err == -NFS4ERR_MOVED) {
 			err = -EREMOTE;
@@ -2342,26 +2349,28 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
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
@@ -2407,7 +2416,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	if (res.fattr == NULL)
 		return -ENOMEM;
 
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		entry->mask = 0;
 		if (res.access & NFS4_ACCESS_READ)
@@ -2474,7 +2483,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -2563,7 +2572,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	if (res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2664,7 +2673,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	if (res.old_fattr == NULL || res.new_fattr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		nfs_post_op_update_inode(old_dir, res.old_fattr);
@@ -2715,7 +2724,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	if (res.fattr == NULL || res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2778,7 +2787,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
-	int status = nfs4_call_sync(NFS_SERVER(dir), &data->msg,
+	int status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &data->msg,
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
@@ -2891,7 +2900,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			(unsigned long long)cookie);
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
-	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
 	if (status >= 0) {
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
 		status += args.pgbase;
@@ -2983,7 +2992,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
-	return  nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return  nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -3014,7 +3023,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -3059,7 +3068,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -3359,7 +3368,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
 	}
-	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
+	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 	if (ret)
 		goto out_free;
 	if (res.acl_len > args.acl_len)
@@ -3432,7 +3441,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		return -EOPNOTSUPP;
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
-	ret = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	/*
 	 * Acl update can result in inode attribute update.
 	 * so mark the attribute cache invalid.
@@ -3787,7 +3796,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
 	arg.lock_owner.s_dev = server->s_dev;
-	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -4518,7 +4527,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 77d5e21..89ac23a 100644
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
index b006857..74c4e71 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1061,7 +1061,7 @@ struct nfs_rpc_ops {
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
-	int	(*lookup)  (struct inode *, struct qstr *,
+	int	(*lookup)  (struct rpc_clnt *clnt, struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*access)  (struct inode *, struct nfs_access_entry *);
 	int	(*readlink)(struct inode *, struct page *, unsigned int,
-- 
1.7.3.4

