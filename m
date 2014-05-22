Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826AbaEVTcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 52/52] nfsd4: better reservation of head space for krb5
Date: Thu, 22 May 2014 15:32:27 -0400
Message-Id: <1400787148-25941-53-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

RPC_MAX_AUTH_SIZE is scattered around several places.  Better to set it
once in the auth code, where this kind of estimate should be made.  And
while we're at it we can leave it zero when we're not using krb5i or
krb5p.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c                |  4 ++--
 fs/nfsd/nfs4state.c               |  2 +-
 fs/nfsd/nfs4xdr.c                 |  5 +++--
 include/linux/sunrpc/svc.h        | 11 +++++------
 net/sunrpc/auth_gss/svcauth_gss.c |  2 ++
 net/sunrpc/svcauth.c              |  2 ++
 6 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f5f608d..71fc494 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1263,13 +1263,13 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 	xdr->buf = buf;
 	xdr->iov = head;
 	xdr->p   = head->iov_base + head->iov_len;
-	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
+	xdr->end = head->iov_base + PAGE_SIZE - rqstp->rq_auth_slack;
 	/* Tail and page_len should be zero at this point: */
 	buf->len = buf->head[0].iov_len;
 	xdr->scratch.iov_len = 0;
 	xdr->page_ptr = buf->pages;
 	buf->buflen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
-		- 2 * RPC_MAX_AUTH_SIZE;
+		- rqstp->rq_auth_slack;
 }
 
 /*
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7a06246..052dc45 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2288,7 +2288,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 			session->se_fchannel.maxresp_sz;
 	status = (seq->cachethis) ? nfserr_rep_too_big_to_cache :
 				    nfserr_rep_too_big;
-	if (xdr_restrict_buflen(xdr, buflen - 2 * RPC_MAX_AUTH_SIZE))
+	if (xdr_restrict_buflen(xdr, buflen - rqstp->rq_auth_slack))
 		goto out_put_session;
 	svc_reserve(rqstp, buflen);
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6813870..fd39c49 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1611,7 +1611,8 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_HEAD;
 	struct nfsd4_op *op;
 	bool cachethis = false;
-	int max_reply = 2 * RPC_MAX_AUTH_SIZE + 8; /* opcnt, status */
+	int auth_slack= argp->rqstp->rq_auth_slack;
+	int max_reply = auth_slack + 8; /* opcnt, status */
 	int readcount = 0;
 	int readbytes = 0;
 	int i;
@@ -1677,7 +1678,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	svc_reserve(argp->rqstp, max_reply + readbytes);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
-	if (readcount > 1 || max_reply > PAGE_SIZE - 2*RPC_MAX_AUTH_SIZE)
+	if (readcount > 1 || max_reply > PAGE_SIZE - auth_slack)
 		argp->rqstp->rq_splice_ok = false;
 
 	DECODE_TAIL;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 39c50e1..0e6b39c 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -259,7 +259,10 @@ struct svc_rqst {
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
 	void *			rq_auth_data;	/* flavor-specific data */
-
+	int			rq_auth_slack;	/* extra space xdr code
+						 * should leave in head
+						 * for krb5i, krb5p.
+						 */
 	int			rq_reserved;	/* space on socket outq
 						 * reserved for this request
 						 */
@@ -455,11 +458,7 @@ char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
  */
 static inline void svc_reserve_auth(struct svc_rqst *rqstp, int space)
 {
-	int added_space = 0;
-
-	if (rqstp->rq_authop->flavour)
-		added_space = RPC_MAX_AUTH_SIZE;
-	svc_reserve(rqstp, space + added_space);
+	svc_reserve(rqstp, space + rqstp->rq_auth_slack);
 }
 
 #endif /* SUNRPC_SVC_H */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 0f73f45..4ce5ecce 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1503,6 +1503,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 			if (unwrap_integ_data(rqstp, &rqstp->rq_arg,
 					gc->gc_seq, rsci->mechctx))
 				goto garbage_args;
+			rqstp->rq_auth_slack = RPC_MAX_AUTH_SIZE;
 			break;
 		case RPC_GSS_SVC_PRIVACY:
 			/* placeholders for length and seq. number: */
@@ -1511,6 +1512,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 			if (unwrap_priv_data(rqstp, &rqstp->rq_arg,
 					gc->gc_seq, rsci->mechctx))
 				goto garbage_args;
+			rqstp->rq_auth_slack = RPC_MAX_AUTH_SIZE * 2;
 			break;
 		default:
 			goto auth_err;
diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
index 2af7b0c..79c0f34 100644
--- a/net/sunrpc/svcauth.c
+++ b/net/sunrpc/svcauth.c
@@ -54,6 +54,8 @@ svc_authenticate(struct svc_rqst *rqstp, __be32 *authp)
 	}
 	spin_unlock(&authtab_lock);
 
+	rqstp->rq_auth_slack = 0;
+
 	rqstp->rq_authop = aops;
 	return aops->accept(rqstp, authp);
 }
-- 
1.9.0

