Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38554 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754226AbaEKUw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 16/43] nfsd4: teach encoders to handle reserve_space failures
Date: Sun, 11 May 2014 16:52:21 -0400
Message-Id: <1399841568-19716-17-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We've tried to prevent running out of space with COMPOUND_SLACK_SPACE
and special checking in those operations (getattr) whose result can vary
enormously.

However:
	- COMPOUND_SLACK_SPACE may be difficult to maintain as we add
	  more protocol.
	- BUG_ON or page faulting on failure seems overly fragile.
	- Especially in the 4.1 case, we prefer not to fail compounds
	  just because the returned result came *close* to session
	  limits.  (Though perfect enforcement here may be difficult.)
	- I'd prefer encoding to be uniform for all encoders instead of
	  having special exceptions for encoders containing, for
	  example, attributes.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/nfs4xdr.c  |  246 ++++++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/xdr4.h     |    2 +-
 3 files changed, 184 insertions(+), 66 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ad0bc5f..d9fe000 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1349,7 +1349,7 @@ encode_op:
 		}
 		if (op->status == nfserr_replay_me) {
 			op->replay = &cstate->replay_owner->so_replay;
-			nfsd4_encode_replay(resp, op);
+			nfsd4_encode_replay(&resp->xdr, op);
 			status = op->status = op->replay->rp_status;
 		} else {
 			nfsd4_encode_operation(resp, op);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index cc219b8..d0e59b9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1746,11 +1746,6 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 	}
 }
 
-#define RESERVE_SPACE(nbytes)	do {				\
-	p = xdr_reserve_space(&resp->xdr, nbytes);		\
-	BUG_ON(!p);						\
-} while (0)
-
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
  */
@@ -2722,23 +2717,29 @@ fail:
 	return -EINVAL;
 }
 
-static void
-nfsd4_encode_stateid(struct nfsd4_compoundres *resp, stateid_t *sid)
+static __be32
+nfsd4_encode_stateid(struct xdr_stream *xdr, stateid_t *sid)
 {
 	__be32 *p;
 
-	RESERVE_SPACE(sizeof(stateid_t));
+	p = xdr_reserve_space(xdr, sizeof(stateid_t));
+	if (!p)
+		return nfserr_resource;
 	WRITE32(sid->si_generation);
 	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
+	return 0;
 }
 
 static __be32
 nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_access *access)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(8);
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(access->ac_supported);
 		WRITE32(access->ac_resp_access);
 	}
@@ -2747,10 +2748,13 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 
 static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_bind_conn_to_session *bcts)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 8);
+		p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 8);
+		if (!p)
+			return nfserr_resource;
 		WRITEMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 		WRITE32(bcts->dir);
 		/* Sorry, we do not yet support RDMA over 4.1: */
@@ -2762,8 +2766,10 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 static __be32
 nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_close *close)
 {
+	struct xdr_stream *xdr = &resp->xdr;
+
 	if (!nfserr)
-		nfsd4_encode_stateid(resp, &close->cl_stateid);
+		nfserr = nfsd4_encode_stateid(xdr, &close->cl_stateid);
 
 	return nfserr;
 }
@@ -2772,10 +2778,13 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 static __be32
 nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_commit *commit)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(NFS4_VERIFIER_SIZE);
+		p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
+		if (!p)
+			return nfserr_resource;
 		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
 	}
 	return nfserr;
@@ -2784,10 +2793,13 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 static __be32
 nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_create *create)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(32);
+		p = xdr_reserve_space(xdr, 32);
+		if (!p)
+			return nfserr_resource;
 		write_cinfo(&p, &create->cr_cinfo);
 		WRITE32(2);
 		WRITE32(create->cr_bmval[0]);
@@ -2814,13 +2826,16 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 static __be32
 nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh **fhpp)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	struct svc_fh *fhp = *fhpp;
 	unsigned int len;
 	__be32 *p;
 
 	if (!nfserr) {
 		len = fhp->fh_handle.fh_size;
-		RESERVE_SPACE(len + 4);
+		p = xdr_reserve_space(xdr, len + 4);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(len);
 		WRITEMEM(&fhp->fh_handle.fh_base, len);
 	}
@@ -2831,13 +2846,15 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 * Including all fields other than the name, a LOCK4denied structure requires
 *   8(clientid) + 4(namelen) + 8(offset) + 8(length) + 4(type) = 32 bytes.
 */
