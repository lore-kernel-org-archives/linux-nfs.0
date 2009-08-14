From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 03/21] nfs: nfs4xdr: get rid of WRITE32
Date: Fri, 14 Aug 2009 17:18:54 +0300
Message-ID: <1250259534-13575-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27274
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756841AbZHNOTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:03 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

s/WRITE32/*p++ = cpu_to_be32/

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  291 +++++++++++++++++++++++++++---------------------------
 1 files changed, 145 insertions(+), 146 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 617273e..9a03b24 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -712,7 +712,6 @@ struct compound_hdr {
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define WRITE32(n)               *p++ = htonl(n)
 #define WRITE64(n)               do {				\
 	*p++ = htonl((uint32_t)((n) >> 32));				\
 	*p++ = htonl((uint32_t)(n));					\
@@ -750,11 +749,11 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
 	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
-	WRITE32(hdr->taglen);
+	*p++ = cpu_to_be32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
-	WRITE32(hdr->minorversion);
+	*p++ = cpu_to_be32(hdr->minorversion);
 	hdr->nops_p = p;
-	WRITE32(hdr->nops);
+	*p++ = cpu_to_be32(hdr->nops);
 }
 
 static void encode_nops(struct compound_hdr *hdr)
@@ -835,7 +834,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	 * We write the bitmap length now, but leave the bitmap and the attribute
 	 * buffer length to be backfilled at the end of this routine.
 	 */
-	WRITE32(2);
+	*p++ = cpu_to_be32(2);
 	q = p;
 	p += 3;
 
@@ -845,39 +844,39 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	}
 	if (iap->ia_valid & ATTR_MODE) {
 		bmval1 |= FATTR4_WORD1_MODE;
-		WRITE32(iap->ia_mode & S_IALLUGO);
+		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
 	}
 	if (iap->ia_valid & ATTR_UID) {
 		bmval1 |= FATTR4_WORD1_OWNER;
-		WRITE32(owner_namelen);
+		*p++ = cpu_to_be32(owner_namelen);
 		WRITEMEM(owner_name, owner_namelen);
 	}
 	if (iap->ia_valid & ATTR_GID) {
 		bmval1 |= FATTR4_WORD1_OWNER_GROUP;
-		WRITE32(owner_grouplen);
+		*p++ = cpu_to_be32(owner_grouplen);
 		WRITEMEM(owner_group, owner_grouplen);
 	}
 	if (iap->ia_valid & ATTR_ATIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
-		WRITE32(NFS4_SET_TO_CLIENT_TIME);
-		WRITE32(0);
-		WRITE32(iap->ia_mtime.tv_sec);
-		WRITE32(iap->ia_mtime.tv_nsec);
+		*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(iap->ia_mtime.tv_sec);
+		*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
 	}
 	else if (iap->ia_valid & ATTR_ATIME) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
