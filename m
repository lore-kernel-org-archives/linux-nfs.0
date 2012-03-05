Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756884Ab2CEQui (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 11:50:38 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 15/16] NFSv4: More xdr cleanups
Date: Mon,  5 Mar 2012 11:50:20 -0500
Message-Id: <1330966221-17164-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330966221-17164-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1330966221-17164-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-7-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-8-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-9-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-10-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-11-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-12-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-13-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |  164 ++++++++++++++++-------------------------------------
 1 files changed, 50 insertions(+), 114 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f958849..4ea9f50 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1084,13 +1084,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 
 static void encode_access(struct xdr_stream *xdr, u32 access, struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_ACCESS);
-	*p = cpu_to_be32(access);
-	hdr->nops++;
-	hdr->replen += decode_access_maxsz;
+	encode_op_hdr(xdr, OP_ACCESS, decode_access_maxsz, hdr);
+	encode_uint32(xdr, access);
 }
 
 static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg, struct compound_hdr *hdr)
@@ -1104,21 +1099,18 @@ static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *ar
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 16);
-	*p++ = cpu_to_be32(OP_COMMIT);
+	encode_op_hdr(xdr, OP_COMMIT, decode_commit_maxsz, hdr);
+	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
 	*p = cpu_to_be32(args->count);
-	hdr->nops++;
-	hdr->replen += decode_commit_maxsz;
 }
 
 static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *create, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_CREATE);
-	*p = cpu_to_be32(create->ftype);
+	encode_op_hdr(xdr, OP_CREATE, decode_create_maxsz, hdr);
+	encode_uint32(xdr, create->ftype);
 
 	switch (create->ftype) {
 	case NF4LNK:
@@ -1138,9 +1130,6 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	}
 
 	encode_string(xdr, create->name->len, create->name->name);
-	hdr->nops++;
-	hdr->replen += decode_create_maxsz;
-
 	encode_attrs(xdr, create->attrs, create->server);
 }
 
@@ -1148,25 +1137,21 @@ static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct c
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 12);
-	*p++ = cpu_to_be32(OP_GETATTR);
+	encode_op_hdr(xdr, OP_GETATTR, decode_getattr_maxsz, hdr);
+	p = reserve_space(xdr, 8);
 	*p++ = cpu_to_be32(1);
 	*p = cpu_to_be32(bitmap);
-	hdr->nops++;
-	hdr->replen += decode_getattr_maxsz;
 }
 
 static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm1, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 16);
-	*p++ = cpu_to_be32(OP_GETATTR);
+	encode_op_hdr(xdr, OP_GETATTR, decode_getattr_maxsz, hdr);
+	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(2);
 	*p++ = cpu_to_be32(bm0);
 	*p = cpu_to_be32(bm1);
-	hdr->nops++;
-	hdr->replen += decode_getattr_maxsz;
 }
 
 static void
@@ -1261,8 +1246,8 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 32);
-	*p++ = cpu_to_be32(OP_LOCK);
+	encode_op_hdr(xdr, OP_LOCK, decode_lock_maxsz, hdr);
+	p = reserve_space(xdr, 28);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, args->block));
 	*p++ = cpu_to_be32(args->reclaim);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
@@ -1278,38 +1263,31 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 		encode_nfs4_stateid(xdr, args->lock_stateid);
 		encode_nfs4_seqid(xdr, args->lock_seqid);
 	}
-	hdr->nops++;
-	hdr->replen += decode_lock_maxsz;
 }
 
 static void encode_lockt(struct xdr_stream *xdr, const struct nfs_lockt_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 24);
-	*p++ = cpu_to_be32(OP_LOCKT);
+	encode_op_hdr(xdr, OP_LOCKT, decode_lockt_maxsz, hdr);
+	p = reserve_space(xdr, 20);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	p = xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	encode_lockowner(xdr, &args->lock_owner);
-	hdr->nops++;
-	hdr->replen += decode_lockt_maxsz;
 }
 
 static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_LOCKU);
