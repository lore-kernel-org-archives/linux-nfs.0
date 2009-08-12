From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 06/13] nfs: nfs4xdr: get rid of WRITEMEM
Date: Wed, 12 Aug 2009 18:22:08 +0300
Message-ID: <1250090528-9703-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:11412
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751724AbZHLPWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:10 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

use xdr_encode_opaque_fixed instead.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   68 +++++++++++++++++++++++++----------------------------
 1 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fce7de3..2096573 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -712,10 +712,6 @@ struct compound_hdr {
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define WRITEMEM(ptr,nbytes)     do {				\
-	p = xdr_encode_opaque_fixed(p, ptr, nbytes);		\
-} while (0)
-
 #define RESERVE_SPACE(nbytes)	do {				\
 	p = xdr_reserve_space(xdr, nbytes);			\
 	BUG_ON(!p);						\
@@ -746,7 +742,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
 	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
 	p = xdr_encode_int(p, hdr->taglen);
-	WRITEMEM(hdr->tag, hdr->taglen);
+	p = xdr_encode_opaque_fixed(p, hdr->tag, hdr->taglen);
 	p = xdr_encode_int(p, hdr->minorversion);
 	hdr->nops_p = p;
 	p = xdr_encode_int(p, hdr->nops);
@@ -845,12 +841,12 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	if (iap->ia_valid & ATTR_UID) {
 		bmval1 |= FATTR4_WORD1_OWNER;
 		p = xdr_encode_int(p, owner_namelen);
-		WRITEMEM(owner_name, owner_namelen);
+		p = xdr_encode_opaque_fixed(p, owner_name, owner_namelen);
 	}
 	if (iap->ia_valid & ATTR_GID) {
 		bmval1 |= FATTR4_WORD1_OWNER_GROUP;
 		p = xdr_encode_int(p, owner_grouplen);
-		WRITEMEM(owner_group, owner_grouplen);
+		p = xdr_encode_opaque_fixed(p, owner_group, owner_grouplen);
 	}
 	if (iap->ia_valid & ATTR_ATIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
@@ -909,7 +905,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 	RESERVE_SPACE(8+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, OP_CLOSE);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
-	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_close_maxsz;
 }
@@ -953,7 +949,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 
 	RESERVE_SPACE(4 + create->name->len);
 	p = xdr_encode_int(p, create->name->len);
-	WRITEMEM(create->name->name, create->name->len);
+	p = xdr_encode_opaque_fixed(p, create->name->name, create->name->len);
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
 
@@ -1020,7 +1016,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 	RESERVE_SPACE(8 + name->len);
 	p = xdr_encode_int(p, OP_LINK);
 	p = xdr_encode_int(p, name->len);
-	WRITEMEM(name->name, name->len);
+	p = xdr_encode_opaque_fixed(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_link_maxsz;
 }
@@ -1057,16 +1053,16 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	if (args->new_lock_owner){
 		RESERVE_SPACE(4+NFS4_STATEID_SIZE+32);
 		p = xdr_encode_int(p, args->open_seqid->sequence->counter);
-		WRITEMEM(args->open_stateid->data, NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, args->open_stateid->data, NFS4_STATEID_SIZE);
 		p = xdr_encode_int(p, args->lock_seqid->sequence->counter);
 		p = xdr_encode_hyper(p, args->lock_owner.clientid);
 		p = xdr_encode_int(p, 16);
-		WRITEMEM("lock id:", 8);
+		p = xdr_encode_opaque_fixed(p, "lock id:", 8);
 		p = xdr_encode_hyper(p, args->lock_owner.id);
 	}
 	else {
 		RESERVE_SPACE(NFS4_STATEID_SIZE+4);
-		WRITEMEM(args->lock_stateid->data, NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, args->lock_stateid->data, NFS4_STATEID_SIZE);
 		p = xdr_encode_int(p, args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
@@ -1084,7 +1080,7 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	p = xdr_encode_hyper(p, args->lock_owner.clientid);
 	p = xdr_encode_int(p, 16);
-	WRITEMEM("lock id:", 8);
+	p = xdr_encode_opaque_fixed(p, "lock id:", 8);
 	p = xdr_encode_hyper(p, args->lock_owner.id);
 	hdr->nops++;
 	hdr->replen += decode_lockt_maxsz;
@@ -1098,7 +1094,7 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	p = xdr_encode_int(p, OP_LOCKU);
 	p = xdr_encode_int(p, nfs4_lock_type(args->fl, 0));
 	p = xdr_encode_int(p, args->seqid->sequence->counter);
-	WRITEMEM(args->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	hdr->nops++;
@@ -1113,7 +1109,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	RESERVE_SPACE(8 + len);
 	p = xdr_encode_int(p, OP_LOOKUP);
 	p = xdr_encode_int(p, len);
-	WRITEMEM(name->name, len);
+	p = xdr_encode_opaque_fixed(p, name->name, len);
 	hdr->nops++;
 	hdr->replen += decode_lookup_maxsz;
 }
@@ -1153,7 +1149,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 	RESERVE_SPACE(28);
 	p = xdr_encode_hyper(p, arg->clientid);
 	p = xdr_encode_int(p, 16);
-	WRITEMEM("open id:", 8);
+	p = xdr_encode_opaque_fixed(p, "open id:", 8);
 	p = xdr_encode_hyper(p, arg->id);
 }
 
@@ -1233,7 +1229,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, NFS4_OPEN_CLAIM_DELEGATE_CUR);
-	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
 	encode_string(xdr, name->len, name->name);
 }
 
