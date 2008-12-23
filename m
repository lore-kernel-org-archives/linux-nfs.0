From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 53/69] NFS: increment number of operations in each encode
 routine
Date: Tue, 23 Dec 2008 18:02:21 -0500
Message-ID: <20081223230221.13743.78601.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbYLWXYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:46 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0d006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |  417 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 247 insertions(+), 170 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 273d001..8f6c061 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -541,6 +541,7 @@ static struct {
 struct compound_hdr {
 	int32_t		status;
 	uint32_t	nops;
+	__be32 *	nops_p;
 	uint32_t	taglen;
 	char *		tag;
 };
@@ -578,7 +579,7 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
 	xdr_encode_opaque(p, str, len);
 }
 
-static int encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
+static void encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -588,8 +589,13 @@ static int encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	WRITE32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
 	WRITE32(NFS4_MINOR_VERSION);
+	hdr->nops_p = p;
 	WRITE32(hdr->nops);
-	return 0;
+}
+
+static void encode_nops(struct compound_hdr *hdr)
+{
+	*hdr->nops_p = htonl(hdr->nops);
 }
 
 static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
@@ -728,18 +734,19 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	return status;
 }
 
-static int encode_access(struct xdr_stream *xdr, u32 access)
+static int encode_access(struct xdr_stream *xdr, u32 access, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(8);
 	WRITE32(OP_ACCESS);
 	WRITE32(access);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
+static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -747,11 +754,12 @@ static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
 	WRITE32(OP_CLOSE);
 	WRITE32(arg->seqid->sequence->counter);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args)
+static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -759,11 +767,12 @@ static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	WRITE32(OP_COMMIT);
 	WRITE64(args->offset);
 	WRITE32(args->count);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create)
+static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -791,11 +800,12 @@ static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *c
 	RESERVE_SPACE(4 + create->name->len);
 	WRITE32(create->name->len);
 	WRITEMEM(create->name->name, create->name->len);
+	hdr->nops++;
 
 	return encode_attrs(xdr, create->attrs, create->server);
 }
 
-static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap)
+static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -803,10 +813,11 @@ static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap)
 	WRITE32(OP_GETATTR);
 	WRITE32(1);
 	WRITE32(bitmap);
+	hdr->nops++;
 	return 0;
 }
 
-static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1)
+static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -815,40 +826,43 @@ static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1
 	WRITE32(2);
 	WRITE32(bm0);
 	WRITE32(bm1);
+	hdr->nops++;
 	return 0;
 }
 
-static int encode_getfattr(struct xdr_stream *xdr, const u32* bitmask)
+static int encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	return encode_getattr_two(xdr,
 			bitmask[0] & nfs4_fattr_bitmap[0],
-			bitmask[1] & nfs4_fattr_bitmap[1]);
+			bitmask[1] & nfs4_fattr_bitmap[1], hdr);
 }
 
-static int encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask)
+static int encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	return encode_getattr_two(xdr, bitmask[0] & nfs4_fsinfo_bitmap[0],
-			bitmask[1] & nfs4_fsinfo_bitmap[1]);
+			bitmask[1] & nfs4_fsinfo_bitmap[1], hdr);
 }
 
-static int encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask)
+static int encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	return encode_getattr_two(xdr,
 				  bitmask[0] & nfs4_fs_locations_bitmap[0],
-				  bitmask[1] & nfs4_fs_locations_bitmap[1]);
+				  bitmask[1] & nfs4_fs_locations_bitmap[1],
+				  hdr);
 }
 
-static int encode_getfh(struct xdr_stream *xdr)
+static int encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_GETFH);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_link(struct xdr_stream *xdr, const struct qstr *name)
+static int encode_link(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -856,6 +870,7 @@ static int encode_link(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_LINK);
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
+	hdr->nops++;
 
 	return 0;
 }
@@ -878,7 +893,7 @@ static inline uint64_t nfs4_lock_length(struct file_lock *fl)
  * opcode,type,reclaim,offset,length,new_lock_owner = 32
  * open_seqid,open_stateid,lock_seqid,lock_owner.clientid, lock_owner.id = 40
  */
-static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args)
+static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -904,11 +919,12 @@ static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args)
 		WRITEMEM(args->lock_stateid->data, NFS4_STATEID_SIZE);
 		WRITE32(args->lock_seqid->sequence->counter);
 	}
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args)
+static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -921,11 +937,12 @@ static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *arg
 	WRITE32(16);
 	WRITEMEM("lock id:", 8);
 	WRITE64(args->lock_owner.id);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args)
+static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -936,11 +953,12 @@ static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *arg
 	WRITEMEM(args->stateid->data, NFS4_STATEID_SIZE);
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name)
+static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	int len = name->len;
 	__be32 *p;
