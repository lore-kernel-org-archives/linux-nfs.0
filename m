From: andros@netapp.com
Subject: [PATCH 1/1] NFS: Increment operation number in each encode_* routine
Date: Mon, 20 Oct 2008 14:19:50 -0400
Message-ID: <1224526790-4434-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6251 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbYJTSUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 14:20:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Pass in the compound_hdr and bump the number of operations in each encode_*
subroutine so as to allow us to more easily construct new compound statements.

Fix tabs

Signed-off-by: Andy Adamson<andros@netapp.com>
---
 fs/nfs/nfs4xdr.c |  610 ++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 391 insertions(+), 219 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..d364f23 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -578,9 +578,10 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
 	xdr_encode_opaque(p, str, len);
 }
 
-static int encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
+static __u32 *
+encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
-	__be32 *p;
+	__be32 *p, *nops;
 
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
@@ -588,8 +589,14 @@ static int encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	WRITE32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
 	WRITE32(NFS4_MINOR_VERSION);
+	nops = p;
 	WRITE32(hdr->nops);
-	return 0;
+	return nops;
+}
+
+static inline void encode_nops(__be32 *nops, struct compound_hdr *hdr)
+{
+	*nops = htonl(hdr->nops);
 }
 
 static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
@@ -728,18 +735,22 @@ static int encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const s
 	return status;
 }
 
-static int encode_access(struct xdr_stream *xdr, u32 access)
+static int
+encode_access(struct xdr_stream *xdr, u32 access, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(8);
 	WRITE32(OP_ACCESS);
 	WRITE32(access);
-	
+	hdr->nops++;
+
 	return 0;
 }
 
-static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
+static int
+encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg,
+	     struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -747,23 +758,29 @@ static int encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
 	WRITE32(OP_CLOSE);
 	WRITE32(arg->seqid->sequence->counter);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
+	hdr->nops++;
 	
 	return 0;
 }
 
-static int encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args)
+static int
+encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args,
+	      struct compound_hdr *hdr)
 {
 	__be32 *p;
         
-        RESERVE_SPACE(16);
-        WRITE32(OP_COMMIT);
-        WRITE64(args->offset);
-        WRITE32(args->count);
+	RESERVE_SPACE(16);
+	WRITE32(OP_COMMIT);
+	WRITE64(args->offset);
+	WRITE32(args->count);
+	hdr->nops++;
 
-        return 0;
+	return 0;
 }
 
-static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create)
+static int
+encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create,
+	      struct compound_hdr *hdr)
 {
 	__be32 *p;
 	
@@ -791,11 +808,14 @@ static int encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *c
 	RESERVE_SPACE(4 + create->name->len);
 	WRITE32(create->name->len);
 	WRITEMEM(create->name->name, create->name->len);
+	hdr->nops++;
 
 	return encode_attrs(xdr, create->attrs, create->server);
 }
 
-static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap)
+static int
+encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap,
+		   struct compound_hdr *hdr)
 {
         __be32 *p;
 
@@ -803,10 +823,13 @@ static int encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap)
         WRITE32(OP_GETATTR);
         WRITE32(1);
         WRITE32(bitmap);
+	hdr->nops++;
         return 0;
 }
 
-static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1)
+static int
+encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1,
+		   struct compound_hdr *hdr)
 {
         __be32 *p;
 
@@ -815,40 +838,51 @@ static int encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1
         WRITE32(2);
         WRITE32(bm0);
         WRITE32(bm1);
+	hdr->nops++;
         return 0;
 }
 
-static int encode_getfattr(struct xdr_stream *xdr, const u32* bitmask)
+static int
+encode_getfattr(struct xdr_stream *xdr, const u32 *bitmask,
+		struct compound_hdr *hdr)
 {
 	return encode_getattr_two(xdr,
 			bitmask[0] & nfs4_fattr_bitmap[0],
-			bitmask[1] & nfs4_fattr_bitmap[1]);
+			bitmask[1] & nfs4_fattr_bitmap[1], hdr);
 }
 
-static int encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask)
+static int
+encode_fsinfo(struct xdr_stream *xdr, const u32 *bitmask,
+	      struct compound_hdr *hdr)
 {
 	return encode_getattr_two(xdr, bitmask[0] & nfs4_fsinfo_bitmap[0],
-			bitmask[1] & nfs4_fsinfo_bitmap[1]);
+			bitmask[1] & nfs4_fsinfo_bitmap[1], hdr);
 }
 
