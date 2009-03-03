From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 27/46] NFS: update hdr->replen for every encode op
Date: Wed,  4 Mar 2009 01:58:33 +0200
Message-ID: <1236124713-3736-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17726
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754196AbZCCX6q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:58:46 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5d665a1..e6f2d84 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -753,6 +753,7 @@ static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hd
 	WRITE32(OP_ACCESS);
 	WRITE32(access);
 	hdr->nops++;
+	hdr->replen += decode_access_maxsz;
 }
 
 static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
@@ -764,6 +765,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 	WRITE32(arg->seqid->sequence->counter);
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
+	hdr->replen += decode_close_maxsz;
 }
 
 static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
@@ -775,6 +777,7 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 	WRITE64(args->offset);
 	WRITE32(args->count);
 	hdr->nops++;
+	hdr->replen += decode_commit_maxsz;
 }
 
 static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create, struct compound_hdr *hdr)
@@ -806,6 +809,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	WRITE32(create->name->len);
 	WRITEMEM(create->name->name, create->name->len);
 	hdr->nops++;
+	hdr->replen += decode_create_maxsz;
 
 	encode_attrs(xdr, create->attrs, create->server);
 }
@@ -819,6 +823,7 @@ static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct c
 	WRITE32(1);
 	WRITE32(bitmap);
 	hdr->nops++;
+	hdr->replen += decode_getattr_maxsz;
 }
 
 static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1, struct compound_hdr *hdr)
@@ -831,6 +836,7 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 	WRITE32(bm0);
 	WRITE32(bm1);
 	hdr->nops++;
+	hdr->replen += decode_getattr_maxsz;
 }
 
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
@@ -858,6 +864,7 @@ static void encode_getfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(4);
 	WRITE32(OP_GETFH);
 	hdr->nops++;
+	hdr->replen += decode_getfh_maxsz;
 }
 
 static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
@@ -869,6 +876,7 @@ static void encode_link(struct xdr_stream *xdr, const struct qstr *name, struct
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
 	hdr->nops++;
+	hdr->replen += decode_link_maxsz;
 }
 
 static inline int nfs4_lock_type(struct file_lock *fl, int block)
@@ -916,6 +924,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 		WRITE32(args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
+	hdr->replen += decode_lock_maxsz;
 }
 
 static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args, struct compound_hdr *hdr)
@@ -932,6 +941,7 @@ static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *ar
 	WRITEMEM("lock id:", 8);
 	WRITE64(args->lock_owner.id);
 	hdr->nops++;
+	hdr->replen += decode_lockt_maxsz;
 }
 
 static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args, struct compound_hdr *hdr)
@@ -946,6 +956,7 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	WRITE64(args->fl->fl_start);
 	WRITE64(nfs4_lock_length(args->fl));
 	hdr->nops++;
+	hdr->replen += decode_locku_maxsz;
 }
 
 static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
@@ -958,6 +969,7 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	WRITE32(len);
 	WRITEMEM(name->name, len);
 	hdr->nops++;
+	hdr->replen += decode_lookup_maxsz;
 }
 
 static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
@@ -1097,6 +1109,7 @@ static void encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg,
 		BUG();
 	}
 	hdr->nops++;
+	hdr->replen += decode_open_maxsz;
 }
 
 static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_confirmargs *arg, struct compound_hdr *hdr)
@@ -1108,6 +1121,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 	WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
 	WRITE32(arg->seqid->sequence->counter);
 	hdr->nops++;
+	hdr->replen += decode_open_confirm_maxsz;
 }
 
 static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
@@ -1120,6 +1134,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	WRITE32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
+	hdr->replen += decode_open_downgrade_maxsz;
 }
 
 static void
@@ -1133,6 +1148,7 @@ encode_putfh(struct xdr_stream *xdr, const struct nfs_fh *fh, struct compound_hd
 	WRITE32(len);
 	WRITEMEM(fh->data, len);
 	hdr->nops++;
+	hdr->replen += decode_putfh_maxsz;
 }
 
 static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