-static void
-nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denied *ld)
+static __be32
+nfsd4_encode_lock_denied(struct xdr_stream *xdr, struct nfsd4_lock_denied *ld)
 {
 	struct xdr_netobj *conf = &ld->ld_owner;
 	__be32 *p;
 
-	RESERVE_SPACE(32 + XDR_LEN(conf->len));
+	p = xdr_reserve_space(xdr, 32 + XDR_LEN(conf->len));
+	if (!p)
+		return nfserr_resource;
 	WRITE64(ld->ld_start);
 	WRITE64(ld->ld_length);
 	WRITE32(ld->ld_type);
@@ -2850,15 +2867,18 @@ nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denie
 		WRITE64((u64)0); /* clientid */
 		WRITE32(0); /* length of owner name */
 	}
+	return nfserr_denied;
 }
 
 static __be32
 nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lock *lock)
 {
+	struct xdr_stream *xdr = &resp->xdr;
+
 	if (!nfserr)
-		nfsd4_encode_stateid(resp, &lock->lk_resp_stateid);
+		nfserr = nfsd4_encode_stateid(xdr, &lock->lk_resp_stateid);
 	else if (nfserr == nfserr_denied)
-		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
+		nfserr = nfsd4_encode_lock_denied(xdr, &lock->lk_denied);
 
 	return nfserr;
 }
@@ -2866,16 +2886,20 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 static __be32
 nfsd4_encode_lockt(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lockt *lockt)
 {
+	struct xdr_stream *xdr = &resp->xdr;
+
 	if (nfserr == nfserr_denied)
-		nfsd4_encode_lock_denied(resp, &lockt->lt_denied);
+		nfsd4_encode_lock_denied(xdr, &lockt->lt_denied);
 	return nfserr;
 }
 
 static __be32
 nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_locku *locku)
 {
+	struct xdr_stream *xdr = &resp->xdr;
+
 	if (!nfserr)
-		nfsd4_encode_stateid(resp, &locku->lu_stateid);
+		nfserr = nfsd4_encode_stateid(xdr, &locku->lu_stateid);
 
 	return nfserr;
 }
@@ -2884,10 +2908,13 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 static __be32
 nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_link *link)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(20);
+		p = xdr_reserve_space(xdr, 20);
+		if (!p)
+			return nfserr_resource;
 		write_cinfo(&p, &link->li_cinfo);
 	}
 	return nfserr;
@@ -2897,13 +2924,18 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 static __be32
 nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open *open)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (nfserr)
 		goto out;
 
-	nfsd4_encode_stateid(resp, &open->op_stateid);
-	RESERVE_SPACE(40);
+	nfserr = nfsd4_encode_stateid(xdr, &open->op_stateid);
+	if (nfserr)
+		goto out;
+	p = xdr_reserve_space(xdr, 40);
+	if (!p)
+		return nfserr_resource;
 	write_cinfo(&p, &open->op_cinfo);
 	WRITE32(open->op_rflags);
 	WRITE32(2);
@@ -2915,8 +2947,12 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	case NFS4_OPEN_DELEGATE_NONE:
 		break;
 	case NFS4_OPEN_DELEGATE_READ:
-		nfsd4_encode_stateid(resp, &open->op_delegate_stateid);
-		RESERVE_SPACE(20);
+		nfserr = nfsd4_encode_stateid(xdr, &open->op_delegate_stateid);
+		if (nfserr)
+			return nfserr;
+		p = xdr_reserve_space(xdr, 20);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(open->op_recall);
 
 		/*
@@ -2928,8 +2964,12 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		WRITE32(0);   /* XXX: is NULL principal ok? */
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
-		nfsd4_encode_stateid(resp, &open->op_delegate_stateid);
-		RESERVE_SPACE(32);
+		nfserr = nfsd4_encode_stateid(xdr, &open->op_delegate_stateid);
+		if (nfserr)
+			return nfserr;
+		p = xdr_reserve_space(xdr, 32);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(0);
 
 		/*
@@ -2951,12 +2991,16 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		switch (open->op_why_no_deleg) {
 		case WND4_CONTENTION:
 		case WND4_RESOURCE:
-			RESERVE_SPACE(8);
+			p = xdr_reserve_space(xdr, 8);
+			if (!p)
+				return nfserr_resource;
 			WRITE32(open->op_why_no_deleg);
 			WRITE32(0);	/* deleg signaling not supported yet */
 			break;
 		default:
-			RESERVE_SPACE(4);
+			p = xdr_reserve_space(xdr, 4);
+			if (!p)
+				return nfserr_resource;
 			WRITE32(open->op_why_no_deleg);
 		}
 		break;
@@ -2971,8 +3015,10 @@ out:
 static __be32
 nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open_confirm *oc)
 {
+	struct xdr_stream *xdr = &resp->xdr;
+
 	if (!nfserr)
-		nfsd4_encode_stateid(resp, &oc->oc_resp_stateid);
+		nfserr = nfsd4_encode_stateid(xdr, &oc->oc_resp_stateid);
 
 	return nfserr;
 }
@@ -2980,8 +3026,10 @@ nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct
 static __be32
 nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open_downgrade *od)
 {
+	struct xdr_stream *xdr = &resp->xdr;
+
 	if (!nfserr)
-		nfsd4_encode_stateid(resp, &od->od_stateid);
+		nfserr = nfsd4_encode_stateid(xdr, &od->od_stateid);
 
 	return nfserr;
 }
@@ -3004,7 +3052,9 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (resp->xdr.buf->page_len)
 		return nfserr_resource;
 
-	RESERVE_SPACE(8); /* eof flag and byte count */
+	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
+	if (!p)
+		return nfserr_resource;
 
 	maxcount = svc_max_payload(resp->rqstp);
 	if (maxcount > read->rd_length)
@@ -3056,7 +3106,9 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	resp->xdr.buf->tail[0].iov_base = p;
 	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
-		RESERVE_SPACE(4);
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
@@ -3084,7 +3136,10 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	page = page_address(*(resp->rqstp->rq_next_page++));
 
 	maxcount = PAGE_SIZE;