-static int encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask)
+static int
+encode_fs_locations(struct xdr_stream *xdr, const u32 *bitmask,
+		    struct compound_hdr *hdr)
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
+static int
+encode_link(struct xdr_stream *xdr, const struct qstr *name,
+	    struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -856,6 +890,7 @@ static int encode_link(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_LINK);
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
+	hdr->nops++;
 	
 	return 0;
 }
@@ -878,7 +913,9 @@ static inline uint64_t nfs4_lock_length(struct file_lock *fl)
  * opcode,type,reclaim,offset,length,new_lock_owner = 32
  * open_seqid,open_stateid,lock_seqid,lock_owner.clientid, lock_owner.id = 40
  */
-static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args)
+static int
+encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args,
+	    struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -904,11 +941,14 @@ static int encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args)
 		WRITEMEM(args->lock_stateid->data, NFS4_STATEID_SIZE);
 		WRITE32(args->lock_seqid->sequence->counter);
 	}
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args)
+static int
+encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args,
+	     struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -921,11 +961,14 @@ static int encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *arg
 	WRITE32(16);
 	WRITEMEM("lock id:", 8);
 	WRITE64(args->lock_owner.id);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args)
+static int
+encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args,
+	     struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -936,11 +979,14 @@ static int encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *arg
 	WRITEMEM(args->stateid->data, NFS4_STATEID_SIZE);
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name)
+static int
+encode_lookup(struct xdr_stream *xdr, const struct qstr *name,
+	      struct compound_hdr *hdr)
 {
 	int len = name->len;
 	__be32 *p;
@@ -949,6 +995,7 @@ static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_LOOKUP);
 	WRITE32(len);
 	WRITEMEM(name->name, len);
+	hdr->nops++;
 
 	return 0;
 }
@@ -1072,7 +1119,9 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg)
+static int
+encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg,
+	    struct compound_hdr *hdr)
 {
 	encode_openhdr(xdr, arg);
 	encode_opentype(xdr, arg);
@@ -1089,10 +1138,14 @@ static int encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 		default:
 			BUG();
 	}
+	hdr->nops++;
 	return 0;
 }
 
-static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg)
+static int
+encode_open_confirm(struct xdr_stream *xdr,
+		    const struct nfs_open_confirmargs *arg,
+		    struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1100,11 +1153,14 @@ static int encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_con
 	WRITE32(OP_OPEN_CONFIRM);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	WRITE32(arg->seqid->sequence->counter);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg)
+static int
+encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg,
+		      struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1113,11 +1169,13 @@ static int encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closea
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	WRITE32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->open_flags);
+	hdr->nops++;
 	return 0;
 }
 
 static int
-encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh)
+encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh,
+	     struct compound_hdr *hdr)
 {
 	int len = fh->size;
 	__be32 *p;
@@ -1126,21 +1184,24 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh)
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
 
-static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx)
+static void
+encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx)
 {
 	nfs4_stateid stateid;
 	__be32 *p;
@@ -1153,7 +1214,9 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 		WRITEMEM(zero_stateid.data, NFS4_STATEID_SIZE);
 }
 
-static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args)
+static int
+encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
+	    struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1165,11 +1228,14 @@ static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args)
 	RESERVE_SPACE(12);
 	WRITE64(args->offset);
 	WRITE32(args->count);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req)
+static int
+encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir,
+	       struct rpc_rqst *req, struct compound_hdr *hdr)
 {
 	uint32_t attrs[2] = {
 		FATTR4_WORD0_RDATTR_ERROR|FATTR4_WORD0_FILEID,
@@ -1191,6 +1257,7 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 		attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 	WRITE32(attrs[0] & readdir->bitmask[0]);
 	WRITE32(attrs[1] & readdir->bitmask[1]);
+	hdr->nops++;
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
 			(unsigned long long)readdir->cookie,
@@ -1202,17 +1269,22 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	return 0;
 }
 
-static int encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req)
+static int
+encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink,
+		struct rpc_rqst *req, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_READLINK);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_remove(struct xdr_stream *xdr, const struct qstr *name)
+static int
+encode_remove(struct xdr_stream *xdr, const struct qstr *name,
+	      struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1220,11 +1292,14 @@ static int encode_remove(struct xdr_stream *xdr, const struct qstr *name)
 	WRITE32(OP_REMOVE);
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname)
+static int
+encode_rename(struct xdr_stream *xdr, const struct qstr *oldname,
+	      const struct qstr *newname, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1236,34 +1311,40 @@ static int encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, con
 	RESERVE_SPACE(4 + newname->len);
 	WRITE32(newname->len);
 	WRITEMEM(newname->name, newname->len);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid)
