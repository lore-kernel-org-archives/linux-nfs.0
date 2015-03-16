Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:44147 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932714AbbCPVSN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 17:18:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Date: Mon, 16 Mar 2015 17:18:08 -0400
Message-ID: <1426540688-32095-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1426540688-32095-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1426540688-32095-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch implements sending an array of segments back to the client.
Clients should be prepared to handle multiple segment reads to make this
useful.  We try to splice the first data segment into the XDR result,
and remaining segments are encoded directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c |  4 ++--
 fs/nfsd/nfs4xdr.c  | 35 ++++++++++++++++++++++++-----------
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e9f4d8f..6801973 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1862,8 +1862,8 @@ static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op
 {
 	u32 maxcount = svc_max_payload(rqstp);
 	u32 rlen = min(op->u.read.rd_length, maxcount);
-	/* enough extra xdr space for encoding either a hole or data segment. */
-	u32 xdr  = 5;
+	/* Extra xdr padding for encoding multiple segments. */
+	u32 xdr  = 20;
 
 	return (op_encode_hdr_size + 2 + xdr + XDR_QUADLEN(rlen)) * sizeof(__be32);
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 799d52c..5eaecd2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4117,7 +4117,7 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 static __be32
 nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
-			    struct file *file)
+			    struct file *file, loff_t hole_pos)
 {
 	__be32 *p, err;
 	unsigned long maxcount;
@@ -4128,20 +4128,26 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 		return nfserr_resource;
 	xdr_commit_encode(xdr);
 
+	if (hole_pos <= read->rd_offset)
+		hole_pos = i_size_read(file_inode(file));
+
 	maxcount = svc_max_payload(resp->rqstp);
 	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+	maxcount = min_t(unsigned long, maxcount, hole_pos - read->rd_offset);
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
 		err = nfsd4_encode_splice_read(resp, read, file, &maxcount);
 	else
 		err = nfsd4_encode_readv(resp, read, file, &maxcount);
+	clear_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags);
 
 	*p++ = cpu_to_be32(NFS4_CONTENT_DATA);
 	p = xdr_encode_hyper(p, read->rd_offset);
 	*p++ = cpu_to_be32(maxcount);
 
 	read->rd_offset += maxcount;
+	read->rd_length -= maxcount;
 	return err;
 }
 
@@ -4156,7 +4162,7 @@ nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	if (data_pos == -ENXIO)
 		data_pos = i_size_read(file_inode(file));
 	if (data_pos <= read->rd_offset)
-		return nfsd4_encode_read_plus_data(resp, read, file);
+		return nfsd4_encode_read_plus_data(resp, read, file, 0);
 
 	maxcount = data_pos - read->rd_offset;
 	p = xdr_reserve_space(&resp->xdr, 4 + 8 + 8);
@@ -4165,6 +4171,10 @@ nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	p = xdr_encode_hyper(p, maxcount);
 
 	read->rd_offset += maxcount;
+	if (maxcount > read->rd_length)
+		read->rd_length = 0;
+	else
+		read->rd_length -= maxcount;
 	return nfs_ok;
 }
 
@@ -4197,17 +4207,20 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 			goto err_truncate;
 	}
 
-	hole_pos = vfs_llseek(file, read->rd_offset, SEEK_HOLE);
-	if (hole_pos == -ENXIO)
-		goto out_encode;
+	do {
+		hole_pos = vfs_llseek(file, read->rd_offset, SEEK_HOLE);
+		if (hole_pos == -ENXIO)
+			break;
 
-	if (hole_pos == read->rd_offset)
-		err = nfsd4_encode_read_plus_hole(resp, read, file);
-	else
-		err = nfsd4_encode_read_plus_data(resp, read, file);
-	segments++;
+		if (hole_pos == read->rd_offset)
+			err = nfsd4_encode_read_plus_hole(resp, read, file);
+		else
+			err = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
+		if (err)
+			break;
+		segments++;
+	} while (read->rd_length > 0);
 
-out_encode:
 	eof = (read->rd_offset >= i_size_read(file_inode(file)));
 	*p++ = cpu_to_be32(eof);
 	*p++ = cpu_to_be32(segments);
-- 
2.3.3