@@ -949,6 +967,7 @@ static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_LOOKUP);
 	WRITE32(len);
 	WRITEMEM(name->name, len);
+	hdr->nops++;
 
 	return 0;
 }
@@ -1072,7 +1091,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg)
+static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg, struct compound_hdr *hdr)
 {
 	encode_openhdr(xdr, arg);
 	encode_opentype(xdr, arg);
@@ -1089,10 +1108,11 @@ static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 	default:
 		BUG();
 	}
+	hdr->nops++;
 	return 0;
 }
 
-static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg)
+static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1100,11 +1120,12 @@ static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_con
 	WRITE32(OP_OPEN_CONFIRM);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	WRITE32(arg->seqid->sequence->counter);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
+static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1113,11 +1134,12 @@ static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closea
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	WRITE32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
+	hdr->nops++;
 	return 0;
 }
 
 static int
-encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh)
+encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hdr *hdr)
 {
 	int len = fh->size;
 	__be32 *p;
@@ -1126,16 +1148,18 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh)
 	WRITE32(OP_PUTFH);
 	WRITE32(len);
 	WRITEMEM(fh->data, len);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_putrootfh(struct xdr_stream *xdr)
+static int encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_PUTROOTFH);
+	hdr->nops++;
 
 	return 0;
 }
@@ -1153,7 +1177,7 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 		WRITEMEM(zero_stateid.data, NFS4_STATEID_SIZE);
 }
 
-static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args)
+static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1165,11 +1189,12 @@ static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args)
 	RESERVE_SPACE(12);
 	WRITE64(args->offset);
 	WRITE32(args->count);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req)
+static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
 {
 	uint32_t attrs[2] = {
 		FATTR4_WORD0_RDATTR_ERROR|FATTR4_WORD0_FILEID,
@@ -1191,6 +1216,7 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 		attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 	WRITE32(attrs[0] & readdir->bitmask[0]);
 	WRITE32(attrs[1] & readdir->bitmask[1]);
+	hdr->nops++;
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
 			(unsigned long long)readdir->cookie,
@@ -1202,17 +1228,18 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	return 0;
 }
 
-static int encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req)
+static int encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_READLINK);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_remove(struct xdr_stream *xdr, const struct qstr *name)
+static int encode_remove(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1220,11 +1247,12 @@ static int encode_remove(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_REMOVE);
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname)
+static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1236,34 +1264,37 @@ static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, con
 	RESERVE_SPACE(4 + newname->len);
 	WRITE32(newname->len);
 	WRITEMEM(newname->name, newname->len);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid)
+static int encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(12);
 	WRITE32(OP_RENEW);
 	WRITE64(client_stateid->cl_clientid);
+	hdr->nops++;
 
 	return 0;
 }
 
 static int
-encode_restorefh(struct xdr_stream *xdr)
+encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_RESTOREFH);
+	hdr->nops++;
 
 	return 0;
 }
 
 static int
-encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg)
+encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1278,21 +1309,23 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg)
 	RESERVE_SPACE(4);
 	WRITE32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
+	hdr->nops++;
 	return 0;
 }
 
 static int
-encode_savefh(struct xdr_stream *xdr)
+encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_SAVEFH);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg, const struct nfs_server *server)
+static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg, const struct nfs_server *server, struct compound_hdr *hdr)
 {
 	int status;
 	__be32 *p;
@@ -1300,6 +1333,7 @@ static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *
 	RESERVE_SPACE(4+NFS4_STATEID_SIZE);
 	WRITE32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
+	hdr->nops++;
 
 	if ((status = encode_attrs(xdr, arg->iap, server)))
 		return status;
@@ -1307,7 +1341,7 @@ static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *
 	return 0;
 }
 
-static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid)
+static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1322,11 +1356,12 @@ static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclien
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
 	RESERVE_SPACE(4);
 	WRITE32(setclientid->sc_cb_ident);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state)
+static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1334,11 +1369,12 @@ static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_c
 	WRITE32(OP_SETCLIENTID_CONFIRM);
 	WRITE64(client_state->cl_clientid);
 	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args)
+static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1353,11 +1389,12 @@ static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args
 	WRITE32(args->count);
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid)
+static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1365,6 +1402,7 @@ static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *statei
 
 	WRITE32(OP_DELEGRETURN);
 	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
+	hdr->nops++;
 	return 0;
 
 }
