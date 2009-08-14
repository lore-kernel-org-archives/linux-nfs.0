From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 09/21] nfs: nfs4xdr: optimize low level encoding
Date: Fri, 14 Aug 2009 17:19:30 +0300
Message-ID: <1250259570-13768-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:23565
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756885AbZHNOTh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:37 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

do not increment encoding ptr if not needed.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  128 +++++++++++++++++++++++++++---------------------------
 1 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3bcde49..d75f821 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -737,7 +737,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	p = xdr_encode_opaque_fixed(p, hdr->tag, hdr->taglen);
 	*p++ = cpu_to_be32(hdr->minorversion);
 	hdr->nops_p = p;
-	*p++ = cpu_to_be32(hdr->nops);
+	*p = cpu_to_be32(hdr->nops);
 }
 
 static void encode_nops(struct compound_hdr *hdr)
@@ -874,7 +874,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	len = (char *)p - (char *)q - 12;
 	*q++ = htonl(bmval0);
 	*q++ = htonl(bmval1);
-	*q++ = htonl(len);
+	*q = htonl(len);
 
 /* out: */
 }
@@ -885,7 +885,7 @@ static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hd
 
 	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_ACCESS);
-	*p++ = cpu_to_be32(access);
+	*p = cpu_to_be32(access);
 	hdr->nops++;
 	hdr->replen += decode_access_maxsz;
 }
@@ -897,7 +897,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 	p = reserve_space(xdr, 8+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_CLOSE);
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
-	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_close_maxsz;
 }
@@ -909,7 +909,7 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(OP_COMMIT);
 	p = xdr_encode_hyper(p, args->offset);
-	*p++ = cpu_to_be32(args->count);
+	*p = cpu_to_be32(args->count);
 	hdr->nops++;
 	hdr->replen += decode_commit_maxsz;
 }
@@ -920,19 +920,19 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 
 	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_CREATE);
-	*p++ = cpu_to_be32(create->ftype);
+	*p = cpu_to_be32(create->ftype);
 
 	switch (create->ftype) {
 	case NF4LNK:
 		p = reserve_space(xdr, 4);
-		*p++ = cpu_to_be32(create->u.symlink.len);
+		*p = cpu_to_be32(create->u.symlink.len);
 		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
 		break;
 
 	case NF4BLK: case NF4CHR:
 		p = reserve_space(xdr, 8);
 		*p++ = cpu_to_be32(create->u.device.specdata1);
-		*p++ = cpu_to_be32(create->u.device.specdata2);
+		*p = cpu_to_be32(create->u.device.specdata2);
 		break;
 
 	default:
@@ -941,7 +941,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 
 	p = reserve_space(xdr, 4 + create->name->len);
 	*p++ = cpu_to_be32(create->name->len);
-	p = xdr_encode_opaque_fixed(p, create->name->name, create->name->len);
+	xdr_encode_opaque_fixed(p, create->name->name, create->name->len);
 	hdr->nops++;
 	hdr->replen += decode_create_maxsz;
 
@@ -955,7 +955,7 @@ static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct c
 	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_GETATTR);
 	*p++ = cpu_to_be32(1);
-	*p++ = cpu_to_be32(bitmap);
+	*p = cpu_to_be32(bitmap);
 	hdr->nops++;
 	hdr->replen += decode_getattr_maxsz;
 }
@@ -968,7 +968,7 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 	*p++ = cpu_to_be32(OP_GETATTR);
 	*p++ = cpu_to_be32(2);
 	*p++ = cpu_to_be32(bm0);
-	*p++ = cpu_to_be32(bm1);
+	*p = cpu_to_be32(bm1);
 	hdr->nops++;
 	hdr->replen += decode_getattr_maxsz;
 }
@@ -996,7 +996,7 @@ static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_GETFH);
+	*p = cpu_to_be32(OP_GETFH);
 	hdr->nops++;
 	hdr->replen += decode_getfh_maxsz;
 }
@@ -1008,7 +1008,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 	p = reserve_space(xdr, 8 + name->len);
 	*p++ = cpu_to_be32(OP_LINK);
 	*p++ = cpu_to_be32(name->len);
-	p = xdr_encode_opaque_fixed(p, name->name, name->len);
+	xdr_encode_opaque_fixed(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_link_maxsz;
 }
