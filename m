From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 08/21] nfs: nfs4xdr: change RESERVE_SPACE macro into a static helper
Date: Fri, 14 Aug 2009 17:19:25 +0300
Message-ID: <1250259565-13736-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27343
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756884AbZHNOTd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:33 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to open code and expose the result pointer assignment.

Alternatively, we can open code the call to xdr_reserve_space
and do the BUG_ON an the error case at the call site.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  138 +++++++++++++++++++++++++----------------------------
 1 files changed, 65 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7c2b162..3bcde49 100644
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
-	RESERVE_SPACE(12 + hdr->taglen);
+	p = reserve_space(xdr, 12 + hdr->taglen);
 	*p++ = cpu_to_be32(hdr->taglen);
 	p = xdr_encode_opaque_fixed(p, hdr->tag, hdr->taglen);
 	*p++ = cpu_to_be32(hdr->minorversion);
@@ -820,7 +812,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		len += 16;
 	else if (iap->ia_valid & ATTR_MTIME)
 		len += 4;
-	RESERVE_SPACE(len);
+	p = reserve_space(xdr, len);
 
 	/*
 	 * We write the bitmap length now, but leave the bitmap and the attribute
@@ -891,7 +883,7 @@ static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hd
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_ACCESS);
 	*p++ = cpu_to_be32(access);
 	hdr->nops++;
@@ -902,7 +894,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 8+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_CLOSE);
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
@@ -914,7 +906,7 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 {
 	__be32 *p;
 
-	RESERVE_SPACE(16);
+	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(OP_COMMIT);
 	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->count);
@@ -926,19 +918,19 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_CREATE);
 	*p++ = cpu_to_be32(create->ftype);
 
 	switch (create->ftype) {
 	case NF4LNK:
-		RESERVE_SPACE(4);
+		p = reserve_space(xdr, 4);
 		*p++ = cpu_to_be32(create->u.symlink.len);
 		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
 		break;
 
 	case NF4BLK: case NF4CHR:
-		RESERVE_SPACE(8);
+		p = reserve_space(xdr, 8);
 		*p++ = cpu_to_be32(create->u.device.specdata1);
 		*p++ = cpu_to_be32(create->u.device.specdata2);
 		break;
@@ -947,7 +939,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 		break;
 	}
 
-	RESERVE_SPACE(4 + create->name->len);
+	p = reserve_space(xdr, 4 + create->name->len);
 	*p++ = cpu_to_be32(create->name->len);
 	p = xdr_encode_opaque_fixed(p, create->name->name, create->name->len);
 	hdr->nops++;
@@ -960,7 +952,7 @@ static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct c
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_GETATTR);
 	*p++ = cpu_to_be32(1);
 	*p++ = cpu_to_be32(bitmap);
@@ -972,7 +964,7 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 {
 	__be32 *p;
 
-	RESERVE_SPACE(16);
+	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(OP_GETATTR);
 	*p++ = cpu_to_be32(2);
 	*p++ = cpu_to_be32(bm0);
@@ -1003,7 +995,7 @@ static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_GETFH);
 	hdr->nops++;
 	hdr->replen += decode_getfh_maxsz;
@@ -1013,7 +1005,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8 + name->len);
+	p = reserve_space(xdr, 8 + name->len);
 	*p++ = cpu_to_be32(OP_LINK);
 	*p++ = cpu_to_be32(name->len);
 	p = xdr_encode_opaque_fixed(p, name->name, name->len);
@@ -1043,7 +1035,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 {
 	__be32 *p;
 
-	RESERVE_SPACE(32);
+	p = reserve_space(xdr, 32);
 	*p++ = cpu_to_be32(OP_LOCK);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, args->block));
 	*p++ = cpu_to_be32(args->reclaim);
@@ -1051,7 +1043,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	*p++ = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
-		RESERVE_SPACE(4+NFS4_STATEID_SIZE+32);
+		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+32);
 		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
 		p = xdr_encode_opaque_fixed(p, args->open_stateid->data, NFS4_STATEID_SIZE);
 		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
@@ -1061,7 +1053,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 		p = xdr_encode_hyper(p, args->lock_owner.id);
 	}
 	else {
-		RESERVE_SPACE(NFS4_STATEID_SIZE+4);
+		p = reserve_space(xdr, NFS4_STATEID_SIZE+4);
 		p = xdr_encode_opaque_fixed(p, args->lock_stateid->data, NFS4_STATEID_SIZE);
 		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
 	}
@@ -1073,7 +1065,7 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 {
 	__be32 *p;
 
-	RESERVE_SPACE(52);
+	p = reserve_space(xdr, 52);
 	*p++ = cpu_to_be32(OP_LOCKT);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	p = xdr_encode_hyper(p, args->fl->fl_start);
@@ -1090,7 +1082,7 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12+NFS4_STATEID_SIZE+16);
+	p = reserve_space(xdr, 12+NFS4_STATEID_SIZE+16);
 	*p++ = cpu_to_be32(OP_LOCKU);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	*p++ = cpu_to_be32(args->seqid->sequence->counter);
@@ -1106,7 +1098,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	int len = name->len;
 	__be32 *p;
 
-	RESERVE_SPACE(8 + len);
+	p = reserve_space(xdr, 8 + len);
 	*p++ = cpu_to_be32(OP_LOOKUP);
 	*p++ = cpu_to_be32(len);
 	p = xdr_encode_opaque_fixed(p, name->name, len);
@@ -1118,7 +1110,7 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
 	case FMODE_READ:
 		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_READ);
@@ -1142,11 +1134,11 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * opcode 4, seqid 4, share_access 4, share_deny 4, clientid 8, ownerlen 4,
  * owner 4 = 32
  */
