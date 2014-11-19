Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:48287 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbaKSMvi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:38 -0500
Received: by mail-qc0-f176.google.com with SMTP id i17so325070qcy.7
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:37 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] sunrpc: move rq_dropme flag into rq_flags
Date: Wed, 19 Nov 2014 07:51:17 -0500
Message-Id: <1416401482-2562-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfssvc.c              | 2 +-
 include/linux/sunrpc/svc.h    | 2 +-
 include/trace/events/sunrpc.h | 8 ++++----
 net/sunrpc/svc.c              | 4 ++--
 net/sunrpc/svc_xprt.c         | 2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 752d56bbe0ba..314f5c8f8f1a 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -692,7 +692,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
-	if (nfserr == nfserr_dropit || rqstp->rq_dropme) {
+	if (nfserr == nfserr_dropit || test_bit(RQ_DROPME, &rqstp->rq_flags)) {
 		dprintk("nfsd: Dropping request; may be revisited later\n");
 		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
 		return 0;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6a3cf4c76dce..d4ea3e5246b0 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -255,6 +255,7 @@ struct svc_rqst {
 #define	RQ_SECURE	(0)			/* secure port */
 #define	RQ_LOCAL	(1)			/* local request */
 #define	RQ_USEDEFERRAL	(2)			/* use deferral */
+#define	RQ_DROPME	(3)			/* drop current reply */
 	unsigned long		rq_flags;	/* flags field */
 
 	void *			rq_argp;	/* decoded arguments */
@@ -271,7 +272,6 @@ struct svc_rqst {
 	struct cache_req	rq_chandle;	/* handle passed to caches for 
 						 * request delaying 
 						 */
-	bool			rq_dropme;
 	/* Catering to nfsd */
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 6d1facdebc92..355671f19a9f 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -416,7 +416,8 @@ TRACE_EVENT(xs_tcp_data_recv,
 	__print_flags(flags, "|",					\
 		{ (1UL << RQ_SECURE),		"RQ_SECURE"},		\
 		{ (1UL << RQ_LOCAL),		"RQ_LOCAL"},		\
-		{ (1UL << RQ_USEDEFERRAL),	"RQ_USEDEFERRAL"})
+		{ (1UL << RQ_USEDEFERRAL),	"RQ_USEDEFERRAL"},	\
+		{ (1UL << RQ_DROPME),		"RQ_DROPME"})
 
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
@@ -459,13 +460,12 @@ DECLARE_EVENT_CLASS(svc_rqst_status,
 	TP_fast_assign(
 		__entry->addr = (struct sockaddr *)&rqst->rq_addr;
 		__entry->xid = rqst->rq_xid;
-		__entry->dropme = (int)rqst->rq_dropme;
 		__entry->status = status;
 		__entry->flags = rqst->rq_flags;
 	),
 
-	TP_printk("addr=%pIScp rq_xid=0x%x dropme=%d status=%d flags=%s",
-		__entry->addr, be32_to_cpu(__entry->xid), __entry->dropme,
+	TP_printk("addr=%pIScp rq_xid=0x%x status=%d flags=%s",
+		__entry->addr, be32_to_cpu(__entry->xid),
 		__entry->status, show_rqstp_flags(__entry->flags))
 );
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 078c6447fa4f..fe4accf95dd8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1091,7 +1091,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	rqstp->rq_splice_ok = true;
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
-	rqstp->rq_dropme = false;
+	clear_bit(RQ_DROPME, &rqstp->rq_flags);
 
 	/* Setup reply header */
 	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
@@ -1191,7 +1191,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 
 		/* Encode reply */
-		if (rqstp->rq_dropme) {
+		if (test_bit(RQ_DROPME, &rqstp->rq_flags)) {
 			if (procp->pc_release)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index a40f3755a33d..143c4c8ea2f1 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1110,7 +1110,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
-	rqstp->rq_dropme = true;
+	set_bit(RQ_DROPME, &rqstp->rq_flags);
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
-- 
2.1.0

