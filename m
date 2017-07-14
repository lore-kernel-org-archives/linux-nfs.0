Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37382 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbdGNUZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 16:25:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd4: individual encoders no longer see error cases
Date: Fri, 14 Jul 2017 16:24:55 -0400
Message-Id: <1500063895-29457-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1500063895-29457-1-git-send-email-bfields@redhat.com>
References: <1500063895-29457-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

With a few exceptions, most individual encoders don't handle error
cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 309 ++++++++++++++++++------------------------------------
 1 file changed, 103 insertions(+), 206 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 08badcf64554..18b9c2fad29a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3105,14 +3105,12 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 8);
-		if (!p)
-			return nfserr_resource;
-		*p++ = cpu_to_be32(access->ac_supported);
-		*p++ = cpu_to_be32(access->ac_resp_access);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, 8);
+	if (!p)
+		return nfserr_resource;
+	*p++ = cpu_to_be32(access->ac_supported);
+	*p++ = cpu_to_be32(access->ac_resp_access);
+	return 0;
 }
 
 static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_bind_conn_to_session *bcts)
@@ -3120,17 +3118,15 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 8);
-		if (!p)
-			return nfserr_resource;
-		p = xdr_encode_opaque_fixed(p, bcts->sessionid.data,
-						NFS4_MAX_SESSIONID_LEN);
-		*p++ = cpu_to_be32(bcts->dir);
-		/* Upshifting from TCP to RDMA is not supported */
-		*p++ = cpu_to_be32(0);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 8);
+	if (!p)
+		return nfserr_resource;
+	p = xdr_encode_opaque_fixed(p, bcts->sessionid.data,
+					NFS4_MAX_SESSIONID_LEN);
+	*p++ = cpu_to_be32(bcts->dir);
+	/* Upshifting from TCP to RDMA is not supported */
+	*p++ = cpu_to_be32(0);
+	return 0;
 }
 
 static __be32
@@ -3138,10 +3134,7 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 {
 	struct xdr_stream *xdr = &resp->xdr;
 
-	if (!nfserr)
-		nfserr = nfsd4_encode_stateid(xdr, &close->cl_stateid);
-
-	return nfserr;
+	return nfsd4_encode_stateid(xdr, &close->cl_stateid);
 }
 
 
@@ -3151,14 +3144,12 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
-		if (!p)
-			return nfserr_resource;
-		p = xdr_encode_opaque_fixed(p, commit->co_verf.data,
+	p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
+	if (!p)
+		return nfserr_resource;
+	p = xdr_encode_opaque_fixed(p, commit->co_verf.data,
 						NFS4_VERIFIER_SIZE);
-	}
-	return nfserr;
+	return 0;
 }
 
 static __be32
@@ -3167,15 +3158,13 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 20);
-		if (!p)
-			return nfserr_resource;
-		encode_cinfo(p, &create->cr_cinfo);
-		nfserr = nfsd4_encode_bitmap(xdr, create->cr_bmval[0],
-				create->cr_bmval[1], create->cr_bmval[2]);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, 20);
+	if (!p)
+		return nfserr_resource;
+	encode_cinfo(p, &create->cr_cinfo);
+	nfserr = nfsd4_encode_bitmap(xdr, create->cr_bmval[0],
+			create->cr_bmval[1], create->cr_bmval[2]);
+	return 0;
 }
 
 static __be32
@@ -3184,13 +3173,8 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	struct svc_fh *fhp = getattr->ga_fhp;
 	struct xdr_stream *xdr = &resp->xdr;
 
-	if (nfserr)
-		return nfserr;
-
-	nfserr = nfsd4_encode_fattr(xdr, fhp, fhp->fh_export, fhp->fh_dentry,
-				    getattr->ga_bmval,
-				    resp->rqstp, 0);
-	return nfserr;
+	return nfsd4_encode_fattr(xdr, fhp, fhp->fh_export, fhp->fh_dentry,
+				    getattr->ga_bmval, resp->rqstp, 0);
 }
 
 static __be32
