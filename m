Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47886 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbaCWBM3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 24/50] nfsd4: remove ADJUST_ARGS
Date: Sat, 22 Mar 2014 21:11:55 -0400
Message-Id: <1395537141-10389-25-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It's just uninteresting debugging code at this point.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 39 ---------------------------------------
 1 file changed, 39 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 43c2a99..a2dbc19 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1751,7 +1751,6 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 	p = xdr_reserve_space(&resp->xdr, nbytes);		\
 	BUG_ON(!p);						\
 } while (0)
-#define ADJUST_ARGS()		WARN_ON_ONCE(p != resp->xdr.p)	\
 
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
@@ -2730,7 +2729,6 @@ nfsd4_encode_stateid(struct nfsd4_compoundres *resp, stateid_t *sid)
 	RESERVE_SPACE(sizeof(stateid_t));
 	WRITE32(sid->si_generation);
 	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
-	ADJUST_ARGS();
 }
 
 static __be32
@@ -2742,7 +2740,6 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		RESERVE_SPACE(8);
 		WRITE32(access->ac_supported);
 		WRITE32(access->ac_resp_access);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2757,7 +2754,6 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		WRITE32(bcts->dir);
 		/* Sorry, we do not yet support RDMA over 4.1: */
 		WRITE32(0);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2780,7 +2776,6 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	if (!nfserr) {
 		RESERVE_SPACE(NFS4_VERIFIER_SIZE);
 		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2796,7 +2791,6 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		WRITE32(2);
 		WRITE32(create->cr_bmval[0]);
 		WRITE32(create->cr_bmval[1]);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2828,7 +2822,6 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 		RESERVE_SPACE(len + 4);
 		WRITE32(len);
 		WRITEMEM(&fhp->fh_handle.fh_base, len);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2856,7 +2849,6 @@ nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denie
 		WRITE64((u64)0); /* clientid */
 		WRITE32(0); /* length of owner name */
 	}
-	ADJUST_ARGS();
 }
 
 static __be32
@@ -2896,7 +2888,6 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 	if (!nfserr) {
 		RESERVE_SPACE(20);
 		write_cinfo(&p, &link->li_cinfo);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2918,7 +2909,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	WRITE32(open->op_bmval[0]);
 	WRITE32(open->op_bmval[1]);
 	WRITE32(open->op_delegate_type);
-	ADJUST_ARGS();
 
 	switch (open->op_delegate_type) {
 	case NFS4_OPEN_DELEGATE_NONE:
@@ -2935,7 +2925,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		WRITE32(0);
 		WRITE32(0);
 		WRITE32(0);   /* XXX: is NULL principal ok? */
-		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
 		nfsd4_encode_stateid(resp, &open->op_delegate_stateid);
@@ -2956,7 +2945,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		WRITE32(0);
 		WRITE32(0);
 		WRITE32(0);   /* XXX: is NULL principal ok? */
-		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_NONE_EXT: /* 4.1 */
 		switch (open->op_why_no_deleg) {
@@ -2970,7 +2958,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 			RESERVE_SPACE(4);
 			WRITE32(open->op_why_no_deleg);
 		}
-		ADJUST_ARGS();
 		break;
 	default:
 		BUG();
@@ -3053,7 +3040,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	WRITE32(eof);
 	WRITE32(maxcount);
-	ADJUST_ARGS();
 	WARN_ON_ONCE(resp->xdr.buf->head[0].iov_len != (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base);
 	resp->xdr.buf->page_len = maxcount;
@@ -3069,7 +3055,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
 		xdr->buf->len -= (maxcount&3);
-		ADJUST_ARGS();
 	}
 	return 0;
 }
@@ -3110,7 +3095,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	}
 
 	WRITE32(maxcount);
-	ADJUST_ARGS();
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
@@ -3125,7 +3109,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-		ADJUST_ARGS();
 	}
 	return 0;
 }
@@ -3152,7 +3135,6 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
 	WRITE32(0);
 	WRITE32(0);
