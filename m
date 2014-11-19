Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:63717 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936AbaKSMvg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:36 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so318322qcz.24
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:36 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] sunrpc: move rq_usedeferral flag to rq_flags
Date: Wed, 19 Nov 2014 07:51:16 -0500
Message-Id: <1416401482-2562-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c            | 4 ++--
 include/linux/sunrpc/svc.h    | 2 +-
 include/trace/events/sunrpc.h | 9 +++++----
 net/sunrpc/svc.c              | 2 +-
 net/sunrpc/svc_xprt.c         | 2 +-
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0beb023f25ac..7b897290a0a3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1331,7 +1331,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	 * Don't use the deferral mechanism for NFSv4; compounds make it
 	 * too hard to avoid non-idempotency problems.
 	 */
-	rqstp->rq_usedeferral = false;
+	clear_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
 
 	/*
 	 * According to RFC3010, this takes precedence over all other errors.
@@ -1447,7 +1447,7 @@ encode_op:
 	BUG_ON(cstate->replay_owner);
 out:
 	/* Reset deferral mechanism for RPC deferrals */
-	rqstp->rq_usedeferral = true;
+	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
 	return status;
 }
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index a91df9047f32..6a3cf4c76dce 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -236,7 +236,6 @@ struct svc_rqst {
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
-	bool			rq_usedeferral;	/* use deferral */
 
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
@@ -255,6 +254,7 @@ struct svc_rqst {
 	u32			rq_prot;	/* IP protocol */
 #define	RQ_SECURE	(0)			/* secure port */
 #define	RQ_LOCAL	(1)			/* local request */
+#define	RQ_USEDEFERRAL	(2)			/* use deferral */
 	unsigned long		rq_flags;	/* flags field */
 
 	void *			rq_argp;	/* decoded arguments */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 98259f163cd8..6d1facdebc92 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -412,10 +412,11 @@ TRACE_EVENT(xs_tcp_data_recv,
 			__entry->copied, __entry->reclen, __entry->offset)
 );
 
-#define show_rqstp_flags(flags)				\
-	__print_flags(flags, "|",			\
-		{ (1UL << RQ_SECURE),	"RQ_SECURE"},	\
-		{ (1UL << RQ_LOCAL),	"RQ_LOCAL"})
+#define show_rqstp_flags(flags)						\
+	__print_flags(flags, "|",					\
+		{ (1UL << RQ_SECURE),		"RQ_SECURE"},		\
+		{ (1UL << RQ_LOCAL),		"RQ_LOCAL"},		\
+		{ (1UL << RQ_USEDEFERRAL),	"RQ_USEDEFERRAL"})
 
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d38b75b0e236..078c6447fa4f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1090,7 +1090,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = true;
 	/* Will be turned off only when NFSv4 Sessions are used */
-	rqstp->rq_usedeferral = true;
+	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
 	rqstp->rq_dropme = false;
 
 	/* Setup reply header */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index eaa9263c2d28..a40f3755a33d 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1081,7 +1081,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
 	struct svc_deferred_req *dr;
 
-	if (rqstp->rq_arg.page_len || !rqstp->rq_usedeferral)
+	if (rqstp->rq_arg.page_len || !test_bit(RQ_USEDEFERRAL, &rqstp->rq_flags))
 		return NULL; /* if more than a page, give up FIXME */
 	if (rqstp->rq_deferred) {
 		dr = rqstp->rq_deferred;
-- 
2.1.0

