From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 54/69] NFS: remove unused status from encode routines
Date: Tue, 23 Dec 2008 18:02:22 -0500
Message-ID: <20081223230221.13743.52098.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752782AbYLWXYn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:43 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcm1006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |  578 +++++++++++++++++-------------------------------------
 1 files changed, 180 insertions(+), 398 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8f6c061..d1e4c8f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -607,7 +607,7 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
 	xdr_encode_opaque_fixed(p, verf->data, NFS4_VERIFIER_SIZE);
 }
 
-static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
+static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
 {
 	char owner_name[IDMAP_NAMESZ];
 	char owner_group[IDMAP_NAMESZ];
@@ -618,7 +618,6 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	int len;
 	uint32_t bmval0 = 0;
 	uint32_t bmval1 = 0;
-	int status;
 
 	/*
 	 * We reserve enough space to write the entire attribute buffer at once.
@@ -729,12 +728,10 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	*q++ = htonl(bmval1);
 	*q++ = htonl(len);
 
-	status = 0;
 /* out: */
-	return status;
 }
 
-static int encode_access(struct xdr_stream *xdr, u32 access, struct compound_hdr *hdr)
+static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -742,11 +739,9 @@ static int encode_access(struct xdr_stream *xdr, u32 access, struct compound_hdr
 	WRITE32(OP_ACCESS);
 	WRITE32(access);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
+static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -755,11 +750,9 @@ static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg,
 	WRITE32(arg->seqid->sequence->counter);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
+static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -768,11 +761,9 @@ static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	WRITE64(args->offset);
 	WRITE32(args->count);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create, struct compound_hdr *hdr)
+static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -802,10 +793,10 @@ static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *c
 	WRITEMEM(create->name->name, create->name->len);
 	hdr->nops++;
 
-	return encode_attrs(xdr, create->attrs, create->server);
+	encode_attrs(xdr, create->attrs, create->server);
 }
 
-static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
+static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -814,10 +805,9 @@ static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct co
 	WRITE32(1);
 	WRITE32(bitmap);
 	hdr->nops++;
-	return 0;
 }
 
-static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1, struct compound_hdr *hdr)
+static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -827,42 +817,36 @@ static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1
 	WRITE32(bm0);
 	WRITE32(bm1);
 	hdr->nops++;
-	return 0;
 }
 
-static int encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
+static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	return encode_getattr_two(xdr,
-			bitmask[0] & nfs4_fattr_bitmap[0],
-			bitmask[1] & nfs4_fattr_bitmap[1], hdr);
+	encode_getattr_two(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
+			   bitmask[1] & nfs4_fattr_bitmap[1], hdr);
 }
 
-static int encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
+static void encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	return encode_getattr_two(xdr, bitmask[0] & nfs4_fsinfo_bitmap[0],
-			bitmask[1] & nfs4_fsinfo_bitmap[1], hdr);
+	encode_getattr_two(xdr, bitmask[0] & nfs4_fsinfo_bitmap[0],
+			   bitmask[1] & nfs4_fsinfo_bitmap[1], hdr);
 }
 
-static int encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
+static void encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	return encode_getattr_two(xdr,
-				  bitmask[0] & nfs4_fs_locations_bitmap[0],
-				  bitmask[1] & nfs4_fs_locations_bitmap[1],
-				  hdr);
+	encode_getattr_two(xdr, bitmask[0] & nfs4_fs_locations_bitmap[0],
+			   bitmask[1] & nfs4_fs_locations_bitmap[1], hdr);
 }
 
-static int encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
+static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_GETFH);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_link(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
+static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -871,8 +855,6 @@ static int encode_link(struct xdr_stream *xdr, const struct qstr *name, struct c
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
 	hdr->nops++;
-
-	return 0;
 }
 
 static inline int nfs4_lock_type(struct file_lock *fl, int block)
@@ -893,7 +875,7 @@ static inline uint64_t nfs4_lock_length(struct file_lock *fl)
  * opcode,type,reclaim,offset,length,new_lock_owner = 32
  * open_seqid,open_stateid,lock_seqid,lock_owner.clientid, lock_owner.id = 40
  */
-static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args, struct compound_hdr *hdr)
+static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -920,11 +902,9 @@ static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args,
 		WRITE32(args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args, struct compound_hdr *hdr)
+static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -938,11 +918,9 @@ static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *arg
 	WRITEMEM("lock id:", 8);
 	WRITE64(args->lock_owner.id);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args, struct compound_hdr *hdr)
