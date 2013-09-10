Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47978 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408Ab3IJQ4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 12:56:35 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 1/1] NFSv4.1 fix decode_free_stateid
Date: Tue, 10 Sep 2013 12:56:29 -0400
Message-ID: <1378832189-2532-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The operation status is decoded in decode_op_hdr.

Stop the print_overflow message that is always hit without this patch:
nfs: decode_free_stateid: prematurely hit end of receive buffer. Remaining
buffer length is 0 words.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fbdad9e..79210d2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -414,7 +414,7 @@ static int nfs4_stat_to_errno(int);
 #define decode_test_stateid_maxsz	(op_decode_hdr_maxsz + 2 + 1)
 #define encode_free_stateid_maxsz	(op_encode_hdr_maxsz + 1 + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE))
-#define decode_free_stateid_maxsz	(op_decode_hdr_maxsz + 1)
+#define decode_free_stateid_maxsz	(op_decode_hdr_maxsz)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -5966,21 +5966,8 @@ out:
 static int decode_free_stateid(struct xdr_stream *xdr,
 			       struct nfs41_free_stateid_res *res)
 {
-	__be32 *p;
-	int status;
-
-	status = decode_op_hdr(xdr, OP_FREE_STATEID);
-	if (status)
-		return status;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	res->status = be32_to_cpup(p++);
+	res->status = decode_op_hdr(xdr, OP_FREE_STATEID);
 	return res->status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.8.3.1