-	*p = cpu_to_be32(nfs4_lock_type(args->fl, 0));
+	encode_op_hdr(xdr, OP_LOCKU, decode_locku_maxsz, hdr);
+	encode_uint32(xdr, nfs4_lock_type(args->fl, 0));
 	encode_nfs4_seqid(xdr, args->seqid);
 	encode_nfs4_stateid(xdr, args->stateid);
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	xdr_encode_hyper(p, nfs4_lock_length(args->fl));
-	hdr->nops++;
-	hdr->replen += decode_locku_maxsz;
 }
 
 static void encode_release_lockowner(struct xdr_stream *xdr, const struct nfs_lowner *lowner, struct compound_hdr *hdr)
@@ -1553,8 +1531,8 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	if (!(readdir->bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID))
 		attrs[0] |= FATTR4_WORD0_FILEID;
 
-	p = reserve_space(xdr, 12);
-	*p++ = cpu_to_be32(OP_READDIR);
+	encode_op_hdr(xdr, OP_READDIR, decode_readdir_maxsz, hdr);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_hyper(p, readdir->cookie);
 	encode_nfs4_verifier(xdr, &readdir->verifier);
 	p = reserve_space(xdr, 20);
@@ -1564,8 +1542,6 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 
 	*p++ = cpu_to_be32(attrs[0] & readdir->bitmask[0]);
 	*p = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
-	hdr->nops++;
-	hdr->replen += decode_readdir_maxsz;
 	memcpy(verf, readdir->verifier.data, sizeof(verf));
 	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
@@ -1598,11 +1574,9 @@ static void encode_renew(struct xdr_stream *xdr, clientid4 clid,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 12);
-	*p++ = cpu_to_be32(OP_RENEW);
+	encode_op_hdr(xdr, OP_RENEW, decode_renew_maxsz, hdr);
+	p = reserve_space(xdr, 8);
 	xdr_encode_hyper(p, clid);
-	hdr->nops++;
-	hdr->replen += decode_renew_maxsz;
 }
 
 static void
@@ -1660,12 +1634,11 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 12);
-	*p++ = cpu_to_be32(OP_SETCLIENTID_CONFIRM);
+	encode_op_hdr(xdr, OP_SETCLIENTID_CONFIRM,
+			decode_setclientid_confirm_maxsz, hdr);
+	p = reserve_space(xdr, 8);
 	p = xdr_encode_hyper(p, arg->clientid);
 	encode_nfs4_verifier(xdr, &arg->confirm);
-	hdr->nops++;
-	hdr->replen += decode_setclientid_confirm_maxsz;
 }
 
 static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
@@ -1758,8 +1731,8 @@ static void encode_create_session(struct xdr_stream *xdr,
 	len = scnprintf(machine_name, sizeof(machine_name), "%s",
 			clp->cl_ipaddr);
 
-	p = reserve_space(xdr, 20 + 2*28 + 20 + len + 12);
-	*p++ = cpu_to_be32(OP_CREATE_SESSION);
+	encode_op_hdr(xdr, OP_CREATE_SESSION, decode_create_session_maxsz, hdr);
+	p = reserve_space(xdr, 16 + 2*28 + 20 + len + 12);
 	p = xdr_encode_hyper(p, clp->cl_clientid);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
 	*p++ = cpu_to_be32(args->flags);			/*flags */
@@ -1792,33 +1765,22 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
 	*p = cpu_to_be32(0);				/* No more gids */
-	hdr->nops++;
-	hdr->replen += decode_create_session_maxsz;
 }
 
 static void encode_destroy_session(struct xdr_stream *xdr,
 				   struct nfs4_session *session,
 				   struct compound_hdr *hdr)
 {
-	__be32 *p;
-	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN);
-	*p++ = cpu_to_be32(OP_DESTROY_SESSION);
-	xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
-	hdr->nops++;
-	hdr->replen += decode_destroy_session_maxsz;
+	encode_op_hdr(xdr, OP_DESTROY_SESSION, decode_destroy_session_maxsz, hdr);
+	encode_opaque_fixed(xdr, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 }
 
 static void encode_reclaim_complete(struct xdr_stream *xdr,
 				    struct nfs41_reclaim_complete_args *args,
 				    struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_RECLAIM_COMPLETE);
