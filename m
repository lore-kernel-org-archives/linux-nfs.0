From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 26/85] nfs41: introduce nfs4_call_sync
Date: Mon, 10 Nov 2008 22:22:35 +0200
Message-ID: <1226348555-8056-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48766 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbYKJUWl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:22:41 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use nfs4_call_sync rather than rpc_call_sync to provide
for a nfs41 sessions-enabled interface for sessions manipulation.

The nfs41 rpc logic uses the rpc_call_validate_args method to
recover and create the session, as well as selecting a free slot id
and the rpc_call_done to free the slot and update slot table
related metadata.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |  127 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 96 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1cc639e..3b7c7fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -349,6 +349,19 @@ nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
 
 #endif /* CONFIG_NFS_V4_1 */
 
+static int _nfs4_call_sync(struct nfs_server *server,
+			   struct rpc_message *msg,
+			   struct nfs41_sequence_args *args,
+			   struct nfs41_sequence_res *res,
+			   int cache_reply)
+{
+	return rpc_call_sync(server->client, msg, 0);
+}
+
+#define nfs4_call_sync(server, msg, args, res, cache_reply) \
+       _nfs4_call_sync((server), (msg), &(args)->seq_args, \
+                       &(res)->seq_res, (cache_reply))
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
@@ -1318,7 +1331,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	return status;
@@ -1620,15 +1633,19 @@ out_drop:
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
+	struct nfs4_server_caps_arg args = {
+		.fhandle = fhandle,
+	};
 	struct nfs4_server_caps_res res = {};
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_SERVER_CAPS),
-		.rpc_argp = fhandle,
+		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
 	int status;
 
-	status = rpc_call_sync(server->client, &msg, 0);
+	dprintk("--> %s\n", __func__);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
@@ -1639,6 +1656,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_SYMLINKS;
 		server->acl_bitmask = res.acl_bitmask;
 	}
+
+	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
 
@@ -1670,8 +1689,13 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	int status;
+
+	dprintk("--> %s\n", __func__);
 	nfs_fattr_init(info->fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	dprintk("<-- %s status= %d\n", __func__, status);
+	return status;
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -1759,9 +1783,12 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	int status;
 	
 	nfs_fattr_init(fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+
+	return status;
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
@@ -1843,10 +1870,10 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	};
 
 	nfs_fattr_init(fattr);
-
 	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	dprintk("NFS reply lookupfh: %d\n", status);
+
 	return status;
 }
 
@@ -1931,7 +1958,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 			args.access |= NFS4_ACCESS_EXECUTE;
 	}
 	nfs_fattr_init(&fattr);
-	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (!status) {
 		entry->mask = 0;
 		if (res.access & NFS4_ACCESS_READ)
@@ -1991,13 +2018,17 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.pglen    = pglen,
 		.pages    = &page,
 	};
+	struct nfs4_readlink_res res;
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_READLINK),
 		.rpc_argp = &args,
-		.rpc_resp = NULL,
+		.rpc_resp = &res,
 	};
+	int status;
+
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 
-	return rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	return status;
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -2090,11 +2121,12 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	int			status;
 
 	nfs_fattr_init(&res.dir_attr);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, &res.dir_attr);
 	}
+
 	return status;
 }
 
@@ -2158,14 +2190,14 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	
 	nfs_fattr_init(res.old_fattr);
 	nfs_fattr_init(res.new_fattr);
-	status = rpc_call_sync(server->client, &msg, 0);
-
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		nfs_post_op_update_inode(old_dir, res.old_fattr);
 		update_changeattr(new_dir, &res.new_cinfo);
 		nfs_post_op_update_inode(new_dir, res.new_fattr);
 	}
+
 	return status;
 }
 
@@ -2207,7 +2239,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 
 	nfs_fattr_init(res.fattr);
 	nfs_fattr_init(res.dir_attr);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2269,7 +2301,9 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