@@ -3201,14 +3185,12 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 	unsigned int len;
 	__be32 *p;
 
-	if (!nfserr) {
-		len = fhp->fh_handle.fh_size;
-		p = xdr_reserve_space(xdr, len + 4);
-		if (!p)
-			return nfserr_resource;
-		p = xdr_encode_opaque(p, &fhp->fh_handle.fh_base, len);
-	}
-	return nfserr;
+	len = fhp->fh_handle.fh_size;
+	p = xdr_reserve_space(xdr, len + 4);
+	if (!p)
+		return nfserr_resource;
+	p = xdr_encode_opaque(p, &fhp->fh_handle.fh_base, len);
+	return 0;
 }
 
 /*
@@ -3278,10 +3260,7 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 {
 	struct xdr_stream *xdr = &resp->xdr;
 
-	if (!nfserr)
-		nfserr = nfsd4_encode_stateid(xdr, &locku->lu_stateid);
-
-	return nfserr;
+	return nfsd4_encode_stateid(xdr, &locku->lu_stateid);
 }
 
 
@@ -3291,13 +3270,11 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 20);
-		if (!p)
-			return nfserr_resource;
-		p = encode_cinfo(p, &link->li_cinfo);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, 20);
+	if (!p)
+		return nfserr_resource;
+	p = encode_cinfo(p, &link->li_cinfo);
+	return 0;
 }
 
 
@@ -3307,12 +3284,9 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (nfserr)
-		goto out;
-
 	nfserr = nfsd4_encode_stateid(xdr, &open->op_stateid);
 	if (nfserr)
-		goto out;
+		return nfserr;
 	p = xdr_reserve_space(xdr, 24);
 	if (!p)
 		return nfserr_resource;
@@ -3322,7 +3296,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	nfserr = nfsd4_encode_bitmap(xdr, open->op_bmval[0], open->op_bmval[1],
 					open->op_bmval[2]);
 	if (nfserr)
-		goto out;
+		return nfserr;
 
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
@@ -3395,8 +3369,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		BUG();
 	}
 	/* XXX save filehandle here */
-out:
-	return nfserr;
+	return 0;
 }
 
 static __be32
@@ -3404,10 +3377,7 @@ nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct
 {
 	struct xdr_stream *xdr = &resp->xdr;
 
-	if (!nfserr)
-		nfserr = nfsd4_encode_stateid(xdr, &oc->oc_resp_stateid);
-
-	return nfserr;
+	return nfsd4_encode_stateid(xdr, &oc->oc_resp_stateid);
 }
 
 static __be32
@@ -3415,10 +3385,7 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 {
 	struct xdr_stream *xdr = &resp->xdr;
 
-	if (!nfserr)
-		nfserr = nfsd4_encode_stateid(xdr, &od->od_stateid);
-
-	return nfserr;
+	return nfsd4_encode_stateid(xdr, &od->od_stateid);
 }
 
 static __be32 nfsd4_encode_splice_read(
@@ -3555,20 +3522,15 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct raparms *ra = NULL;
 	__be32 *p;
 
-	if (nfserr)
-		goto out;
-
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
 	if (!p) {
 		WARN_ON_ONCE(test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags));
-		nfserr = nfserr_resource;
-		goto out;
+		return nfserr_resource;
 	}
 	if (resp->xdr.buf->page_len &&
 	    test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags)) {
 		WARN_ON_ONCE(1);
-		nfserr = nfserr_resource;
-		goto out;
+		return nfserr_resource;
 	}
 	xdr_commit_encode(xdr);
 
@@ -3592,7 +3554,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (nfserr)
 		xdr_truncate_encode(xdr, starting_len);
 
-out:
 	return nfserr;
 }
 
