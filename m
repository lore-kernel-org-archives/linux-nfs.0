Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:17257 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760307AbbIDTH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 15:07:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/3] NFSD: Add basic READ_PLUS support
Date: Fri, 4 Sep 2015 15:07:20 -0400
Message-ID: <1441393641-30152-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1441393641-30152-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1441393641-30152-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds READ_PLUS support for both NFS4_CONTENT_DATA and
NFS4_CONTENT_HOLE segments.  I keep things simple for now by only
returning one segment at a time to clients issuing the READ_PLUS call.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c |  16 ++++++++
 fs/nfsd/nfs4xdr.c  | 114 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 128 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 90cfda7..fe4fc24 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1849,6 +1849,16 @@ static inline u32 nfsd4_read_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 	return (op_encode_hdr_size + 2 + XDR_QUADLEN(rlen)) * sizeof(__be32);
 }
 
+static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	u32 maxcount = svc_max_payload(rqstp);
+	u32 rlen = min(op->u.read.rd_length, maxcount);
+	/* enough extra xdr space for encoding either a hole or data segment. */
+	u32 xdr  = 5;
+
+	return (op_encode_hdr_size + 2 + xdr + XDR_QUADLEN(rlen)) * sizeof(__be32);
+}
+
 static inline u32 nfsd4_readdir_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	u32 maxcount = 0, rlen = 0;
@@ -2281,6 +2291,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
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
index 2af54fa..7ab4033 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1782,7 +1782,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_read,
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
@@ -4128,6 +4128,116 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
 #endif /* CONFIG_NFSD_PNFS */
 
 static __be32
+nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
+			    struct file *file, loff_t hole_pos)
+{
+	__be32 *p, err;
+	unsigned long maxcount;
+	struct xdr_stream *xdr = &resp->xdr;
+
+	p = xdr_reserve_space(xdr, 4 + 8 + 4);
+	if (!p)
+		return nfserr_resource;
+	xdr_commit_encode(xdr);
+
+	if (hole_pos <= read->rd_offset)
+		hole_pos = i_size_read(file_inode(file));
+
+	maxcount = svc_max_payload(resp->rqstp);
+	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
+	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+	maxcount = min_t(unsigned long, maxcount, hole_pos - read->rd_offset);
+
+	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
+		err = nfsd4_encode_splice_read(resp, read, file, &maxcount);
+	else
+		err = nfsd4_encode_readv(resp, read, file, &maxcount);
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
+nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
+			    struct file *file)
+{
+	__be32 *p;
+	unsigned long maxcount;
+	loff_t data_pos = vfs_llseek(file, read->rd_offset, SEEK_DATA);
+
+	if (data_pos == -ENXIO)
+		data_pos = i_size_read(file_inode(file));
+	if (data_pos <= read->rd_offset)
+		return nfsd4_encode_read_plus_data(resp, read, file, 0);
+
+	maxcount = data_pos - read->rd_offset;
+	p = xdr_reserve_space(&resp->xdr, 4 + 8 + 8);
+	*p++ = cpu_to_be32(NFS4_CONTENT_HOLE);
+	p = xdr_encode_hyper(p, read->rd_offset);
+	p = xdr_encode_hyper(p, maxcount);
+
+	read->rd_offset += maxcount;
+	return nfs_ok;
+}
+
+static __be32
+nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
+		       struct nfsd4_read *read)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct file *file = read->rd_filp;
+	int starting_len = xdr->buf->len;
+	struct raparms *ra = NULL;
+	loff_t hole_pos;
+	__be32 *p;
+	u32 eof, segments = 0;
+
+	if (nfserr)
+		goto out;
+
+	/* eof flag, segment count */
+	p = xdr_reserve_space(xdr, 4 + 4 );
+	if (!p) {
+		nfserr = nfserr_resource;
+		goto out;
+	}
+	xdr_commit_encode(xdr);
+
+	if (read->rd_tmp_file)
+		ra = nfsd_init_raparms(file);
+
+	hole_pos = vfs_llseek(file, read->rd_offset, SEEK_HOLE);
+	if (hole_pos == -ENXIO)
+		goto out_encode;
+
+	if (hole_pos == read->rd_offset)
+		nfserr = nfsd4_encode_read_plus_hole(resp, read, file);
+	else
+		nfserr = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
+	segments++;
+
+out_encode:
+	eof = (read->rd_offset >= i_size_read(file_inode(file)));
+	*p++ = cpu_to_be32(eof);
+	*p++ = cpu_to_be32(segments);
+
+	if (ra)
+		nfsd_put_raparams(file, ra);
+
+	if (nfserr)
+		xdr_truncate_encode(xdr, starting_len);
+
+out:
+	if (file)
+		fput(file);
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -4234,7 +4344,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_LAYOUTSTATS]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_read_plus,
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
 	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
 };
-- 
2.5.1