@@ -1041,7 +1041,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	*p++ = cpu_to_be32(args->reclaim);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
-	*p++ = cpu_to_be32(args->new_lock_owner);
+	*p = cpu_to_be32(args->new_lock_owner);
 	if (args->new_lock_owner){
 		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+32);
 		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
@@ -1050,12 +1050,12 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 		p = xdr_encode_hyper(p, args->lock_owner.clientid);
 		*p++ = cpu_to_be32(16);
 		p = xdr_encode_opaque_fixed(p, "lock id:", 8);
-		p = xdr_encode_hyper(p, args->lock_owner.id);
+		xdr_encode_hyper(p, args->lock_owner.id);
 	}
 	else {
 		p = reserve_space(xdr, NFS4_STATEID_SIZE+4);
 		p = xdr_encode_opaque_fixed(p, args->lock_stateid->data, NFS4_STATEID_SIZE);
-		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
+		*p = cpu_to_be32(args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
 	hdr->replen += decode_lock_maxsz;
@@ -1073,7 +1073,7 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 	p = xdr_encode_hyper(p, args->lock_owner.clientid);
 	*p++ = cpu_to_be32(16);
 	p = xdr_encode_opaque_fixed(p, "lock id:", 8);
-	p = xdr_encode_hyper(p, args->lock_owner.id);
+	xdr_encode_hyper(p, args->lock_owner.id);
 	hdr->nops++;
 	hdr->replen += decode_lockt_maxsz;
 }
@@ -1088,7 +1088,7 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	*p++ = cpu_to_be32(args->seqid->sequence->counter);
 	p = xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
-	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
+	xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	hdr->nops++;
 	hdr->replen += decode_locku_maxsz;
 }
@@ -1101,7 +1101,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	p = reserve_space(xdr, 8 + len);
 	*p++ = cpu_to_be32(OP_LOOKUP);
 	*p++ = cpu_to_be32(len);
-	p = xdr_encode_opaque_fixed(p, name->name, len);
+	xdr_encode_opaque_fixed(p, name->name, len);
 	hdr->nops++;
 	hdr->replen += decode_lookup_maxsz;
 }
@@ -1124,7 +1124,7 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 	default:
 		*p++ = cpu_to_be32(0);
 	}
-	*p++ = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
+	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
 }
 
 static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1136,13 +1136,13 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  */
 	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(OP_OPEN);
-	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
+	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	p = reserve_space(xdr, 28);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(16);
 	p = xdr_encode_opaque_fixed(p, "open id:", 8);
-	p = xdr_encode_hyper(p, arg->id);
+	xdr_encode_hyper(p, arg->id);
 }
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1152,11 +1152,11 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	p = reserve_space(xdr, 4);
 	switch(arg->open_flags & O_EXCL) {
 	case 0:
-		*p++ = cpu_to_be32(NFS4_CREATE_UNCHECKED);
+		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
 		encode_attrs(xdr, arg->u.attrs, arg->server);
 		break;
 	default:
-		*p++ = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
+		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
 	}
 }
@@ -1168,11 +1168,11 @@ static void encode_opentype(struct xdr_stream *xdr, const struct nfs_openargs *a
 	p = reserve_space(xdr, 4);
 	switch (arg->open_flags & O_CREAT) {
 	case 0:
-		*p++ = cpu_to_be32(NFS4_OPEN_NOCREATE);
+		*p = cpu_to_be32(NFS4_OPEN_NOCREATE);
 		break;
 	default:
 		BUG_ON(arg->claim != NFS4_OPEN_CLAIM_NULL);
-		*p++ = cpu_to_be32(NFS4_OPEN_CREATE);
+		*p = cpu_to_be32(NFS4_OPEN_CREATE);
 		encode_createmode(xdr, arg);
 	}
 }
@@ -1184,13 +1184,13 @@ static inline void encode_delegation_type(struct xdr_stream *xdr, fmode_t delega
 	p = reserve_space(xdr, 4);
 	switch (delegation_type) {
 	case 0:
-		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_NONE);
+		*p = cpu_to_be32(NFS4_OPEN_DELEGATE_NONE);
 		break;
 	case FMODE_READ:
-		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_READ);
+		*p = cpu_to_be32(NFS4_OPEN_DELEGATE_READ);
 		break;
 	case FMODE_WRITE|FMODE_READ:
-		*p++ = cpu_to_be32(NFS4_OPEN_DELEGATE_WRITE);
+		*p = cpu_to_be32(NFS4_OPEN_DELEGATE_WRITE);
 		break;
 	default:
 		BUG();
@@ -1202,7 +1202,7 @@ static inline void encode_claim_null(struct xdr_stream *xdr, const struct qstr *
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_NULL);
+	*p = cpu_to_be32(NFS4_OPEN_CLAIM_NULL);
 	encode_string(xdr, name->len, name->name);
 }
 
@@ -1211,7 +1211,7 @@ static inline void encode_claim_previous(struct xdr_stream *xdr, fmode_t type)
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_PREVIOUS);
+	*p = cpu_to_be32(NFS4_OPEN_CLAIM_PREVIOUS);
 	encode_delegation_type(xdr, type);
 }
 
@@ -1221,7 +1221,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
-	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
 	encode_string(xdr, name->len, name->name);
 }
 
@@ -1253,7 +1253,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	*p++ = cpu_to_be32(OP_OPEN_CONFIRM);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
-	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
+	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	hdr->nops++;
 	hdr->replen += decode_open_confirm_maxsz;
 }
@@ -1265,7 +1265,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	*p++ = cpu_to_be32(OP_OPEN_DOWNGRADE);
 	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
-	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
+	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
 	hdr->replen += decode_open_downgrade_maxsz;
@@ -1280,7 +1280,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	p = reserve_space(xdr, 8 + len);
 	*p++ = cpu_to_be32(OP_PUTFH);
 	*p++ = cpu_to_be32(len);
-	p = xdr_encode_opaque_fixed(p, fh->data, len);
+	xdr_encode_opaque_fixed(p, fh->data, len);
 	hdr->nops++;
 	hdr->replen += decode_putfh_maxsz;
 }
@@ -1290,7 +1290,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_PUTROOTFH);
+	*p = cpu_to_be32(OP_PUTROOTFH);
 	hdr->nops++;
 	hdr->replen += decode_putrootfh_maxsz;
 }
@@ -1303,9 +1303,9 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, ctx->lockowner);
-		p = xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
+		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
 	} else
-		p = xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
+		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
 }
 
 static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
@@ -1313,13 +1313,13 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_READ);
+	*p = cpu_to_be32(OP_READ);
 
 	encode_stateid(xdr, args->context);
 
 	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
-	*p++ = cpu_to_be32(args->count);
+	*p = cpu_to_be32(args->count);
 	hdr->nops++;
 	hdr->replen += decode_read_maxsz;
 }
@@ -1345,7 +1345,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	else
 		attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 	*p++ = cpu_to_be32(attrs[0] & readdir->bitmask[0]);
-	*p++ = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
+	*p = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
 	hdr->nops++;
 	hdr->replen += decode_readdir_maxsz;
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
@@ -1362,7 +1362,7 @@ static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_READLINK);
+	*p = cpu_to_be32(OP_READLINK);
 	hdr->nops++;
 	hdr->replen += decode_readlink_maxsz;
 }
@@ -1374,7 +1374,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 	p = reserve_space(xdr, 8 + name->len);
 	*p++ = cpu_to_be32(OP_REMOVE);
 	*p++ = cpu_to_be32(name->len);
-	p = xdr_encode_opaque_fixed(p, name->name, name->len);
+	xdr_encode_opaque_fixed(p, name->name, name->len);
 	hdr->nops++;
 	hdr->replen += decode_remove_maxsz;
 }
@@ -1386,11 +1386,11 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 	p = reserve_space(xdr, 8 + oldname->len);
 	*p++ = cpu_to_be32(OP_RENAME);
 	*p++ = cpu_to_be32(oldname->len);
-	p = xdr_encode_opaque_fixed(p, oldname->name, oldname->len);
+	xdr_encode_opaque_fixed(p, oldname->name, oldname->len);
 
 	p = reserve_space(xdr, 4 + newname->len);
 	*p++ = cpu_to_be32(newname->len);
-	p = xdr_encode_opaque_fixed(p, newname->name, newname->len);
+	xdr_encode_opaque_fixed(p, newname->name, newname->len);
 	hdr->nops++;
 	hdr->replen += decode_rename_maxsz;
 }
@@ -1401,7 +1401,7 @@ static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client
 
 	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_RENEW);
