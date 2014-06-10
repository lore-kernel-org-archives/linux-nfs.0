Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:59186 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaFJKaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 06:30:01 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so684744pdb.16
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 03:30:00 -0700 (PDT)
Message-ID: <5396DE13.6070506@gmail.com>
Date: Tue, 10 Jun 2014 18:29:39 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] SUNRPC/NFSD: Change to type of bool for rq_usedeferral and
 rq_splice_ok
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rq_usedeferral and rq_splice_ok are used as 0 and 1, just defined to bool.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c                | 4 ++--
 include/linux/sunrpc/svc.h        | 4 ++--
 net/sunrpc/auth_gss/svcauth_gss.c | 2 +-
 net/sunrpc/svc.c                  | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index baa3803..be67340 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1298,7 +1298,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	 * Don't use the deferral mechanism for NFSv4; compounds make it
 	 * too hard to avoid non-idempotency problems.
 	 */
-	rqstp->rq_usedeferral = 0;
+	rqstp->rq_usedeferral = false;
 
 	/*
 	 * According to RFC3010, this takes precedence over all other errors.
@@ -1417,7 +1417,7 @@ encode_op:
 	BUG_ON(cstate->replay_owner);
 out:
 	/* Reset deferral mechanism for RPC deferrals */
-	rqstp->rq_usedeferral = 1;
+	rqstp->rq_usedeferral = true;
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
 	return status;
 }
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 1bc7cd0..cf61ecd 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -236,7 +236,7 @@ struct svc_rqst {
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
-	int			rq_usedeferral;	/* use deferral */
+	bool			rq_usedeferral;	/* use deferral */
 
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
@@ -277,7 +277,7 @@ struct svc_rqst {
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
 	int			rq_cachetype;
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
-	int			rq_splice_ok;   /* turned off in gss privacy
+	bool			rq_splice_ok;   /* turned off in gss privacy
 						 * to prevent encrypting page
 						 * cache pages */
 	wait_queue_head_t	rq_wait;	/* synchronization */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 4ce5ecce..c548ab2 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -886,7 +886,7 @@ unwrap_priv_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct gs
 	u32 priv_len, maj_stat;
 	int pad, saved_len, remaining_len, offset;
 
-	rqstp->rq_splice_ok = 0;
+	rqstp->rq_splice_ok = false;
 
 	priv_len = svc_getnl(&buf->head[0]);
 	if (rqstp->rq_deferred) {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5de6801..1db5007 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1086,9 +1086,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		goto err_short_len;
 
 	/* Will be turned off only in gss privacy case: */
-	rqstp->rq_splice_ok = 1;
+	rqstp->rq_splice_ok = true;
 	/* Will be turned off only when NFSv4 Sessions are used */
-	rqstp->rq_usedeferral = 1;
+	rqstp->rq_usedeferral = true;
 	rqstp->rq_dropme = false;
 
 	/* Setup reply header */
-- 
1.9.3