-	*p++ = cpu_to_be32(args->one_fs);
-	hdr->nops++;
-	hdr->replen += decode_reclaim_complete_maxsz;
+	encode_op_hdr(xdr, OP_RECLAIM_COMPLETE, decode_reclaim_complete_maxsz, hdr);
+	encode_uint32(xdr, args->one_fs);
 }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -1840,8 +1802,7 @@ static void encode_sequence(struct xdr_stream *xdr,
 	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
 	slot = tp->slots + args->sa_slotid;
 
-	p = reserve_space(xdr, 4 + NFS4_MAX_SESSIONID_LEN + 16);
-	*p++ = cpu_to_be32(OP_SEQUENCE);
+	encode_op_hdr(xdr, OP_SEQUENCE, decode_sequence_maxsz, hdr);
 
 	/*
 	 * Sessionid + seqid + slotid + max slotid + cache_this
@@ -1855,13 +1816,12 @@ static void encode_sequence(struct xdr_stream *xdr,
 		((u32 *)session->sess_id.data)[3],
 		slot->seq_nr, args->sa_slotid,
 		tp->highest_used_slotid, args->sa_cache_this);
+	p = reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 16);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(slot->seq_nr);
 	*p++ = cpu_to_be32(args->sa_slotid);
 	*p++ = cpu_to_be32(tp->highest_used_slotid);
 	*p = cpu_to_be32(args->sa_cache_this);
-	hdr->nops++;
-	hdr->replen += decode_sequence_maxsz;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -1876,14 +1836,12 @@ encode_getdevicelist(struct xdr_stream *xdr,
 		.data = "dummmmmy",
 	};
 
-	p = reserve_space(xdr, 20);
-	*p++ = cpu_to_be32(OP_GETDEVICELIST);
+	encode_op_hdr(xdr, OP_GETDEVICELIST, decode_getdevicelist_maxsz, hdr);
+	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(args->layoutclass);
 	*p++ = cpu_to_be32(NFS4_PNFS_GETDEVLIST_MAXNUM);
 	xdr_encode_hyper(p, 0ULL);                          /* cookie */
 	encode_nfs4_verifier(xdr, &dummy);
-	hdr->nops++;
-	hdr->replen += decode_getdevicelist_maxsz;
 }
 
 static void
@@ -1893,15 +1851,13 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 16 + NFS4_DEVICEID4_SIZE);
-	*p++ = cpu_to_be32(OP_GETDEVICEINFO);
+	encode_op_hdr(xdr, OP_GETDEVICEINFO, decode_getdeviceinfo_maxsz, hdr);
+	p = reserve_space(xdr, 12 + NFS4_DEVICEID4_SIZE);
 	p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
 				    NFS4_DEVICEID4_SIZE);
 	*p++ = cpu_to_be32(args->pdev->layout_type);
 	*p++ = cpu_to_be32(args->pdev->pglen);		/* gdia_maxcount */
 	*p++ = cpu_to_be32(0);				/* bitmap length 0 */
-	hdr->nops++;
-	hdr->replen += decode_getdeviceinfo_maxsz;
 }
 
 static void
@@ -1911,8 +1867,8 @@ encode_layoutget(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 40);
-	*p++ = cpu_to_be32(OP_LAYOUTGET);
+	encode_op_hdr(xdr, OP_LAYOUTGET, decode_layoutget_maxsz, hdr);
+	p = reserve_space(xdr, 36);
 	*p++ = cpu_to_be32(0);     /* Signal layout available */
 	*p++ = cpu_to_be32(args->type);
 	*p++ = cpu_to_be32(args->range.iomode);