-	RESERVE_SPACE(4);
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return nfserr_resource;
 
 	/*
 	 * XXX: By default, the ->readlink() VFS op will truncate symlinks
@@ -3111,7 +3166,9 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	resp->xdr.buf->tail[0].iov_base = p;
 	resp->xdr.buf->tail[0].iov_len = 0;
 	if (maxcount&3) {
-		RESERVE_SPACE(4);
+		p = xdr_reserve_space(xdr, 4);
+		if  (!p)
+			return nfserr_resource;
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
@@ -3136,7 +3193,9 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	if (!*resp->rqstp->rq_next_page)
 		return nfserr_resource;
 
-	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
+	p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
+	if (!p)
+		return nfserr_resource;
 
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
 	WRITE32(0);
@@ -3204,10 +3263,13 @@ err_no_verf:
 static __be32
 nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_remove *remove)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(20);
+		p = xdr_reserve_space(xdr, 20);
+		if (!p)
+			return nfserr_resource;
 		write_cinfo(&p, &remove->rm_cinfo);
 	}
 	return nfserr;
@@ -3216,10 +3278,13 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 static __be32
 nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_rename *rename)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(40);
+		p = xdr_reserve_space(xdr, 40);
+		if (!p)
+			return nfserr_resource;
 		write_cinfo(&p, &rename->rn_sinfo);
 		write_cinfo(&p, &rename->rn_tinfo);
 	}
@@ -3227,7 +3292,7 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 }
 
 static __be32
-nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
+nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 			 __be32 nfserr, struct svc_export *exp)
 {
 	u32 i, nflavs, supported;
@@ -3238,6 +3303,7 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 
 	if (nfserr)
 		goto out;
+	nfserr = nfserr_resource;
 	if (exp->ex_nflavors) {
 		flavs = exp->ex_flavors;
 		nflavs = exp->ex_nflavors;
@@ -3259,7 +3325,9 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 	}
 
 	supported = 0;
-	RESERVE_SPACE(4);
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		goto out;
 	flavorsp = p++;		/* to be backfilled later */
 
 	for (i = 0; i < nflavs; i++) {
@@ -3268,7 +3336,9 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 
 		if (rpcauth_get_gssinfo(pf, &info) == 0) {
 			supported++;
-			RESERVE_SPACE(4 + 4 + XDR_LEN(info.oid.len) + 4 + 4);
+			p = xdr_reserve_space(xdr, 4 + 4 + XDR_LEN(info.oid.len) + 4 + 4);
+			if (!p)
+				goto out;
 			WRITE32(RPC_AUTH_GSS);
 			WRITE32(info.oid.len);
 			WRITEMEM(info.oid.data, info.oid.len);
@@ -3276,7 +3346,9 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 			WRITE32(info.service);
 		} else if (pf < RPC_AUTH_MAXFLAVOR) {
 			supported++;
-			RESERVE_SPACE(4);
+			p = xdr_reserve_space(xdr, 4);
+			if (!p)
+				goto out;
 			WRITE32(pf);
 		} else {
 			if (report)
@@ -3288,7 +3360,7 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 	if (nflavs != supported)
 		report = false;
 	*flavorsp = htonl(supported);
-
+	nfserr = 0;
 out:
 	if (exp)
 		exp_put(exp);
@@ -3299,14 +3371,18 @@ static __be32
 nfsd4_encode_secinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 		     struct nfsd4_secinfo *secinfo)
 {
-	return nfsd4_do_encode_secinfo(resp, nfserr, secinfo->si_exp);
+	struct xdr_stream *xdr = &resp->xdr;
+
+	return nfsd4_do_encode_secinfo(xdr, nfserr, secinfo->si_exp);
 }
 
 static __be32
 nfsd4_encode_secinfo_no_name(struct nfsd4_compoundres *resp, __be32 nfserr,
 		     struct nfsd4_secinfo_no_name *secinfo)
 {
-	return nfsd4_do_encode_secinfo(resp, nfserr, secinfo->sin_exp);
+	struct xdr_stream *xdr = &resp->xdr;
+
+	return nfsd4_do_encode_secinfo(xdr, nfserr, secinfo->sin_exp);
 }
 
 /*
@@ -3316,9 +3392,12 @@ nfsd4_encode_secinfo_no_name(struct nfsd4_compoundres *resp, __be32 nfserr,
 static __be32
 nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_setattr *setattr)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	RESERVE_SPACE(16);
+	p = xdr_reserve_space(xdr, 16);
+	if (!p)
+		return nfserr_resource;
 	if (nfserr) {
 		WRITE32(3);
 		WRITE32(0);
@@ -3337,15 +3416,20 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 static __be32
 nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_setclientid *scd)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(8 + NFS4_VERIFIER_SIZE);
+		p = xdr_reserve_space(xdr, 8 + NFS4_VERIFIER_SIZE);
+		if (!p)
+			return nfserr_resource;
 		WRITEMEM(&scd->se_clientid, 8);
 		WRITEMEM(&scd->se_confirm, NFS4_VERIFIER_SIZE);
 	}
 	else if (nfserr == nfserr_clid_inuse) {
-		RESERVE_SPACE(8);
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(0);
 		WRITE32(0);
 	}
@@ -3355,10 +3439,13 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
 static __be32
 nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_write *write)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (!nfserr) {
-		RESERVE_SPACE(16);
+		p = xdr_reserve_space(xdr, 16);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(write->wr_bytes_written);
 		WRITE32(write->wr_how_written);
 		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
@@ -3378,6 +3465,7 @@ static __be32
 nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 			 struct nfsd4_exchange_id *exid)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 	char *major_id;
 	char *server_scope;
@@ -3393,11 +3481,13 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	server_scope = utsname()->nodename;
 	server_scope_sz = strlen(server_scope);
 
-	RESERVE_SPACE(
+	p = xdr_reserve_space(xdr,
 		8 /* eir_clientid */ +
 		4 /* eir_sequenceid */ +
 		4 /* eir_flags */ +
 		4 /* spr_how */);
+	if (!p)
+		return nfserr_resource;
 
 	WRITEMEM(&exid->clientid, 8);
 	WRITE32(exid->seqid);
@@ -3410,7 +3500,9 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		break;
 	case SP4_MACH_CRED:
 		/* spo_must_enforce, spo_must_allow */
-		RESERVE_SPACE(16);
+		p = xdr_reserve_space(xdr, 16);
+		if (!p)
+			return nfserr_resource;
 
 		/* spo_must_enforce bitmap: */
 		WRITE32(2);
@@ -3424,13 +3516,15 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		WARN_ON_ONCE(1);
 	}
 
