Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:27930 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDTH5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 15:07:57 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v1 5/5] NFS: Add support for decoding multiple segments
Date: Fri, 4 Sep 2015 15:07:49 -0400
Message-ID: <1441393669-30280-6-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1441393669-30280-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1441393669-30280-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We now have everything we need to read holes and then shift data to
where it's supposed to be.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 333da85..b0e6a35 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -275,11 +275,11 @@ static int decode_read_plus_data(struct xdr_stream *xdr, struct nfs_pgio_res *re
 	p = xdr_decode_hyper(p, &offset);
 	count = be32_to_cpup(p);
 
-	recvd = xdr_read_pages(xdr, count);
+	recvd = xdr_align_data(xdr, res->count, count);
 	if (recvd < count)
 		res->eof = 0;
 
-	res->count = recvd;
+	res->count += recvd;
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -299,11 +299,11 @@ static int decode_read_plus_hole(struct xdr_stream *xdr, struct nfs_pgio_res *re
 	p = xdr_decode_hyper(p, &offset);
 	p = xdr_decode_hyper(p, &length);
 
-	recvd = xdr_expand_hole(xdr, 0, length);
+	recvd = xdr_expand_hole(xdr, res->count, length);
 	if (recvd < length)
 		res->eof = 0;
 
-	res->count = recvd;
+	res->count += recvd;
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -314,7 +314,7 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 {
 	__be32 *p;
 	int status, type;
-	uint32_t segments;
+	uint32_t i, segments;
 
 	status = decode_op_hdr(xdr, OP_READ_PLUS);
 	if (status)
@@ -327,20 +327,24 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 	res->count = 0;
 	res->eof = be32_to_cpup(p++);
 	segments = be32_to_cpup(p++);
-	if (segments == 0)
-		return 0;
 
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
+	for (i = 0; i < segments; i++) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 
-	type = be32_to_cpup(p++);
-	if (type == NFS4_CONTENT_DATA)
-		status = decode_read_plus_data(xdr, res);
-	else
-		status = decode_read_plus_hole(xdr, res);
+		type = be32_to_cpup(p);
+		if (type == NFS4_CONTENT_DATA)
+			status = decode_read_plus_data(xdr, res);
+		else
+			status = decode_read_plus_hole(xdr, res);
+		if (status)
+			break;
+		if (res->count == xdr->buf->page_len)
+			break;
+	}
 
-	if (segments > 1)
+	if (i < segments)
 		res->eof = 0;
 	return status;
 out_overflow:
-- 
2.5.1