@@ -3606,9 +3567,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	int length_offset = xdr->buf->len;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		return nfserr_resource;
@@ -3652,9 +3610,6 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	int starting_len = xdr->buf->len;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
 	if (!p)
 		return nfserr_resource;
@@ -3740,13 +3695,11 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 20);
-		if (!p)
-			return nfserr_resource;
-		p = encode_cinfo(p, &remove->rm_cinfo);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, 20);
+	if (!p)
+		return nfserr_resource;
+	p = encode_cinfo(p, &remove->rm_cinfo);
+	return 0;
 }
 
 static __be32
@@ -3755,19 +3708,16 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 40);
-		if (!p)
-			return nfserr_resource;
-		p = encode_cinfo(p, &rename->rn_sinfo);
-		p = encode_cinfo(p, &rename->rn_tinfo);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, 40);
+	if (!p)
+		return nfserr_resource;
+	p = encode_cinfo(p, &rename->rn_sinfo);
+	p = encode_cinfo(p, &rename->rn_tinfo);
+	return 0;
 }
 
 static __be32
-nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
-			 __be32 nfserr, struct svc_export *exp)
+nfsd4_do_encode_secinfo(struct xdr_stream *xdr, struct svc_export *exp)
 {
 	u32 i, nflavs, supported;
 	struct exp_flavor_info *flavs;
@@ -3775,9 +3725,6 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 	__be32 *p, *flavorsp;
 	static bool report = true;
 
-	if (nfserr)
-		goto out;
-	nfserr = nfserr_resource;
 	if (exp->ex_nflavors) {
 		flavs = exp->ex_flavors;
 		nflavs = exp->ex_nflavors;
@@ -3801,7 +3748,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 	supported = 0;
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
-		goto out;
+		return nfserr_resource;
 	flavorsp = p++;		/* to be backfilled later */
 
 	for (i = 0; i < nflavs; i++) {
@@ -3813,7 +3760,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 			p = xdr_reserve_space(xdr, 4 + 4 +
 					      XDR_LEN(info.oid.len) + 4 + 4);
 			if (!p)
-				goto out;
+				return nfserr_resource;
 			*p++ = cpu_to_be32(RPC_AUTH_GSS);
 			p = xdr_encode_opaque(p,  info.oid.data, info.oid.len);
 			*p++ = cpu_to_be32(info.qop);
@@ -3822,7 +3769,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 			supported++;
 			p = xdr_reserve_space(xdr, 4);
 			if (!p)
-				goto out;
+				return nfserr_resource;
 			*p++ = cpu_to_be32(pf);
 		} else {
 			if (report)
@@ -3834,9 +3781,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 	if (nflavs != supported)
 		report = false;
 	*flavorsp = htonl(supported);
-	nfserr = 0;
-out:
-	return nfserr;
+	return 0;
 }
 
 static __be32
@@ -3845,7 +3790,7 @@ nfsd4_encode_secinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 {
 	struct xdr_stream *xdr = &resp->xdr;
 
-	return nfsd4_do_encode_secinfo(xdr, nfserr, secinfo->si_exp);
+	return nfsd4_do_encode_secinfo(xdr, secinfo->si_exp);
 }
 
 static __be32
@@ -3854,7 +3799,7 @@ nfsd4_encode_secinfo_no_name(struct nfsd4_compoundres *resp, __be32 nfserr,
 {
 	struct xdr_stream *xdr = &resp->xdr;
 
-	return nfsd4_do_encode_secinfo(xdr, nfserr, secinfo->sin_exp);
+	return nfsd4_do_encode_secinfo(xdr, secinfo->sin_exp);
 }
 
 /*
@@ -3915,16 +3860,14 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (!nfserr) {
-		p = xdr_reserve_space(xdr, 16);
-		if (!p)
-			return nfserr_resource;
-		*p++ = cpu_to_be32(write->wr_bytes_written);
-		*p++ = cpu_to_be32(write->wr_how_written);
-		p = xdr_encode_opaque_fixed(p, write->wr_verifier.data,
-							NFS4_VERIFIER_SIZE);
-	}
-	return nfserr;
+	p = xdr_reserve_space(xdr, 16);
+	if (!p)
+		return nfserr_resource;
+	*p++ = cpu_to_be32(write->wr_bytes_written);
+	*p++ = cpu_to_be32(write->wr_how_written);
+	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data,
+						NFS4_VERIFIER_SIZE);
+	return 0;
 }
 
 static __be32
@@ -3937,12 +3880,8 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	char *server_scope;
 	int major_id_sz;
 	int server_scope_sz;
-	int status = 0;
 	uint64_t minor_id = 0;
 
-	if (nfserr)
-		return nfserr;
-
 	major_id = utsname()->nodename;
 	major_id_sz = strlen(major_id);
 	server_scope = utsname()->nodename;
@@ -3967,19 +3906,19 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		break;
 	case SP4_MACH_CRED:
 		/* spo_must_enforce bitmap: */
-		status = nfsd4_encode_bitmap(xdr,
+		nfserr = nfsd4_encode_bitmap(xdr,
 					exid->spo_must_enforce[0],
 					exid->spo_must_enforce[1],
 					exid->spo_must_enforce[2]);
-		if (status)
-			goto out;
+		if (nfserr)
+			return nfserr;
 		/* spo_must_allow bitmap: */
-		status = nfsd4_encode_bitmap(xdr,
+		nfserr = nfsd4_encode_bitmap(xdr,
 					exid->spo_must_allow[0],
 					exid->spo_must_allow[1],
 					exid->spo_must_allow[2]);
-		if (status)
-			goto out;
+		if (nfserr)
+			return nfserr;
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -4006,8 +3945,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	/* Implementation id */
 	*p++ = cpu_to_be32(0);	/* zero length nfs_impl_id4 array */
 	return 0;
-out:
-	return status;
 }
 
 static __be32
@@ -4017,9 +3954,6 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, 24);
 	if (!p)
 		return nfserr_resource;
@@ -4073,9 +4007,6 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 20);
 	if (!p)
 		return nfserr_resource;
@@ -4100,9 +4031,6 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct nfsd4_test_stateid_id *stateid, *next;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, 4 + (4 * test_stateid->ts_num_ids));
 	if (!p)
 		return nfserr_resource;
@@ -4112,7 +4040,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 		*p++ = stateid->ts_id_status;
 	}
 
