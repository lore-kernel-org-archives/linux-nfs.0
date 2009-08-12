From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 08/13] nfs: nfs4xdr: change RESERVE_SPACE macro into a static helper
Date: Wed, 12 Aug 2009 18:22:20 +0300
Message-ID: <1250090540-9767-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:10887
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752655AbZHLPWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:21 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to open code and expose the result pointer assignment.

Alternatively, we can open code the call to xdr_reserve_space
and do the BUG_ON an the error case at the call site.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  156 +++++++++++++++++++++++++----------------------------
 1 files changed, 74 insertions(+), 82 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d26c437..7fac008 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -702,20 +702,12 @@ struct compound_hdr {
 	u32		minorversion;
 };
 
-/*
- * START OF "GENERIC" ENCODE ROUTINES.
- *   These may look a little ugly since they are imported from a "generic"
- * set of XDR encode/decode routines which are intended to be shared by
- * all of our NFSv4 implementations (OpenBSD, MacOS X...).
- *
- * If the pain of reading these is too great, it should be a straightforward
- * task to translate them into Linux-specific versions which are more
- * consistent with the style used in NFSv2/v3...
- */
-#define RESERVE_SPACE(nbytes)	do {				\
-	p = xdr_reserve_space(xdr, nbytes);			\
-	BUG_ON(!p);						\
-} while (0)
+static __be32 *reserve_space(struct xdr_stream *xdr, size_t nbytes)
+{
+	__be32 *p = xdr_reserve_space(xdr, nbytes);
+	BUG_ON(!p);
+	return p;
+}
 
 static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
@@ -740,7 +732,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
-	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
+	p = reserve_space(xdr, 12+(XDR_QUADLEN(hdr->taglen)<<2));
 	p = xdr_encode_opaque(p, hdr->tag, hdr->taglen);
 	p = xdr_encode_int(p, hdr->minorversion);
 	hdr->nops_p = p;
@@ -819,7 +811,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		len += 16;
 	else if (iap->ia_valid & ATTR_MTIME)
 		len += 4;
