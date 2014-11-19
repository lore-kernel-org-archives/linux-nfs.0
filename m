Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:61166 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbaKSMvk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:40 -0500
Received: by mail-qa0-f49.google.com with SMTP id s7so298893qap.36
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:39 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] sunrpc: move rq_splice_ok flag into rq_flags
Date: Wed, 19 Nov 2014 07:51:18 -0500
Message-Id: <1416401482-2562-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c                | 2 +-
 fs/nfsd/nfs4xdr.c                 | 8 ++++----
 fs/nfsd/vfs.c                     | 2 +-
 include/linux/sunrpc/svc.h        | 6 +++---
 include/trace/events/sunrpc.h     | 3 ++-
 net/sunrpc/auth_gss/svcauth_gss.c | 2 +-
 net/sunrpc/svc.c                  | 2 +-
 7 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7b897290a0a3..0878d5d234fb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -772,7 +772,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * the client wants us to do more in this compound:
 	 */
 	if (!nfsd4_last_compound_op(rqstp))
-		rqstp->rq_splice_ok = false;
+		clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index eeea7a90eb87..2e28ab94cc00 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1714,7 +1714,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
 	if (readcount > 1 || max_reply > PAGE_SIZE - auth_slack)
-		argp->rqstp->rq_splice_ok = false;
+		clear_bit(RQ_SPLICE_OK, &argp->rqstp->rq_flags);
 
 	DECODE_TAIL;
 }
@@ -3236,10 +3236,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
 	if (!p) {
-		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
+		WARN_ON_ONCE(test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags));
 		return nfserr_resource;
 	}
-	if (resp->xdr.buf->page_len && resp->rqstp->rq_splice_ok) {
+	if (resp->xdr.buf->page_len && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags)) {
 		WARN_ON_ONCE(1);
 		return nfserr_resource;
 	}
@@ -3256,7 +3256,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 			goto err_truncate;
 	}
 
-	if (file->f_op->splice_read && resp->rqstp->rq_splice_ok)
+	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
 		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		err = nfsd4_encode_readv(resp, read, file, maxcount);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d4ab255ae4a8..876e04c931ce 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -881,7 +881,7 @@ static __be32
 nfsd_vfs_read(struct svc_rqst *rqstp, struct file *file,
 	      loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
-	if (file->f_op->splice_read && rqstp->rq_splice_ok)
+	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
 		return nfsd_splice_read(rqstp, file, offset, count);
 	else
 		return nfsd_readv(file, offset, vec, vlen, count);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index d4ea3e5246b0..2714287fc4f6 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -256,6 +256,9 @@ struct svc_rqst {
 #define	RQ_LOCAL	(1)			/* local request */
 #define	RQ_USEDEFERRAL	(2)			/* use deferral */
 #define	RQ_DROPME	(3)			/* drop current reply */
+#define	RQ_SPLICE_OK	(4)			/* turned off in gss privacy
+						 * to prevent encrypting page
+						 * cache pages */
 	unsigned long		rq_flags;	/* flags field */
 
 	void *			rq_argp;	/* decoded arguments */
@@ -277,9 +280,6 @@ struct svc_rqst {
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
 	int			rq_cachetype;
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
-	bool			rq_splice_ok;   /* turned off in gss privacy
-						 * to prevent encrypting page
-						 * cache pages */
 	struct task_struct	*rq_task;	/* service thread */
 };
 
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 355671f19a9f..5848fc235869 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -417,7 +417,8 @@ TRACE_EVENT(xs_tcp_data_recv,
 		{ (1UL << RQ_SECURE),		"RQ_SECURE"},		\
 		{ (1UL << RQ_LOCAL),		"RQ_LOCAL"},		\
 		{ (1UL << RQ_USEDEFERRAL),	"RQ_USEDEFERRAL"},	\
-		{ (1UL << RQ_DROPME),		"RQ_DROPME"})
+		{ (1UL << RQ_DROPME),		"RQ_DROPME"},		\
+		{ (1UL << RQ_SPLICE_OK),	"RQ_SPLICE_OK"})
 
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index de856ddf5fed..224a82f24d3c 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -886,7 +886,7 @@ unwrap_priv_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct gs
 	u32 priv_len, maj_stat;
 	int pad, saved_len, remaining_len, offset;
 
-	rqstp->rq_splice_ok = false;
+	clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 
 	priv_len = svc_getnl(&buf->head[0]);
 	if (rqstp->rq_deferred) {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index fe4accf95dd8..34019ee9eaa1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1088,7 +1088,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		goto err_short_len;
 
 	/* Will be turned off only in gss privacy case: */
-	rqstp->rq_splice_ok = true;
+	set_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
 	clear_bit(RQ_DROPME, &rqstp->rq_flags);
-- 
2.1.0

