Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37266 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbaJQVYr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2014 17:24:47 -0400
Date: Fri, 17 Oct 2014 17:24:46 -0400
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Message-ID: <20141017212446.GC3474@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We added this new estimator function but forgot to hook it up.  The
effect is that NFSv4.1 won't do zero-copy reads.

The estimate was also wrong by 8 bytes.

Fixes: ccae70a9ee41 "nfsd4: estimate sequence response size"
Cc: stable@vger.kernel.org
Reported-by: Chuck Lever <chucklever@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Whoops, this should have gone in some time ago but I lost it somehow.
Thanks to Chuck for noticing the oversight.

I'll pass it along upstream soon.--b.

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cdeb3cf..f990983 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1589,7 +1589,8 @@ static inline u32 nfsd4_rename_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op
 static inline u32 nfsd4_sequence_rsize(struct svc_rqst *rqstp,
 				       struct nfsd4_op *op)
 {
-	return NFS4_MAX_SESSIONID_LEN + 20;
+	return (op_encode_hdr_size
+		+ XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN + 5)) * sizeof(__be32);
 }
 
 static inline u32 nfsd4_setattr_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
@@ -1893,6 +1894,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_sequence,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_sequence_rsize,
 	},
 	[OP_DESTROY_CLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
-- 
1.9.1

