Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47143 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbaLQWfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:15 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4] NFSD: Add support for encoding holes in files
Date: Wed, 17 Dec 2014 17:35:03 -0500
Message-ID: <1418855704-14127-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
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
 fs/nfsd/nfs4xdr.c | 34 +++++++++++++++++++++++++++++++---
 1 file changed, 31 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6ed22ca..2ec9860 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3800,7 +3800,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 static __be32
 nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *read,
-			    struct file *file)
+			    struct file *file, loff_t hole_pos)
 {
 	__be32 *p, err;
 	unsigned long maxcount;
@@ -3814,6 +3814,7 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	maxcount = svc_max_payload(resp->rqstp);
 	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+	maxcount = min_t(unsigned long, maxcount, hole_pos - read->rd_offset);
 
 	err = nfsd4_encode_readv(resp, read, file, &maxcount);
 
@@ -3826,6 +3827,22 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
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
@@ -3833,6 +3850,7 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct file *file = read->rd_filp;
 	int starting_len = xdr->buf->len;
 	struct raparms *ra;
+	loff_t hole_pos, data_pos;
 	__be32 *p;
 	__be32 err;
 	u32 eof, segments = 0;
@@ -3853,10 +3871,20 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
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
2.1.3