+static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -954,11 +932,9 @@ static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *arg
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
+static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	int len = name->len;
 	__be32 *p;
@@ -968,8 +944,6 @@ static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct
 	WRITE32(len);
 	WRITEMEM(name->name, len);
 	hdr->nops++;
-
-	return 0;
 }
 
 static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
@@ -1091,7 +1065,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg, struct compound_hdr *hdr)
+static void encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg, struct compound_hdr *hdr)
 {
 	encode_openhdr(xdr, arg);
 	encode_opentype(xdr, arg);
@@ -1109,10 +1083,9 @@ static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg, s
 		BUG();
 	}
 	hdr->nops++;
-	return 0;
 }
 
-static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg, struct compound_hdr *hdr)
+static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1121,11 +1094,9 @@ static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_con
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	WRITE32(arg->seqid->sequence->counter);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
+static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1135,10 +1106,9 @@ static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closea
 	WRITE32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
-	return 0;
 }
 
-static int
+static void
 encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hdr *hdr)
 {
 	int len = fh->size;
@@ -1149,19 +1119,15 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	WRITE32(len);
 	WRITEMEM(fh->data, len);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
+static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_PUTROOTFH);
 	hdr->nops++;
-
-	return 0;
 }
 
 static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx)
@@ -1177,7 +1143,7 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 		WRITEMEM(zero_stateid.data, NFS4_STATEID_SIZE);
 }
 
-static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
+static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1190,11 +1156,9 @@ static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	WRITE64(args->offset);
 	WRITE32(args->count);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
+static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
 {
 	uint32_t attrs[2] = {
 		FATTR4_WORD0_RDATTR_ERROR|FATTR4_WORD0_FILEID,
@@ -1224,22 +1188,18 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 			((u32 *)readdir->verifier.data)[1],
 			attrs[0] & readdir->bitmask[0],
 			attrs[1] & readdir->bitmask[1]);
-
-	return 0;
 }
 
-static int encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req, struct compound_hdr *hdr)
+static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_READLINK);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_remove(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
+static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1248,11 +1208,9 @@ static int encode_remove(struct xdr_stream *xdr, const struct qstr *name, struct
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname, struct compound_hdr *hdr)
+static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1265,11 +1223,9 @@ static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, con
 	WRITE32(newname->len);
 	WRITEMEM(newname->name, newname->len);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid, struct compound_hdr *hdr)
+static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1277,11 +1233,9 @@ static int encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_
 	WRITE32(OP_RENEW);
 	WRITE64(client_stateid->cl_clientid);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int
+static void
 encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1289,8 +1243,6 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(4);
 	WRITE32(OP_RESTOREFH);
 	hdr->nops++;
-
-	return 0;
 }
 
 static int
@@ -1313,7 +1265,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	return 0;
 }
 
-static int
+static void
 encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1321,27 +1273,20 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(4);
 	WRITE32(OP_SAVEFH);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg, const struct nfs_server *server, struct compound_hdr *hdr)
+static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg, const struct nfs_server *server, struct compound_hdr *hdr)
 {
-	int status;
 	__be32 *p;
 
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 	WRITE32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
-
-	if ((status = encode_attrs(xdr, arg->iap, server)))
-		return status;
-
-	return 0;
+	encode_attrs(xdr, arg->iap, server);
 }
 
-static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
+static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1357,11 +1302,9 @@ static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclien
 	RESERVE_SPACE(4);
 	WRITE32(setclientid->sc_cb_ident);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state, struct compound_hdr *hdr)
+static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1370,11 +1313,9 @@ static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_c
 	WRITE64(client_state->cl_clientid);
 	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
+static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1390,11 +1331,9 @@ static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 	hdr->nops++;
-
-	return 0;
 }
 
-static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid, struct compound_hdr *hdr)
+static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1403,8 +1342,6 @@ static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *statei
 	WRITE32(OP_DELEGRETURN);
 	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