-	p = xdr_encode_hyper(p, client_stateid->cl_clientid);
+	xdr_encode_hyper(p, client_stateid->cl_clientid);
 	hdr->nops++;
 	hdr->replen += decode_renew_maxsz;
 }
@@ -1412,7 +1412,7 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_RESTOREFH);
+	*p = cpu_to_be32(OP_RESTOREFH);
 	hdr->nops++;
 	hdr->replen += decode_restorefh_maxsz;
 }
@@ -1424,14 +1424,14 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_SETATTR);
-	p = xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
 	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
-	*p++ = cpu_to_be32(FATTR4_WORD0_ACL);
+	*p = cpu_to_be32(FATTR4_WORD0_ACL);
 	if (arg->acl_len % 4)
 		return -EINVAL;
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(arg->acl_len);
+	*p = cpu_to_be32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
 	hdr->replen += decode_setacl_maxsz;
@@ -1444,7 +1444,7 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_SAVEFH);
+	*p = cpu_to_be32(OP_SAVEFH);
 	hdr->nops++;
 	hdr->replen += decode_savefh_maxsz;
 }
@@ -1455,7 +1455,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_SETATTR);
-	p = xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setattr_maxsz;
 	encode_attrs(xdr, arg->iap, server);
@@ -1467,15 +1467,15 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 
 	p = reserve_space(xdr, 4 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID);
-	p = xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
+	xdr_encode_opaque_fixed(p, setclientid->sc_verifier->data, NFS4_VERIFIER_SIZE);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(setclientid->sc_prog);
+	*p = cpu_to_be32(setclientid->sc_prog);
 	encode_string(xdr, setclientid->sc_netid_len, setclientid->sc_netid);
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(setclientid->sc_cb_ident);
+	*p = cpu_to_be32(setclientid->sc_cb_ident);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_maxsz;
 }
@@ -1487,7 +1487,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 	p = reserve_space(xdr, 12 + NFS4_VERIFIER_SIZE);
 	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
 	p = xdr_encode_hyper(p, client_state->cl_clientid);
-	p = xdr_encode_opaque_fixed(p, client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
+	xdr_encode_opaque_fixed(p, client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setclientid_confirm_maxsz;
 }
@@ -1497,14 +1497,14 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
-	*p++ = cpu_to_be32(OP_WRITE);
+	*p = cpu_to_be32(OP_WRITE);
 
 	encode_stateid(xdr, args->context);
 
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->stable);
-	*p++ = cpu_to_be32(args->count);
+	*p = cpu_to_be32(args->count);
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 	hdr->nops++;
@@ -1518,7 +1518,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 
 	*p++ = cpu_to_be32(OP_DELEGRETURN);
-	p = xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
 }
@@ -1533,14 +1533,14 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 
 	p = reserve_space(xdr, 4 + sizeof(args->verifier->data));
 	*p++ = cpu_to_be32(OP_EXCHANGE_ID);
-	p = xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
+	xdr_encode_opaque_fixed(p, args->verifier->data, sizeof(args->verifier->data));
 
 	encode_string(xdr, args->id_len, args->id);
 
 	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(args->flags);
 	*p++ = cpu_to_be32(0);	/* zero length state_protect4_a */
-	*p++ = cpu_to_be32(0);	/* zero length implementation id array */
+	*p = cpu_to_be32(0);	/* zero length implementation id array */
 	hdr->nops++;
 	hdr->replen += decode_exchange_id_maxsz;
 }
@@ -1591,7 +1591,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	p = xdr_encode_opaque_fixed(p, machine_name, len);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
-	*p++ = cpu_to_be32(0);				/* No more gids */
+	*p = cpu_to_be32(0);				/* No more gids */
 	hdr->nops++;
 	hdr->replen += decode_create_session_maxsz;
 }
@@ -1603,7 +1603,7 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 	__be32 *p;
 	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(OP_DESTROY_SESSION);
-	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	hdr->nops++;
 	hdr->replen += decode_destroy_session_maxsz;
 }
@@ -1646,7 +1646,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(slot->seq_nr);
 	*p++ = cpu_to_be32(args->sa_slotid);
 	*p++ = cpu_to_be32(tp->highest_used_slotid);
-	*p++ = cpu_to_be32(args->sa_cache_this);
+	*p = cpu_to_be32(args->sa_cache_this);
 	hdr->nops++;
 	hdr->replen += decode_sequence_maxsz;
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.4