@@ -1920,8 +1876,7 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->range.length);
 	p = xdr_encode_hyper(p, args->minlength);
 	encode_nfs4_stateid(xdr, &args->stateid);
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(args->maxcount);
+	encode_uint32(xdr, args->maxcount);
 
 	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
 		__func__,
@@ -1930,8 +1885,6 @@ encode_layoutget(struct xdr_stream *xdr,
 		(unsigned long)args->range.offset,
 		(unsigned long)args->range.length,
 		args->maxcount);
-	hdr->nops++;
-	hdr->replen += decode_layoutget_maxsz;
 }
 
 static int
@@ -1945,8 +1898,8 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	dprintk("%s: lbw: %llu type: %d\n", __func__, args->lastbytewritten,
 		NFS_SERVER(args->inode)->pnfs_curr_ld->id);
 
-	p = reserve_space(xdr, 24);
-	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
+	encode_op_hdr(xdr, OP_LAYOUTCOMMIT, decode_layoutcommit_maxsz, hdr);
+	p = reserve_space(xdr, 20);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
 	p = xdr_encode_hyper(p, args->lastbytewritten + 1);	/* length */
@@ -1961,13 +1914,9 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	if (NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit)
 		NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit(
 			NFS_I(inode)->layout, xdr, args);
-	else {
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(0); /* no layout-type payload */
-	}
+	else
+		encode_uint32(xdr, 0); /* no layout-type payload */
 
-	hdr->nops++;
-	hdr->replen += decode_layoutcommit_maxsz;
 	return 0;
 }
 
@@ -1978,8 +1927,8 @@ encode_layoutreturn(struct xdr_stream *xdr,
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 20);
-	*p++ = cpu_to_be32(OP_LAYOUTRETURN);
+	encode_op_hdr(xdr, OP_LAYOUTRETURN, decode_layoutreturn_maxsz, hdr);
+	p = reserve_space(xdr, 16);
 	*p++ = cpu_to_be32(0);		/* reclaim. always 0 for now */
 	*p++ = cpu_to_be32(args->layout_type);
 	*p++ = cpu_to_be32(IOMODE_ANY);
@@ -1993,12 +1942,8 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
 		NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
 			NFS_I(args->inode)->layout, xdr, args);
-	} else {
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(0);
-	}
-	hdr->nops++;
-	hdr->replen += decode_layoutreturn_maxsz;
+	} else
+		encode_uint32(xdr, 0);
 }
 
 static int
@@ -2006,12 +1951,8 @@ encode_secinfo_no_name(struct xdr_stream *xdr,
 		       const struct nfs41_secinfo_no_name_args *args,
 		       struct compound_hdr *hdr)
 {
-	__be32 *p;
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_SECINFO_NO_NAME);
-	*p++ = cpu_to_be32(args->style);
-	hdr->nops++;
-	hdr->replen += decode_secinfo_no_name_maxsz;
+	encode_op_hdr(xdr, OP_SECINFO_NO_NAME, decode_secinfo_no_name_maxsz, hdr);
+	encode_uint32(xdr, args->style);
 	return 0;
 }
 
@@ -2019,14 +1960,9 @@ static void encode_test_stateid(struct xdr_stream *xdr,
 				struct nfs41_test_stateid_args *args,
 				struct compound_hdr *hdr)
 {
-	__be32 *p;
-
-	p = reserve_space(xdr, 8);
-	*p++ = cpu_to_be32(OP_TEST_STATEID);
-	*p = cpu_to_be32(1);
+	encode_op_hdr(xdr, OP_TEST_STATEID, decode_test_stateid_maxsz, hdr);
+	encode_uint32(xdr, 1);
 	encode_nfs4_stateid(xdr, args->stateid);
-	hdr->nops++;
-	hdr->replen += decode_test_stateid_maxsz;
 }
 
 static void encode_free_stateid(struct xdr_stream *xdr,
-- 
1.7.7.6

