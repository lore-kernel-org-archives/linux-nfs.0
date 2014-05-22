Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752837AbaEVTct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 50/52] nfsd4: kill WRITEMEM
Date: Thu, 22 May 2014 15:32:25 -0400
Message-Id: <1400787148-25941-51-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 62 +++++++++++++++++++++++++------------------------------
 1 file changed, 28 insertions(+), 34 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 46fc861..2a5bd29 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1683,12 +1683,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_TAIL;
 }
 
-#define WRITEMEM(ptr,nbytes)     do { if (nbytes > 0) {		\
-	*(p + XDR_QUADLEN(nbytes) -1) = 0;                      \
-	memcpy(p, ptr, nbytes);					\
-	p += XDR_QUADLEN(nbytes);				\
-}} while (0)
-
 static void write32(__be32 **p, u32 n)
 {
 	*(*p)++ = htonl(n);
@@ -1769,8 +1763,7 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
 			p = xdr_reserve_space(xdr, strlen + 4);
 			if (!p)
 				return nfserr_resource;
-			*p++ = cpu_to_be32(strlen);
-			WRITEMEM(str, strlen);
+			p = xdr_encode_opaque(p, str, strlen);
 			count++;
 		}
 		else
@@ -1865,8 +1858,7 @@ static __be32 nfsd4_encode_path(struct xdr_stream *xdr,
 			spin_unlock(&dentry->d_lock);
 			goto out_free;
 		}
-		*p++ = cpu_to_be32(len);
-		WRITEMEM(dentry->d_name.name, len);
+		p = xdr_encode_opaque(p, dentry->d_name.name, len);
 		dprintk("/%s", dentry->d_name.name);
 		spin_unlock(&dentry->d_lock);
 		dput(dentry);
@@ -2239,7 +2231,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			*p++ = cpu_to_be32(MINOR(stat.dev));
 			break;
 		case FSIDSOURCE_UUID:
-			WRITEMEM(exp->ex_uuid, 16);
+			p = xdr_encode_opaque_fixed(p, exp->ex_uuid, 16);
 			break;
 		}
 	}
@@ -2326,8 +2318,8 @@ out_acl:
 		p = xdr_reserve_space(xdr, fhp->fh_handle.fh_size + 4);
 		if (!p)
 			goto out_resource;
-		*p++ = cpu_to_be32(fhp->fh_handle.fh_size);
-		WRITEMEM(&fhp->fh_handle.fh_base, fhp->fh_handle.fh_size);
+		p = xdr_encode_opaque(p, &fhp->fh_handle.fh_base,
+					fhp->fh_handle.fh_size);
 	}
 	if (bmval0 & FATTR4_WORD0_FILEID) {
 		p = xdr_reserve_space(xdr, 8);
@@ -2748,7 +2740,8 @@ nfsd4_encode_stateid(struct xdr_stream *xdr, stateid_t *sid)
 	if (!p)
 		return nfserr_resource;
 	*p++ = cpu_to_be32(sid->si_generation);
-	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
+	p = xdr_encode_opaque_fixed(p, &sid->si_opaque,
+					sizeof(stateid_opaque_t));
 	return 0;
 }
 
@@ -2777,7 +2770,8 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 8);
 		if (!p)
 			return nfserr_resource;
-		WRITEMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+		p = xdr_encode_opaque_fixed(p, bcts->sessionid.data,
+						NFS4_MAX_SESSIONID_LEN);
 		*p++ = cpu_to_be32(bcts->dir);
 		/* Sorry, we do not yet support RDMA over 4.1: */
 		*p++ = cpu_to_be32(0);
@@ -2807,7 +2801,8 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		p = xdr_reserve_space(xdr, NFS4_VERIFIER_SIZE);
 		if (!p)
 			return nfserr_resource;
-		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
+		p = xdr_encode_opaque_fixed(p, commit->co_verf.data,
+						NFS4_VERIFIER_SIZE);
 	}
 	return nfserr;
 }
@@ -2858,8 +2853,7 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 		p = xdr_reserve_space(xdr, len + 4);
 		if (!p)
 			return nfserr_resource;
-		*p++ = cpu_to_be32(len);
-		WRITEMEM(&fhp->fh_handle.fh_base, len);
+		p = xdr_encode_opaque(p, &fhp->fh_handle.fh_base, len);
 	}
 	return nfserr;
 }