+static int
+encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid,
+	     struct compound_hdr *hdr)
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
+encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg,
+	      struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1278,21 +1359,25 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg)
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
+static int
+encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg,
+	       const struct nfs_server *server, struct compound_hdr *hdr)
 {
 	int status;
 	__be32 *p;
@@ -1300,6 +1385,7 @@ static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *
         RESERVE_SPACE(4+NFS4_STATEID_SIZE);
         WRITE32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
+	hdr->nops++;
 
         if ((status = encode_attrs(xdr, arg->iap, server)))
 		return status;
@@ -1307,7 +1393,10 @@ static int encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *
         return 0;
 }
 
-static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid)
+static int
+encode_setclientid(struct xdr_stream *xdr,
+		   const struct nfs4_setclientid *setclientid,
+		   struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1322,11 +1411,15 @@ static int encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclien
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
 	RESERVE_SPACE(4);
 	WRITE32(setclientid->sc_cb_ident);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state)
+static int
+encode_setclientid_confirm(struct xdr_stream *xdr,
+			   const struct nfs_client *client_state,
+			   struct compound_hdr *hdr)
 {
         __be32 *p;
 
@@ -1334,11 +1427,14 @@ static int encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_c
         WRITE32(OP_SETCLIENTID_CONFIRM);
         WRITE64(client_state->cl_clientid);
         WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
+	hdr->nops++;
 
         return 0;
 }
 
-static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args)
+static int
+encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args,
+	     struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1353,11 +1449,14 @@ static int encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args
 	WRITE32(args->count);
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
+	hdr->nops++;
 
 	return 0;
 }
 
-static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid)
+static int
+encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid,
+		   struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1365,6 +1464,7 @@ static int encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *statei
 
 	WRITE32(OP_DELEGRETURN);
 	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
+	hdr->nops++;
 	return 0;
 
 }
@@ -1379,20 +1479,22 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1403,20 +1505,22 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 4,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1427,17 +1531,19 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putrootfh(&xdr)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
+	if ((status = encode_putrootfh(&xdr, &hdr)) != 0)
 		goto out;
-	if ((status = encode_getfh(&xdr)) == 0)
-		status = encode_getfattr(&xdr, args->bitmask);
+	if ((status = encode_getfh(&xdr, &hdr)) == 0)
+		status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1448,18 +1554,20 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
+	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
 		goto out;
-	if ((status = encode_remove(&xdr, &args->name)) != 0)
+	if ((status = encode_remove(&xdr, &args->name, &hdr)) != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1470,26 +1578,29 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->old_dir)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1500,26 +1611,28 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1530,26 +1643,28 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1568,14 +1683,16 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->fh)) == 0)
-		status = encode_getfattr(&xdr, args->bitmask);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	if ((status = encode_putfh(&xdr, args->fh, &hdr)) == 0)
+		status = encode_getfattr(&xdr, args->bitmask, &hdr);
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1586,20 +1703,22 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 {
         struct xdr_stream xdr;
         struct compound_hdr hdr = {
-                .nops   = 3,
+		.nops   = 0,
         };
         int status;
+	__be32 *nops;
 
         xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-        encode_compound_hdr(&xdr, &hdr);
-        status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
         if(status)
                 goto out;
-        status = encode_close(&xdr, args);
+	status = encode_close(&xdr, args, &hdr);
 	if (status != 0)
 		goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(nops, &hdr);
         return status;
 }
 
