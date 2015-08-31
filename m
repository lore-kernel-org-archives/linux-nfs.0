Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:13094 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667AbbHaTuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 15:50:24 -0400
From: <andros@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH 04/16] NFS COPY xdr changes
Date: Mon, 31 Aug 2015 15:49:54 -0400
Message-ID: <1441050606-40897-5-git-send-email-andros@netapp.com>
In-Reply-To: <1441050606-40897-1-git-send-email-andros@netapp.com>
References: <1441050606-40897-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

add support for decoding NFS4ERR_OFFLOAD_NO_REQS status and corresponding
copy_requirements structure.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42xdr.c | 35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 489bbf3..ae260d3 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -290,19 +290,9 @@ out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
-
-static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
-{
+static int decode_copy_requirements(struct xdr_stream *xdr,
+				    struct nfs42_copy_res *res) {
 	__be32 *p;
-	int status;
-
-	status = decode_op_hdr(xdr, OP_COPY);
-	if (status)
-		return status;
-
-	status = decode_write_response(xdr, &res->write_res);
-	if (status)
-		return status;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
 	if (unlikely(!p))
@@ -311,12 +301,31 @@ static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
 	res->consecutive = be32_to_cpup(p++);
 	res->synchronous = be32_to_cpup(p++);
 	return 0;
-
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
 
+static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
+{
+	int status;
+
+	status = decode_op_hdr(xdr, OP_COPY);
+	if (status == NFS4ERR_OFFLOAD_NO_REQS) {
+		status = decode_copy_requirements(xdr, res);
+		if (status)
+			return status;
+		return NFS4ERR_OFFLOAD_NO_REQS;
+	} else if (status)
+		return status;
+
+	status = decode_write_response(xdr, &res->write_res);
+	if (status)
+		return status;
+
+	return decode_copy_requirements(xdr, res);
+}
+
 static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
-- 
1.8.3.1

