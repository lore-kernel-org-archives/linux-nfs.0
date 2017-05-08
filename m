Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:37004 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750808AbdEHWC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 18:02:27 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 1/1] NFS append COMMIT after synchronous COPY
Date: Mon, 8 May 2017 18:02:24 -0400
Message-ID: <20170508220224.8382-1-kolga@netapp.com>
In-Reply-To: <CAN-5tyFLGa3FG3PetdvYwm9Xf1RK19A83i6k5=XV94EjS=k_2A@mail.gmail.com>
References: <CAN-5tyFLGa3FG3PetdvYwm9Xf1RK19A83i6k5=XV94EjS=k_2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of messing with the commit path which has been causing issues,
add a COMMIT op after the COPY and ask for stable copies in the first
space.

It saves a round trip, since after the COPY, the client sends a COMMIT
anyway.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/internal.h       |  1 -
 fs/nfs/nfs42proc.c      | 21 +++++++++++++++------
 fs/nfs/nfs42xdr.c       | 22 ++++++++++++++++++++--
 fs/nfs/write.c          | 30 ------------------------------
 include/linux/nfs_xdr.h |  1 +
 5 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31b26cf..e9b4c33 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -495,7 +495,6 @@ void nfs_mark_request_commit(struct nfs_page *req,
 			     u32 ds_commit_idx);
 int nfs_write_need_commit(struct nfs_pgio_header *);
 void nfs_writeback_update_inode(struct nfs_pgio_header *hdr);
-int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf);
 int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
 			    int how, struct nfs_commit_info *cinfo);
 void nfs_retry_commit(struct list_head *page_list,
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 87f5b7b..929d09a 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -167,23 +167,29 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
+	res->commit_res.verf = kzalloc(sizeof(struct nfs_writeverf), GFP_NOFS);
+	if (!res->commit_res.verf)
+		return -ENOMEM;
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
 	if (status == -ENOTSUPP)
 		server->caps &= ~NFS_CAP_COPY;
 	if (status)
-		return status;
+		goto out;
 
-	if (res->write_res.verifier.committed != NFS_FILE_SYNC) {
-		status = nfs_commit_file(dst, &res->write_res.verifier.verifier);
-		if (status)
-			return status;
+	if (!nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
+				    &res->commit_res.verf->verifier)) {
+		status = -EAGAIN;
+		goto out;
 	}
 
 	truncate_pagecache_range(dst_inode, pos_dst,
 				 pos_dst + res->write_res.count);
 
-	return res->write_res.count;
+	status = res->write_res.count;
+out:
+	kfree(res->commit_res.verf);
+	return status;
 }
 
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
@@ -240,6 +246,9 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		if (err == -ENOTSUPP) {
 			err = -EOPNOTSUPP;
 			break;
+		} if (err == -EAGAIN) {
+			dst_exception.retry = 1;
+			continue;
 		}
 
 		err2 = nfs4_handle_exception(server, err, &src_exception);
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 6c72964..528362f 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -66,12 +66,14 @@
 					 encode_putfh_maxsz + \
 					 encode_savefh_maxsz + \
 					 encode_putfh_maxsz + \
-					 encode_copy_maxsz)
+					 encode_copy_maxsz + \
+					 encode_commit_maxsz)
 #define NFS4_dec_copy_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_savefh_maxsz + \
 					 decode_putfh_maxsz + \
-					 decode_copy_maxsz)
+					 decode_copy_maxsz + \
+					 decode_commit_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -222,6 +224,18 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+static void encode_copy_commit(struct xdr_stream *xdr,
+			  struct nfs42_copy_args *args,
+			  struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	encode_op_hdr(xdr, OP_COMMIT, decode_commit_maxsz, hdr);
+	p = reserve_space(xdr, 12);
+	p = xdr_encode_hyper(p, args->dst_pos);
+	*p = cpu_to_be32(args->count);
+}
+
 /*
  * Encode COPY request
  */
@@ -239,6 +253,7 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->dst_fh, &hdr);
 	encode_copy(xdr, args, &hdr);
+	encode_copy_commit(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -481,6 +496,9 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
 	if (status)
 		goto out;
 	status = decode_copy(xdr, res);
+	if (status)
+		goto out;
+	status = decode_commit(xdr, &res->commit_res);
 out:
 	return status;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 59e21cc..85bfa41 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1742,36 +1742,6 @@ void nfs_retry_commit(struct list_head *page_list,
 				   data->mds_ops, how, 0);
 }
 
-int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf)
-{
-	struct inode *inode = file_inode(file);
-	struct nfs_open_context *open;
-	struct nfs_commit_info cinfo;
-	struct nfs_page *req;
-	int ret;
-
-	open = get_nfs_open_context(nfs_file_open_context(file));
-	req  = nfs_create_request(open, NULL, NULL, 0, i_size_read(inode));
-	if (IS_ERR(req)) {
-		ret = PTR_ERR(req);
-		goto out_put;
-	}
-
-	nfs_init_cinfo_from_inode(&cinfo, inode);
-
-	memcpy(&req->wb_verf, verf, sizeof(struct nfs_write_verifier));
-	nfs_request_add_commit_list(req, &cinfo);
-	ret = nfs_commit_inode(inode, FLUSH_SYNC);
-	if (ret > 0)
-		ret = 0;
-
-	nfs_free_request(req);
-out_put:
-	put_nfs_open_context(open);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(nfs_commit_file);
-
 /*
  * COMMIT call returned
  */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 677c6b9..b28c834 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1383,6 +1383,7 @@ struct nfs42_copy_res {
 	struct nfs42_write_res		write_res;
 	bool				consecutive;
 	bool				synchronous;
+	struct nfs_commitres		commit_res;
 };
 
 struct nfs42_seek_args {
-- 
1.8.3.1

