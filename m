Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38040 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755961Ab2CDXDP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 18:03:15 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] NFSv4: Add a encode op helper
Date: Sun,  4 Mar 2012 18:03:03 -0500
Message-Id: <1330902183-18879-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-7-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-8-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-9-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |  161 +++++++++++-------------------------------------------
 1 files changed, 32 insertions(+), 129 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 604da06..7b55c3c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -935,6 +935,15 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	*p = cpu_to_be32(hdr->nops);
 }
 
+static void encode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 op,
+		uint32_t replen,
+		struct compound_hdr *hdr)
+{
+	encode_word(xdr, op);
+	hdr->nops++;
+	hdr->replen += replen;
+}
+
 static void encode_nops(struct compound_hdr *hdr)
 {
 	BUG_ON(hdr->nops > NFS4_MAX_OPS);
@@ -1086,14 +1095,9 @@ static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hd
 
 static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_CLOSE);
+	encode_op_hdr(xdr, OP_CLOSE, decode_close_maxsz, hdr);
 	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_nfs4_stateid(xdr, arg->stateid);
-	hdr->nops++;
-	hdr->replen += decode_close_maxsz;
 }
 
 static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
@@ -1172,8 +1176,7 @@ encode_getattr_three(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_GETATTR);
+	encode_op_hdr(xdr, OP_GETATTR, decode_getattr_maxsz, hdr);
 	if (bm2) {
 		p = reserve_space(xdr, 16);
 		*p++ = cpu_to_be32(3);
@@ -1190,8 +1193,6 @@ encode_getattr_three(struct xdr_stream *xdr,
 		*p++ = cpu_to_be32(1);
 		*p = cpu_to_be32(bm0);
 	}
-	hdr->nops++;
-	hdr->replen += decode_getattr_maxsz;
 }
 
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
@@ -1217,23 +1218,13 @@ static void encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, stru
 
 static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_GETFH);
-	hdr->nops++;
-	hdr->replen += decode_getfh_maxsz;
+	encode_op_hdr(xdr, OP_GETFH, decode_getfh_maxsz, hdr);
 }
 
 static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_LINK);
+	encode_op_hdr(xdr, OP_LINK, decode_link_maxsz, hdr);
 	encode_string(xdr, name->len, name->name);
-	hdr->nops++;
-	hdr->replen += decode_link_maxsz;
 }
 
 static inline int nfs4_lock_type(struct file_lock *fl, int block)
@@ -1323,24 +1314,14 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 
 static void encode_release_lockowner(struct xdr_stream *xdr, const struct nfs_lowner *lowner, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_RELEASE_LOCKOWNER);
+	encode_op_hdr(xdr, OP_RELEASE_LOCKOWNER, decode_release_lockowner_maxsz, hdr);
 	encode_lockowner(xdr, lowner);
-	hdr->nops++;
-	hdr->replen += decode_release_lockowner_maxsz;
 }
 
 static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_LOOKUP);
+	encode_op_hdr(xdr, OP_LOOKUP, decode_lookup_maxsz, hdr);
 	encode_string(xdr, name->len, name->name);
-	hdr->nops++;
-	hdr->replen += decode_lookup_maxsz;
 }
 
 static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
@@ -1371,8 +1352,6 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * opcode 4, seqid 4, share_access 4, share_deny 4, clientid 8, ownerlen 4,
  * owner 4 = 32
  */
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_OPEN);
 	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_share_access(xdr, arg->fmode);
 	p = reserve_space(xdr, 32);
@@ -1481,6 +1460,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 
 static void encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg, struct compound_hdr *hdr)
 {
+	encode_op_hdr(xdr, OP_OPEN, decode_open_maxsz, hdr);
 	encode_openhdr(xdr, arg);
 	encode_opentype(xdr, arg);
 	switch (arg->claim) {
@@ -1496,55 +1476,33 @@ static void encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg,
 	default:
 		BUG();
 	}
-	hdr->nops++;
-	hdr->replen += decode_open_maxsz;
 }
 
 static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_OPEN_CONFIRM);
+	encode_op_hdr(xdr, OP_OPEN_CONFIRM, decode_open_confirm_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	hdr->nops++;
-	hdr->replen += decode_open_confirm_maxsz;
 }
 
 static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_OPEN_DOWNGRADE);
+	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_share_access(xdr, arg->fmode);
-	hdr->nops++;
-	hdr->replen += decode_open_downgrade_maxsz;
 }
 
 static void
 encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_PUTFH);