-		WRITE32(NFS4_SET_TO_SERVER_TIME);
+		*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
 	if (iap->ia_valid & ATTR_MTIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
-		WRITE32(NFS4_SET_TO_CLIENT_TIME);
-		WRITE32(0);
-		WRITE32(iap->ia_mtime.tv_sec);
-		WRITE32(iap->ia_mtime.tv_nsec);
+		*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
+		*p++ = cpu_to_be32(0);
+		*p++ = cpu_to_be32(iap->ia_mtime.tv_sec);
+		*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
 	}
 	else if (iap->ia_valid & ATTR_MTIME) {
 		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
-		WRITE32(NFS4_SET_TO_SERVER_TIME);
+		*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
 
 	/*
@@ -901,8 +900,8 @@ static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hd
 	__be32 *p;
 
 	RESERVE_SPACE(8);
-	WRITE32(OP_ACCESS);
-	WRITE32(access);
+	*p++ = cpu_to_be32(OP_ACCESS);
+	*p++ = cpu_to_be32(access);
 	hdr->nops++;
 	hdr->replen += decode_access_maxsz;
 }
@@ -912,8 +911,8 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 	__be32 *p;
 
 	RESERVE_SPACE(8+NFS4_STATEID_SIZE);
-	WRITE32(OP_CLOSE);
-	WRITE32(arg->seqid->sequence->counter);
+	*p++ = cpu_to_be32(OP_CLOSE);
+	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_close_maxsz;
@@ -924,9 +923,9 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 	__be32 *p;
 
 	RESERVE_SPACE(16);
-	WRITE32(OP_COMMIT);
+	*p++ = cpu_to_be32(OP_COMMIT);
 	WRITE64(args->offset);
-	WRITE32(args->count);
+	*p++ = cpu_to_be32(args->count);
 	hdr->nops++;
 	hdr->replen += decode_commit_maxsz;
 }
@@ -936,20 +935,20 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	__be32 *p;
 
 	RESERVE_SPACE(8);
-	WRITE32(OP_CREATE);
-	WRITE32(create->ftype);
+	*p++ = cpu_to_be32(OP_CREATE);
+	*p++ = cpu_to_be32(create->ftype);
 
 	switch (create->ftype) {
 	case NF4LNK:
 		RESERVE_SPACE(4);
-		WRITE32(create->u.symlink.len);
+		*p++ = cpu_to_be32(create->u.symlink.len);
 		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
 		break;
 
 	case NF4BLK: case NF4CHR:
 		RESERVE_SPACE(8);
-		WRITE32(create->u.device.specdata1);
-		WRITE32(create->u.device.specdata2);
+		*p++ = cpu_to_be32(create->u.device.specdata1);
+		*p++ = cpu_to_be32(create->u.device.specdata2);
 		break;
 
 	default:
@@ -957,7 +956,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	}
 
 	RESERVE_SPACE(4 + create->name->len);
-	WRITE32(create->name->len);
+	*p++ = cpu_to_be32(create->name->len);
 	WRITEMEM(create->name->name, create->name->len);
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
@@ -970,9 +969,9 @@ static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct c
 	__be32 *p;
 
 	RESERVE_SPACE(12);
-	WRITE32(OP_GETATTR);
-	WRITE32(1);
-	WRITE32(bitmap);
+	*p++ = cpu_to_be32(OP_GETATTR);
+	*p++ = cpu_to_be32(1);
+	*p++ = cpu_to_be32(bitmap);
 	hdr->nops++;
 	hdr->replen += decode_getattr_maxsz;
 }
@@ -982,10 +981,10 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 	__be32 *p;
 
 	RESERVE_SPACE(16);
-	WRITE32(OP_GETATTR);
-	WRITE32(2);
-	WRITE32(bm0);
-	WRITE32(bm1);
+	*p++ = cpu_to_be32(OP_GETATTR);
+	*p++ = cpu_to_be32(2);
+	*p++ = cpu_to_be32(bm0);
+	*p++ = cpu_to_be32(bm1);
 	hdr->nops++;
 	hdr->replen += decode_getattr_maxsz;
 }
@@ -1013,7 +1012,7 @@ static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_GETFH);
+	*p++ = cpu_to_be32(OP_GETFH);
 	hdr->nops++;
 	hdr->replen += decode_getfh_maxsz;
 }
@@ -1023,8 +1022,8 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 	__be32 *p;
 
 	RESERVE_SPACE(8 + name->len);
-	WRITE32(OP_LINK);
-	WRITE32(name->len);
+	*p++ = cpu_to_be32(OP_LINK);
+	*p++ = cpu_to_be32(name->len);
 	WRITEMEM(name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_link_maxsz;
@@ -1053,26 +1052,26 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	__be32 *p;
 
 	RESERVE_SPACE(32);
-	WRITE32(OP_LOCK);
-	WRITE32(nfs4_lock_type(args->fl, args->block));
-	WRITE32(args->reclaim);
+	*p++ = cpu_to_be32(OP_LOCK);
+	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, args->block));
+	*p++ = cpu_to_be32(args->reclaim);
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
-	WRITE32(args->new_lock_owner);
+	*p++ = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
 		RESERVE_SPACE(4+NFS4_STATEID_SIZE+32);
-		WRITE32(args->open_seqid->sequence->counter);
+		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
 		WRITEMEM(args->open_stateid->data, NFS4_STATEID_SIZE);
-		WRITE32(args->lock_seqid->sequence->counter);
+		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
 		WRITE64(args->lock_owner.clientid);
-		WRITE32(16);
+		*p++ = cpu_to_be32(16);
 		WRITEMEM("lock id:", 8);
 		WRITE64(args->lock_owner.id);
 	}
 	else {
 		RESERVE_SPACE(NFS4_STATEID_SIZE+4);
 		WRITEMEM(args->lock_stateid->data, NFS4_STATEID_SIZE);
-		WRITE32(args->lock_seqid->sequence->counter);
+		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
 	hdr->replen += decode_lock_maxsz;
@@ -1083,12 +1082,12 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 	__be32 *p;
 
 	RESERVE_SPACE(52);
-	WRITE32(OP_LOCKT);
-	WRITE32(nfs4_lock_type(args->fl, 0));
+	*p++ = cpu_to_be32(OP_LOCKT);
+	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
 	WRITE64(args->lock_owner.clientid);
-	WRITE32(16);
+	*p++ = cpu_to_be32(16);
 	WRITEMEM("lock id:", 8);
 	WRITE64(args->lock_owner.id);
 	hdr->nops++;
@@ -1100,9 +1099,9 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	__be32 *p;
 
 	RESERVE_SPACE(12+NFS4_STATEID_SIZE+16);
-	WRITE32(OP_LOCKU);
-	WRITE32(nfs4_lock_type(args->fl, 0));
-	WRITE32(args->seqid->sequence->counter);
+	*p++ = cpu_to_be32(OP_LOCKU);
+	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
+	*p++ = cpu_to_be32(args->seqid->sequence->counter);
 	WRITEMEM(args->stateid->data, NFS4_STATEID_SIZE);
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
@@ -1116,8 +1115,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	__be32 *p;
 
 	RESERVE_SPACE(8 + len);
-	WRITE32(OP_LOOKUP);
-	WRITE32(len);
+	*p++ = cpu_to_be32(OP_LOOKUP);
+	*p++ = cpu_to_be32(len);
 	WRITEMEM(name->name, len);
 	hdr->nops++;
 	hdr->replen += decode_lookup_maxsz;
@@ -1130,18 +1129,18 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 	RESERVE_SPACE(8);
 	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
 	case FMODE_READ:
-		WRITE32(NFS4_SHARE_ACCESS_READ);
+		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_READ);
 		break;
 	case FMODE_WRITE:
-		WRITE32(NFS4_SHARE_ACCESS_WRITE);
+		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_WRITE);
 		break;
 	case FMODE_READ|FMODE_WRITE:
-		WRITE32(NFS4_SHARE_ACCESS_BOTH);
+		*p++ = cpu_to_be32(NFS4_SHARE_ACCESS_BOTH);
 		break;
 	default:
-		WRITE32(0);
+		*p++ = cpu_to_be32(0);
 	}
-	WRITE32(0);		/* for linux, share_deny = 0 always */
+	*p++ = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
 }
 
 static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1152,12 +1151,12 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	RESERVE_SPACE(8);