-	return 0;
-
 }
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
@@ -1419,20 +1356,14 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status != 0)
-		goto out;
-	status = encode_access(&xdr, args->access, &hdr);
-	if (status != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_access(&xdr, args->access, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1444,20 +1375,15 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
-		goto out;
-	if ((status = encode_lookup(&xdr, args->name, &hdr)) != 0)
-		goto out;
-	if ((status = encode_getfh(&xdr, &hdr)) != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->dir_fh, &hdr);
+	encode_lookup(&xdr, args->name, &hdr);
+	encode_getfh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1469,17 +1395,14 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putrootfh(&xdr, &hdr)) != 0)
-		goto out;
-	if ((status = encode_getfh(&xdr, &hdr)) == 0)
-		status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putrootfh(&xdr, &hdr);
+	encode_getfh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1491,18 +1414,14 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
-		goto out;
-	if ((status = encode_remove(&xdr, &args->name, &hdr)) != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_remove(&xdr, &args->name, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1514,27 +1433,18 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->old_dir, &hdr)) != 0)
-		goto out;
-	if ((status = encode_savefh(&xdr, &hdr)) != 0)
-		goto out;
-	if ((status = encode_putfh(&xdr, args->new_dir, &hdr)) != 0)
-		goto out;
-	if ((status = encode_rename(&xdr, args->old_name, args->new_name,
-				    &hdr)) != 0)
-		goto out;
-	if ((status = encode_getfattr(&xdr, args->bitmask, &hdr)) != 0)
-		goto out;
-	if ((status = encode_restorefh(&xdr, &hdr)) != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->old_dir, &hdr);
+	encode_savefh(&xdr, &hdr);
+	encode_putfh(&xdr, args->new_dir, &hdr);
+	encode_rename(&xdr, args->old_name, args->new_name, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_restorefh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1546,26 +1456,18 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
-		goto out;
-	if ((status = encode_savefh(&xdr, &hdr)) != 0)
-		goto out;
-	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
-		goto out;
-	if ((status = encode_link(&xdr, args->name, &hdr)) != 0)
-		goto out;
-	if ((status = encode_getfattr(&xdr, args->bitmask, &hdr)) != 0)
-		goto out;
-	if ((status = encode_restorefh(&xdr, &hdr)) != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_savefh(&xdr, &hdr);
+	encode_putfh(&xdr, args->dir_fh, &hdr);
+	encode_link(&xdr, args->name, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_restorefh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1577,26 +1479,18 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
-		goto out;
-	if ((status = encode_savefh(&xdr, &hdr)) != 0)
-		goto out;
-	if ((status = encode_create(&xdr, args, &hdr)) != 0)
-		goto out;
-	if ((status = encode_getfh(&xdr, &hdr)) != 0)
-		goto out;
-	if ((status = encode_getfattr(&xdr, args->bitmask, &hdr)) != 0)
-		goto out;
-	if ((status = encode_restorefh(&xdr, &hdr)) != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->dir_fh, &hdr);
+	encode_savefh(&xdr, &hdr);
+	encode_create(&xdr, args, &hdr);
+	encode_getfh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_restorefh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1616,14 +1510,13 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh, &hdr)) == 0)
-		status = encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1635,20 +1528,14 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_close(&xdr, args, &hdr);
-	if (status != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_close(&xdr, args, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1660,32 +1547,18 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_savefh(&xdr, &hdr);
-	if (status)
-		goto out;
-	status = encode_open(&xdr, args, &hdr);
-	if (status)
-		goto out;
-	status = encode_getfh(&xdr, &hdr);
-	if (status)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-	if (status)
-		goto out;
-	status = encode_restorefh(&xdr, &hdr);
-	if (status)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_savefh(&xdr, &hdr);
+	encode_open(&xdr, args, &hdr);
+	encode_getfh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_restorefh(&xdr, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1697,17 +1570,13 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_open_confirm(&xdr, args, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_open_confirm(&xdr, args, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1719,20 +1588,14 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_open(&xdr, args, &hdr);
-	if (status)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_open(&xdr, args, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1744,20 +1607,14 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_open_downgrade(&xdr, args, &hdr);
-	if (status != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_open_downgrade(&xdr, args, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1769,17 +1626,13 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_lock(&xdr, args, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_lock(&xdr, args, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1791,17 +1644,13 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_lockt(&xdr, args, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_lockt(&xdr, args, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1813,17 +1662,13 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_locku(&xdr, args, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_locku(&xdr, args, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1837,14 +1682,11 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	unsigned int replen;
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_readlink(&xdr, args, req, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_readlink(&xdr, args, req, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
@@ -1853,10 +1695,8 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_readlink_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
 			args->pgbase, args->pglen);
-
-out:
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1870,14 +1710,11 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_readdir(&xdr, args, req, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_readdir(&xdr, args, req, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
@@ -1889,10 +1726,8 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
 			__func__, replen, args->pages,
 			args->pgbase, args->count);
-
-out:
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1905,16 +1740,12 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int replen, status;
+	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_read(&xdr, args, &hdr);
-	if (status)
-		goto out;
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_read(&xdr, args, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel status + taglen=0 + rescount + OP_PUTFH + status
@@ -1924,9 +1755,8 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 			 args->pages, args->pgbase, args->count);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
-out:
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1938,20 +1768,14 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if(status)
-		goto out;
-	status = encode_setattr(&xdr, args, args->server, &hdr);
-	if(status)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_setattr(&xdr, args, args->server, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1966,21 +1790,19 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int replen, status;
+	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
+
 	/* set up reply buffer: */
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_getacl_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 		args->acl_pages, args->acl_pgbase, args->acl_len);
-out:
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -1992,21 +1814,15 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_write(&xdr, args, &hdr);
-	if (status)
-		goto out;
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_write(&xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2018,20 +1834,14 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
-	status = encode_commit(&xdr, args, &hdr);
-	if (status)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_commit(&xdr, args, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2043,15 +1853,13 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (!status)
-		status = encode_fsinfo(&xdr, args->bitmask, &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_fsinfo(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2063,17 +1871,14 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (!status)
-		status = encode_getattr_one(&xdr,
-				args->bitmask[0] & nfs4_pathconf_bitmap[0],
-				&hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
+			   &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2085,17 +1890,14 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status == 0)
-		status = encode_getattr_two(&xdr,
-				args->bitmask[0] & nfs4_statfs_bitmap[0],
-				args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
+	encode_putfh(&xdr, args->fh, &hdr);
+	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
+			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2107,18 +1909,16 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struc
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, fhandle, &hdr);
-	if (status == 0)
-		status = encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
-				FATTR4_WORD0_LINK_SUPPORT|
-				FATTR4_WORD0_SYMLINK_SUPPORT|
-				FATTR4_WORD0_ACLSUPPORT, &hdr);
+	encode_putfh(&xdr, fhandle, &hdr);
+	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
+			   FATTR4_WORD0_LINK_SUPPORT|
+			   FATTR4_WORD0_SYMLINK_SUPPORT|
+			   FATTR4_WORD0_ACLSUPPORT, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2130,13 +1930,12 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_renew(&xdr, clp, &hdr);
+	encode_renew(&xdr, clp, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2148,13 +1947,12 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_setclientid(&xdr, sc, &hdr);
+	encode_setclientid(&xdr, sc, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2167,17 +1965,14 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 		.nops	= 0,
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_setclientid_confirm(&xdr, clp, &hdr);
-	if (!status)
-		status = encode_putrootfh(&xdr, &hdr);
-	if (!status)
-		status = encode_fsinfo(&xdr, lease_bitmap, &hdr);
+	encode_setclientid_confirm(&xdr, clp, &hdr);
+	encode_putrootfh(&xdr, &hdr);
+	encode_fsinfo(&xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2189,20 +1984,14 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fhandle, &hdr);
-	if (status != 0)
-		goto out;
-	status = encode_delegreturn(&xdr, args->stateid, &hdr);
-	if (status != 0)
-		goto out;
-	status = encode_getfattr(&xdr, args->bitmask, &hdr);
-out:
+	encode_putfh(&xdr, args->fhandle, &hdr);
+	encode_delegreturn(&xdr, args->stateid, &hdr);
+	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -2216,16 +2005,13 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
-		goto out;
-	if ((status = encode_lookup(&xdr, args->name, &hdr)) != 0)
-		goto out;
-	if ((status = encode_fs_locations(&xdr, args->bitmask, &hdr)) != 0)
-		goto out;
+	encode_putfh(&xdr, args->dir_fh, &hdr);
+	encode_lookup(&xdr, args->name, &hdr);
+	encode_fs_locations(&xdr, args->bitmask, &hdr);
+
 	/* set up reply
 	 *   toplevel_status + OP_PUTFH + status
 	 *   + OP_LOOKUP + status + OP_GETATTR + status = 7
@@ -2233,9 +2019,8 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + 7) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen, &args->page,
 			0, PAGE_SIZE);
-out:
 	encode_nops(&hdr);
-	return status;
+	return 0;
 }
 
 /*
@@ -4115,11 +3900,8 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh, &hdr);
-	if (status)
-		goto out;
+	encode_putfh(&xdr, args->fh, &hdr);
 	status = encode_setacl(&xdr, args, &hdr);
-out:
 	encode_nops(&hdr);
 	return status;
 }