-	RESERVE_SPACE(8);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_OPEN);
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
-	RESERVE_SPACE(28);
+	p = reserve_space(xdr, 28);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(16);
 	p = xdr_encode_opaque_fixed(p, "open id:", 8);
@@ -1157,7 +1149,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	switch(arg->open_flags & O_EXCL) {
 	case 0:
 		*p++ = cpu_to_be32(NFS4_CREATE_UNCHECKED);
@@ -1173,7 +1165,7 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	switch (arg->open_flags & O_CREAT) {
 	case 0:
 		*p++ = cpu_to_be32(NFS4_OPEN_NOCREATE);
@@ -1189,7 +1181,7 @@ static inline void encode_delegation_type(struct xdr_stream *xdr, fmode_t delega
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	switch (delegation_type) {
 	case 0:
 		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_NONE);
@@ -1209,7 +1201,7 @@ static inline void encode_claim_null(struct xdr_stream *xdr, const struct qstr *
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_NULL);
 	encode_string(xdr, name->len, name->name);
 }
@@ -1218,7 +1210,7 @@ static inline void encode_claim_previous(struct xdr_stream *xdr, fmode_t type)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_PREVIOUS);
 	encode_delegation_type(xdr, type);
 }
@@ -1227,7 +1219,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
 	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
 	encode_string(xdr, name->len, name->name);
@@ -1258,7 +1250,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	*p++ = cpu_to_be32(OP_OPEN_CONFIRM);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
@@ -1270,7 +1262,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	*p++ = cpu_to_be32(OP_OPEN_DOWNGRADE);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
@@ -1285,7 +1277,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	int len = fh->size;
 	__be32 *p;
 
-	RESERVE_SPACE(8 + len);
+	p = reserve_space(xdr, 8 + len);
 	*p++ = cpu_to_be32(OP_PUTFH);
 	*p++ = cpu_to_be32(len);
 	p = xdr_encode_opaque_fixed(p, fh->data, len);
@@ -1297,7 +1289,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_PUTROOTFH);
 	hdr->nops++;
 	hdr->replen += decode_putrootfh_maxsz;
@@ -1308,7 +1300,7 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 	nfs4_stateid stateid;
 	__be32 *p;
 
-	RESERVE_SPACE(NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, ctx->lockowner);
 		p = xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
@@ -1320,12 +1312,12 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_READ);
 
 	encode_stateid(xdr, args->context);
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->count);
 	hdr->nops++;
@@ -1340,7 +1332,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	};
 	__be32 *p;
 
-	RESERVE_SPACE(12+NFS4_VERIFIER_SIZE+20);
+	p = reserve_space(xdr, 12+NFS4_VERIFIER_SIZE+20);
 	*p++ = cpu_to_be32(OP_READDIR);
 	p = xdr_encode_hyper(p, readdir->cookie);
 	p = xdr_encode_opaque_fixed(p, readdir->verifier.data, NFS4_VERIFIER_SIZE);
