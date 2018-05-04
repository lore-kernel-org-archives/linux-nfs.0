Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:45230 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbeEDUXn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 16:23:43 -0400
Received: by mail-qk0-f196.google.com with SMTP id x22so17615044qkb.12
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 13:23:42 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFS: Pass "privileged" value to nfs4_call_sync()
Date: Fri,  4 May 2018 16:22:51 -0400
Message-Id: <20180504202252.5862-5-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
References: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This lets us convert a few other users of synchronous RPC calls to the
nfs4_call_sync() function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c |  8 ++---
 fs/nfs/nfs4_fs.h   |  2 +-
 fs/nfs/nfs4proc.c  | 78 ++++++++++++++++++++++------------------------
 3 files changed, 42 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 4d4a3df28779..7e9a208940e2 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -47,7 +47,7 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 		return -ENOMEM;
 
 	status = nfs4_call_sync(server->client, server, msg,
-				&args.seq_args, &res.seq_res, 0);
+				&args.seq_args, &res.seq_res, 0, 0);
 	if (status == 0)
 		status = nfs_post_op_update_inode(inode, res.falloc_fattr);
 
@@ -172,7 +172,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (!res->commit_res.verf)
 		return -ENOMEM;
 	status = nfs4_call_sync(server->client, server, &msg,
-				&args->seq_args, &res->seq_res, 0);
+				&args->seq_args, &res->seq_res, 0, 0);
 	if (status == -ENOTSUPP)
 		server->caps &= ~NFS_CAP_COPY;
 	if (status)
@@ -297,7 +297,7 @@ static loff_t _nfs42_proc_llseek(struct file *filep,
 		return status;
 
 	status = nfs4_call_sync(server->client, server, &msg,
-				&args.seq_args, &res.seq_res, 0);
+				&args.seq_args, &res.seq_res, 0, 0);
 	if (status == -ENOTSUPP)
 		server->caps &= ~NFS_CAP_SEEK;
 	if (status)
@@ -509,7 +509,7 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 		return -ENOMEM;
 
 	status = nfs4_call_sync(server->client, server, msg,
-				&args.seq_args, &res.seq_res, 0);
+				&args.seq_args, &res.seq_res, 0, 0);
 	if (status == 0)
 		status = nfs_post_op_update_inode(dst_inode, res.dst_fattr);
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 06a41aa2fdb2..9a2e04a422ec 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -250,7 +250,7 @@ int nfs4_replace_transport(struct nfs_server *server,
 extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
-			  struct nfs4_sequence_res *, int);
+			  struct nfs4_sequence_res *, int, int);
 extern void nfs4_init_sequence(struct nfs4_sequence_args *, struct nfs4_sequence_res *, int, int);
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6c749ce7587e..505f605dcac2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1029,9 +1029,10 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct rpc_message *msg,
 		   struct nfs4_sequence_args *args,
 		   struct nfs4_sequence_res *res,
-		   int cache_reply)
+		   int cache_reply,
+		   int privileged)
 {
-	nfs4_init_sequence(args, res, cache_reply, 0);
+	nfs4_init_sequence(args, res, cache_reply, privileged);
 	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
 }
 
@@ -3061,7 +3062,7 @@ static int _nfs4_do_setattr(struct inode *inode,
 	if (delegation_cred)
 		msg.rpc_cred = delegation_cred;
 
-	status = nfs4_call_sync(server->client, server, &msg, &arg->seq_args, &res->seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg->seq_args, &res->seq_res, 1, 0);
 
 	put_rpccred(delegation_cred);
 	if (status == 0 && ctx != NULL)
@@ -3488,7 +3489,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	if (minorversion)
 		bitmask[2] = FATTR4_WORD2_SUPPATTR_EXCLCREAT;
 
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 	if (status == 0) {
 		/* Sanity check the server answers */
 		switch (minorversion) {
@@ -3596,7 +3597,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	bitmask[2] = nfs4_fattr_bitmap[2] & ~FATTR4_WORD2_SECURITY_LABEL;
 
 	nfs_fattr_init(info->fattr);
-	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -3820,7 +3821,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	args.bitmask = nfs4_bitmask(server, label);
 
 	nfs_fattr_init(fattr);
-	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -3932,7 +3933,7 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookup %s\n", name->name);
-	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 	dprintk("NFS reply lookup: %d\n", status);
 	return status;
 }
@@ -4045,7 +4046,7 @@ static int _nfs4_proc_lookupp(struct inode *inode,
 
 	dprintk("NFS call  lookupp ino=0x%lx\n", inode->i_ino);
 	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
-				&res.seq_res, 0);
+				&res.seq_res, 0, 0);
 	dprintk("NFS reply lookupp: %d\n", status);
 	return status;
 }
@@ -4089,7 +4090,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		args.bitmask = server->cache_consistency_bitmask;
 	}
 
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 	if (!status) {
 		nfs_access_set_mask(entry, res.access);
 		if (res.fattr)
@@ -4150,7 +4151,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0, 0);
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -4217,7 +4218,7 @@ static int _nfs4_proc_remove(struct inode *dir, const struct qstr *name)
 	unsigned long timestamp = jiffies;
 	int status;
 
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1, 0);
 	if (status == 0)
 		update_changeattr(dir, &res.cinfo, timestamp);
 	return status;
@@ -4375,7 +4376,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 
 	nfs4_inode_make_writeable(inode);
 
