Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab1AFV6l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 16:58:41 -0500
Message-ID: <4D263B0F.6040402@netapp.com>
Date: Thu, 06 Jan 2011 16:58:39 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 1/5] NFS: convert call_sync() to a function
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


This patch changes nfs4_call_sync() from a macro into a
static inline function.  As a macro, the call_sync()
function will not do any type checking and depends
on the sequence arguments always having the same name.
As a function, we get to have type checking and can
rename the arguments if we so choose.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   53 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f2b92f6..41f0a06 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -701,9 +701,16 @@ int _nfs4_call_sync(struct nfs_server *server,
 	return rpc_call_sync(server->client, msg, 0);
 }
 
-#define nfs4_call_sync(server, msg, args, res, cache_reply) \
-	(server)->nfs_client->cl_mvops->call_sync((server), (msg), &(args)->seq_args, \
-			&(res)->seq_res, (cache_reply))
+static inline
+int nfs4_call_sync(struct nfs_server *server,
+		   struct rpc_message *msg,
+		   struct nfs4_sequence_args *args,
+		   struct nfs4_sequence_res *res,
+		   int cache_reply)
+{
+	return server->nfs_client->cl_mvops->call_sync(server, msg, args,
+						res, cache_reply);
+}
 
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
@@ -1810,7 +1817,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	return status;
@@ -2069,7 +2076,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	};
 	int status;
 
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
@@ -2139,7 +2146,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(info->fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -2228,7 +2235,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	
 	nfs_fattr_init(fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
@@ -2312,7 +2319,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply lookupfh: %d\n", status);
 	return status;
 }
@@ -2400,7 +2407,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	if (res.fattr == NULL)
 		return -ENOMEM;
 
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		entry->mask = 0;
 		if (res.access & NFS4_ACCESS_READ)
@@ -2467,7 +2474,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
+	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -2556,7 +2563,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	if (res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &args, &res, 1);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2657,7 +2664,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	if (res.old_fattr == NULL || res.new_fattr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		nfs_post_op_update_inode(old_dir, res.old_fattr);
@@ -2708,7 +2715,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	if (res.fattr == NULL || res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2772,7 +2779,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
 	int status = nfs4_call_sync(NFS_SERVER(dir), &data->msg,
-				    &data->arg, &data->res, 1);
+				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
 		nfs_post_op_update_inode(dir, data->res.dir_fattr);
@@ -2884,7 +2891,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			(unsigned long long)cookie);
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
-	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args, &res, 0);
+	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
 	if (status >= 0) {
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
 		status += args.pgbase;
@@ -2976,7 +2983,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
-	return  nfs4_call_sync(server, &msg, &args, &res, 0);
+	return  nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -3007,7 +3014,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -3052,7 +3059,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -3352,7 +3359,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
 	}
-	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
+	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 	if (ret)
 		goto out_free;
 	if (res.acl_len > args.acl_len)
@@ -3425,7 +3432,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		return -EOPNOTSUPP;
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
-	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	ret = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	/*
 	 * Acl update can result in inode attribute update.
 	 * so mark the attribute cache invalid.
@@ -3780,7 +3787,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
 	arg.lock_owner.s_dev = server->s_dev;
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -4511,7 +4518,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
@@ -5434,7 +5441,7 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 	int status;
 
 	dprintk("--> %s\n", __func__);
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	return status;
-- 
1.7.3.4

