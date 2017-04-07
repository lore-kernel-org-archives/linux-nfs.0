Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:55096 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932552AbdDGSPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:51 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/34] NFS: Remove extra dprintk()s from callback_xdr.c
Date: Fri, 7 Apr 2017 14:15:04 -0400
Message-ID: <20170407181528.2832-11-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_xdr.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e54e697340a4..c14758e08d73 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -171,8 +171,6 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 	}
 	hdr->nops = ntohl(*p);
-	dprintk("%s: minorversion %d nops %d\n", __func__,
-		hdr->minorversion, hdr->nops);
 	return 0;
 }
 
@@ -665,7 +663,6 @@ static __be32 encode_getattr_res(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	status = encode_attr_mtime(xdr, res->bitmap, &res->mtime);
 	*savep = htonl((unsigned int)((char *)xdr->p - (char *)(savep+1)));
 out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -827,14 +824,10 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 	long maxlen;
 	__be32 res;
 
-	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
 	if (unlikely(status))
 		return status;
 
-	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
-		__func__, cps->minorversion, nop, op_nr);
-
 	switch (cps->minorversion) {
 	case 0:
 		status = preprocess_nfs4_op(op_nr, &op);
@@ -873,7 +866,6 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 		return res;
 	if (op->encode_res != NULL && status == 0)
 		status = op->encode_res(rqstp, xdr_out, resp);
-	dprintk("%s: done, status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -893,8 +885,6 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	};
 	unsigned int nops = 0;
 
-	dprintk("%s: start\n", __func__);
-
 	xdr_init_decode(&xdr_in, &rqstp->rq_arg, rqstp->rq_arg.head[0].iov_base);
 
 	p = (__be32*)((char *)rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len);
@@ -933,7 +923,6 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	*hdr_res.nops = htonl(nops);
 	nfs4_cb_free_slot(&cps);
 	nfs_put_client(cps.clp);
-	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
 
 out_invalidcred:
-- 
2.12.2

