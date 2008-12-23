From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 51/69] NFS: fix tabs in nfs4xdr.c
Date: Tue, 23 Dec 2008 18:02:21 -0500
Message-ID: <20081223230220.13743.71354.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbYLWXYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:41 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcSi021557
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |  490 +++++++++++++++++++++++++++---------------------------
 1 files changed, 245 insertions(+), 245 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7dde309..29656c5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -755,12 +755,12 @@ static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 {
 	__be32 *p;
 
-        RESERVE_SPACE(16);
-        WRITE32(OP_COMMIT);
-        WRITE64(args->offset);
-        WRITE32(args->count);
+	RESERVE_SPACE(16);
+	WRITE32(OP_COMMIT);
+	WRITE64(args->offset);
+	WRITE32(args->count);
 
-        return 0;
+	return 0;
 }
 
 static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create)
@@ -797,25 +797,25 @@ static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *c
 
 static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap)
 {
-        __be32 *p;
+	__be32 *p;
 
-        RESERVE_SPACE(12);
-        WRITE32(OP_GETATTR);
-        WRITE32(1);
-        WRITE32(bitmap);
-        return 0;
+	RESERVE_SPACE(12);
+	WRITE32(OP_GETATTR);
+	WRITE32(1);
+	WRITE32(bitmap);
+	return 0;
 }
 
 static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1)
 {
-        __be32 *p;
+	__be32 *p;
 
-        RESERVE_SPACE(16);
-        WRITE32(OP_GETATTR);
-        WRITE32(2);
-        WRITE32(bm0);
-        WRITE32(bm1);
-        return 0;
+	RESERVE_SPACE(16);
+	WRITE32(OP_GETATTR);
+	WRITE32(2);
+	WRITE32(bm0);
+	WRITE32(bm1);
+	return 0;
 }
 
 static int encode_getfattr(struct xdr_stream *xdr, const u32* bitmask)
@@ -959,17 +959,17 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 
 	RESERVE_SPACE(8);
 	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
-		case FMODE_READ:
-			WRITE32(NFS4_SHARE_ACCESS_READ);
-			break;
-		case FMODE_WRITE:
-			WRITE32(NFS4_SHARE_ACCESS_WRITE);
-			break;
-		case FMODE_READ|FMODE_WRITE:
-			WRITE32(NFS4_SHARE_ACCESS_BOTH);
-			break;
-		default:
-			WRITE32(0);
+	case FMODE_READ:
+		WRITE32(NFS4_SHARE_ACCESS_READ);
+		break;
+	case FMODE_WRITE:
+		WRITE32(NFS4_SHARE_ACCESS_WRITE);
+		break;
+	case FMODE_READ|FMODE_WRITE:
+		WRITE32(NFS4_SHARE_ACCESS_BOTH);
+		break;
+	default:
+		WRITE32(0);
 	}
 	WRITE32(0);		/* for linux, share_deny = 0 always */
 }
@@ -998,13 +998,13 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 
 	RESERVE_SPACE(4);
 	switch(arg->open_flags & O_EXCL) {
-		case 0:
-			WRITE32(NFS4_CREATE_UNCHECKED);
-			encode_attrs(xdr, arg->u.attrs, arg->server);
-			break;
-		default:
-			WRITE32(NFS4_CREATE_EXCLUSIVE);
-			encode_nfs4_verifier(xdr, &arg->u.verifier);
+	case 0:
+		WRITE32(NFS4_CREATE_UNCHECKED);
+		encode_attrs(xdr, arg->u.attrs, arg->server);
+		break;
+	default:
+		WRITE32(NFS4_CREATE_EXCLUSIVE);
+		encode_nfs4_verifier(xdr, &arg->u.verifier);
 	}
 }
 
