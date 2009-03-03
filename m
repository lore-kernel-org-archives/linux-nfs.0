From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 18/46] NFS: get rid of unused xdr decode_setattr(, res) argument
Date: Wed,  4 Mar 2009 01:55:05 +0200
Message-ID: <1236124505-3459-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17544
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753707AbZCCXzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:55:17 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 62fc817..13320af 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3573,7 +3573,7 @@ decode_savefh(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_SAVEFH);
 }
 
-static int decode_setattr(struct xdr_stream *xdr, struct nfs_setattrres *res)
+static int decode_setattr(struct xdr_stream *xdr)
 {
 	__be32 *p;
 	uint32_t bmlen;
@@ -3924,7 +3924,7 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr, res);
+	status = decode_setattr(&xdr);
 out:
 	return status;
 }
@@ -4077,7 +4077,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr, res);
+	status = decode_setattr(&xdr);
 	if (status)
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
-- 
1.6.1.3

