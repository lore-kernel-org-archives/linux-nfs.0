Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab2DZVDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:03:45 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] NFSv4: Simplify the NFSv4 REMOVE, LINK and RENAME compounds
Date: Thu, 26 Apr 2012 17:03:35 -0400
Message-Id: <1335474215-29127-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335474215-29127-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1335474215-29127-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-6-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-7-git-send-email-Trond.Myklebust@netapp.com>
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
index 0239d52..ef7e29d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2756,7 +2756,6 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 		.fh = NFS_FH(dir),
 		.name.len = name->len,
 		.name.name = name->name,
-		.bitmask = server->attr_bitmask,
 	};
 	struct nfs_removeres res = {
 		.server = server,
@@ -2766,19 +2765,11 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
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
 
@@ -2800,7 +2791,6 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	struct nfs_removeargs *args = msg->rpc_argp;
 	struct nfs_removeres *res = msg->rpc_resp;
 
-	args->bitmask = server->cache_consistency_bitmask;
 	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 	nfs41_init_sequence(&args->seq_args, &res->seq_res, 1);
@@ -2825,7 +2815,6 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
-	nfs_post_op_update_inode(dir, res->dir_attr);
 	return 1;
 }
 
@@ -2836,7 +2825,6 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	struct nfs_renameres *res = msg->rpc_resp;
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
-	arg->bitmask = server->attr_bitmask;
 	res->server = server;
 	nfs41_init_sequence(&arg->seq_args, &res->seq_res, 1);
 }
@@ -2862,9 +2850,7 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		return 0;
 
 	update_changeattr(old_dir, &res->old_cinfo);
-	nfs_post_op_update_inode(old_dir, res->old_fattr);
 	update_changeattr(new_dir, &res->new_cinfo);
-	nfs_post_op_update_inode(new_dir, res->new_fattr);
 	return 1;
 }
 
@@ -2877,7 +2863,6 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_dir = NFS_FH(new_dir),
 		.old_name = old_name,
 		.new_name = new_name,
-		.bitmask = server->attr_bitmask,
 	};
 	struct nfs_renameres res = {
 		.server = server,
@@ -2889,21 +2874,11 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
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
 
@@ -2941,18 +2916,15 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
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
index e77097c..4a37c31 100644
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
@@ -2051,7 +2041,6 @@ static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_remove(xdr, &args->name, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -2071,9 +2060,6 @@ static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->new_dir, &hdr);
 	encode_rename(xdr, args->old_name, args->new_name, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
-	encode_restorefh(xdr, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -2093,7 +2079,6 @@ static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->dir_fh, &hdr);
 	encode_link(xdr, args->name, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_restorefh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -5798,9 +5783,6 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	status = decode_remove(xdr, &res->cinfo);
-	if (status)
-		goto out;
-	decode_getfattr(xdr, res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -5830,15 +5812,6 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
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
@@ -5874,8 +5847,6 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(xdr, res->dir_attr, res->server))
-		goto out;
 	status = decode_restorefh(xdr);
 	if (status)
 		goto out;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8f4cd0d..f199c43 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -524,7 +524,6 @@ struct nfs_writeres {
 struct nfs_removeargs {
 	const struct nfs_fh	*fh;
 	struct qstr		name;
-	const u32 *		bitmask;
 	struct nfs4_sequence_args	seq_args;
 };
 
@@ -543,7 +542,6 @@ struct nfs_renameargs {
 	const struct nfs_fh		*new_dir;
 	const struct qstr		*old_name;
 	const struct qstr		*new_name;
-	const u32			*bitmask;
 	struct nfs4_sequence_args	seq_args;
 };
 
-- 
1.7.7.6

