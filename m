Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38527 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbaEKUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/43] nfsd4: remove ADJUST_ARGS
Date: Sun, 11 May 2014 16:52:15 -0400
Message-Id: <1399841568-19716-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It's just uninteresting debugging code at this point.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   40 ----------------------------------------
 1 file changed, 40 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 53de2db..53708ce 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1750,7 +1750,6 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 	p = xdr_reserve_space(&resp->xdr, nbytes);		\
 	BUG_ON(!p);						\
 } while (0)
-#define ADJUST_ARGS()		WARN_ON_ONCE(p != resp->xdr.p)	\
 
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
@@ -2729,7 +2728,6 @@ nfsd4_encode_stateid(struct nfsd4_compoundres *resp, stateid_t *sid)
 	RESERVE_SPACE(sizeof(stateid_t));
 	WRITE32(sid->si_generation);
 	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
-	ADJUST_ARGS();
 }
 
 static __be32
@@ -2741,7 +2739,6 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		RESERVE_SPACE(8);
 		WRITE32(access->ac_supported);
 		WRITE32(access->ac_resp_access);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2756,7 +2753,6 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		WRITE32(bcts->dir);
 		/* Sorry, we do not yet support RDMA over 4.1: */
 		WRITE32(0);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2779,7 +2775,6 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	if (!nfserr) {
 		RESERVE_SPACE(NFS4_VERIFIER_SIZE);
 		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2795,7 +2790,6 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		WRITE32(2);
 		WRITE32(create->cr_bmval[0]);
 		WRITE32(create->cr_bmval[1]);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2827,7 +2821,6 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 		RESERVE_SPACE(len + 4);
 		WRITE32(len);
 		WRITEMEM(&fhp->fh_handle.fh_base, len);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2855,7 +2848,6 @@ nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denie
 		WRITE64((u64)0); /* clientid */
 		WRITE32(0); /* length of owner name */
 	}
-	ADJUST_ARGS();
 }
 
 static __be32
@@ -2895,7 +2887,6 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 	if (!nfserr) {
 		RESERVE_SPACE(20);
 		write_cinfo(&p, &link->li_cinfo);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -2917,7 +2908,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	WRITE32(open->op_bmval[0]);
 	WRITE32(open->op_bmval[1]);
 	WRITE32(open->op_delegate_type);
-	ADJUST_ARGS();
 
 	switch (open->op_delegate_type) {
 	case NFS4_OPEN_DELEGATE_NONE:
@@ -2934,7 +2924,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		WRITE32(0);
 		WRITE32(0);
 		WRITE32(0);   /* XXX: is NULL principal ok? */
-		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
 		nfsd4_encode_stateid(resp, &open->op_delegate_stateid);
@@ -2955,7 +2944,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		WRITE32(0);
 		WRITE32(0);
 		WRITE32(0);   /* XXX: is NULL principal ok? */
-		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_NONE_EXT: /* 4.1 */
 		switch (open->op_why_no_deleg) {
@@ -2969,7 +2957,6 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 			RESERVE_SPACE(4);
 			WRITE32(open->op_why_no_deleg);
 		}
-		ADJUST_ARGS();
 		break;
 	default:
 		BUG();
@@ -3051,7 +3038,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	WRITE32(eof);
 	WRITE32(maxcount);
-	ADJUST_ARGS();
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
@@ -3065,7 +3051,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-		ADJUST_ARGS();
 	}
 	return 0;
 }
@@ -3106,7 +3091,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 	}
 
 	WRITE32(maxcount);
-	ADJUST_ARGS();
 	resp->xdr.buf->head[0].iov_len = (char*)p
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	resp->xdr.buf->page_len = maxcount;
@@ -3120,7 +3104,6 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 		WRITE32(0);
 		resp->xdr.buf->tail[0].iov_base += maxcount&3;
 		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
-		ADJUST_ARGS();
 	}
 	return 0;
 }
@@ -3147,7 +3130,6 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
 	WRITE32(0);
 	WRITE32(0);
-	ADJUST_ARGS();
 	resp->xdr.buf->head[0].iov_len = ((char*)resp->xdr.p)
 				- (char*)resp->xdr.buf->head[0].iov_base;
 	tailbase = p;
@@ -3217,7 +3199,6 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	if (!nfserr) {
 		RESERVE_SPACE(20);
 		write_cinfo(&p, &remove->rm_cinfo);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3231,7 +3212,6 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		RESERVE_SPACE(40);
 		write_cinfo(&p, &rename->rn_sinfo);
 		write_cinfo(&p, &rename->rn_tinfo);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3271,7 +3251,6 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
 	supported = 0;
 	RESERVE_SPACE(4);
 	flavorsp = p++;		/* to be backfilled later */
-	ADJUST_ARGS();
 
 	for (i = 0; i < nflavs; i++) {
 		rpc_authflavor_t pf = flavs[i].pseudoflavor;
@@ -3285,12 +3264,10 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
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
@@ -3344,7 +3321,6 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		WRITE32(setattr->sa_bmval[1]);
 		WRITE32(setattr->sa_bmval[2]);
 	}
-	ADJUST_ARGS();
 	return nfserr;
 }
 
@@ -3357,13 +3333,11 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
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
@@ -3378,7 +3352,6 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 		WRITE32(write->wr_bytes_written);
 		WRITE32(write->wr_how_written);
 		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
-		ADJUST_ARGS();
 	}
 	return nfserr;
 }
@@ -3421,7 +3394,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(exid->flags);
 
 	WRITE32(exid->spa_how);
-	ADJUST_ARGS();
 
 	switch (exid->spa_how) {
 	case SP4_NONE:
@@ -3437,7 +3409,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		/* empty spo_must_allow bitmap: */
 		WRITE32(0);
 
-		ADJUST_ARGS();
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -3463,7 +3434,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	/* Implementation id */
 	WRITE32(0);	/* zero length nfs_impl_id4 array */
-	ADJUST_ARGS();
 	return 0;
 }
 
@@ -3480,7 +3450,6 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITEMEM(sess->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(sess->seqid);
 	WRITE32(sess->flags);
-	ADJUST_ARGS();
 
 	RESERVE_SPACE(28);
 	WRITE32(0); /* headerpadsz */
@@ -3490,12 +3459,10 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
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
@@ -3506,12 +3473,10 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
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
@@ -3534,7 +3499,6 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(seq->maxslots - 1); /* sr_target_highest_slotid */
 	WRITE32(seq->status_flags);
 
-	ADJUST_ARGS();
 	resp->cstate.datap = p; /* DRC cache data pointer */
 	return 0;
 }
@@ -3556,7 +3520,6 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 		*p++ = stateid->ts_id_status;
 	}
 
-	ADJUST_ARGS();
 	return nfserr;
 }
 
@@ -3691,7 +3654,6 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
 	statp = p++;	/* to be backfilled at the end */
-	ADJUST_ARGS();
 
 	if (op->opnum == OP_ILLEGAL)
 		goto status;
@@ -3756,11 +3718,9 @@ nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
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
1.7.9.5