@@ -1379,20 +1417,21 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_access(&xdr, args->access);
+	status = encode_access(&xdr, args->access, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1403,20 +1442,21 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 4,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_lookup(&xdr, args->name)) != 0)
+	if ((status = encode_lookup(&xdr, args->name, &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfh(&xdr)) != 0)
+	if ((status = encode_getfh(&xdr, &hdr)) != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1427,17 +1467,18 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putrootfh(&xdr)) != 0)
+	if ((status = encode_putrootfh(&xdr, &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfh(&xdr)) == 0)
-		status = encode_getfattr(&xdr, args->bitmask);
+	if ((status = encode_getfh(&xdr, &hdr)) == 0)
+		status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1448,18 +1489,19 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh)) != 0)
+	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_remove(&xdr, &args->name)) != 0)
+	if ((status = encode_remove(&xdr, &args->name, &hdr)) != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1470,26 +1512,28 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->old_dir)) != 0)
+	if ((status = encode_putfh(&xdr, args->old_dir, &hdr)) != 0)
 		goto out;
-	if ((status = encode_savefh(&xdr)) != 0)
+	if ((status = encode_savefh(&xdr, &hdr)) != 0)
 		goto out;
-	if ((status = encode_putfh(&xdr, args->new_dir)) != 0)
+	if ((status = encode_putfh(&xdr, args->new_dir, &hdr)) != 0)
 		goto out;
-	if ((status = encode_rename(&xdr, args->old_name, args->new_name)) != 0)
+	if ((status = encode_rename(&xdr, args->old_name, args->new_name,
+				    &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfattr(&xdr, args->bitmask)) != 0)
+	if ((status = encode_getfattr(&xdr, args->bitmask, &hdr)) != 0)
 		goto out;
-	if ((status = encode_restorefh(&xdr)) != 0)
+	if ((status = encode_restorefh(&xdr, &hdr)) != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1500,26 +1544,27 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh)) != 0)
+	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_savefh(&xdr)) != 0)
+	if ((status = encode_savefh(&xdr, &hdr)) != 0)
 		goto out;
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_link(&xdr, args->name)) != 0)
+	if ((status = encode_link(&xdr, args->name, &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfattr(&xdr, args->bitmask)) != 0)
+	if ((status = encode_getfattr(&xdr, args->bitmask, &hdr)) != 0)
 		goto out;
-	if ((status = encode_restorefh(&xdr)) != 0)
+	if ((status = encode_restorefh(&xdr, &hdr)) != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1530,26 +1575,27 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_savefh(&xdr)) != 0)
+	if ((status = encode_savefh(&xdr, &hdr)) != 0)
 		goto out;
