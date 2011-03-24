Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32249 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933682Ab1CXRMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 13:12:25 -0400
Message-ID: <4D8B7B77.6080103@netapp.com>
Date: Thu, 24 Mar 2011 13:12:23 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 1/5] NFS: convert call_sync() to a function
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
index 6f2f402..9acad79 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -719,9 +719,16 @@ int _nfs4_call_sync(struct nfs_server *server,
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
@@ -1831,7 +1838,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	return status;
@@ -2090,7 +2097,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	};
 	int status;
 
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
@@ -2160,7 +2167,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(info->fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -2249,7 +2256,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	
 	nfs_fattr_init(fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
@@ -2333,7 +2340,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply lookupfh: %d\n", status);
 	return status;
 }
@@ -2421,7 +2428,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	if (res.fattr == NULL)
 		return -ENOMEM;
 
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		entry->mask = 0;
 		if (res.access & NFS4_ACCESS_READ)
@@ -2488,7 +2495,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
+	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -2577,7 +2584,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	if (res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &args, &res, 1);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2678,7 +2685,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	if (res.old_fattr == NULL || res.new_fattr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		nfs_post_op_update_inode(old_dir, res.old_fattr);
@@ -2729,7 +2736,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	if (res.fattr == NULL || res.dir_attr == NULL)
 		goto out;
 
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2793,7 +2800,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
 	int status = nfs4_call_sync(NFS_SERVER(dir), &data->msg,
-				    &data->arg, &data->res, 1);
+				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
 		nfs_post_op_update_inode(dir, data->res.dir_fattr);
@@ -2905,7 +2912,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			(unsigned long long)cookie);
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
-	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args, &res, 0);
+	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
 	if (status >= 0) {
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
 		status += args.pgbase;
@@ -2997,7 +3004,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
-	return  nfs4_call_sync(server, &msg, &args, &res, 0);
+	return  nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -3028,7 +3035,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -3073,7 +3080,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return nfs4_call_sync(server, &msg, &args, &res, 0);
+	return nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -3462,7 +3469,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
 	}
-	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
+	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
 	if (ret)
 		goto out_free;
 	if (res.acl_len > args.acl_len)
@@ -3537,7 +3544,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	if (i < 0)
 		return i;
 	nfs_inode_return_delegation(inode);
-	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	ret = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
 	 * Free each page after tx, so the only ref left is
@@ -3900,7 +3907,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
 	arg.lock_owner.s_dev = server->s_dev;
-	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	status = nfs4_call_sync(server, &msg, &arg.seq_args, &res.seq_res, 1);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -4628,7 +4635,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
@@ -5596,7 +5603,7 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 	int status;
 
 	dprintk("--> %s\n", __func__);
-	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	status = nfs4_call_sync(server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	return status;
-- 
1.7.4.1