-	WRITE32(OP_OPEN);
-	WRITE32(arg->seqid->sequence->counter);
+	*p++ = cpu_to_be32(OP_OPEN);
+	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	RESERVE_SPACE(28);
 	WRITE64(arg->clientid);
-	WRITE32(16);
+	*p++ = cpu_to_be32(16);
 	WRITEMEM("open id:", 8);
 	WRITE64(arg->id);
 }
@@ -1169,11 +1168,11 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	RESERVE_SPACE(4);
 	switch(arg->open_flags & O_EXCL) {
 	case 0:
-		WRITE32(NFS4_CREATE_UNCHECKED);
+		*p++ = cpu_to_be32(NFS4_CREATE_UNCHECKED);
 		encode_attrs(xdr, arg->u.attrs, arg->server);
 		break;
 	default:
-		WRITE32(NFS4_CREATE_EXCLUSIVE);
+		*p++ = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
 	}
 }
@@ -1185,11 +1184,11 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 	RESERVE_SPACE(4);
 	switch (arg->open_flags & O_CREAT) {
 	case 0:
-		WRITE32(NFS4_OPEN_NOCREATE);
+		*p++ = cpu_to_be32(NFS4_OPEN_NOCREATE);
 		break;
 	default:
 		BUG_ON(arg->claim != NFS4_OPEN_CLAIM_NULL);
-		WRITE32(NFS4_OPEN_CREATE);
+		*p++ = cpu_to_be32(NFS4_OPEN_CREATE);
 		encode_createmode(xdr, arg);
 	}
 }
