From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 04/21] nfs: nfs4xdr: get rid of WRITE64
Date: Fri, 14 Aug 2009 17:19:01 +0300
Message-ID: <1250259541-13607-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:28027
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756873AbZHNOTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:09 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

s/WRITE64/p = xdr_encode_hyper(p, /

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   44 ++++++++++++++++++++------------------------
 1 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9a03b24..5d80766 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -712,10 +712,6 @@ struct compound_hdr {
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define WRITE64(n)               do {				\
-	*p++ = htonl((uint32_t)((n) >> 32));				\
-	*p++ = htonl((uint32_t)(n));					\
-} while (0)
 #define WRITEMEM(ptr,nbytes)     do {				\
 	p = xdr_encode_opaque_fixed(p, ptr, nbytes);		\
 } while (0)
@@ -840,7 +836,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 
 	if (iap->ia_valid & ATTR_SIZE) {
 		bmval0 |= FATTR4_WORD0_SIZE;
-		WRITE64(iap->ia_size);
+		p = xdr_encode_hyper(p, iap->ia_size);
 	}
 	if (iap->ia_valid & ATTR_MODE) {
 		bmval1 |= FATTR4_WORD1_MODE;
@@ -924,7 +920,7 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 
 	RESERVE_SPACE(16);
 	*p++ = cpu_to_be32(OP_COMMIT);
-	WRITE64(args->offset);
+	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->count);
 	hdr->nops++;
 	hdr->replen += decode_commit_maxsz;
@@ -1055,18 +1051,18 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	*p++ = cpu_to_be32(OP_LOCK);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, args->block));
 	*p++ = cpu_to_be32(args->reclaim);
-	WRITE64(args->fl->fl_start);
-	WRITE64(nfs4_lock_length(args->fl));
+	p = xdr_encode_hyper(p, args->fl->fl_start);
+	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	*p++ = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
 		RESERVE_SPACE(4+NFS4_STATEID_SIZE+32);
 		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
 		WRITEMEM(args->open_stateid->data, NFS4_STATEID_SIZE);
 		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
-		WRITE64(args->lock_owner.clientid);
+		p = xdr_encode_hyper(p, args->lock_owner.clientid);
 		*p++ = cpu_to_be32(16);
 		WRITEMEM("lock id:", 8);
-		WRITE64(args->lock_owner.id);
+		p = xdr_encode_hyper(p, args->lock_owner.id);
 	}
 	else {
 		RESERVE_SPACE(NFS4_STATEID_SIZE+4);
@@ -1084,12 +1080,12 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 	RESERVE_SPACE(52);
 	*p++ = cpu_to_be32(OP_LOCKT);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
-	WRITE64(args->fl->fl_start);
-	WRITE64(nfs4_lock_length(args->fl));
-	WRITE64(args->lock_owner.clientid);
+	p = xdr_encode_hyper(p, args->fl->fl_start);
+	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
+	p = xdr_encode_hyper(p, args->lock_owner.clientid);
 	*p++ = cpu_to_be32(16);
 	WRITEMEM("lock id:", 8);
-	WRITE64(args->lock_owner.id);
+	p = xdr_encode_hyper(p, args->lock_owner.id);
 	hdr->nops++;
 	hdr->replen += decode_lockt_maxsz;
 }
@@ -1103,8 +1099,8 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	*p++ = cpu_to_be32(args->seqid->sequence->counter);
 	WRITEMEM(args->stateid->data, NFS4_STATEID_SIZE);
-	WRITE64(args->fl->fl_start);
-	WRITE64(nfs4_lock_length(args->fl));
+	p = xdr_encode_hyper(p, args->fl->fl_start);
+	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	hdr->nops++;
 	hdr->replen += decode_locku_maxsz;
 }
@@ -1155,10 +1151,10 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	RESERVE_SPACE(28);
-	WRITE64(arg->clientid);
+	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(16);
 	WRITEMEM("open id:", 8);
-	WRITE64(arg->id);
+	p = xdr_encode_hyper(p, arg->id);
 }
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1334,7 +1330,7 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	encode_stateid(xdr, args->context);
 
 	RESERVE_SPACE(12);
-	WRITE64(args->offset);
+	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->count);
 	hdr->nops++;
 	hdr->replen += decode_read_maxsz;
@@ -1350,7 +1346,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 
 	RESERVE_SPACE(12+NFS4_VERIFIER_SIZE+20);
 	*p++ = cpu_to_be32(OP_READDIR);
-	WRITE64(readdir->cookie);
+	p = xdr_encode_hyper(p, readdir->cookie);
 	WRITEMEM(readdir->verifier.data, NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(readdir->count >> 1);  /* We're not doing readdirplus */
 	*p++ = cpu_to_be32(readdir->count);
@@ -1417,7 +1413,7 @@ static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client
 
 	RESERVE_SPACE(12);
 	*p++ = cpu_to_be32(OP_RENEW);
-	WRITE64(client_stateid->cl_clientid);
+	p = xdr_encode_hyper(p, client_stateid->cl_clientid);
 	hdr->nops++;
 	hdr->replen += decode_renew_maxsz;
 }
@@ -1502,7 +1498,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 
 	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
-	WRITE64(client_state->cl_clientid);
+	p = xdr_encode_hyper(p, client_state->cl_clientid);
 	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
@@ -1518,7 +1514,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	encode_stateid(xdr, args->context);
 
 	RESERVE_SPACE(16);
-	WRITE64(args->offset);
+	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->stable);
 	*p++ = cpu_to_be32(args->count);
 
@@ -1574,7 +1570,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(OP_CREATE_SESSION);
 
 	RESERVE_SPACE(8);
-	WRITE64(clp->cl_ex_clid);
+	p = xdr_encode_hyper(p, clp->cl_ex_clid);
 
 	RESERVE_SPACE(8);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
-- 
1.6.4

