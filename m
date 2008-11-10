From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 13/85] nfs41: use ptr to rpc procedures via struct nfs_client
Date: Mon, 10 Nov 2008 22:20:05 +0200
Message-ID: <1226348405-7533-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60736 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbYKJUUO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:20:14 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support heterogenuous mount minor version, use the ptr to the effective
rpc procedures table via nfs_client->cl_rpcclient->cl_procinfo rather than
a global one.

nfs4_proc() is a static inline helper to get the rpc procedure
given a struct nfs_client * and the procedure index.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h         |    5 ---
 fs/nfs/nfs4_fs.h          |    1 -
 fs/nfs/nfs4proc.c         |   88 ++++++++++++++++++++++++++-------------------
 fs/nfs/nfs4xdr.c          |   22 +++++++++--
 include/linux/nfs_fs_sb.h |    9 +++++
 include/linux/nfs_xdr.h   |    3 ++
 6 files changed, 81 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b423422..8386e99 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -134,11 +134,6 @@ extern __be32 *nfs3_decode_dirent(__be32 *, struct nfs_entry *, int);
 extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
 #endif
 
-/* nfs4proc.c */
-#ifdef CONFIG_NFS_V4
-extern struct rpc_procinfo nfs4_procedures[];
-#endif
-
 /* dir.c */
 extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea79064..5fb7382 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -226,7 +226,6 @@ extern const nfs4_stateid zero_stateid;
 
 /* nfs4xdr.c */
 extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
-extern struct rpc_procinfo nfs4_procedures[];
 
 struct nfs4_mount_data;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0256c97..ef3370f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -762,7 +762,8 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	struct nfs_server *server = NFS_SERVER(data->dir->d_inode);
 	struct rpc_task *task;
 	struct  rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_CONFIRM],
+		.rpc_proc = nfs4_proc(server->nfs_client,
+				      NFSPROC4_CLNT_OPEN_CONFIRM),
 		.rpc_argp = &data->c_arg,
 		.rpc_resp = &data->c_res,
 		.rpc_cred = data->owner->so_cred,
@@ -823,7 +824,8 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	data->o_arg.id = sp->so_owner_id.id;
 	data->o_arg.clientid = sp->so_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
-		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
+		task->tk_msg.rpc_proc = nfs4_proc(sp->so_client,
+						  NFSPROC4_CLNT_OPEN_NOATTR);
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
@@ -899,7 +901,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	struct nfs_openres *o_res = &data->o_res;
 	struct rpc_task *task;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_OPEN),
 		.rpc_argp = o_arg,
 		.rpc_resp = o_res,
 		.rpc_cred = data->owner->so_cred,
@@ -1153,7 +1155,8 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		.server		= server,
         };
         struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
+                .rpc_proc       = nfs4_proc(server->nfs_client,
+					    NFSPROC4_CLNT_SETATTR),
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred,
@@ -1271,10 +1274,12 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	}
 	nfs_fattr_init(calldata->res.fattr);
 	if (test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0) {
-		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
+		task->tk_msg.rpc_proc = nfs4_proc(state->owner->so_client,
+						  NFSPROC4_CLNT_OPEN_DOWNGRADE);
 		calldata->arg.open_flags = FMODE_READ;
 	} else if (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0) {
-		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
+		task->tk_msg.rpc_proc = nfs4_proc(state->owner->so_client,
+						  NFSPROC4_CLNT_OPEN_DOWNGRADE);
 		calldata->arg.open_flags = FMODE_WRITE;
 	}
 	calldata->timestamp = jiffies;
@@ -1305,7 +1310,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	struct nfs4_state_owner *sp = state->owner;
 	struct rpc_task *task;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE],
+		.rpc_proc = nfs4_proc(sp->so_client, NFSPROC4_CLNT_CLOSE),
 		.rpc_cred = state->owner->so_cred,
 	};
 	struct rpc_task_setup task_setup_data = {
@@ -1472,7 +1477,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 {
 	struct nfs4_server_caps_res res = {};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SERVER_CAPS],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_SERVER_CAPS),
 		.rpc_argp = fhandle,
 		.rpc_resp = &res,
 	};