@@ -1201,13 +1200,13 @@ static inline void encode_delegation_type(struct xdr_stream *xdr, fmode_t delega
 	RESERVE_SPACE(4);
 	switch (delegation_type) {
 	case 0:
-		WRITE32(NFS4_OPEN_DELEGATE_NONE);
+		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_NONE);
 		break;
 	case FMODE_READ:
-		WRITE32(NFS4_OPEN_DELEGATE_READ);
+		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_READ);
 		break;
 	case FMODE_WRITE|FMODE_READ:
-		WRITE32(NFS4_OPEN_DELEGATE_WRITE);
+		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_WRITE);
 		break;
 	default:
 		BUG();
@@ -1219,7 +1218,7 @@ static inline void encode_claim_null(struct xdr_stream *xdr, const struct qstr *
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(NFS4_OPEN_CLAIM_NULL);
+	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_NULL);
 	encode_string(xdr, name->len, name->name);
 }
 
@@ -1228,7 +1227,7 @@ static inline void encode_claim_previous(struct xdr_stream *xdr, fmode_t type)
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(NFS4_OPEN_CLAIM_PREVIOUS);
+	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_PREVIOUS);
 	encode_delegation_type(xdr, type);
 }
 
@@ -1237,7 +1236,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 	__be32 *p;
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
-	WRITE32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
+	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
 	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
 	encode_string(xdr, name->len, name->name);
 }
@@ -1268,9 +1267,9 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 	__be32 *p;
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
-	WRITE32(OP_OPEN_CONFIRM);
+	*p++ = cpu_to_be32(OP_OPEN_CONFIRM);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
-	WRITE32(arg->seqid->sequence->counter);
+	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	hdr->nops++;
 	hdr->replen += decode_open_confirm_maxsz;
 }
@@ -1280,9 +1279,9 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	__be32 *p;
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE+4);
-	WRITE32(OP_OPEN_DOWNGRADE);
+	*p++ = cpu_to_be32(OP_OPEN_DOWNGRADE);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
-	WRITE32(arg->seqid->sequence->counter);
+	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
 	hdr->replen += decode_open_downgrade_maxsz;
@@ -1295,8 +1294,8 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	__be32 *p;
 
 	RESERVE_SPACE(8 + len);
-	WRITE32(OP_PUTFH);
-	WRITE32(len);
+	*p++ = cpu_to_be32(OP_PUTFH);
+	*p++ = cpu_to_be32(len);
 	WRITEMEM(fh->data, len);
 	hdr->nops++;
 	hdr->replen += decode_putfh_maxsz;
@@ -1307,7 +1306,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_PUTROOTFH);
+	*p++ = cpu_to_be32(OP_PUTROOTFH);
 	hdr->nops++;
 	hdr->replen += decode_putrootfh_maxsz;
 }
@@ -1330,13 +1329,13 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_READ);
+	*p++ = cpu_to_be32(OP_READ);
 
 	encode_stateid(xdr, args->context);
 
 	RESERVE_SPACE(12);
 	WRITE64(args->offset);
-	WRITE32(args->count);
+	*p++ = cpu_to_be32(args->count);
 	hdr->nops++;
 	hdr->replen += decode_read_maxsz;
 }
@@ -1350,19 +1349,19 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	__be32 *p;
 
 	RESERVE_SPACE(12+NFS4_VERIFIER_SIZE+20);
-	WRITE32(OP_READDIR);
+	*p++ = cpu_to_be32(OP_READDIR);
 	WRITE64(readdir->cookie);
 	WRITEMEM(readdir->verifier.data, NFS4_VERIFIER_SIZE);