-	RESERVE_SPACE(
+	p = xdr_reserve_space(xdr,
 		8 /* so_minor_id */ +
 		4 /* so_major_id.len */ +
 		(XDR_QUADLEN(major_id_sz) * 4) +
 		4 /* eir_server_scope.len */ +
 		(XDR_QUADLEN(server_scope_sz) * 4) +
 		4 /* eir_server_impl_id.count (0) */);
+	if (!p)
+		return nfserr_resource;
 
 	/* The server_owner struct */
 	WRITE64(minor_id);      /* Minor id */
@@ -3451,17 +3545,22 @@ static __be32
 nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 			    struct nfsd4_create_session *sess)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
 
-	RESERVE_SPACE(24);
+	p = xdr_reserve_space(xdr, 24);
+	if (!p)
+		return nfserr_resource;
 	WRITEMEM(sess->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(sess->seqid);
 	WRITE32(sess->flags);
 
-	RESERVE_SPACE(28);
+	p = xdr_reserve_space(xdr, 28);
+	if (!p)
+		return nfserr_resource;
 	WRITE32(0); /* headerpadsz */
 	WRITE32(sess->fore_channel.maxreq_sz);
 	WRITE32(sess->fore_channel.maxresp_sz);
@@ -3471,11 +3570,15 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(sess->fore_channel.nr_rdma_attrs);
 
 	if (sess->fore_channel.nr_rdma_attrs) {
-		RESERVE_SPACE(4);
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(sess->fore_channel.rdma_attrs);
 	}
 
-	RESERVE_SPACE(28);
+	p = xdr_reserve_space(xdr, 28);
+	if (!p)
+		return nfserr_resource;
 	WRITE32(0); /* headerpadsz */
 	WRITE32(sess->back_channel.maxreq_sz);
 	WRITE32(sess->back_channel.maxresp_sz);
@@ -3485,7 +3588,9 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(sess->back_channel.nr_rdma_attrs);
 
 	if (sess->back_channel.nr_rdma_attrs) {
-		RESERVE_SPACE(4);
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
+			return nfserr_resource;
 		WRITE32(sess->back_channel.rdma_attrs);
 	}
 	return 0;
@@ -3495,12 +3600,15 @@ static __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 		      struct nfsd4_sequence *seq)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
 
-	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 20);
+	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 20);
+	if (!p)
+		return nfserr_resource;
 	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(seq->seqid);
 	WRITE32(seq->slotid);
@@ -3517,13 +3625,16 @@ static __be32
 nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 			  struct nfsd4_test_stateid *test_stateid)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	struct nfsd4_test_stateid_id *stateid, *next;
 	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
 
-	RESERVE_SPACE(4 + (4 * test_stateid->ts_num_ids));
+	p = xdr_reserve_space(xdr, 4 + (4 * test_stateid->ts_num_ids));
+	if (!p)
+		return nfserr_resource;
 	*p++ = htonl(test_stateid->ts_num_ids);
 
 	list_for_each_entry_safe(stateid, next, &test_stateid->ts_stateid_list, ts_id_list) {
@@ -3662,7 +3773,11 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	nfsd4_enc encoder;
 	__be32 *p;
 
-	RESERVE_SPACE(8);
+	p = xdr_reserve_space(xdr, 8);
+	if (!p) {
+		WARN_ON_ONCE(1);
+		return;
+	}
 	WRITE32(op->opnum);
 	post_err_offset = xdr->buf->len;
 
@@ -3719,18 +3834,21 @@ status:
  * called with nfs4_lock_state() held
  */
 void
-nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
+nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
 {
 	__be32 *p;
 	struct nfs4_replay *rp = op->replay;
 
 	BUG_ON(!rp);
 
-	RESERVE_SPACE(8);
+	p = xdr_reserve_space(xdr, 8 + rp->rp_buflen);
+	if (!p) {
+		WARN_ON_ONCE(1);
+		return;
+	}
 	WRITE32(op->opnum);
 	*p++ = rp->rp_status;  /* already xdr'ed */
 
-	RESERVE_SPACE(rp->rp_buflen);
 	WRITEMEM(rp->rp_buf, rp->rp_buflen);
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index fa3a589..19bf3fc 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -614,7 +614,7 @@ int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundres *);
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
-void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
+void nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
 		struct svc_fh *fhp, struct svc_export *exp,
 		struct dentry *dentry,
-- 
1.7.9.5