@@ -1516,7 +1521,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.fh = fhandle,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOOKUP_ROOT],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_LOOKUP_ROOT),
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
@@ -1605,7 +1610,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		.server = server,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETATTR],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_GETATTR),
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
@@ -1687,7 +1692,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 		.fh = fhandle,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOOKUP],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_LOOKUP),
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
@@ -1756,7 +1761,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		.fattr = &fattr,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_ACCESS),
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 		.rpc_cred = entry->cred,
@@ -1834,6 +1839,7 @@ static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		unsigned int pgbase, unsigned int pglen)
 {
+	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_readlink args = {
 		.fh       = NFS_FH(inode),
 		.pgbase	  = pgbase,
@@ -1841,7 +1847,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.pages    = &page,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READLINK],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_READLINK),
 		.rpc_argp = &args,
 		.rpc_resp = NULL,
 	};
@@ -1932,7 +1938,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 		.server = server,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_REMOVE),
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
@@ -1967,7 +1973,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 	args->bitmask = server->attr_bitmask;
 	res->server = server;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
+	msg->rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_REMOVE);
 }
 
 static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
@@ -1999,7 +2005,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_fattr = &new_fattr,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_RENAME),
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
@@ -2048,7 +2054,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 		.dir_attr = &dir_attr,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LINK],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_LINK),
 		.rpc_argp = &arg,
 		.rpc_resp = &res,
 	};
@@ -2096,7 +2102,8 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 	if (data != NULL) {
 		struct nfs_server *server = NFS_SERVER(dir);
 
-		data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE];
+		data->msg.rpc_proc = nfs4_proc(server->nfs_client,
+					       NFSPROC4_CLNT_CREATE);
 		data->msg.rpc_argp = &data->arg;
 		data->msg.rpc_resp = &data->res;
 		data->arg.dir_fh = NFS_FH(dir);
@@ -2145,7 +2152,8 @@ static int _nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 	if (data == NULL)
 		goto out;
 
-	data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SYMLINK];
+	data->msg.rpc_proc = nfs4_proc(NFS_SERVER(dir)->nfs_client,
+				       NFSPROC4_CLNT_SYMLINK);
 	data->arg.u.symlink.pages = &page;
 	data->arg.u.symlink.len = len;
 	
@@ -2204,6 +2212,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
                   u64 cookie, struct page *page, unsigned int count, int plus)
 {
 	struct inode		*dir = dentry->d_inode;
+	struct nfs_server	*server = NFS_SERVER(dir);
 	struct nfs4_readdir_arg args = {
 		.fh = NFS_FH(dir),
 		.pages = &page,
@@ -2213,7 +2222,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 	};
 	struct nfs4_readdir_res res;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READDIR],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_READDIR),
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 		.rpc_cred = cred,
@@ -2305,7 +2314,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 		.bitmask = server->attr_bitmask,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_STATFS],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_STATFS),
 		.rpc_argp = &args,
 		.rpc_resp = fsstat,
 	};
@@ -2334,7 +2343,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.bitmask = server->attr_bitmask,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FSINFO],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_FSINFO),
 		.rpc_argp = &args,
 		.rpc_resp = fsinfo,
 	};
@@ -2369,7 +2378,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 		.bitmask = server->attr_bitmask,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PATHCONF],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_PATHCONF),
 		.rpc_argp = &args,
 		.rpc_resp = pathconf,
 	};
@@ -2415,8 +2424,10 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
+	struct nfs_server *server = NFS_SERVER(data->inode);
+
 	data->timestamp   = jiffies;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+	msg->rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_READ);
 }
 
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -2442,7 +2453,7 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
+	msg->rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_WRITE);
 }
 
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -2463,7 +2474,7 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 	
 	data->args.bitmask = server->attr_bitmask;
 	data->res.server = server;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