-	WRITE32(readdir->count >> 1);  /* We're not doing readdirplus */
-	WRITE32(readdir->count);
-	WRITE32(2);
+	*p++ = cpu_to_be32(readdir->count >> 1);  /* We're not doing readdirplus */
+	*p++ = cpu_to_be32(readdir->count);
+	*p++ = cpu_to_be32(2);
 	/* Switch to mounted_on_fileid if the server supports it */
 	if (readdir->bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)
 		attrs[0] &= ~FATTR4_WORD0_FILEID;
 	else
 		attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
-	WRITE32(attrs[0] & readdir->bitmask[0]);
-	WRITE32(attrs[1] & readdir->bitmask[1]);
+	*p++ = cpu_to_be32(attrs[0] & readdir->bitmask[0]);
+	*p++ = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
 	hdr->nops++;
 	hdr->replen += decode_readdir_maxsz;
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
@@ -1379,7 +1378,7 @@ static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_READLINK);
+	*p++ = cpu_to_be32(OP_READLINK);
 	hdr->nops++;
 	hdr->replen += decode_readlink_maxsz;
 }
@@ -1389,8 +1388,8 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 	__be32 *p;
 
 	RESERVE_SPACE(8 + name->len);
-	WRITE32(OP_REMOVE);
-	WRITE32(name->len);
+	*p++ = cpu_to_be32(OP_REMOVE);
+	*p++ = cpu_to_be32(name->len);
 	WRITEMEM(name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_remove_maxsz;
@@ -1401,12 +1400,12 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 	__be32 *p;
 
 	RESERVE_SPACE(8 + oldname->len);
-	WRITE32(OP_RENAME);
-	WRITE32(oldname->len);
+	*p++ = cpu_to_be32(OP_RENAME);
+	*p++ = cpu_to_be32(oldname->len);
 	WRITEMEM(oldname->name, oldname->len);
 
 	RESERVE_SPACE(4 + newname->len);
-	WRITE32(newname->len);
+	*p++ = cpu_to_be32(newname->len);
 	WRITEMEM(newname->name, newname->len);
 	hdr->nops++;
 	hdr->replen += decode_rename_maxsz;
@@ -1417,7 +1416,7 @@ static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client
 	__be32 *p;
 
 	RESERVE_SPACE(12);
-	WRITE32(OP_RENEW);
+	*p++ = cpu_to_be32(OP_RENEW);
 	WRITE64(client_stateid->cl_clientid);
 	hdr->nops++;
 	hdr->replen += decode_renew_maxsz;
@@ -1429,7 +1428,7 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_RESTOREFH);
+	*p++ = cpu_to_be32(OP_RESTOREFH);
 	hdr->nops++;
 	hdr->replen += decode_restorefh_maxsz;
 }
@@ -1440,15 +1439,15 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	__be32 *p;
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
-	WRITE32(OP_SETATTR);
+	*p++ = cpu_to_be32(OP_SETATTR);
 	WRITEMEM(zero_stateid.data, NFS4_STATEID_SIZE);
 	RESERVE_SPACE(2*4);
-	WRITE32(1);
-	WRITE32(FATTR4_WORD0_ACL);
+	*p++ = cpu_to_be32(1);
+	*p++ = cpu_to_be32(FATTR4_WORD0_ACL);
 	if (arg->acl_len % 4)
 		return -EINVAL;
 	RESERVE_SPACE(4);
-	WRITE32(arg->acl_len);
+	*p++ = cpu_to_be32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
 	hdr->replen += decode_setacl_maxsz;
@@ -1461,7 +1460,7 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_SAVEFH);
+	*p++ = cpu_to_be32(OP_SAVEFH);
 	hdr->nops++;
 	hdr->replen += decode_savefh_maxsz;
 }
@@ -1471,7 +1470,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 	__be32 *p;
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
-	WRITE32(OP_SETATTR);
+	*p++ = cpu_to_be32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setattr_maxsz;
@@ -1483,16 +1482,16 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 	__be32 *p;
 
 	RESERVE_SPACE(4 + NFS4_VERIFIER_SIZE);
