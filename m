From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 16/67] NFS: get rid of unused xdr decode_setattr(, res) argument
Date: Thu,  2 Apr 2009 16:52:30 +0300
Message-ID: <1238680350-13900-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25924 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753959AbZDBNwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:42 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3e77789..27dd25d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3658,7 +3658,7 @@ decode_savefh(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_SAVEFH);
 }
 
-static int decode_setattr(struct xdr_stream *xdr, struct nfs_setattrres *res)
+static int decode_setattr(struct xdr_stream *xdr)
 {
 	__be32 *p;
 	uint32_t bmlen;
@@ -4009,7 +4009,7 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr, res);
+	status = decode_setattr(&xdr);
 out:
 	return status;
 }
@@ -4162,7 +4162,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr, res);
+	status = decode_setattr(&xdr);
 	if (status)
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
-- 
1.6.2.1