@@ -2892,9 +2886,8 @@ again:
 	p = xdr_encode_hyper(p, ld->ld_length);
 	*p++ = cpu_to_be32(ld->ld_type);
 	if (conf->len) {
-		WRITEMEM(&ld->ld_clientid, 8);
-		*p++ = cpu_to_be32(conf->len);
-		WRITEMEM(conf->data, conf->len);
+		p = xdr_encode_opaque_fixed(p, &ld->ld_clientid, 8);
+		p = xdr_encode_opaque(p, conf->data, conf->len);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
 		p = xdr_encode_hyper(p, (u64)0); /* clientid */
 		*p++ = cpu_to_be32(0); /* length of owner name */
@@ -3461,8 +3454,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
 			if (!p)
 				goto out;
 			*p++ = cpu_to_be32(RPC_AUTH_GSS);
-			*p++ = cpu_to_be32(info.oid.len);
-			WRITEMEM(info.oid.data, info.oid.len);
+			p = xdr_encode_opaque(p,  info.oid.data, info.oid.len);
 			*p++ = cpu_to_be32(info.qop);
 			*p++ = cpu_to_be32(info.service);
 		} else if (pf < RPC_AUTH_MAXFLAVOR) {
@@ -3544,8 +3536,9 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
 		p = xdr_reserve_space(xdr, 8 + NFS4_VERIFIER_SIZE);
 		if (!p)
 			return nfserr_resource;
-		WRITEMEM(&scd->se_clientid, 8);
-		WRITEMEM(&scd->se_confirm, NFS4_VERIFIER_SIZE);
+		p = xdr_encode_opaque_fixed(p, &scd->se_clientid, 8);
+		p = xdr_encode_opaque_fixed(p, &scd->se_confirm,
+						NFS4_VERIFIER_SIZE);
 	}
 	else if (nfserr == nfserr_clid_inuse) {
 		p = xdr_reserve_space(xdr, 8);
@@ -3569,7 +3562,8 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 			return nfserr_resource;
 		*p++ = cpu_to_be32(write->wr_bytes_written);
 		*p++ = cpu_to_be32(write->wr_how_written);
-		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
+		p = xdr_encode_opaque_fixed(p, write->wr_verifier.data,
+							NFS4_VERIFIER_SIZE);
 	}
 	return nfserr;
 }
@@ -3610,7 +3604,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	if (!p)
 		return nfserr_resource;
 
-	WRITEMEM(&exid->clientid, 8);
+	p = xdr_encode_opaque_fixed(p, &exid->clientid, 8);
 	*p++ = cpu_to_be32(exid->seqid);
 	*p++ = cpu_to_be32(exid->flags);
 
@@ -3650,12 +3644,10 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	/* The server_owner struct */
 	p = xdr_encode_hyper(p, minor_id);      /* Minor id */
 	/* major id */
-	*p++ = cpu_to_be32(major_id_sz);
-	WRITEMEM(major_id, major_id_sz);
+	p = xdr_encode_opaque(p, major_id, major_id_sz);
 
 	/* Server scope */
-	*p++ = cpu_to_be32(server_scope_sz);
-	WRITEMEM(server_scope, server_scope_sz);
+	p = xdr_encode_opaque(p, server_scope, server_scope_sz);
 
 	/* Implementation id */
 	*p++ = cpu_to_be32(0);	/* zero length nfs_impl_id4 array */
@@ -3675,7 +3667,8 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	p = xdr_reserve_space(xdr, 24);
 	if (!p)
 		return nfserr_resource;
-	WRITEMEM(sess->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	p = xdr_encode_opaque_fixed(p, sess->sessionid.data,
+					NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(sess->seqid);
 	*p++ = cpu_to_be32(sess->flags);
 
@@ -3730,7 +3723,8 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 20);
 	if (!p)
 		return nfserr_resource;
-	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	p = xdr_encode_opaque_fixed(p, seq->sessionid.data,
+					NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(seq->seqid);
 	*p++ = cpu_to_be32(seq->slotid);
 	/* Note slotid's are numbered from zero: */
@@ -3959,7 +3953,7 @@ nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
 	*p++ = cpu_to_be32(op->opnum);
 	*p++ = rp->rp_status;  /* already xdr'ed */
 
-	WRITEMEM(rp->rp_buf, rp->rp_buflen);
+	p = xdr_encode_opaque_fixed(p, rp->rp_buf, rp->rp_buflen);
 }
 
 int
-- 
1.9.0

