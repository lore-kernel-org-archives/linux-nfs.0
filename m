Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:27516 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761446AbbA1UnD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:43:03 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Date: Wed, 28 Jan 2015 15:42:55 -0500
Message-ID: <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This patch adds READ_PLUS support by encoding file contents ase one
single data segment, matching the behavior of the READ operation.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c | 16 +++++++++++
 fs/nfsd/nfs4xdr.c  | 79 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 93 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ac71d13..fdf9ce3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1603,6 +1603,16 @@ static inline u32 nfsd4_read_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 	return (op_encode_hdr_size + 2 + XDR_QUADLEN(rlen)) * sizeof(__be32);
 }
 
+static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	u32 maxcount = svc_max_payload(rqstp);
+	u32 rlen = min(op->u.read.rd_length, maxcount);
+	/* extra xdr space for encoding read plus segments. */
+	u32 xdr  = 4;
+
+	return (op_encode_hdr_size + 2 + xdr + XDR_QUADLEN(rlen)) * sizeof(__be32);
+}
+
 static inline u32 nfsd4_readdir_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	u32 maxcount = 0, rlen = 0;
@@ -1980,6 +1990,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
 	},
+	[OP_READ_PLUS] = {
+		.op_func = (nfsd4op_func)nfsd4_read,
+		.op_name = "OP_READ_PLUS",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_plus_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 01248b2..480b07f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1630,7 +1630,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_read,
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
@@ -3802,6 +3802,81 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
+nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
+			    struct file *file)
+{
+	__be32 *p, err;
+	unsigned long maxcount;
+	struct xdr_stream *xdr = &resp->xdr;
+
+	p = xdr_reserve_space(xdr, 4 + 8 + 4); /* content type, offset, maxcount */
+	if (!p)
+		return nfserr_resource;
+	xdr_commit_encode(xdr);
+
+	maxcount = svc_max_payload(resp->rqstp);
+	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
+	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+
+	err = nfsd4_encode_readv(resp, read, file, &maxcount);
+
+	*p++ = cpu_to_be32(NFS4_CONTENT_DATA);
+	p = xdr_encode_hyper(p, read->rd_offset);
+	*p++ = cpu_to_be32(maxcount);
+
+	read->rd_offset += maxcount;
+	return err;
+}
+
+static __be32
+nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
+		       struct nfsd4_read *read)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct file *file = read->rd_filp;
+	int starting_len = xdr->buf->len;
+	struct raparms *ra;
+	__be32 *p;
+	__be32 err;
+	u32 eof, segments = 0;
+
+	if (nfserr)
+		return nfserr;
+
+	/* eof flag, segment count */
+	p = xdr_reserve_space(xdr, 4 + 4 );
+	if (!p)
+		return nfserr_resource;
+	xdr_commit_encode(xdr);
+
+	if (!read->rd_filp) {
+		err = nfsd_get_tmp_read_open(resp->rqstp, read->rd_fhp,
+						&file, &ra);
+		if (err)
+			goto err_truncate;
+	}
+
+	if (read->rd_offset >= i_size_read(file_inode(file)))
+		goto out_encode;
+
+	err = nfsd4_encode_read_plus_data(resp, read, file);
+	segments++;
+
+out_encode:
+	eof = (read->rd_offset >= i_size_read(file_inode(file)));
+	*p++ = cpu_to_be32(eof);
+	*p++ = cpu_to_be32(segments);
+
+	if (!read->rd_filp)
+		nfsd_put_tmp_read_open(file, ra);
+
+err_truncate:
+	if (err)
+		xdr_truncate_encode(xdr, starting_len);
+	return err;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -3900,7 +3975,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_LAYOUTSTATS]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_read_plus,
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
 };
-- 
2.2.2

