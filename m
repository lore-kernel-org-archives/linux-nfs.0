Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:47457 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933251AbbA1UnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:43:04 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 4/4] NFSD: Add support for encoding multiple segments
Date: Wed, 28 Jan 2015 15:42:57 -0500
Message-ID: <1422477777-27933-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This patch implements sending an array of segments back to the client.
Clients should be prepared to handle multiple segment reads to make this
useful.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c |  4 ++--
 fs/nfsd/nfs4xdr.c  | 36 ++++++++++++++++++++++--------------
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3db34ee..5f3c75a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1607,8 +1607,8 @@ static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op
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
index c85e658..dbd4580 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3826,6 +3826,7 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	*p++ = cpu_to_be32(maxcount);
 
 	read->rd_offset += maxcount;
+	read->rd_length -= maxcount;
 	return err;
 }
 
@@ -3842,6 +3843,10 @@ nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	p = xdr_encode_hyper(p, maxcount);
 
 	read->rd_offset += maxcount;
+	if (maxcount > read->rd_length)
+		read->rd_length = 0;
+	else
+		read->rd_length -= maxcount;
 	return nfs_ok;
 }
 
@@ -3874,23 +3879,26 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 			goto err_truncate;
 	}
 
-	hole_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_HOLE);
-	if (hole_pos == -ENXIO)
-		goto out_encode;
+	do {
+		hole_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_HOLE);
+		if (hole_pos == -ENXIO)
+			break;
 
-	data_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_DATA);
-	if (data_pos == -ENXIO)
-		data_pos = i_size_read(file_inode(file));
+		data_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_DATA);
+		if (data_pos == -ENXIO)
+			data_pos = i_size_read(file_inode(file));
 
-	if ((data_pos == read->rd_offset) && (hole_pos > data_pos))
-		err = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
-	else if ((hole_pos == read->rd_offset) && (data_pos > hole_pos))
-		err = nfsd4_encode_read_plus_hole(resp, read, file, data_pos);
-	else /* The file probably changed on us between seeks. */
-		err = nfsd4_encode_read_plus_data(resp, read, file, i_size_read(file_inode(file)));
-	segments++;
+		if ((data_pos == read->rd_offset) && (hole_pos > data_pos))
+			err = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
+		else if ((hole_pos == read->rd_offset) && (data_pos > hole_pos))
+			err = nfsd4_encode_read_plus_hole(resp, read, file, data_pos);
+		else /* The file probably changed on us between seeks. */
+			err = nfsd4_encode_read_plus_data(resp, read, file, i_size_read(file_inode(file)));
+		if (err)
+			break;
+		segments++;
+	} while (read->rd_length > 0);
 
-out_encode:
 	eof = (read->rd_offset >= i_size_read(file_inode(file)));
 	*p++ = cpu_to_be32(eof);
 	*p++ = cpu_to_be32(segments);
-- 
2.2.2