@@ -1369,7 +1361,7 @@ static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_READLINK);
 	hdr->nops++;
 	hdr->replen += decode_readlink_maxsz;
@@ -1379,7 +1371,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8 + name->len);
+	p = reserve_space(xdr, 8 + name->len);
 	*p++ = cpu_to_be32(OP_REMOVE);
 	*p++ = cpu_to_be32(name->len);
 	p = xdr_encode_opaque_fixed(p, name->name, name->len);
@@ -1391,12 +1383,12 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 {
 	__be32 *p;
 
-	RESERVE_SPACE(8 + oldname->len);
+	p = reserve_space(xdr, 8 + oldname->len);
 	*p++ = cpu_to_be32(OP_RENAME);
 	*p++ = cpu_to_be32(oldname->len);
 	p = xdr_encode_opaque_fixed(p, oldname->name, oldname->len);
 
-	RESERVE_SPACE(4 + newname->len);
+	p = reserve_space(xdr, 4 + newname->len);
 	*p++ = cpu_to_be32(newname->len);
 	p = xdr_encode_opaque_fixed(p, newname->name, newname->len);
 	hdr->nops++;
@@ -1407,7 +1399,7 @@ static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_RENEW);
 	p = xdr_encode_hyper(p, client_stateid->cl_clientid);
 	hdr->nops++;
@@ -1419,7 +1411,7 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_RESTOREFH);
 	hdr->nops++;
 	hdr->replen += decode_restorefh_maxsz;
@@ -1430,15 +1422,15 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_SETATTR);
 	p = xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
-	RESERVE_SPACE(2*4);
+	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
 	*p++ = cpu_to_be32(FATTR4_WORD0_ACL);
 	if (arg->acl_len % 4)
 		return -EINVAL;
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
@@ -1451,7 +1443,7 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_SAVEFH);
 	hdr->nops++;
 	hdr->replen += decode_savefh_maxsz;
@@ -1461,7 +1453,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_SETATTR);
 	p = xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
@@ -1473,16 +1465,16 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4 + NFS4_VERIFIER_SIZE);
+	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID);
 	p = xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(setclientid->sc_prog);
 	encode_string(xdr, setclientid->sc_netid_len, setclientid->sc_netid);
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(setclientid->sc_cb_ident);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_maxsz;
@@ -1492,7 +1484,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
+	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, client_state->cl_clientid);
 	p = xdr_encode_opaque_fixed(p, client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
@@ -1504,12 +1496,12 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4);
+	p = reserve_space(xdr, 4);
 	*p++ = cpu_to_be32(OP_WRITE);
 
 	encode_stateid(xdr, args->context);
 
-	RESERVE_SPACE(16);
+	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->stable);
 	*p++ = cpu_to_be32(args->count);
@@ -1523,7 +1515,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 
 	*p++ = cpu_to_be32(OP_DELEGRETURN);
 	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
@@ -1539,13 +1531,13 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	RESERVE_SPACE(4 + sizeof(args->verifier->data));
+	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
 	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
 	p = xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
 
 	encode_string(xdr, args->id_len, args->id);
 
-	RESERVE_SPACE(12);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(args->flags);
 	*p++ = cpu_to_be32(0);	/* zero length state_protect4_a */
 	*p++ = cpu_to_be32(0);	/* zero length implementation id array */
@@ -1565,7 +1557,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	len = scnprintf(machine_name, sizeof(machine_name), "%s",
 			clp->cl_ipaddr);
 
-	RESERVE_SPACE(20 + 2*28 + 20 + len + 12);
+	p = reserve_space(xdr, 20 + 2*28 + 20 + len + 12);
 	*p++ = cpu_to_be32(OP_CREATE_SESSION);
 	p = xdr_encode_hyper(p, clp->cl_ex_clid);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
@@ -1609,7 +1601,7 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 				   struct compound_hdr *hdr)
 {
 	__be32 *p;
-	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN);
+	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(OP_DESTROY_SESSION);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	hdr->nops++;
@@ -1635,7 +1627,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
 	slot = tp->slots + args->sa_slotid;
 
-	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN + 16);
+	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN + 16);
 	*p++ = cpu_to_be32(OP_SEQUENCE);
 
 	/*
-- 
1.6.4

