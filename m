Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35505 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbbAGA3f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 19:29:35 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so1076787pac.8
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 16:29:34 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 22/49] nfs: save server READ/WRITE/COMMIT status
Date: Tue,  6 Jan 2015 16:28:27 -0800
Message-Id: <1420590534-84063-23-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Flexfiles layout would want to use them to report DS IO status.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs2xdr.c        | 10 +++++++---
 fs/nfs/nfs3xdr.c        |  3 +++
 fs/nfs/nfs4xdr.c        |  3 +++
 include/linux/nfs_xdr.h |  2 ++
 4 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 5f61b83..b4e03ed 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -481,7 +481,8 @@ out_overflow:
  *		void;
  *	};
  */
-static int decode_attrstat(struct xdr_stream *xdr, struct nfs_fattr *result)
+static int decode_attrstat(struct xdr_stream *xdr, struct nfs_fattr *result,
+			   __u32 *op_status)
 {
 	enum nfs_stat status;
 	int error;
@@ -489,6 +490,8 @@ static int decode_attrstat(struct xdr_stream *xdr, struct nfs_fattr *result)
 	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
+	if (op_status)
+		*op_status = status;
 	if (status != NFS_OK)
 		goto out_default;
 	error = decode_fattr(xdr, result);
@@ -808,7 +811,7 @@ out_default:
 static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 struct nfs_fattr *result)
 {
-	return decode_attrstat(xdr, result);
+	return decode_attrstat(xdr, result, NULL);
 }
 
 static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, struct xdr_stream *xdr,
@@ -865,6 +868,7 @@ static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
 	error = decode_stat(xdr, &status);
 	if (unlikely(error))
 		goto out;
+	result->op_status = status;
 	if (status != NFS_OK)
 		goto out_default;
 	error = decode_fattr(xdr, result->fattr);
@@ -882,7 +886,7 @@ static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
 {
 	/* All NFSv2 writes are "file sync" writes */
 	result->verf->committed = NFS_FILE_SYNC;
-	return decode_attrstat(xdr, result->fattr);
+	return decode_attrstat(xdr, result->fattr, &result->op_status);
 }
 
 /**
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 8f4cbe7..2a932fd 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1636,6 +1636,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 	error = decode_post_op_attr(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
+	result->op_status = status;
 	if (status != NFS3_OK)
 		goto out_status;
 	error = decode_read3resok(xdr, result);
@@ -1708,6 +1709,7 @@ static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 	error = decode_wcc_data(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
+	result->op_status = status;
 	if (status != NFS3_OK)
 		goto out_status;
 	error = decode_write3resok(xdr, result);
@@ -2323,6 +2325,7 @@ static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 	error = decode_wcc_data(xdr, result->fattr);
 	if (unlikely(error))
 		goto out;
+	result->op_status = status;
 	if (status != NFS3_OK)
 		goto out_status;
 	error = decode_writeverf3(xdr, &result->verf->verifier);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index cb4376b..7d8d7a4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6567,6 +6567,7 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	int status;
 
 	status = decode_compound_hdr(xdr, &hdr);
+	res->op_status = hdr.status;
 	if (status)
 		goto out;
 	status = decode_sequence(xdr, &res->seq_res, rqstp);
@@ -6592,6 +6593,7 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	int status;
 
 	status = decode_compound_hdr(xdr, &hdr);
+	res->op_status = hdr.status;
 	if (status)
 		goto out;
 	status = decode_sequence(xdr, &res->seq_res, rqstp);
@@ -6621,6 +6623,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	int status;
 
 	status = decode_compound_hdr(xdr, &hdr);
+	res->op_status = hdr.status;
 	if (status)
 		goto out;
 	status = decode_sequence(xdr, &res->seq_res, rqstp);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 467c84e..962f461 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -513,6 +513,7 @@ struct nfs_pgio_res {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *	fattr;
 	__u32			count;
+	__u32			op_status;
 	int			eof;		/* used by read */
 	struct nfs_writeverf *	verf;		/* used by write */
 	const struct nfs_server *server;	/* used by write */
@@ -532,6 +533,7 @@ struct nfs_commitargs {
 
 struct nfs_commitres {
 	struct nfs4_sequence_res	seq_res;
+	__u32			op_status;
 	struct nfs_fattr	*fattr;
 	struct nfs_writeverf	*verf;
 	const struct nfs_server *server;
-- 
1.9.3