-	WRITE32(OP_SETCLIENTID);
+	*p++ = cpu_to_be32(OP_SETCLIENTID);
 	WRITEMEM(setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
 	RESERVE_SPACE(4);
-	WRITE32(setclientid->sc_prog);
+	*p++ = cpu_to_be32(setclientid->sc_prog);
 	encode_string(xdr, setclientid->sc_netid_len, setclientid->sc_netid);
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
 	RESERVE_SPACE(4);
-	WRITE32(setclientid->sc_cb_ident);
+	*p++ = cpu_to_be32(setclientid->sc_cb_ident);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_maxsz;
 }
@@ -1502,7 +1501,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 	__be32 *p;
 
 	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
-	WRITE32(OP_SETCLIENTID_CONFIRM);
+	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
 	WRITE64(client_state->cl_clientid);
 	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
@@ -1514,14 +1513,14 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	__be32 *p;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_WRITE);
+	*p++ = cpu_to_be32(OP_WRITE);
 
 	encode_stateid(xdr, args->context);
 
 	RESERVE_SPACE(16);
 	WRITE64(args->offset);
-	WRITE32(args->stable);
-	WRITE32(args->count);
+	*p++ = cpu_to_be32(args->stable);
+	*p++ = cpu_to_be32(args->count);
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 	hdr->nops++;
@@ -1534,7 +1533,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 
-	WRITE32(OP_DELEGRETURN);
+	*p++ = cpu_to_be32(OP_DELEGRETURN);
 	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
@@ -1549,15 +1548,15 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	__be32 *p;
 
 	RESERVE_SPACE(4 + sizeof(args->verifier->data));
-	WRITE32(OP_EXCHANGE_ID);
+	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
 	WRITEMEM(args->verifier->data, sizeof(args->verifier->data));
 
 	encode_string(xdr, args->id_len, args->id);
 
 	RESERVE_SPACE(12);
-	WRITE32(args->flags);
-	WRITE32(0);	/* zero length state_protect4_a */
-	WRITE32(0);	/* zero length implementation id array */
+	*p++ = cpu_to_be32(args->flags);
+	*p++ = cpu_to_be32(0);	/* zero length state_protect4_a */
+	*p++ = cpu_to_be32(0);	/* zero length implementation id array */
 	hdr->nops++;
 	hdr->replen += decode_exchange_id_maxsz;
 }
@@ -1572,54 +1571,54 @@ static void encode_create_session(struct xdr_stream *xdr,
 	struct nfs_client *clp = args->client;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_CREATE_SESSION);
+	*p++ = cpu_to_be32(OP_CREATE_SESSION);
 
 	RESERVE_SPACE(8);
 	WRITE64(clp->cl_ex_clid);
 
 	RESERVE_SPACE(8);
-	WRITE32(clp->cl_seqid);			/*Sequence id */
-	WRITE32(args->flags);			/*flags */
+	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
+	*p++ = cpu_to_be32(args->flags);			/*flags */
 
 	RESERVE_SPACE(2*28);			/* 2 channel_attrs */
 	/* Fore Channel */
