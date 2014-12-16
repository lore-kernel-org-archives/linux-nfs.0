Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35439 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbaLPTCr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:47 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so14444542pac.8
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:47 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 22/50] nfs: save server READ/WRITE/COMMIT status
Date: Tue, 16 Dec 2014 11:01:25 -0800
Message-Id: <1418756513-95187-23-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Flexfiles layout would want to use them to report DS IO status.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs3xdr.c        | 3 +++
 fs/nfs/nfs4xdr.c        | 3 +++
 include/linux/nfs_xdr.h | 2 ++
 3 files changed, 8 insertions(+)

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

