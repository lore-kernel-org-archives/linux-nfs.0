Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:27516 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761452AbbA1UnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:43:04 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3/4] NFSD: Add READ_PLUS support for hole segments
Date: Wed, 28 Jan 2015 15:42:56 -0500
Message-ID: <1422477777-27933-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This patch adds support for returning NFS4_CONTENT_HOLE segments to the
client.  I did notice a race condition where the same offset can be
reported as both a hole and as data, and this patch gets around this
without a lock by encoding questionable regions as data.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c |  4 ++--
 fs/nfsd/nfs4xdr.c  | 34 +++++++++++++++++++++++++++++++---
 2 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fdf9ce3..3db34ee 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1607,8 +1607,8 @@ static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op
 {
 	u32 maxcount = svc_max_payload(rqstp);
 	u32 rlen = min(op->u.read.rd_length, maxcount);
-	/* extra xdr space for encoding read plus segments. */
-	u32 xdr  = 4;
+	/* enough extra xdr space for encoding either a hole or data segment. */
+	u32 xdr  = 5;
 
 	return (op_encode_hdr_size + 2 + xdr + XDR_QUADLEN(rlen)) * sizeof(__be32);
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 480b07f..c85e658 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3803,7 +3803,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 static __be32
 nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
-			    struct file *file)
+			    struct file *file, loff_t hole_pos)
 {
 	__be32 *p, err;
 	unsigned long maxcount;
@@ -3817,6 +3817,7 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	maxcount = svc_max_payload(resp->rqstp);
 	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+	maxcount = min_t(unsigned long, maxcount, hole_pos - read->rd_offset);
 
 	err = nfsd4_encode_readv(resp, read, file, &maxcount);
 
@@ -3829,6 +3830,22 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 }
 
 static __be32
+nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
+			    struct file *file, loff_t data_pos)
+{
+	__be32 *p;
+	unsigned long maxcount = data_pos - read->rd_offset;
+
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
 nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 		       struct nfsd4_read *read)
 {
@@ -3836,6 +3853,7 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct file *file = read->rd_filp;
 	int starting_len = xdr->buf->len;
 	struct raparms *ra;
+	loff_t hole_pos, data_pos;
 	__be32 *p;
 	__be32 err;
 	u32 eof, segments = 0;
@@ -3856,10 +3874,20 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 			goto err_truncate;
 	}
 
-	if (read->rd_offset >= i_size_read(file_inode(file)))
+	hole_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_HOLE);
+	if (hole_pos == -ENXIO)
 		goto out_encode;
 
-	err = nfsd4_encode_read_plus_data(resp, read, file);
+	data_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_DATA);
+	if (data_pos == -ENXIO)
+		data_pos = i_size_read(file_inode(file));
+
+	if ((data_pos == read->rd_offset) && (hole_pos > data_pos))
+		err = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
+	else if ((hole_pos == read->rd_offset) && (data_pos > hole_pos))
+		err = nfsd4_encode_read_plus_hole(resp, read, file, data_pos);
+	else /* The file probably changed on us between seeks. */
+		err = nfsd4_encode_read_plus_data(resp, read, file, i_size_read(file_inode(file)));
 	segments++;
 
 out_encode:
-- 
2.2.2

