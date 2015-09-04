Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:17257 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDTH1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 15:07:27 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 3/3] NFSD: Add support for encoding multiple segments
Date: Fri, 4 Sep 2015 15:07:21 -0400
Message-ID: <1441393641-30152-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1441393641-30152-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1441393641-30152-1-git-send-email-Anna.Schumaker@Netapp.com>
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
 fs/nfsd/nfs4xdr.c  | 27 ++++++++++++++++++---------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fe4fc24..0e34ae9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1853,8 +1853,8 @@ static inline u32 nfsd4_read_plus_rsize(struct svc_rqst *rqstp, struct nfsd4_op
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
index 7ab4033..735a4ff 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4152,12 +4152,14 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
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
 
@@ -4181,6 +4183,10 @@ nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	p = xdr_encode_hyper(p, maxcount);
 
 	read->rd_offset += maxcount;
+	if (maxcount > read->rd_length)
+		read->rd_length = 0;
+	else
+		read->rd_length -= maxcount;
 	return nfs_ok;
 }
 
@@ -4210,17 +4216,20 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (read->rd_tmp_file)
 		ra = nfsd_init_raparms(file);
 
-	hole_pos = vfs_llseek(file, read->rd_offset, SEEK_HOLE);
-	if (hole_pos == -ENXIO)
-		goto out_encode;
+	do {
+		hole_pos = vfs_llseek(file, read->rd_offset, SEEK_HOLE);
+		if (hole_pos == -ENXIO)
+			break;
 
-	if (hole_pos == read->rd_offset)
-		nfserr = nfsd4_encode_read_plus_hole(resp, read, file);
-	else
-		nfserr = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
-	segments++;
+		if (hole_pos == read->rd_offset)
+			nfserr = nfsd4_encode_read_plus_hole(resp, read, file);
+		else
+			nfserr = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
+		if (nfserr)
+			break;
+		segments++;
+	} while (read->rd_length > 0);
 
-out_encode:
 	eof = (read->rd_offset >= i_size_read(file_inode(file)));
 	*p++ = cpu_to_be32(eof);
 	*p++ = cpu_to_be32(segments);
-- 
2.5.1