@@ -1142,6 +1158,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(4);
 	WRITE32(OP_PUTROOTFH);
 	hdr->nops++;
+	hdr->replen += decode_putrootfh_maxsz;
 }
 
 static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx)
@@ -1170,6 +1187,7 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	WRITE64(args->offset);
 	WRITE32(args->count);
 	hdr->nops++;
+	hdr->replen += decode_read_maxsz;
 }
 
 static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req, struct compound_hdr *hdr)
@@ -1195,6 +1213,7 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	WRITE32(attrs[0] & readdir->bitmask[0]);
 	WRITE32(attrs[1] & readdir->bitmask[1]);
 	hdr->nops++;
+	hdr->replen += decode_readdir_maxsz;
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
 			(unsigned long long)readdir->cookie,
@@ -1211,6 +1230,7 @@ static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *
 	RESERVE_SPACE(4);
 	WRITE32(OP_READLINK);
 	hdr->nops++;
+	hdr->replen += decode_readlink_maxsz;
 }
 
 static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
@@ -1222,6 +1242,7 @@ static void encode_remove(struct xdr_stream *xdr, const struct qstr *name, struc
 	WRITE32(name->len);
 	WRITEMEM(name->name, name->len);
 	hdr->nops++;
+	hdr->replen += decode_remove_maxsz;
 }
 
 static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, const struct qstr *newname, struct compound_hdr *hdr)
@@ -1237,6 +1258,7 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 	WRITE32(newname->len);
 	WRITEMEM(newname->name, newname->len);
 	hdr->nops++;
+	hdr->replen += decode_rename_maxsz;
 }
 
 static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid, struct compound_hdr *hdr)
@@ -1247,6 +1269,7 @@ static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client
 	WRITE32(OP_RENEW);
 	WRITE64(client_stateid->cl_clientid);
 	hdr->nops++;
+	hdr->replen += decode_renew_maxsz;
 }
 
 static void
@@ -1257,6 +1280,7 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(4);
 	WRITE32(OP_RESTOREFH);
 	hdr->nops++;
+	hdr->replen += decode_restorefh_maxsz;
 }
 
 static int
@@ -1276,6 +1300,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	WRITE32(arg->acl_len);
 	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
+	hdr->replen += decode_setacl_maxsz;
 	return 0;
 }
 
@@ -1287,6 +1312,7 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(4);
 	WRITE32(OP_SAVEFH);
 	hdr->nops++;
+	hdr->replen += decode_savefh_maxsz;
 }
 
 static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg, const struct nfs_server *server, struct compound_hdr *hdr)
@@ -1297,6 +1323,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 	WRITE32(OP_SETATTR);
 	WRITEMEM(arg->stateid.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
+	hdr->replen += decode_setattr_maxsz;
 	encode_attrs(xdr, arg->iap, server);
 }
 
@@ -1316,6 +1343,7 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 	RESERVE_SPACE(4);
 	WRITE32(setclientid->sc_cb_ident);
 	hdr->nops++;
+	hdr->replen += decode_setclientid_maxsz;
 }
 
 static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_client *client_state, struct compound_hdr *hdr)
@@ -1327,6 +1355,7 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs_
 	WRITE64(client_state->cl_clientid);
 	WRITEMEM(client_state->cl_confirm.data, NFS4_VERIFIER_SIZE);
 	hdr->nops++;
+	hdr->replen += decode_setclientid_confirm_maxsz;
 }
 
 static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
@@ -1345,6 +1374,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 	hdr->nops++;
+	hdr->replen += decode_write_maxsz;
 }
 
 static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid, struct compound_hdr *hdr)
@@ -1356,6 +1386,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	WRITE32(OP_DELEGRETURN);
 	WRITEMEM(stateid->data, NFS4_STATEID_SIZE);
 	hdr->nops++;
+	hdr->replen += decode_delegreturn_maxsz;
 }
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
-- 
1.6.1.3