-	return nfserr;
+	return 0;
 }
 
 #ifdef CONFIG_NFSD_PNFS
@@ -4125,14 +4053,9 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 	u32 starting_len = xdr->buf->len, needed_len;
 	__be32 *p;
 
-	dprintk("%s: err %d\n", __func__, be32_to_cpu(nfserr));
-	if (nfserr)
-		goto out;
-
-	nfserr = nfserr_resource;
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
-		goto out;
+		return nfserr_resource;
 
 	*p++ = cpu_to_be32(gdev->gd_layout_type);
 
@@ -4148,41 +4071,33 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 			 */
 			if (xdr->buf->len + 4 > gdev->gd_maxcount)
 				goto toosmall;
-			goto out;
+			return nfserr;
 		}
 	}
 
-	nfserr = nfserr_resource;
 	if (gdev->gd_notify_types) {
 		p = xdr_reserve_space(xdr, 4 + 4);
 		if (!p)
-			goto out;
+			return nfserr_resource;
 		*p++ = cpu_to_be32(1);			/* bitmap length */
 		*p++ = cpu_to_be32(gdev->gd_notify_types);
 	} else {
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
-			goto out;
+			return nfserr_resource;
 		*p++ = 0;
 	}
 
-	nfserr = 0;
-out:
-	dprintk("%s: done: %d\n", __func__, be32_to_cpu(nfserr));
-	return nfserr;
-
+	return 0;
 toosmall:
 	dprintk("%s: maxcount too small\n", __func__);
 	needed_len = xdr->buf->len + 4 /* notifications */;
 	xdr_truncate_encode(xdr, starting_len);
 	p = xdr_reserve_space(xdr, 4);