+	msg->rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_COMMIT);
 }
 
 /*
@@ -2497,7 +2508,7 @@ static const struct rpc_call_ops nfs4_renew_ops = {
 int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
+		.rpc_proc	= nfs4_proc(clp, NFSPROC4_CLNT_RENEW),
 		.rpc_argp	= clp,
 		.rpc_cred	= cred,
 	};
@@ -2509,7 +2520,7 @@ int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
 int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
+		.rpc_proc	= nfs4_proc(clp, NFSPROC4_CLNT_RENEW),
 		.rpc_argp	= clp,
 		.rpc_cred	= cred,
 	};
@@ -2629,8 +2640,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	};
 	size_t resp_len = buflen;
 	void *resp_buf;
+	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_GETACL),
 		.rpc_argp = &args,
 		.rpc_resp = &resp_len,
 	};
@@ -2713,7 +2725,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		.acl_len	= buflen,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_SETACL],
+		.rpc_proc	= nfs4_proc(server->nfs_client, NFSPROC4_CLNT_SETACL),
 		.rpc_argp	= &arg,
 		.rpc_resp	= NULL,
 	};
@@ -2853,7 +2865,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 		.sc_prog = program,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
+		.rpc_proc = nfs4_proc(clp, NFSPROC4_CLNT_SETCLIENTID),
 		.rpc_argp = &setclientid,
 		.rpc_resp = clp,
 		.rpc_cred = cred,
@@ -2902,7 +2914,7 @@ static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cre
 {
 	struct nfs_fsinfo fsinfo;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID_CONFIRM],
+		.rpc_proc = nfs4_proc(clp, NFSPROC4_CLNT_SETCLIENTID_CONFIRM),
 		.rpc_argp = clp,
 		.rpc_resp = &fsinfo,
 		.rpc_cred = cred,
@@ -2974,7 +2986,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_task *task;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DELEGRETURN],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_DELEGRETURN),
 		.rpc_cred = cred,
 	};
 	struct rpc_task_setup task_setup_data = {
@@ -3066,7 +3078,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 		.denied = request,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_LOCKT],
+		.rpc_proc	= nfs4_proc(clp, NFSPROC4_CLNT_LOCKT),
 		.rpc_argp       = &arg,
 		.rpc_resp       = &res,
 		.rpc_cred	= state->owner->so_cred,
@@ -3218,7 +3230,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 {
 	struct nfs4_unlockdata *data;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOCKU],
+		.rpc_proc = nfs4_proc(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
+				      NFSPROC4_CLNT_LOCKU),
 		.rpc_cred = ctx->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
@@ -3405,7 +3418,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	struct nfs4_lockdata *data;
 	struct rpc_task *task;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOCK],
+		.rpc_proc = nfs4_proc(NFS_SERVER(state->inode)->nfs_client,
+				      NFSPROC4_CLNT_LOCK),
 		.rpc_cred = state->owner->so_cred,
 	};
 	struct rpc_task_setup task_setup_data = {
@@ -3648,7 +3662,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		.bitmask = bitmask,
 	};
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_proc = nfs4_proc(server->nfs_client, NFSPROC4_CLNT_FS_LOCATIONS),
 		.rpc_argp = &args,
 		.rpc_resp = fs_locations,
 	};
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c1ff9c9..30addf4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4922,11 +4922,25 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 };
 
-struct rpc_version		nfs_version4 = {
-	.number			= 4,
-	.nrprocs		= ARRAY_SIZE(nfs4_procedures),
-	.procs			= nfs4_procedures
+#if defined(CONFIG_NFS_V4_1)
+struct rpc_procinfo	nfs41_procedures[] = {
 };
+#endif /* CONFIG_NFS_V4_1 */
+
+struct rpc_version      nfs_version4 = {
+	.number                 = 4,
+	.nrprocs                = ARRAY_SIZE(nfs4_procedures),
+	.procs                  = nfs4_procedures
+};
+
+#ifdef CONFIG_NFS_V4_1
+struct rpc_version      nfs_version41 = {
+	.number                 = 4,
+	.nrprocs                = ARRAY_SIZE(nfs41_procedures),
+	.procs                  = nfs41_procedures
+};
+
+#endif /* CONFIG_NFS_V4_1 */
 
 /*
  * Local variables:
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8379dd5..c5cb574 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -73,6 +73,15 @@ struct nfs_client {
 #endif /* CONFIG_NFS_V4 */
 };
 
+#ifdef CONFIG_NFS_V4
+static inline struct rpc_procinfo *
+nfs4_proc(struct nfs_client *clp, int idx)
+{
+	struct rpc_procinfo *procs = clp->cl_rpcclient->cl_procinfo;
+	return &procs[idx];
+}
+#endif /* CONFIG_NFS_V4 */
+
 /*
  * NFS client parameters stored in the superblock.
  */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1d6f09a..743b5ac 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -969,6 +969,9 @@ extern const struct nfs_rpc_ops	nfs_v4_clientops;
 extern const struct nfs_rpc_ops	nfs_v40_clientops;
 extern const struct nfs_rpc_ops	nfs_v41_clientops;
 extern const struct nfs_rpc_ops	*nfsv4_minorversion_clientops[];
+extern struct rpc_version *nfs4_minorversions[];
+extern struct rpc_procinfo *nfs4_minorversion_procedures[];
+
 extern struct rpc_version	nfs_version2;
 extern struct rpc_version	nfs_version3;
 extern struct rpc_version	nfs_version4;
-- 
1.6.0.2