@@ -1014,13 +1014,13 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 
 	RESERVE_SPACE(4);
 	switch (arg->open_flags & O_CREAT) {
-		case 0:
-			WRITE32(NFS4_OPEN_NOCREATE);
-			break;
-		default:
-			BUG_ON(arg->claim != NFS4_OPEN_CLAIM_NULL);
-			WRITE32(NFS4_OPEN_CREATE);
-			encode_createmode(xdr, arg);
+	case 0:
+		WRITE32(NFS4_OPEN_NOCREATE);
+		break;
+	default:
+		BUG_ON(arg->claim != NFS4_OPEN_CLAIM_NULL);
+		WRITE32(NFS4_OPEN_CREATE);
+		encode_createmode(xdr, arg);
 	}
 }
 
@@ -1030,17 +1030,17 @@ static inline void encode_delegation_type(struct xdr_stream *xdr, fmode_t delega
 
 	RESERVE_SPACE(4);
 	switch (delegation_type) {
-		case 0:
-			WRITE32(NFS4_OPEN_DELEGATE_NONE);
-			break;
-		case FMODE_READ:
-			WRITE32(NFS4_OPEN_DELEGATE_READ);
-			break;
-		case FMODE_WRITE|FMODE_READ:
-			WRITE32(NFS4_OPEN_DELEGATE_WRITE);
-			break;
-		default:
-			BUG();
+	case 0:
+		WRITE32(NFS4_OPEN_DELEGATE_NONE);
+		break;
+	case FMODE_READ:
+		WRITE32(NFS4_OPEN_DELEGATE_READ);
+		break;
+	case FMODE_WRITE|FMODE_READ:
+		WRITE32(NFS4_OPEN_DELEGATE_WRITE);
+		break;
+	default:
+		BUG();
 	}
 }
 
@@ -1077,17 +1077,17 @@ static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 	encode_openhdr(xdr, arg);
 	encode_opentype(xdr, arg);
 	switch (arg->claim) {
-		case NFS4_OPEN_CLAIM_NULL:
-			encode_claim_null(xdr, arg->name);
-			break;
-		case NFS4_OPEN_CLAIM_PREVIOUS:
-			encode_claim_previous(xdr, arg->u.delegation_type);
-			break;
-		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
-			encode_claim_delegate_cur(xdr, arg->name, &arg->u.delegation);
-			break;
-		default:
-			BUG();
+	case NFS4_OPEN_CLAIM_NULL:
+		encode_claim_null(xdr, arg->name);
+		break;
+	case NFS4_OPEN_CLAIM_PREVIOUS:
+		encode_claim_previous(xdr, arg->u.delegation_type);
+		break;
+	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+		encode_claim_delegate_cur(xdr, arg->name, &arg->u.delegation);
+		break;
+	default:
+		BUG();
 	}
 	return 0;
 }
@@ -1132,12 +1132,12 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh)
 
 static int encode_putrootfh(struct xdr_stream *xdr)
 {
-        __be32 *p;
+	__be32 *p;
 
-        RESERVE_SPACE(4);
-        WRITE32(OP_PUTROOTFH);
+	RESERVE_SPACE(4);
+	WRITE32(OP_PUTROOTFH);
 
-        return 0;
+	return 0;
 }
 
 static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx)
@@ -1297,14 +1297,14 @@ static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *
 	int status;
 	__be32 *p;
 
-        RESERVE_SPACE(4+NFS4_STATEID_SIZE);
-        WRITE32(OP_SETATTR);
+	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	WRITE32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
 
-        if ((status = encode_attrs(xdr, arg->iap, server)))
+	if ((status = encode_attrs(xdr, arg->iap, server)))
 		return status;
 
-        return 0;
+	return 0;
 }
 
 static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid)
@@ -1328,14 +1328,14 @@ static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclien
 
 static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state)
 {
-        __be32 *p;
+	__be32 *p;
 
-        RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
-        WRITE32(OP_SETCLIENTID_CONFIRM);
-        WRITE64(client_state->cl_clientid);
-        WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
+	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
+	WRITE32(OP_SETCLIENTID_CONFIRM);
+	WRITE64(client_state->cl_clientid);
+	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 
-        return 0;
+	return 0;
 }
 
 static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args)