-	if (!p) {
-		nfserr = nfserr_resource;
-	} else {
-		*p++ = cpu_to_be32(needed_len);
-		nfserr = nfserr_toosmall;
-	}
-	goto out;
+	if (!p)
+		return nfserr_resource;
+	*p++ = cpu_to_be32(needed_len);
+	return nfserr_toosmall;
 }
 
 static __be32
@@ -4193,14 +4108,9 @@ nfsd4_encode_layoutget(struct nfsd4_compoundres *resp, __be32 nfserr,
 	const struct nfsd4_layout_ops *ops;
 	__be32 *p;
 
-	dprintk("%s: err %d\n", __func__, nfserr);
-	if (nfserr)
-		goto out;
-
-	nfserr = nfserr_resource;
 	p = xdr_reserve_space(xdr, 36 + sizeof(stateid_opaque_t));
 	if (!p)
-		goto out;
+		return nfserr_resource;
 
 	*p++ = cpu_to_be32(1);	/* we always set return-on-close */
 	*p++ = cpu_to_be32(lgp->lg_sid.si_generation);
@@ -4214,9 +4124,7 @@ nfsd4_encode_layoutget(struct nfsd4_compoundres *resp, __be32 nfserr,
 	*p++ = cpu_to_be32(lgp->lg_layout_type);
 
 	ops = nfsd4_layout_ops[lgp->lg_layout_type];
-	nfserr = ops->encode_layoutget(xdr, lgp);
-out:
-	return nfserr;
+	return ops->encode_layoutget(xdr, lgp);
 }
 
 static __be32
@@ -4226,9 +4134,6 @@ nfsd4_encode_layoutcommit(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		return nfserr_resource;
@@ -4240,7 +4145,7 @@ nfsd4_encode_layoutcommit(struct nfsd4_compoundres *resp, __be32 nfserr,
 		p = xdr_encode_hyper(p, lcp->lc_newsize);
 	}
 
-	return nfs_ok;
+	return 0;
 }
 
 static __be32
@@ -4250,16 +4155,13 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct xdr_stream *xdr = &resp->xdr;
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		return nfserr_resource;
 	*p++ = cpu_to_be32(lrp->lrs_present);
 	if (lrp->lrs_present)
 		return nfsd4_encode_stateid(xdr, &lrp->lr_sid);
-	return nfs_ok;
+	return 0;
 }
 #endif /* CONFIG_NFSD_PNFS */
 
@@ -4286,16 +4188,14 @@ nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
 {
 	__be32 *p;
 
-	if (!nfserr) {
-		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res);
-		if (nfserr)
-			return nfserr;
+	nfserr = nfsd42_encode_write_res(resp, &copy->cp_res);
+	if (nfserr)
+		return nfserr;
 
-		p = xdr_reserve_space(&resp->xdr, 4 + 4);
-		*p++ = cpu_to_be32(copy->cp_consecutive);
-		*p++ = cpu_to_be32(copy->cp_synchronous);
-	}
-	return nfserr;
+	p = xdr_reserve_space(&resp->xdr, 4 + 4);
+	*p++ = cpu_to_be32(copy->cp_consecutive);
+	*p++ = cpu_to_be32(copy->cp_synchronous);
+	return 0;
 }
 
 static __be32
@@ -4304,14 +4204,11 @@ nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 {
 	__be32 *p;
 
-	if (nfserr)
-		return nfserr;
-
 	p = xdr_reserve_space(&resp->xdr, 4 + 8);
 	*p++ = cpu_to_be32(seek->seek_eof);
 	p = xdr_encode_hyper(p, seek->seek_pos);
 
-	return nfserr;
+	return 0;
 }
 
 static __be32
-- 
2.9.4