-	WRITE32(args->fc_attrs.headerpadsz);	/* header padding size */
-	WRITE32(args->fc_attrs.max_rqst_sz);	/* max req size */
-	WRITE32(args->fc_attrs.max_resp_sz);	/* max resp size */
-	WRITE32(args->fc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
-	WRITE32(args->fc_attrs.max_ops);	/* max operations */
-	WRITE32(args->fc_attrs.max_reqs);	/* max requests */
-	WRITE32(0);				/* rdmachannel_attrs */
+	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
+	*p++ = cpu_to_be32(args->fc_attrs.max_rqst_sz);	/* max req size */
+	*p++ = cpu_to_be32(args->fc_attrs.max_resp_sz);	/* max resp size */
+	*p++ = cpu_to_be32(args->fc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
+	*p++ = cpu_to_be32(args->fc_attrs.max_ops);	/* max operations */
+	*p++ = cpu_to_be32(args->fc_attrs.max_reqs);	/* max requests */
+	*p++ = cpu_to_be32(0);				/* rdmachannel_attrs */
 
 	/* Back Channel */
-	WRITE32(args->fc_attrs.headerpadsz);	/* header padding size */
-	WRITE32(args->bc_attrs.max_rqst_sz);	/* max req size */
-	WRITE32(args->bc_attrs.max_resp_sz);	/* max resp size */
-	WRITE32(args->bc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
-	WRITE32(args->bc_attrs.max_ops);	/* max operations */
-	WRITE32(args->bc_attrs.max_reqs);	/* max requests */
-	WRITE32(0);				/* rdmachannel_attrs */
+	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
+	*p++ = cpu_to_be32(args->bc_attrs.max_rqst_sz);	/* max req size */
+	*p++ = cpu_to_be32(args->bc_attrs.max_resp_sz);	/* max resp size */
+	*p++ = cpu_to_be32(args->bc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
+	*p++ = cpu_to_be32(args->bc_attrs.max_ops);	/* max operations */
+	*p++ = cpu_to_be32(args->bc_attrs.max_reqs);	/* max requests */
+	*p++ = cpu_to_be32(0);				/* rdmachannel_attrs */
 
 	RESERVE_SPACE(4);
-	WRITE32(args->cb_program);		/* cb_program */
+	*p++ = cpu_to_be32(args->cb_program);		/* cb_program */
 
 	RESERVE_SPACE(4);			/* # of security flavors */
-	WRITE32(1);
+	*p++ = cpu_to_be32(1);
 
 	RESERVE_SPACE(4);
-	WRITE32(RPC_AUTH_UNIX);			/* auth_sys */
+	*p++ = cpu_to_be32(RPC_AUTH_UNIX);			/* auth_sys */
 
 	/* authsys_parms rfc1831 */
 	RESERVE_SPACE(4);
-	WRITE32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
+	*p++ = cpu_to_be32((u32)clp->cl_boot_time.tv_nsec);	/* stamp */
 	len = scnprintf(machine_name, sizeof(machine_name), "%s",
 			clp->cl_ipaddr);
 	RESERVE_SPACE(16 + len);
-	WRITE32(len);
+	*p++ = cpu_to_be32(len);
 	WRITEMEM(machine_name, len);
-	WRITE32(0);				/* UID */
-	WRITE32(0);				/* GID */
-	WRITE32(0);				/* No more gids */
+	*p++ = cpu_to_be32(0);				/* UID */
+	*p++ = cpu_to_be32(0);				/* GID */
+	*p++ = cpu_to_be32(0);				/* No more gids */
 	hdr->nops++;
 	hdr->replen += decode_create_session_maxsz;
 }
@@ -1630,7 +1629,7 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 {
 	__be32 *p;
 	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN);
-	WRITE32(OP_DESTROY_SESSION);
+	*p++ = cpu_to_be32(OP_DESTROY_SESSION);
 	WRITEMEM(session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	hdr->nops++;
 	hdr->replen += decode_destroy_session_maxsz;
@@ -1656,7 +1655,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 	slot = tp->slots + args->sa_slotid;
 
 	RESERVE_SPACE(4);
-	WRITE32(OP_SEQUENCE);
+	*p++ = cpu_to_be32(OP_SEQUENCE);
 
 	/*
 	 * Sessionid + seqid + slotid + max slotid + cache_this
@@ -1672,10 +1671,10 @@ static void encode_sequence(struct xdr_stream *xdr,
 		tp->highest_used_slotid, args->sa_cache_this);
 	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 16);
 	WRITEMEM(session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
-	WRITE32(slot->seq_nr);
-	WRITE32(args->sa_slotid);
-	WRITE32(tp->highest_used_slotid);
-	WRITE32(args->sa_cache_this);
+	*p++ = cpu_to_be32(slot->seq_nr);
+	*p++ = cpu_to_be32(args->sa_slotid);
+	*p++ = cpu_to_be32(tp->highest_used_slotid);
+	*p++ = cpu_to_be32(args->sa_cache_this);
 	hdr->nops++;
 	hdr->replen += decode_sequence_maxsz;
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.4