-	if ((status = encode_create(&xdr, args)) != 0)
+	if ((status = encode_create(&xdr, args, &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfh(&xdr)) != 0)
+	if ((status = encode_getfh(&xdr, &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfattr(&xdr, args->bitmask)) != 0)
+	if ((status = encode_getfattr(&xdr, args->bitmask, &hdr)) != 0)
 		goto out;
-	if ((status = encode_restorefh(&xdr)) != 0)
+	if ((status = encode_restorefh(&xdr, &hdr)) != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1568,14 +1614,15 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh)) == 0)
-		status = encode_getfattr(&xdr, args->bitmask);
+	if ((status = encode_putfh(&xdr, args->fh, &hdr)) == 0)
+		status = encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1586,20 +1633,21 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 3,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_close(&xdr, args);
+	status = encode_close(&xdr, args, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1610,32 +1658,33 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_savefh(&xdr);
+	status = encode_savefh(&xdr, &hdr);
 	if (status)
 		goto out;
-	status = encode_open(&xdr, args);
+	status = encode_open(&xdr, args, &hdr);
 	if (status)
 		goto out;
-	status = encode_getfh(&xdr);
+	status = encode_getfh(&xdr, &hdr);
 	if (status)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 	if (status)
 		goto out;
-	status = encode_restorefh(&xdr);
+	status = encode_restorefh(&xdr, &hdr);
 	if (status)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1646,17 +1695,18 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_open_confirm(&xdr, args);
+	status = encode_open_confirm(&xdr, args, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1667,20 +1717,21 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 3,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_open(&xdr, args);
+	status = encode_open(&xdr, args, &hdr);
 	if (status)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1691,20 +1742,21 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 3,
+		.nops	= 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_open_downgrade(&xdr, args);
+	status = encode_open_downgrade(&xdr, args, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1715,17 +1767,18 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_lock(&xdr, args);
+	status = encode_lock(&xdr, args, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1736,17 +1789,18 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_lockt(&xdr, args);
+	status = encode_lockt(&xdr, args, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1757,17 +1811,18 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_locku(&xdr, args);
+	status = encode_locku(&xdr, args, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1778,7 +1833,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	unsigned int replen;
@@ -1786,10 +1841,10 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_readlink(&xdr, args, req);
+	status = encode_readlink(&xdr, args, req, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
@@ -1800,6 +1855,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 			args->pgbase, args->pglen);
 
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1810,7 +1866,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
@@ -1818,10 +1874,10 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_readdir(&xdr, args, req);
+	status = encode_readdir(&xdr, args, req, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
@@ -1835,6 +1891,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 			args->pgbase, args->count);
 
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1846,16 +1903,16 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int replen, status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_read(&xdr, args);
+	status = encode_read(&xdr, args, &hdr);
 	if (status)
 		goto out;
 
@@ -1868,6 +1925,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 			 args->pages, args->pgbase, args->count);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1878,20 +1936,21 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 3,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_setattr(&xdr, args, args->server);
+	status = encode_setattr(&xdr, args, args->server, &hdr);
 	if(status)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1905,21 +1964,22 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 	struct xdr_stream xdr;
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int replen, status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0);
+	status = encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 	/* set up reply buffer: */
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_getacl_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 		args->acl_pages, args->acl_pgbase, args->acl_len);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1930,21 +1990,22 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_write(&xdr, args);
+	status = encode_write(&xdr, args, &hdr);
 	if (status)
 		goto out;
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1955,20 +2016,21 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_commit(&xdr, args);
+	status = encode_commit(&xdr, args, &hdr);
 	if (status)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1979,15 +2041,16 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 2,
+		.nops	= 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (!status)
-		status = encode_fsinfo(&xdr, args->bitmask);
+		status = encode_fsinfo(&xdr, args->bitmask, &hdr);
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -1998,16 +2061,18 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (!status)
 		status = encode_getattr_one(&xdr,
-				args->bitmask[0] & nfs4_pathconf_bitmap[0]);
+				args->bitmask[0] & nfs4_pathconf_bitmap[0],
+				&hdr);
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -2018,17 +2083,18 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status == 0)
 		status = encode_getattr_two(&xdr,
 				args->bitmask[0] & nfs4_statfs_bitmap[0],
-				args->bitmask[1] & nfs4_statfs_bitmap[1]);
+				args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -2039,18 +2105,19 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, fhandle);
+	status = encode_putfh(&xdr, fhandle, &hdr);
 	if (status == 0)
 		status = encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 				FATTR4_WORD0_LINK_SUPPORT|
 				FATTR4_WORD0_SYMLINK_SUPPORT|
-				FATTR4_WORD0_ACLSUPPORT);
+				FATTR4_WORD0_ACLSUPPORT, &hdr);
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -2061,12 +2128,15 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 1,
+		.nops	= 0,
 	};
+	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	return encode_renew(&xdr, clp);
+	status = encode_renew(&xdr, clp, &hdr);
+	encode_nops(&hdr);
+	return status;
 }
 
 /*
@@ -2076,12 +2146,15 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 1,
+		.nops	= 0,
 	};
+	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	return encode_setclientid(&xdr, sc);
+	status = encode_setclientid(&xdr, sc, &hdr);
+	encode_nops(&hdr);
+	return status;
 }
 
 /*
@@ -2091,18 +2164,19 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 3,
+		.nops	= 0,
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_setclientid_confirm(&xdr, clp);
+	status = encode_setclientid_confirm(&xdr, clp, &hdr);
 	if (!status)
-		status = encode_putrootfh(&xdr);
+		status = encode_putrootfh(&xdr, &hdr);
 	if (!status)
-		status = encode_fsinfo(&xdr, lease_bitmap);
+		status = encode_fsinfo(&xdr, lease_bitmap, &hdr);
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -2113,20 +2187,21 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fhandle);
+	status = encode_putfh(&xdr, args->fhandle, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_delegreturn(&xdr, args->stateid);
+	status = encode_delegreturn(&xdr, args->stateid, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -2137,7 +2212,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
@@ -2145,11 +2220,11 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_lookup(&xdr, args->name)) != 0)
+	if ((status = encode_lookup(&xdr, args->name, &hdr)) != 0)
 		goto out;
-	if ((status = encode_fs_locations(&xdr, args->bitmask)) != 0)
+	if ((status = encode_fs_locations(&xdr, args->bitmask, &hdr)) != 0)
 		goto out;
 	/* set up reply
 	 *   toplevel_status + OP_PUTFH + status
@@ -2159,6 +2234,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	xdr_inline_pages(&req->rq_rcv_buf, replen, &args->page,
 			0, PAGE_SIZE);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 
@@ -4033,17 +4109,18 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_setacl(&xdr, args);
+	status = encode_setacl(&xdr, args, &hdr);
 out:
+	encode_nops(&hdr);
 	return status;
 }
 