@@ -1584,23 +1584,23 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
  */
 static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr = {
-                .nops   = 3,
-        };
-        int status;
-
-        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-        encode_compound_hdr(&xdr, &hdr);
-        status = encode_putfh(&xdr, args->fh);
-        if(status)
-                goto out;
-        status = encode_close(&xdr, args);
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops   = 3,
+	};
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh);
+	if(status)
+		goto out;
+	status = encode_close(&xdr, args);
 	if (status != 0)
 		goto out;
 	status = encode_getfattr(&xdr, args->bitmask);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -1875,25 +1875,24 @@ out:
  * Encode an SETATTR request
  */
 static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_setattrargs *args)
-
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr = {
-                .nops   = 3,
-        };
-        int status;
-
-        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-        encode_compound_hdr(&xdr, &hdr);
-        status = encode_putfh(&xdr, args->fh);
-        if(status)
-                goto out;
-        status = encode_setattr(&xdr, args, args->server);
-        if(status)
-                goto out;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops   = 3,
+	};
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh);
+	if(status)
+		goto out;
+	status = encode_setattr(&xdr, args, args->server);
+	if(status)
+		goto out;
 	status = encode_getfattr(&xdr, args->bitmask);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -3343,27 +3342,27 @@ static int decode_lookup(struct xdr_stream *xdr)
 /* This is too sick! */
 static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 {
-        __be32 *p;
+	__be32 *p;
 	uint32_t limit_type, nblocks, blocksize;
 
 	READ_BUF(12);
 	READ32(limit_type);
 	switch (limit_type) {
-		case 1:
-			READ64(*maxsize);
-			break;
-		case 2:
-			READ32(nblocks);
-			READ32(blocksize);
-			*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
+	case 1:
+		READ64(*maxsize);
+		break;
+	case 2:
+		READ32(nblocks);
+		READ32(blocksize);
+		*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
 	return 0;
 }
 
 static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 {
-        __be32 *p;
-        uint32_t delegation_type;
+	__be32 *p;
+	uint32_t delegation_type;
 
 	READ_BUF(4);
 	READ32(delegation_type);
@@ -3374,13 +3373,14 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	READ_BUF(NFS4_STATEID_SIZE+4);
 	COPYMEM(res->delegation.data, NFS4_STATEID_SIZE);
 	READ32(res->do_recall);
+
 	switch (delegation_type) {
-		case NFS4_OPEN_DELEGATE_READ:
-			res->delegation_type = FMODE_READ;
-			break;
-		case NFS4_OPEN_DELEGATE_WRITE:
-			res->delegation_type = FMODE_WRITE|FMODE_READ;
-			if (decode_space_limit(xdr, &res->maxsize) < 0)
+	case NFS4_OPEN_DELEGATE_READ:
+		res->delegation_type = FMODE_READ;
+		break;
+	case NFS4_OPEN_DELEGATE_WRITE:
+		res->delegation_type = FMODE_WRITE|FMODE_READ;
+		if (decode_space_limit(xdr, &res->maxsize) < 0)
 				return -EIO;
 	}
 	return decode_ace(xdr, NULL, res->server->nfs_client);
@@ -3388,27 +3388,27 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 
 static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 {
-        __be32 *p;
+	__be32 *p;
 	uint32_t savewords, bmlen, i;
-        int status;
+	int status;
 
-        status = decode_op_hdr(xdr, OP_OPEN);
+	status = decode_op_hdr(xdr, OP_OPEN);
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
-        if (status)
-                return status;
-        READ_BUF(NFS4_STATEID_SIZE);
-        COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+	if (status)
+		return status;
+	READ_BUF(NFS4_STATEID_SIZE);
+	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
 
-        decode_change_info(xdr, &res->cinfo);
+	decode_change_info(xdr, &res->cinfo);
 
-        READ_BUF(8);
-        READ32(res->rflags);
-        READ32(bmlen);
-        if (bmlen > 10)
-                goto xdr_error;
+	READ_BUF(8);
+	READ32(res->rflags);
+	READ32(bmlen);
+	if (bmlen > 10)
+		goto xdr_error;
 
-        READ_BUF(bmlen << 2);
+	READ_BUF(bmlen << 2);
 	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
 	for (i = 0; i < savewords; ++i)
 		READ32(res->attrset[i]);
@@ -3423,17 +3423,17 @@ xdr_error:
 
 static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmres *res)
 {
-        __be32 *p;
+	__be32 *p;
 	int status;
 
-        status = decode_op_hdr(xdr, OP_OPEN_CONFIRM);
+	status = decode_op_hdr(xdr, OP_OPEN_CONFIRM);
 	if (status != -EIO)
 		nfs_increment_open_seqid(status, res->seqid);
-        if (status)
-                return status;
-        READ_BUF(NFS4_STATEID_SIZE);
-        COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
-        return 0;
+	if (status)
+		return status;
+	READ_BUF(NFS4_STATEID_SIZE);
+	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+	return 0;
 }
 
 static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *res)
@@ -3794,23 +3794,23 @@ static int decode_delegreturn(struct xdr_stream *xdr)
  */
 static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
-
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
-        status = decode_putfh(&xdr);
-        if (status)
-                goto out;
-        status = decode_open_downgrade(&xdr, res);
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_open_downgrade(&xdr, res);
 	if (status != 0)
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -4023,7 +4023,6 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
-
 }
 
 /*
@@ -4032,21 +4031,22 @@ out:
 static int
 nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr = {
-                .nops   = 2,
-        };
-        int status;
-
-        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-        encode_compound_hdr(&xdr, &hdr);
-        status = encode_putfh(&xdr, args->fh);
-        if (status)
-                goto out;
-        status = encode_setacl(&xdr, args);
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops   = 2,
+	};
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh);
+	if (status)
+		goto out;
+	status = encode_setacl(&xdr, args);
 out:
-        return status;
+	return status;
 }
+
 /*
  * Decode SETACL response
  */