-	int status = rpc_call_sync(NFS_CLIENT(dir), &data->msg, 0);
+	struct nfs_server *server = NFS_SERVER(dir);
+	int status = nfs4_call_sync(server, &data->msg,
+				    &data->arg, &data->res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
 		nfs_post_op_update_inode(dir, data->res.dir_fattr);
@@ -2378,12 +2412,14 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			(unsigned long long)cookie);
+
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
-	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (status == 0)
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
 
+
 	nfs_invalidate_atime(dir);
 
 	dprintk("%s: returns %d\n", __func__, status);
@@ -2458,14 +2494,20 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 		.fh = fhandle,
 		.bitmask = server->attr_bitmask,
 	};
+	struct nfs4_statfs_res res = {
+		.fsstat = fsstat,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_STATFS),
 		.rpc_argp = &args,
-		.rpc_resp = fsstat,
+		.rpc_resp = &res,
 	};
+	int status;
 
 	nfs_fattr_init(fsstat->fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	status =  nfs4_call_sync(server, &msg, &args, &res, 0);
+
+	return status;
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -2487,13 +2529,21 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.fh = fhandle,
 		.bitmask = server->attr_bitmask,
 	};
+	struct nfs4_fsinfo_res res = {
+		.fsinfo = fsinfo,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_FSINFO),
 		.rpc_argp = &args,
-		.rpc_resp = fsinfo,
+		.rpc_resp = &res,
 	};
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 
-	return rpc_call_sync(server->client, &msg, 0);
+	dprintk("<-- %s status= %d\n", __func__, status);
+	return status;
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -2522,20 +2572,28 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 		.fh = fhandle,
 		.bitmask = server->attr_bitmask,
 	};
+	struct nfs4_pathconf_res res = {
+		.pathconf = pathconf,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_PATHCONF),
 		.rpc_argp = &args,
-		.rpc_resp = pathconf,
+		.rpc_resp = &res,
 	};
+	int status = 0;
 
+	dprintk("--> %s\n", __func__);
 	/* None of the pathconf attributes are mandatory to implement */
 	if ((args.bitmask[0] & nfs4_pathconf_bitmap[0]) == 0) {
 		memset(pathconf, 0, sizeof(*pathconf));
-		return 0;
+		goto out;
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+out:
+	dprintk("<-- %s status= %d\n", __func__, status);
+	return status;
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -2778,18 +2836,21 @@ out:
 static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
 	struct page *pages[NFS4ACL_MAXPAGES];
+	size_t resp_len = buflen;
 	struct nfs_getaclargs args = {
 		.fh = NFS_FH(inode),
 		.acl_pages = pages,
 		.acl_len = buflen,
 	};
-	size_t resp_len = buflen;
+	struct nfs_getaclres res = {
+		.acl_len = &resp_len,
+	};
 	void *resp_buf;
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_GETACL),
 		.rpc_argp = &args,
-		.rpc_resp = &resp_len,
+		.rpc_resp = &res,
 	};
 	struct page *localpage = NULL;
 	int ret;
@@ -2808,7 +2869,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
 	}
-	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	ret = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (ret)
 		goto out_free;
 	if (resp_len > args.acl_len)
@@ -2869,10 +2930,11 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		.acl_pages	= pages,
 		.acl_len	= buflen,
 	};
+	struct nfs_setaclres res;
 	struct rpc_message msg = {
 		.rpc_proc	= nfs4_proc(server->nfs_client, NFSPROC4_CLNT_SETACL),
 		.rpc_argp	= &arg,
-		.rpc_resp	= NULL,
+		.rpc_resp	= &res,
 	};
 	int ret;
 
@@ -2880,7 +2942,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		return -EOPNOTSUPP;
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
-	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
 	return ret;
@@ -3240,7 +3302,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -3808,10 +3870,13 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		.page = page,
 		.bitmask = bitmask,
 	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations = fs_locations,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_FS_LOCATIONS),
 		.rpc_argp = &args,
-		.rpc_resp = fs_locations,
+		.rpc_resp = &res,
 	};
 	int status;
 
@@ -3819,7 +3884,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }
-- 
1.6.0.2