-	ADJUST_ARGS();
 	resp->xdr.buf->head[0].iov_len = ((char*)resp->xdr.p)
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	tailbase = p;
@@ -3221,7 +3203,6 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	if (!nfserr) {
 		RESERVE_SPACE(20);
 		write_cinfo(&p, &remove->rm_cinfo);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3235,7 +3216,6 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		RESERVE_SPACE(40);
 		write_cinfo(&p, &rename->rn_sinfo);
 		write_cinfo(&p, &rename->rn_tinfo);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3275,7 +3255,6 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 	supported = 0;
 	RESERVE_SPACE(4);
 	flavorsp = p++;		/* to be backfilled later */
-	ADJUST_ARGS();
 
 	for (i = 0; i < nflavs; i++) {
 		rpc_authflavor_t pf = flavs[i].pseudoflavor;
@@ -3289,12 +3268,10 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 			WRITEMEM(info.oid.data, info.oid.len);
 			WRITE32(info.qop);
 			WRITE32(info.service);
-			ADJUST_ARGS();
 		} else if (pf < RPC_AUTH_MAXFLAVOR) {
 			supported++;
 			RESERVE_SPACE(4);
 			WRITE32(pf);
-			ADJUST_ARGS();
 		} else {
 			if (report)
 				pr_warn("NFS: SECINFO: security flavor %u "
@@ -3348,7 +3325,6 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		WRITE32(setattr->sa_bmval[1]);
 		WRITE32(setattr->sa_bmval[2]);
 	}
-	ADJUST_ARGS();
 	return nfserr;
 }
 
@@ -3361,13 +3337,11 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
 		RESERVE_SPACE(8 + NFS4_VERIFIER_SIZE);
 		WRITEMEM(&scd->se_clientid, 8);
 		WRITEMEM(&scd->se_confirm, NFS4_VERIFIER_SIZE);
-		ADJUST_ARGS();
 	}
 	else if (nfserr == nfserr_clid_inuse) {
 		RESERVE_SPACE(8);
 		WRITE32(0);
 		WRITE32(0);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3382,7 +3356,6 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 		WRITE32(write->wr_bytes_written);
 		WRITE32(write->wr_how_written);
 		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3425,7 +3398,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(exid->flags);
 
 	WRITE32(exid->spa_how);
-	ADJUST_ARGS();
 
 	switch (exid->spa_how) {
 	case SP4_NONE:
@@ -3441,7 +3413,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		/* empty spo_must_allow bitmap: */
 		WRITE32(0);
 
-		ADJUST_ARGS();
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -3467,7 +3438,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	/* Implementation id */
 	WRITE32(0);	/* zero length nfs_impl_id4 array */
-	ADJUST_ARGS();
 	return 0;
 }
 
@@ -3484,7 +3454,6 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITEMEM(sess->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(sess->seqid);
 	WRITE32(sess->flags);
-	ADJUST_ARGS();
 
 	RESERVE_SPACE(28);
 	WRITE32(0); /* headerpadsz */
@@ -3494,12 +3463,10 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(sess->fore_channel.maxops);
 	WRITE32(sess->fore_channel.maxreqs);
 	WRITE32(sess->fore_channel.nr_rdma_attrs);
-	ADJUST_ARGS();
 
 	if (sess->fore_channel.nr_rdma_attrs) {
 		RESERVE_SPACE(4);
 		WRITE32(sess->fore_channel.rdma_attrs);
-		ADJUST_ARGS();
 	}
 
 	RESERVE_SPACE(28);
@@ -3510,12 +3477,10 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(sess->back_channel.maxops);
 	WRITE32(sess->back_channel.maxreqs);
 	WRITE32(sess->back_channel.nr_rdma_attrs);
-	ADJUST_ARGS();
 
 	if (sess->back_channel.nr_rdma_attrs) {
 		RESERVE_SPACE(4);
 		WRITE32(sess->back_channel.rdma_attrs);
-		ADJUST_ARGS();
 	}
 	return 0;
 }
@@ -3538,7 +3503,6 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(seq->maxslots - 1); /* sr_target_highest_slotid */
 	WRITE32(seq->status_flags);
 
-	ADJUST_ARGS();
 	resp->cstate.datap = p; /* DRC cache data pointer */
 	return 0;
 }
@@ -3560,7 +3524,6 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 		*p++ = stateid->ts_id_status;
 	}
 
-	ADJUST_ARGS();
 	return nfserr;
 }
 
@@ -3768,11 +3731,9 @@ nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
 	*p++ = rp->rp_status;  /* already xdr'ed */
-	ADJUST_ARGS();
 
 	RESERVE_SPACE(rp->rp_buflen);
 	WRITEMEM(rp->rp_buf, rp->rp_buflen);
-	ADJUST_ARGS();
 }
 
 int
-- 
1.8.5.3

