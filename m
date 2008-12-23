From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 50/69] NFS: remove white space from nfs4xdr.c
Date: Tue, 23 Dec 2008 18:02:20 -0500
Message-ID: <20081223230220.13743.8821.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbYLWXYp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:45 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0b006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Clean-up

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |   62 +++++++++++++++++++++++++-----------------------------
 1 files changed, 29 insertions(+), 33 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7eeed0e..7dde309 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -8,7 +8,7 @@
  *
  *  Kendrick Smith <kmsmith@umich.edu>
  *  Andy Adamson   <andros@umich.edu>
- * 
+ *
  *  Redistribution and use in source and binary forms, with or without
  *  modification, are permitted provided that the following conditions
  *  are met:
@@ -67,7 +67,7 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_MAXTAGLEN		0
 #endif
 
-/* lock,open owner id: 
+/* lock,open owner id:
  * we currently use size 2 (u64) out of (NFS4_OPAQUE_LIMIT  >> 2)
  */
 #define open_owner_id_maxsz	(1 + 4)
@@ -709,7 +709,7 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
 		WRITE32(NFS4_SET_TO_SERVER_TIME);
 	}
-	
+
 	/*
 	 * Now we backfill the bitmap and the attribute buffer length.
 	 */
@@ -735,7 +735,7 @@ static int encode_access(struct xdr_stream *xdr, u32 access)
 	RESERVE_SPACE(8);
 	WRITE32(OP_ACCESS);
 	WRITE32(access);
-	
+
 	return 0;
 }
 
@@ -747,14 +747,14 @@ static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
 	WRITE32(OP_CLOSE);
 	WRITE32(arg->seqid->sequence->counter);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
-	
+
 	return 0;
 }
 
 static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args)
 {
 	__be32 *p;
-        
+
         RESERVE_SPACE(16);
         WRITE32(OP_COMMIT);
         WRITE64(args->offset);
@@ -766,7 +766,7 @@ static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create)
 {
 	__be32 *p;
-	
+
 	RESERVE_SPACE(8);
 	WRITE32(OP_CREATE);
 	WRITE32(create->ftype);
@@ -856,7 +856,7 @@ static int encode_link(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_LINK);
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
-	
+
 	return 0;
 }
 
@@ -1133,7 +1133,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh)
 static int encode_putrootfh(struct xdr_stream *xdr)
 {
         __be32 *p;
-        
+
         RESERVE_SPACE(4);
         WRITE32(OP_PUTROOTFH);
 
@@ -1232,7 +1232,7 @@ static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, con
 	WRITE32(OP_RENAME);
 	WRITE32(oldname->len);
 	WRITEMEM(oldname->name, oldname->len);
-	
+
 	RESERVE_SPACE(4 + newname->len);
 	WRITE32(newname->len);
 	WRITEMEM(newname->name, newname->len);
@@ -1296,7 +1296,7 @@ static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *
 {
 	int status;
 	__be32 *p;
-	
+
         RESERVE_SPACE(4+NFS4_STATEID_SIZE);
         WRITE32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
@@ -2217,7 +2217,7 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	READ_BUF(8);
 	READ32(hdr->status);
 	READ32(hdr->taglen);
-	
+
 	READ_BUF(hdr->taglen + 4);
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
@@ -3049,8 +3049,7 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
 {
 	__be32 *savep;
-	uint32_t attrlen, 
-		 bitmap[2] = {0};
+	uint32_t attrlen, bitmap[2] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -3072,14 +3071,13 @@ xdr_error:
 	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
-	
+
 static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 {
 	__be32 *savep;
-	uint32_t attrlen, 
-		 bitmap[2] = {0};
+	uint32_t attrlen, bitmap[2] = {0};
 	int status;
-	
+
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
@@ -3109,10 +3107,9 @@ xdr_error:
 static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf)
 {
 	__be32 *savep;
-	uint32_t attrlen, 
-		 bitmap[2] = {0};
+	uint32_t attrlen, bitmap[2] = {0};
 	int status;
-	
+
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
@@ -3258,7 +3255,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 static int decode_link(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 {
 	int status;
-	
+
 	status = decode_op_hdr(xdr, OP_LINK);
 	if (status)
 		return status;
@@ -3564,7 +3561,7 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
 	}
-out:	
+out:
 	kunmap_atomic(kaddr, KM_USER0);
 	return 0;
 short_pkt:
@@ -3720,7 +3717,6 @@ static int decode_setattr(struct xdr_stream *xdr, struct nfs_setattrres *res)
 	uint32_t bmlen;
 	int status;
 
-        
 	status = decode_op_hdr(xdr, OP_SETATTR);
 	if (status)
 		return status;
@@ -3740,7 +3736,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	READ32(opnum);
 	if (opnum != OP_SETCLIENTID) {
 		dprintk("nfs: decode_setclientid: Server returned operation"
-			       	" %d\n", opnum);
+			" %d\n", opnum);
 		return -EIO;
 	}
 	READ32(nfserr);
@@ -3829,7 +3825,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -3852,7 +3848,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -3875,7 +3871,7 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -3895,7 +3891,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -3916,7 +3912,7 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -3946,7 +3942,7 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -3979,7 +3975,7 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
 		goto out;
@@ -4016,7 +4012,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)