@@ -1264,7 +1260,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
 	p = xdr_encode_int(p, OP_OPEN_CONFIRM);
-	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
 	hdr->nops++;
 	hdr->replen += decode_open_confirm_maxsz;
@@ -1276,7 +1272,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
 	p = xdr_encode_int(p, OP_OPEN_DOWNGRADE);
-	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
@@ -1292,7 +1288,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	RESERVE_SPACE(8 + len);
 	p = xdr_encode_int(p, OP_PUTFH);
 	p = xdr_encode_int(p, len);
-	WRITEMEM(fh->data, len);
+	p = xdr_encode_opaque_fixed(p, fh->data, len);
 	hdr->nops++;
 	hdr->replen += decode_putfh_maxsz;
 }
@@ -1315,9 +1311,9 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 	RESERVE_SPACE(NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, ctx->lockowner);
-		WRITEMEM(stateid.data, NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
 	} else
-		WRITEMEM(zero_stateid.data, NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
 }
 
 static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
@@ -1347,7 +1343,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	RESERVE_SPACE(12+NFS4_VERIFIER_SIZE+20);
 	p = xdr_encode_int(p, OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
-	WRITEMEM(readdir->verifier.data, NFS4_VERIFIER_SIZE);
+	p = xdr_encode_opaque_fixed(p, readdir->verifier.data, NFS4_VERIFIER_SIZE);
 	p = xdr_encode_int(p, readdir->count >> 1);  /* We're not doing readdirplus */
 	p = xdr_encode_int(p, readdir->count);
 	p = xdr_encode_int(p, 2);
@@ -1386,7 +1382,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 	RESERVE_SPACE(8 + name->len);
 	p = xdr_encode_int(p, OP_REMOVE);
 	p = xdr_encode_int(p, name->len);
-	WRITEMEM(name->name, name->len);
+	p = xdr_encode_opaque_fixed(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_remove_maxsz;
 }
@@ -1398,11 +1394,11 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 	RESERVE_SPACE(8 + oldname->len);
 	p = xdr_encode_int(p, OP_RENAME);
 	p = xdr_encode_int(p, oldname->len);
-	WRITEMEM(oldname->name, oldname->len);
+	p = xdr_encode_opaque_fixed(p, oldname->name, oldname->len);
 
 	RESERVE_SPACE(4 + newname->len);
 	p = xdr_encode_int(p, newname->len);
-	WRITEMEM(newname->name, newname->len);
+	p = xdr_encode_opaque_fixed(p, newname->name, newname->len);
 	hdr->nops++;
 	hdr->replen += decode_rename_maxsz;
 }
@@ -1436,7 +1432,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, OP_SETATTR);
-	WRITEMEM(zero_stateid.data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
 	RESERVE_SPACE(2*4);
 	p = xdr_encode_int(p, 1);
 	p = xdr_encode_int(p, FATTR4_WORD0_ACL);
@@ -1467,7 +1463,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, OP_SETATTR);
-	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setattr_maxsz;
 	encode_attrs(xdr, arg->iap, server);
@@ -1479,7 +1475,7 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 
 	RESERVE_SPACE(4 + NFS4_VERIFIER_SIZE);
 	p = xdr_encode_int(p, OP_SETCLIENTID);
-	WRITEMEM(setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
+	p = xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
 	RESERVE_SPACE(4);
@@ -1499,7 +1495,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
 	p = xdr_encode_int(p, OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, client_state->cl_clientid);
-	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
+	p = xdr_encode_opaque_fixed(p, client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
 }
@@ -1530,7 +1526,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 
 	p = xdr_encode_int(p, OP_DELEGRETURN);
-	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
 }
@@ -1545,7 +1541,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 
 	RESERVE_SPACE(4 + sizeof(args->verifier->data));
 	p = xdr_encode_int(p, OP_EXCHANGE_ID);
-	WRITEMEM(args->verifier->data, sizeof(args->verifier->data));
+	p = xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
 
 	encode_string(xdr, args->id_len, args->id);
 
@@ -1611,7 +1607,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 			clp->cl_ipaddr);
 	RESERVE_SPACE(16 + len);
 	p = xdr_encode_int(p, len);
-	WRITEMEM(machine_name, len);
+	p = xdr_encode_opaque_fixed(p, machine_name, len);
 	p = xdr_encode_int(p, 0);				/* UID */
 	p = xdr_encode_int(p, 0);				/* GID */
 	p = xdr_encode_int(p, 0);				/* No more gids */
@@ -1626,7 +1622,7 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 	__be32 *p;
 	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN);
 	p = xdr_encode_int(p, OP_DESTROY_SESSION);
-	WRITEMEM(session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	hdr->nops++;
 	hdr->replen += decode_destroy_session_maxsz;
 }
@@ -1666,7 +1662,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 		slot->seq_nr, args->sa_slotid,
 		tp->highest_used_slotid, args->sa_cache_this);
 	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 16);
-	WRITEMEM(session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	p = xdr_encode_int(p, slot->seq_nr);
 	p = xdr_encode_int(p, args->sa_slotid);
 	p = xdr_encode_int(p, tp->highest_used_slotid);
-- 
1.6.4