+	encode_op_hdr(xdr, OP_PUTFH, decode_putfh_maxsz, hdr);
 	encode_string(xdr, fh->size, fh->data);
-	hdr->nops++;
-	hdr->replen += decode_putfh_maxsz;
 }
 
 static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_PUTROOTFH);
-	hdr->nops++;
-	hdr->replen += decode_putrootfh_maxsz;
+	encode_op_hdr(xdr, OP_PUTROOTFH, decode_putrootfh_maxsz, hdr);
 }
 
 static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)
@@ -1564,17 +1522,13 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_READ);
-
+	encode_op_hdr(xdr, OP_READ, decode_read_maxsz, hdr);
 	encode_open_stateid(xdr, args->context, args->lock_context,
 		       hdr->minorversion);
 
 	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
 	*p = cpu_to_be32(args->count);
-	hdr->nops++;
-	hdr->replen += decode_read_maxsz;
 }
 
 static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
@@ -1622,35 +1576,20 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 
 static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_READLINK);
-	hdr->nops++;
-	hdr->replen += decode_readlink_maxsz;
+	encode_op_hdr(xdr, OP_READLINK, decode_readlink_maxsz, hdr);
 }
 
 static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_REMOVE);
+	encode_op_hdr(xdr, OP_REMOVE, decode_remove_maxsz, hdr);
 	encode_string(xdr, name->len, name->name);
-	hdr->nops++;
-	hdr->replen += decode_remove_maxsz;
 }
 
 static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_RENAME);
+	encode_op_hdr(xdr, OP_RENAME, decode_rename_maxsz, hdr);
 	encode_string(xdr, oldname->len, oldname->name);
 	encode_string(xdr, newname->len, newname->name);
-	hdr->nops++;
-	hdr->replen += decode_rename_maxsz;
 }
 
 static void encode_renew(struct xdr_stream *xdr, clientid4 clid,
@@ -1668,12 +1607,7 @@ static void encode_renew(struct xdr_stream *xdr, clientid4 clid,
 static void
 encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_RESTOREFH);
-	hdr->nops++;
-	hdr->replen += decode_restorefh_maxsz;
+	encode_op_hdr(xdr, OP_RESTOREFH, decode_restorefh_maxsz, hdr);
 }
 
 static void
@@ -1681,8 +1615,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_SETATTR);
+	encode_op_hdr(xdr, OP_SETATTR, decode_setacl_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &zero_stateid);
 	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
@@ -1691,30 +1624,18 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
-	hdr->nops++;
-	hdr->replen += decode_setacl_maxsz;
 }
 
 static void
 encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_SAVEFH);
-	hdr->nops++;
-	hdr->replen += decode_savefh_maxsz;
+	encode_op_hdr(xdr, OP_SAVEFH, decode_savefh_maxsz, hdr);
 }
 
 static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg, const struct nfs_server *server, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_SETATTR);
+	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &arg->stateid);
-	hdr->nops++;
-	hdr->replen += decode_setattr_maxsz;
 	encode_attrs(xdr, arg->iap, server);
 }
 
@@ -1753,9 +1674,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_WRITE);
-
+	encode_op_hdr(xdr, OP_WRITE, decode_write_maxsz, hdr);
 	encode_open_stateid(xdr, args->context, args->lock_context,
 		       hdr->minorversion);
 
@@ -1765,30 +1684,18 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	*p = cpu_to_be32(args->count);
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
-	hdr->nops++;
-	hdr->replen += decode_write_maxsz;
 }
 
 static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_DELEGRETURN);
+	encode_op_hdr(xdr, OP_DELEGRETURN, decode_delegreturn_maxsz, hdr);
 	encode_nfs4_stateid(xdr, stateid);
-	hdr->nops++;
-	hdr->replen += decode_delegreturn_maxsz;
 }
 
 static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_SECINFO);
+	encode_op_hdr(xdr, OP_SECINFO, decode_secinfo_maxsz, hdr);
 	encode_string(xdr, name->len, name->name);
-	hdr->nops++;
-	hdr->replen += decode_secinfo_maxsz;
 }
 
 #if defined(CONFIG_NFS_V4_1)
@@ -2132,12 +2039,8 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 				struct nfs41_free_stateid_args *args,
 				struct compound_hdr *hdr)
 {
-	__be32 *p;
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_FREE_STATEID);
+	encode_op_hdr(xdr, OP_FREE_STATEID, decode_free_stateid_maxsz, hdr);
 	encode_nfs4_stateid(xdr, args->stateid);
-	hdr->nops++;
-	hdr->replen += decode_free_stateid_maxsz;
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.7.7.6