@@ -1610,32 +1729,34 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 7,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1646,17 +1767,19 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_open_confirm(&xdr, args);
+	status = encode_open_confirm(&xdr, args, &hdr);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1667,20 +1790,22 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 3,
+		.nops   = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1691,20 +1816,22 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 3,
+		.nops	= 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1715,17 +1842,19 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_lock(&xdr, args);
+	status = encode_lock(&xdr, args, &hdr);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1736,17 +1865,19 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_lockt(&xdr, args);
+	status = encode_lockt(&xdr, args, &hdr);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1757,17 +1888,19 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_locku(&xdr, args);
+	status = encode_locku(&xdr, args, &hdr);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1778,18 +1911,19 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	unsigned int replen;
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_readlink(&xdr, args, req);
+	status = encode_readlink(&xdr, args, req, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
@@ -1800,6 +1934,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 			args->pgbase, args->pglen);
 
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1810,18 +1945,19 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
-	status = encode_readdir(&xdr, args, req);
+	status = encode_readdir(&xdr, args, req, &hdr);
 
 	/* set up reply kvec
 	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
@@ -1835,6 +1971,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 			args->pgbase, args->count);
 
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1846,16 +1983,17 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int replen, status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
-	status = encode_read(&xdr, args);
+	status = encode_read(&xdr, args, &hdr);
 	if (status)
 		goto out;
 
@@ -1868,6 +2006,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 			 args->pages, args->pgbase, args->count);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1879,20 +2018,22 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 {
         struct xdr_stream xdr;
         struct compound_hdr hdr = {
-                .nops   = 3,
+		.nops   = 0,
         };
         int status;
+	__be32 *nops;
 
         xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-        encode_compound_hdr(&xdr, &hdr);
-        status = encode_putfh(&xdr, args->fh);
+        nops = encode_compound_hdr(&xdr, &hdr);
+        status = encode_putfh(&xdr, args->fh, &hdr);
         if(status)
                 goto out;
-        status = encode_setattr(&xdr, args, args->server);
+        status = encode_setattr(&xdr, args, args->server, &hdr);
         if(status)
                 goto out;
-	status = encode_getfattr(&xdr, args->bitmask);
+	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
+	encode_nops(nops, &hdr);
         return status;
 }
 
@@ -1906,21 +2047,23 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 	struct xdr_stream xdr;
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct compound_hdr hdr = {
-		.nops   = 2,
+		.nops   = 0,
 	};
 	int replen, status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1931,21 +2074,23 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1956,20 +2101,22 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1980,15 +2127,17 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 2,
+		.nops	= 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (!status)
-		status = encode_fsinfo(&xdr, args->bitmask);
+		status = encode_fsinfo(&xdr, args->bitmask, &hdr);
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -1999,16 +2148,19 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (!status)
 		status = encode_getattr_one(&xdr,
-				args->bitmask[0] & nfs4_pathconf_bitmap[0]);
+				args->bitmask[0] & nfs4_pathconf_bitmap[0],
+				&hdr);
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -2019,17 +2171,19 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fh);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status == 0)
 		status = encode_getattr_two(&xdr,
 				args->bitmask[0] & nfs4_statfs_bitmap[0],
-				args->bitmask[1] & nfs4_statfs_bitmap[1]);
+				args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -2040,18 +2194,20 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 2,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, fhandle);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, fhandle, &hdr);
 	if (status == 0)
 		status = encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 				FATTR4_WORD0_LINK_SUPPORT|
 				FATTR4_WORD0_SYMLINK_SUPPORT|
-				FATTR4_WORD0_ACLSUPPORT);
+				FATTR4_WORD0_ACLSUPPORT, &hdr);
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -2062,12 +2218,16 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 1,
+		.nops	= 0,
 	};
+	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	return encode_renew(&xdr, clp);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_renew(&xdr, clp, &hdr);
+	encode_nops(nops, &hdr);
+	return status;
 }
 
 /*
@@ -2077,12 +2237,16 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 1,
+		.nops	= 0,
 	};
+	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	return encode_setclientid(&xdr, sc);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_setclientid(&xdr, sc, &hdr);
+	encode_nops(nops, &hdr);
+	return status;
 }
 
 /*
@@ -2092,18 +2256,20 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 3,
+		.nops	= 0,
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_setclientid_confirm(&xdr, clp);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_setclientid_confirm(&xdr, clp, &hdr);
 	if (!status)
-		status = encode_putrootfh(&xdr);
+		status = encode_putrootfh(&xdr, &hdr);
 	if (!status)
-		status = encode_fsinfo(&xdr, lease_bitmap);
+		status = encode_fsinfo(&xdr, lease_bitmap, &hdr);
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -2114,20 +2280,22 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, args->fhandle);
+	nops = encode_compound_hdr(&xdr, &hdr);
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
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -2138,19 +2306,20 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 3,
+		.nops = 0,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
 	int status;
+	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
-	if ((status = encode_putfh(&xdr, args->dir_fh)) != 0)
+	nops = encode_compound_hdr(&xdr, &hdr);
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
@@ -2160,6 +2329,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	xdr_inline_pages(&req->rq_rcv_buf, replen, &args->page,
 			0, PAGE_SIZE);
 out:
+	encode_nops(nops, &hdr);
 	return status;
 }
 
@@ -4034,20 +4204,22 @@ out:
 static int
 nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr = {
-                .nops   = 2,
-        };
-        int status;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.nops   = 0,
+	};
+	int status;
+	__be32 *nops;
 
-        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-        encode_compound_hdr(&xdr, &hdr);
-        status = encode_putfh(&xdr, args->fh);
-        if (status)
-                goto out;
-        status = encode_setacl(&xdr, args);
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	status = encode_putfh(&xdr, args->fh, &hdr);
+	if (status)
+		goto out;
+	status = encode_setacl(&xdr, args, &hdr);
 out:
-        return status;
+	encode_nops(nops, &hdr);
+	return status;
 }
 /*
  * Decode SETACL response
-- 
1.5.4.3

