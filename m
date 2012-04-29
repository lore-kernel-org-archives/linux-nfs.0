Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344Ab2D2Uue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:34 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 13/15] NFSv4: Simplify the NFSv4 REMOVE, LINK and RENAME compounds
Date: Sun, 29 Apr 2012 16:50:18 -0400
Message-Id: <1335732620-10445-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-7-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-8-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-9-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-10-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-11-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-12-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of the post-op GETATTR on the directory in order to reduce
the amount of processing done on the server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |   34 +++-------------------------------
 fs/nfs/nfs4xdr.c        |   37 ++++---------------------------------
 include/linux/nfs_xdr.h |    2 --
 3 files changed, 7 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 619bc1e..c746b0c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2775,7 +2775,6 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 		.fh = NFS_FH(dir),
 		.name.len = name->len,
 		.name.name = name->name,
-		.bitmask = server->attr_bitmask,
 	};
 	struct nfs_removeres res = {
 		.server = server,
@@ -2785,19 +2784,11 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int status = -ENOMEM;
-
-	res.dir_attr = nfs_alloc_fattr();
-	if (res.dir_attr == NULL)
-		goto out;
+	int status;
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
-	if (status == 0) {
+	if (status == 0)
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, res.dir_attr);
-	}
-	nfs_free_fattr(res.dir_attr);
-out:
 	return status;
 }
 
@@ -2819,7 +2810,6 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	struct nfs_removeargs *args = msg->rpc_argp;
 	struct nfs_removeres *res = msg->rpc_resp;
 
-	args->bitmask = server->cache_consistency_bitmask;
 	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 	nfs41_init_sequence(&args->seq_args, &res->seq_res, 1);
@@ -2844,7 +2834,6 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
-	nfs_post_op_update_inode(dir, res->dir_attr);
 	return 1;
 }
 
@@ -2855,7 +2844,6 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	struct nfs_renameres *res = msg->rpc_resp;
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
-	arg->bitmask = server->attr_bitmask;
 	res->server = server;
 	nfs41_init_sequence(&arg->seq_args, &res->seq_res, 1);
 }
@@ -2881,9 +2869,7 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		return 0;
 
 	update_changeattr(old_dir, &res->old_cinfo);
-	nfs_post_op_update_inode(old_dir, res->old_fattr);
 	update_changeattr(new_dir, &res->new_cinfo);
-	nfs_post_op_update_inode(new_dir, res->new_fattr);
 	return 1;
 }
 
@@ -2896,7 +2882,6 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_dir = NFS_FH(new_dir),
 		.old_name = old_name,
 		.new_name = new_name,
-		.bitmask = server->attr_bitmask,
 	};
 	struct nfs_renameres res = {
 		.server = server,
@@ -2908,21 +2893,11 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	};
 	int status = -ENOMEM;
 	
-	res.old_fattr = nfs_alloc_fattr();
-	res.new_fattr = nfs_alloc_fattr();
-	if (res.old_fattr == NULL || res.new_fattr == NULL)
-		goto out;
-
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
-		nfs_post_op_update_inode(old_dir, res.old_fattr);
 		update_changeattr(new_dir, &res.new_cinfo);
-		nfs_post_op_update_inode(new_dir, res.new_fattr);
 	}
-out:
-	nfs_free_fattr(res.new_fattr);
-	nfs_free_fattr(res.old_fattr);
 	return status;
 }
 
@@ -2960,18 +2935,15 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	int status = -ENOMEM;
 
 	res.fattr = nfs_alloc_fattr();
-	res.dir_attr = nfs_alloc_fattr();
-	if (res.fattr == NULL || res.dir_attr == NULL)
+	if (res.fattr == NULL)
 		goto out;
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, res.dir_attr);
 		nfs_post_op_update_inode(inode, res.fattr);
 	}
 out:
-	nfs_free_fattr(res.dir_attr);
 	nfs_free_fattr(res.fattr);
 	return status;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1a70097..49483f1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -589,38 +589,29 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_remove_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
-				encode_remove_maxsz + \
-				encode_getattr_maxsz)
+				encode_remove_maxsz)
 #define NFS4_dec_remove_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
-				decode_remove_maxsz + \
-				decode_getattr_maxsz)
+				decode_remove_maxsz)
 #define NFS4_enc_rename_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
-				encode_rename_maxsz + \
-				encode_getattr_maxsz + \
-				encode_restorefh_maxsz + \
-				encode_getattr_maxsz)
+				encode_rename_maxsz)
 #define NFS4_dec_rename_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_putfh_maxsz + \
-				decode_rename_maxsz + \
-				decode_getattr_maxsz + \
-				decode_restorefh_maxsz + \
-				decode_getattr_maxsz)
+				decode_rename_maxsz)
 #define NFS4_enc_link_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
 				encode_link_maxsz + \
-				encode_getattr_maxsz + \
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_link_sz	(compound_decode_hdr_maxsz + \
@@ -629,7 +620,6 @@ static int nfs4_stat_to_errno(int);
 				decode_savefh_maxsz + \
 				decode_putfh_maxsz + \
 				decode_link_maxsz + \
-				decode_getattr_maxsz + \
 				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_symlink_sz	(compound_encode_hdr_maxsz + \
@@ -2052,7 +2042,6 @@ static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_remove(xdr, &args->name, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -2072,9 +2061,6 @@ static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->new_dir, &hdr);
 	encode_rename(xdr, args->old_name, args->new_name, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
-	encode_restorefh(xdr, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -2094,7 +2080,6 @@ static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->dir_fh, &hdr);
 	encode_link(xdr, args->name, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_restorefh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -5782,9 +5767,6 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	status = decode_remove(xdr, &res->cinfo);
-	if (status)
-		goto out;
-	decode_getfattr(xdr, res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -5814,15 +5796,6 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	status = decode_rename(xdr, &res->old_cinfo, &res->new_cinfo);
-	if (status)
-		goto out;
-	/* Current FH is target directory */
-	if (decode_getfattr(xdr, res->new_fattr, res->server))
-		goto out;
-	status = decode_restorefh(xdr);
-	if (status)
-		goto out;
-	decode_getfattr(xdr, res->old_fattr, res->server);
 out:
 	return status;
 }
@@ -5858,8 +5831,6 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(xdr, res->dir_attr, res->server))
-		goto out;
 	status = decode_restorefh(xdr);
 	if (status)
 		goto out;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5a05739..4bb1f9b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -540,7 +540,6 @@ struct nfs_commitres {
 struct nfs_removeargs {
 	const struct nfs_fh	*fh;
 	struct qstr		name;
-	const u32 *		bitmask;
 	struct nfs4_sequence_args	seq_args;
 };
 
@@ -559,7 +558,6 @@ struct nfs_renameargs {
 	const struct nfs_fh		*new_dir;
 	const struct qstr		*old_name;
 	const struct qstr		*new_name;
-	const u32			*bitmask;
 	struct nfs4_sequence_args	seq_args;
 };
 
-- 
1.7.7.6

