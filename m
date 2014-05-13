Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933421AbaEMOrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 May 2014 10:47:47 -0400
Date: Tue, 13 May 2014 10:47:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/43] nfsd4: reserve head space for krb5 integ/priv info
Message-ID: <20140513144723.GA17206@pad.redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-5-git-send-email-bfields@redhat.com>
 <20140512053727.GE29134@infradead.org>
 <20140512214545.GA11493@pad.redhat.com>
 <20140513050553.GA5056@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140513050553.GA5056@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 12, 2014 at 10:05:53PM -0700, Christoph Hellwig wrote:
> On Mon, May 12, 2014 at 05:45:45PM -0400, J. Bruce Fields wrote:
> > Yes.  At the end of this series we have RPC_MAX_AUTH_SIZE scattered
> > around in a few different places.  Rather than have each place have some
> > flavor-specific logic I think I'd like the auth code to set an
> > rq_auth_slack field in the struct svc_rqst for code like this to use.
> 
> That sounds pretty reasonable to me.

Here's an attempt.

(The limit still could be tightened a lot.  RPC_MAX_AUTH_SIZE really has
nothing to do with the amount of extra space required for krb5i/p, it's
just a random constant that we happen to know is plenty large enough.)

--b.

commit a5f2429b2756a66c35aab463a2784f334718719f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon May 12 18:10:58 2014 -0400

    nfsd4: better reservation of head space for krb5
    
    RPC_MAX_AUTH_SIZE is scattered around several places.  Better to set it
    once in the auth code, where this kind of estimate should be made.  And
    while we're at it we can leave it zero when we're not using krb5i or
    krb5p.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3ab29ba..d1885a1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1211,13 +1211,13 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
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
index 2526426..7336462 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2284,7 +2284,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 			session->se_fchannel.maxresp_sz;
 	status = (seq->cachethis) ? nfserr_rep_too_big_to_cache :
 				    nfserr_rep_too_big;
-	if (xdr_restrict_buflen(xdr, buflen - 2 * RPC_MAX_AUTH_SIZE))
+	if (xdr_restrict_buflen(xdr, buflen - rqstp->rq_auth_slack))
 		goto out_put_session;
 	svc_reserve(rqstp, buflen);
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 53731b7..7a8259c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1628,7 +1628,8 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	DECODE_HEAD;
 	struct nfsd4_op *op;
 	bool cachethis = false;
-	int max_reply = 2 * RPC_MAX_AUTH_SIZE; /* uh, kind of a guess */
+	int auth_slack = argp->rqstp->rq_auth_slack;
+	int max_reply = auth_slack;
 	int readcount = 0;
 	int readbytes = 0;
 	int i;
@@ -1693,7 +1694,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	svc_reserve(argp->rqstp, max_reply + readbytes);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
-	if (readcount > 1 || max_reply > PAGE_SIZE - 2*RPC_MAX_AUTH_SIZE)
+	if (readcount > 1 || max_reply > PAGE_SIZE - auth_slack)
 		argp->rqstp->rq_splice_ok = false;
 
 	DECODE_TAIL;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 39c50e1..b987bd9 100644
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