-	RESERVE_SPACE(len);
+	p = reserve_space(xdr, len);
 
 	/*
 	 * We write the bitmap length now, but leave the bitmap and the attribute
@@ -888,7 +880,7 @@ static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hd
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_int(p, OP_ACCESS);
 	p = xdr_encode_int(p, access);
 	hdr->nops++;
@@ -899,7 +891,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 8+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, OP_CLOSE);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
@@ -911,7 +903,7 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 {
 	__be32 *p;
 
-	RESERVE_SPACE(16);
+	p = reserve_space(xdr, 16);
 	p = xdr_encode_int(p, OP_COMMIT);
 	p = xdr_encode_hyper(p, args->offset);
 	p = xdr_encode_int(p, args->count);
@@ -923,19 +915,19 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_int(p, OP_CREATE);
 	p = xdr_encode_int(p, create->ftype);
 
 	switch (create->ftype) {
 	case NF4LNK:
-		RESERVE_SPACE(4);
+		p = reserve_space(xdr, 4);
 		p = xdr_encode_int(p, create->u.symlink.len);
 		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
 		break;
 
 	case NF4BLK: case NF4CHR:
-		RESERVE_SPACE(8);
+		p = reserve_space(xdr, 8);
 		p = xdr_encode_int(p, create->u.device.specdata1);
 		p = xdr_encode_int(p, create->u.device.specdata2);
 		break;
@@ -944,7 +936,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 		break;
 	}
 
-	RESERVE_SPACE(4 + create->name->len);
+	p = reserve_space(xdr, 4 + create->name->len);
 	p = xdr_encode_opaque(p, create->name->name, create->name->len);
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
@@ -956,7 +948,7 @@ static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct c
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	p = xdr_encode_int(p, OP_GETATTR);
 	p = xdr_encode_int(p, 1);
 	p = xdr_encode_int(p, bitmap);
@@ -968,7 +960,7 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 {
 	__be32 *p;
 
-	RESERVE_SPACE(16);
+	p = reserve_space(xdr, 16);
 	p = xdr_encode_int(p, OP_GETATTR);
 	p = xdr_encode_int(p, 2);
 	p = xdr_encode_int(p, bm0);
@@ -999,7 +991,7 @@ static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_GETFH);
 	hdr->nops++;
 	hdr->replen += decode_getfh_maxsz;
@@ -1009,7 +1001,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8 + name->len);
+	p = reserve_space(xdr, 8 + name->len);
 	p = xdr_encode_int(p, OP_LINK);
 	p = xdr_encode_opaque(p, name->name, name->len);
 	hdr->nops++;
@@ -1038,7 +1030,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 {
 	__be32 *p;
 
-	RESERVE_SPACE(32);
+	p = reserve_space(xdr, 32);
 	p = xdr_encode_int(p, OP_LOCK);
 	p = xdr_encode_int(p, nfs4_lock_type(args->fl, args->block));
 	p = xdr_encode_int(p, args->reclaim);
@@ -1046,7 +1038,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	p = xdr_encode_int(p, args->new_lock_owner);
 	if (args->new_lock_owner){
-		RESERVE_SPACE(4+NFS4_STATEID_SIZE+32);
+		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+32);
 		p = xdr_encode_int(p, args->open_seqid->sequence->counter);
 		p = xdr_encode_opaque_fixed(p, args->open_stateid->data, NFS4_STATEID_SIZE);
 		p = xdr_encode_int(p, args->lock_seqid->sequence->counter);
@@ -1056,7 +1048,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 		p = xdr_encode_hyper(p, args->lock_owner.id);
 	}
 	else {
-		RESERVE_SPACE(NFS4_STATEID_SIZE+4);
+		p = reserve_space(xdr, NFS4_STATEID_SIZE+4);
 		p = xdr_encode_opaque_fixed(p, args->lock_stateid->data, NFS4_STATEID_SIZE);
 		p = xdr_encode_int(p, args->lock_seqid->sequence->counter);
 	}
@@ -1068,7 +1060,7 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 {
 	__be32 *p;
 
-	RESERVE_SPACE(52);
+	p = reserve_space(xdr, 52);
 	p = xdr_encode_int(p, OP_LOCKT);
 	p = xdr_encode_int(p, nfs4_lock_type(args->fl, 0));
 	p = xdr_encode_hyper(p, args->fl->fl_start);
@@ -1085,7 +1077,7 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12+NFS4_STATEID_SIZE+16);
+	p = reserve_space(xdr, 12+NFS4_STATEID_SIZE+16);
 	p = xdr_encode_int(p, OP_LOCKU);
 	p = xdr_encode_int(p, nfs4_lock_type(args->fl, 0));
 	p = xdr_encode_int(p, args->seqid->sequence->counter);
@@ -1101,7 +1093,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	int len = name->len;
 	__be32 *p;
 
-	RESERVE_SPACE(8 + len);
+	p = reserve_space(xdr, 8 + len);
 	p = xdr_encode_int(p, OP_LOOKUP);
 	p = xdr_encode_opaque(p, name->name, len);
 	hdr->nops++;
@@ -1112,7 +1104,7 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
 	case FMODE_READ:
 		p = xdr_encode_int(p, NFS4_SHARE_ACCESS_READ);
@@ -1136,11 +1128,11 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * opcode 4, seqid 4, share_access 4, share_deny 4, clientid 8, ownerlen 4,
  * owner 4 = 32
  */
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_int(p, OP_OPEN);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
-	RESERVE_SPACE(28);
+	p = reserve_space(xdr, 28);
 	p = xdr_encode_hyper(p, arg->clientid);
 	p = xdr_encode_int(p, 16);
 	p = xdr_encode_opaque_fixed(p, "open id:", 8);