@@ -4097,18 +4097,18 @@ out:
  */
 static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
-
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
-        status = decode_putfh(&xdr);
-        if (status)
-                goto out;
-        status = decode_close(&xdr, res);
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_close(&xdr, res);
 	if (status != 0)
 		goto out;
 	/*
@@ -4119,7 +4119,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 */
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -4127,23 +4127,23 @@ out:
  */
 static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
-
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
-        status = decode_putfh(&xdr);
-        if (status)
-                goto out;
-        status = decode_savefh(&xdr);
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_savefh(&xdr);
+	if (status)
+		goto out;
+	status = decode_open(&xdr, res);
 	if (status)
 		goto out;
-        status = decode_open(&xdr, res);
-        if (status)
-                goto out;
 	if (decode_getfh(&xdr, &res->fh) != 0)
 		goto out;
 	if (decode_getfattr(&xdr, res->f_attr, res->server) != 0)
@@ -4152,7 +4152,7 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -4160,20 +4160,20 @@ out:
  */
 static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp, __be32 *p, struct nfs_open_confirmres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
-
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
-        status = decode_putfh(&xdr);
-        if (status)
-                goto out;
-        status = decode_open_confirm(&xdr, res);
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_open_confirm(&xdr, res);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -4181,23 +4181,23 @@ out:
  */
 static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
-
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
-        status = decode_putfh(&xdr);
-        if (status)
-                goto out;
-        status = decode_open(&xdr, res);
-        if (status)
-                goto out;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_open(&xdr, res);
+	if (status)
+		goto out;
 	decode_getfattr(&xdr, res->f_attr, res->server);
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -4205,25 +4205,25 @@ out:
  */
 static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_setattrres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
-
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
-        status = decode_putfh(&xdr);
-        if (status)
-                goto out;
-        status = decode_setattr(&xdr, res);
-        if (status)
-                goto out;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_putfh(&xdr);
+	if (status)
+		goto out;
+	status = decode_setattr(&xdr, res);
+	if (status)
+		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 	if (status == NFS4ERR_DELAY)
 		status = 0;
 out:
-        return status;
+	return status;
 }
 
 /*
@@ -4707,7 +4707,7 @@ nfs4_stat_to_errno(int stat)
 	.p_replen = NFS4_##restype##_sz,			\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
 	.p_name   = #proc,					\
-    }
+}
 
 struct rpc_procinfo	nfs4_procedures[] = {
   PROC(READ,		enc_read,	dec_read),

