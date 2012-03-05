Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63818 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756674Ab2CEQuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 11:50:32 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/16] NFSv4: Add a helper for encoding stateids
Date: Mon,  5 Mar 2012 11:50:11 -0500
Message-Id: <1330966221-17164-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330966221-17164-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1330966221-17164-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |  113 +++++++++++++++++++++++++++++------------------------
 1 files changed, 62 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index de4cb5c..c03ba77 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -928,6 +928,11 @@ static void encode_nops(struct compound_hdr *hdr)
 	*hdr->nops_p = htonl(hdr->nops);
 }
 
+static void encode_nfs4_stateid(struct xdr_stream *xdr, const nfs4_stateid *stateid)
+{
+	encode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
+}
+
 static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
 {
 	encode_opaque_fixed(xdr, verf->data, NFS4_VERIFIER_SIZE);
@@ -1070,10 +1075,10 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_CLOSE);
-	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
-	xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	*p = cpu_to_be32(arg->seqid->sequence->counter);
+	encode_nfs4_stateid(xdr, arg->stateid);
 	hdr->nops++;
 	hdr->replen += decode_close_maxsz;
 }
@@ -1260,15 +1265,16 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	*p = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
-		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
-		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
-		p = xdr_encode_opaque_fixed(p, args->open_stateid->data, NFS4_STATEID_SIZE);
-		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(args->open_seqid->sequence->counter);
+		encode_nfs4_stateid(xdr, args->open_stateid);
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(args->lock_seqid->sequence->counter);
 		encode_lockowner(xdr, &args->lock_owner);
 	}
 	else {
-		p = reserve_space(xdr, NFS4_STATEID_SIZE+4);
-		p = xdr_encode_opaque_fixed(p, args->lock_stateid->data, NFS4_STATEID_SIZE);
+		encode_nfs4_stateid(xdr, args->lock_stateid);
+		p = reserve_space(xdr, 4);
 		*p = cpu_to_be32(args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
@@ -1293,11 +1299,12 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 12+NFS4_STATEID_SIZE+16);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_LOCKU);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
-	*p++ = cpu_to_be32(args->seqid->sequence->counter);
-	p = xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
+	*p = cpu_to_be32(args->seqid->sequence->counter);
+	encode_nfs4_stateid(xdr, args->stateid);
+	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	hdr->nops++;
@@ -1457,9 +1464,9 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
-	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
-	xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
+	encode_nfs4_stateid(xdr, stateid);
 	encode_string(xdr, name->len, name->name);
 }
 
@@ -1488,9 +1495,10 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
-	*p++ = cpu_to_be32(OP_OPEN_CONFIRM);
-	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_OPEN_CONFIRM);
+	encode_nfs4_stateid(xdr, arg->stateid);
+	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	hdr->nops++;
 	hdr->replen += decode_open_confirm_maxsz;
@@ -1500,9 +1508,10 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
-	*p++ = cpu_to_be32(OP_OPEN_DOWNGRADE);
-	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_OPEN_DOWNGRADE);
+	encode_nfs4_stateid(xdr, arg->stateid);
+	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
@@ -1535,16 +1544,14 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)
 {
 	nfs4_stateid stateid;
-	__be32 *p;
 
-	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
 		if (zero_seqid)
 			stateid.stateid.seqid = 0;
-		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
+		encode_nfs4_stateid(xdr, &stateid);
 	} else
-		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
+		encode_nfs4_stateid(xdr, &zero_stateid);
 }
 
 static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
@@ -1668,9 +1675,9 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
-	*p++ = cpu_to_be32(OP_SETATTR);
-	xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_SETATTR);
+	encode_nfs4_stateid(xdr, &zero_stateid);
 	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
@@ -1697,9 +1704,9 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
-	*p++ = cpu_to_be32(OP_SETATTR);
-	xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_SETATTR);
+	encode_nfs4_stateid(xdr, &arg->stateid);
 	hdr->nops++;
 	hdr->replen += decode_setattr_maxsz;
 	encode_attrs(xdr, arg->iap, server);
@@ -1760,10 +1767,9 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
-
-	*p++ = cpu_to_be32(OP_DELEGRETURN);
-	xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_DELEGRETURN);
+	encode_nfs4_stateid(xdr, stateid);
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
 }
@@ -1999,7 +2005,7 @@ encode_layoutget(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 40);
 	*p++ = cpu_to_be32(OP_LAYOUTGET);
 	*p++ = cpu_to_be32(0);     /* Signal layout available */
 	*p++ = cpu_to_be32(args->type);
@@ -2007,7 +2013,8 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->range.offset);
 	p = xdr_encode_hyper(p, args->range.length);
 	p = xdr_encode_hyper(p, args->minlength);
-	p = xdr_encode_opaque_fixed(p, &args->stateid.data, NFS4_STATEID_SIZE);
+	encode_nfs4_stateid(xdr, &args->stateid);
+	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(args->maxcount);
 
 	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
@@ -2032,13 +2039,14 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	dprintk("%s: lbw: %llu type: %d\n", __func__, args->lastbytewritten,
 		NFS_SERVER(args->inode)->pnfs_curr_ld->id);
 
-	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 24);
 	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
 	p = xdr_encode_hyper(p, args->lastbytewritten + 1);	/* length */
-	*p++ = cpu_to_be32(0); /* reclaim */
-	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
+	*p = cpu_to_be32(0); /* reclaim */
+	encode_nfs4_stateid(xdr, &args->stateid);
+	p = reserve_space(xdr, 20);
 	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
 	p = xdr_encode_hyper(p, args->lastbytewritten);
 	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
@@ -2070,11 +2078,11 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->layout_type);
 	*p++ = cpu_to_be32(IOMODE_ANY);
 	*p = cpu_to_be32(RETURN_FILE);
-	p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, 0);
 	p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
 	spin_lock(&args->inode->i_lock);
-	xdr_encode_opaque_fixed(p, &args->stateid.data, NFS4_STATEID_SIZE);
+	encode_nfs4_stateid(xdr, &args->stateid);
 	spin_unlock(&args->inode->i_lock);
 	if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
 		NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
@@ -2107,10 +2115,10 @@ static void encode_test_stateid(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8 + NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_TEST_STATEID);
-	*p++ = cpu_to_be32(1);
-	xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
+	*p = cpu_to_be32(1);
+	encode_nfs4_stateid(xdr, args->stateid);
 	hdr->nops++;
 	hdr->replen += decode_test_stateid_maxsz;
 }
@@ -2120,9 +2128,9 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 				struct compound_hdr *hdr)
 {
 	__be32 *p;
-	p = reserve_space(xdr, 4 + NFS4_STATEID_SIZE);
-	*p++ = cpu_to_be32(OP_FREE_STATEID);
-	xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_FREE_STATEID);
+	encode_nfs4_stateid(xdr, args->stateid);
 	hdr->nops++;
 	hdr->replen += decode_free_stateid_maxsz;
 }
@@ -5640,11 +5648,14 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	status = decode_op_hdr(xdr, OP_LAYOUTGET);
 	if (status)
 		return status;
-	p = xdr_inline_decode(xdr, 8 + NFS4_STATEID_SIZE);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->return_on_close = be32_to_cpup(p);
+	decode_stateid(xdr, &res->stateid);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	res->return_on_close = be32_to_cpup(p++);
-	p = xdr_decode_opaque_fixed(p, res->stateid.data, NFS4_STATEID_SIZE);
 	layout_count = be32_to_cpup(p);
 	if (!layout_count) {
 		dprintk("%s: server responded with empty layout array\n",
-- 
1.7.7.6