-	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1, 0);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo, res.fattr->time_start);
 		status = nfs_post_op_update_inode(inode, res.fattr);
@@ -4450,7 +4451,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
 	int status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &data->msg,
-				    &data->arg.seq_args, &data->res.seq_res, 1);
+				    &data->arg.seq_args, &data->res.seq_res, 1, 0);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo,
 				data->res.fattr->time_start);
@@ -4579,7 +4580,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			(unsigned long long)cookie);
 	nfs4_setup_readdir(cookie, NFS_I(dir)->cookieverf, dentry, &args);
 	res.pgbase = args.pgbase;
-	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0, 0);
 	if (status >= 0) {
 		memcpy(NFS_I(dir)->cookieverf, res.verifier.data, NFS4_VERIFIER_SIZE);
 		status += args.pgbase;
@@ -4682,7 +4683,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
-	return  nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -4713,7 +4714,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -4774,7 +4775,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -5282,7 +5283,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
 		__func__, buf, buflen, npages, args.acl_len);
 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
-			     &msg, &args.seq_args, &res.seq_res, 0);
+			     &msg, &args.seq_args, &res.seq_res, 0, 0);
 	if (ret)
 		goto out_free;
 
@@ -5373,7 +5374,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	if (i < 0)
 		return i;
 	nfs4_inode_make_writeable(inode);
-	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
+	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1, 0);
 
 	/*
 	 * Free each page after tx, so the only ref left is
@@ -5435,7 +5436,7 @@ static int _nfs4_get_security_label(struct inode *inode, void *buf,
 
 	nfs_fattr_init(&fattr);
 
-	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 0);
+	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 0, 0);
 	if (ret)
 		return ret;
 	if (!(fattr.valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL))
@@ -5493,7 +5494,7 @@ static int _nfs4_do_set_security_label(struct inode *inode,
 
 	nfs4_stateid_copy(&arg.stateid, &zero_stateid);
 
-	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1, 0);
 	if (status)
 		dprintk("%s failed: %d\n", __func__, status);
 
@@ -6063,7 +6064,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_seqid.owner_id;
 	arg.lock_owner.s_dev = server->s_dev;
-	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
+	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1, 0);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -7040,7 +7041,7 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }
@@ -7104,9 +7105,8 @@ static int _nfs40_proc_get_locations(struct inode *inode,
 	locations->server = server;
 	locations->nlocations = 0;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
-	status = nfs4_call_sync_sequence(clnt, server, &msg,
-					&args.seq_args, &res.seq_res);
+	status = nfs4_call_sync(clnt, server, &msg,
+				&args.seq_args, &res.seq_res, 0, 1);
 	if (status)
 		return status;
 
@@ -7157,9 +7157,8 @@ static int _nfs41_proc_get_locations(struct inode *inode,
 	locations->server = server;
 	locations->nlocations = 0;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
-	status = nfs4_call_sync_sequence(clnt, server, &msg,
-					&args.seq_args, &res.seq_res);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
+				&res.seq_res, 0, 1);
 	if (status == NFS4_OK &&
 	    res.seq_res.sr_status_flags & SEQ4_STATUS_LEASE_MOVED)
 		status = -NFS4ERR_LEASE_MOVED;
@@ -7244,9 +7243,8 @@ static int _nfs40_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
 	if (res.fh == NULL)
 		return -ENOMEM;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
-	status = nfs4_call_sync_sequence(clnt, server, &msg,
-						&args.seq_args, &res.seq_res);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
+				&res.seq_res, 0, 1);
 	nfs_free_fhandle(res.fh);
 	if (status)
 		return status;
@@ -7285,9 +7283,8 @@ static int _nfs41_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
 	if (res.fh == NULL)
 		return -ENOMEM;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
-	status = nfs4_call_sync_sequence(clnt, server, &msg,
-						&args.seq_args, &res.seq_res);
+	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
+				&res.seq_res, 0, 1);
 	nfs_free_fhandle(res.fh);
 	if (status == NFS4_OK &&
 	    res.seq_res.sr_status_flags & SEQ4_STATUS_LEASE_MOVED)
@@ -7372,7 +7369,7 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		NFS_SP4_MACH_CRED_SECINFO, &clnt, &msg);
 
 	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args,
-				&res.seq_res, 0);
+				&res.seq_res, 0, 0);
 	dprintk("NFS reply  secinfo: %d\n", status);
 
 	if (cred)
@@ -8950,7 +8947,7 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 	int status;
 
 	dprintk("--> %s\n", __func__);
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 0);
 	if (res.notification & ~args.notify_types)
 		dprintk("%s: unsupported notification\n", __func__);
 	if (res.notification != args.notify_types)
@@ -9107,7 +9104,7 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	dprintk("--> %s\n", __func__);
 	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
-				&res.seq_res, 0);
+				&res.seq_res, 0, 0);
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	if (cred)
@@ -9243,9 +9240,8 @@ static int _nfs41_test_stateid(struct nfs_server *server,
 		&rpc_client, &msg);
 
 	dprintk("NFS call  test_stateid %p\n", stateid);
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
-	status = nfs4_call_sync_sequence(rpc_client, server, &msg,
-			&args.seq_args, &res.seq_res);
+	status = nfs4_call_sync(rpc_client, server, &msg, &args.seq_args,
+				&res.seq_res, 0, 1);
 	if (status != NFS_OK) {
 		dprintk("NFS reply test_stateid: failed, %d\n", status);
 		return status;
-- 
2.17.0