@@ -1151,7 +1143,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	switch(arg->open_flags & O_EXCL) {
 	case 0:
 		p = xdr_encode_int(p, NFS4_CREATE_UNCHECKED);
@@ -1167,7 +1159,7 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	switch (arg->open_flags & O_CREAT) {
 	case 0:
 		p = xdr_encode_int(p, NFS4_OPEN_NOCREATE);
@@ -1183,7 +1175,7 @@ static inline void encode_delegation_type(struct xdr_stream *xdr, fmode_t delega
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	switch (delegation_type) {
 	case 0:
 		p = xdr_encode_int(p, NFS4_OPEN_DELEGATE_NONE);
@@ -1203,7 +1195,7 @@ static inline void encode_claim_null(struct xdr_stream *xdr, const struct qstr *
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, NFS4_OPEN_CLAIM_NULL);
 	encode_string(xdr, name->len, name->name);
 }
@@ -1212,7 +1204,7 @@ static inline void encode_claim_previous(struct xdr_stream *xdr, fmode_t type)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, NFS4_OPEN_CLAIM_PREVIOUS);
 	encode_delegation_type(xdr, type);
 }
@@ -1221,7 +1213,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, NFS4_OPEN_CLAIM_DELEGATE_CUR);
 	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
 	encode_string(xdr, name->len, name->name);
@@ -1252,7 +1244,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	p = xdr_encode_int(p, OP_OPEN_CONFIRM);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
@@ -1264,7 +1256,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	p = xdr_encode_int(p, OP_OPEN_DOWNGRADE);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, arg->seqid->sequence->counter);
@@ -1279,7 +1271,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	int len = fh->size;
 	__be32 *p;
 
-	RESERVE_SPACE(8 + len);
+	p = reserve_space(xdr, 8 + len);
 	p = xdr_encode_int(p, OP_PUTFH);
 	p = xdr_encode_opaque(p, fh->data, len);
 	hdr->nops++;
@@ -1290,7 +1282,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_PUTROOTFH);
 	hdr->nops++;
 	hdr->replen += decode_putrootfh_maxsz;
@@ -1301,7 +1293,7 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 	nfs4_stateid stateid;
 	__be32 *p;
 
-	RESERVE_SPACE(NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, ctx->lockowner);
 		p = xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
@@ -1313,12 +1305,12 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_READ);
 
 	encode_stateid(xdr, args->context);
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
 	p = xdr_encode_int(p, args->count);
 	hdr->nops++;
@@ -1333,7 +1325,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	};
 	__be32 *p;
 
-	RESERVE_SPACE(12+NFS4_VERIFIER_SIZE+20);
+	p = reserve_space(xdr, 12+NFS4_VERIFIER_SIZE+20);
 	p = xdr_encode_int(p, OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
 	p = xdr_encode_opaque_fixed(p, readdir->verifier.data, NFS4_VERIFIER_SIZE);
@@ -1362,7 +1354,7 @@ static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_READLINK);
 	hdr->nops++;
 	hdr->replen += decode_readlink_maxsz;
@@ -1372,7 +1364,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8 + name->len);
+	p = reserve_space(xdr, 8 + name->len);
 	p = xdr_encode_int(p, OP_REMOVE);
 	p = xdr_encode_opaque(p, name->name, name->len);
 	hdr->nops++;
@@ -1383,11 +1375,11 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8 + oldname->len);
+	p = reserve_space(xdr, 8 + oldname->len);
 	p = xdr_encode_int(p, OP_RENAME);
 	p = xdr_encode_opaque(p, oldname->name, oldname->len);
 
-	RESERVE_SPACE(4 + newname->len);
+	p = reserve_space(xdr, 4 + newname->len);
 	p = xdr_encode_opaque(p, newname->name, newname->len);
 	hdr->nops++;
 	hdr->replen += decode_rename_maxsz;
@@ -1397,7 +1389,7 @@ static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	p = xdr_encode_int(p, OP_RENEW);
 	p = xdr_encode_hyper(p, client_stateid->cl_clientid);
 	hdr->nops++;
@@ -1409,7 +1401,7 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_RESTOREFH);
 	hdr->nops++;
 	hdr->replen += decode_restorefh_maxsz;
@@ -1420,15 +1412,15 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, OP_SETATTR);
 	p = xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
-	RESERVE_SPACE(2*4);
+	p = reserve_space(xdr, 2*4);
 	p = xdr_encode_int(p, 1);
 	p = xdr_encode_int(p, FATTR4_WORD0_ACL);
 	if (arg->acl_len % 4)
 		return -EINVAL;
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
@@ -1441,7 +1433,7 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_SAVEFH);
 	hdr->nops++;
 	hdr->replen += decode_savefh_maxsz;
@@ -1451,7 +1443,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	p = xdr_encode_int(p, OP_SETATTR);
 	p = xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
@@ -1463,16 +1455,16 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4 + NFS4_VERIFIER_SIZE);
+	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	p = xdr_encode_int(p, OP_SETCLIENTID);
 	p = xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, setclientid->sc_prog);
 	encode_string(xdr, setclientid->sc_netid_len, setclientid->sc_netid);
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, setclientid->sc_cb_ident);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_maxsz;
@@ -1482,7 +1474,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
+	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
 	p = xdr_encode_int(p, OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, client_state->cl_clientid);
 	p = xdr_encode_opaque_fixed(p, client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
@@ -1494,12 +1486,12 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_WRITE);
 
 	encode_stateid(xdr, args->context);
 
-	RESERVE_SPACE(16);
+	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
 	p = xdr_encode_int(p, args->stable);
 	p = xdr_encode_int(p, args->count);
@@ -1513,7 +1505,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 
 	p = xdr_encode_int(p, OP_DELEGRETURN);
 	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
@@ -1529,13 +1521,13 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4 + sizeof(args->verifier->data));
+	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
 	p = xdr_encode_int(p, OP_EXCHANGE_ID);
 	p = xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
 
 	encode_string(xdr, args->id_len, args->id);
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	p = xdr_encode_int(p, args->flags);
 	p = xdr_encode_int(p, 0);	/* zero length state_protect4_a */
 	p = xdr_encode_int(p, 0);	/* zero length implementation id array */
@@ -1552,17 +1544,17 @@ static void encode_create_session(struct xdr_stream *xdr,
 	uint32_t len;
 	struct nfs_client *clp = args->client;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_CREATE_SESSION);
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_hyper(p, clp->cl_ex_clid);
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_int(p, clp->cl_seqid);			/*Sequence id */
 	p = xdr_encode_int(p, args->flags);			/*flags */
 
-	RESERVE_SPACE(2*28);			/* 2 channel_attrs */
+	p = reserve_space(xdr, 2*28);			/* 2 channel_attrs */
 	/* Fore Channel */
 	p = xdr_encode_int(p, args->fc_attrs.headerpadsz);	/* header padding size */
 	p = xdr_encode_int(p, args->fc_attrs.max_rqst_sz);	/* max req size */
@@ -1581,21 +1573,21 @@ static void encode_create_session(struct xdr_stream *xdr,
 	p = xdr_encode_int(p, args->bc_attrs.max_reqs);	/* max requests */
 	p = xdr_encode_int(p, 0);				/* rdmachannel_attrs */
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, args->cb_program);		/* cb_program */
 
-	RESERVE_SPACE(4);			/* # of security flavors */
+	p = reserve_space(xdr, 4);			/* # of security flavors */
 	p = xdr_encode_int(p, 1);
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, (u32)clp->cl_boot_time.tv_nsec);	/* stamp */
 	len = scnprintf(machine_name, sizeof(machine_name), "%s",
 			clp->cl_ipaddr);
-	RESERVE_SPACE(16 + len);
+	p = reserve_space(xdr, 16 + len);
 	p = xdr_encode_opaque(p, machine_name, len);
 	p = xdr_encode_int(p, 0);				/* UID */
 	p = xdr_encode_int(p, 0);				/* GID */
@@ -1609,7 +1601,7 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 				   struct compound_hdr *hdr)
 {
 	__be32 *p;
-	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN);
+	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN);
 	p = xdr_encode_int(p, OP_DESTROY_SESSION);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	hdr->nops++;
@@ -1635,7 +1627,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
 	slot = tp->slots + args->sa_slotid;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	p = xdr_encode_int(p, OP_SEQUENCE);
 
 	/*
@@ -1650,7 +1642,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 		((u32 *)session->sess_id.data)[3],
 		slot->seq_nr, args->sa_slotid,
 		tp->highest_used_slotid, args->sa_cache_this);
-	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 16);
+	p = reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 16);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	p = xdr_encode_int(p, slot->seq_nr);
 	p = xdr_encode_int(p, args->sa_slotid);
-- 
1.6.4

