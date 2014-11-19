Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:48449 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbaKSMvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:35 -0500
Received: by mail-qa0-f46.google.com with SMTP id u7so300475qaz.33
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:34 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] sunrpc: move rq_local field to rq_flags
Date: Wed, 19 Nov 2014 07:51:15 -0500
Message-Id: <1416401482-2562-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/vfs.c                 | 4 ++--
 include/linux/sunrpc/svc.h    | 2 +-
 include/trace/events/sunrpc.h | 3 ++-
 net/sunrpc/svcsock.c          | 5 ++++-
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 989129e2d6ea..d4ab255ae4a8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -940,7 +940,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	loff_t			pos = offset;
 	unsigned int		pflags = current->flags;
 
-	if (rqstp->rq_local)
+	if (test_bit(RQ_LOCAL, &rqstp->rq_flags))
 		/*
 		 * We want less throttling in balance_dirty_pages()
 		 * and shrink_inactive_list() so that nfs to
@@ -981,7 +981,7 @@ out_nfserr:
 		err = 0;
 	else
 		err = nfserrno(host_err);
-	if (rqstp->rq_local)
+	if (test_bit(RQ_LOCAL, &rqstp->rq_flags))
 		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
 	return err;
 }
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index b60eb7c3f3f7..a91df9047f32 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -254,8 +254,8 @@ struct svc_rqst {
 	u32			rq_proc;	/* procedure number */
 	u32			rq_prot;	/* IP protocol */
 #define	RQ_SECURE	(0)			/* secure port */
+#define	RQ_LOCAL	(1)			/* local request */
 	unsigned long		rq_flags;	/* flags field */
-	unsigned short		rq_local   : 1;	/* local request */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 5eb5f79d9794..98259f163cd8 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -414,7 +414,8 @@ TRACE_EVENT(xs_tcp_data_recv,
 
 #define show_rqstp_flags(flags)				\
 	__print_flags(flags, "|",			\
-		{ (1UL << RQ_SECURE),	"RQ_SECURE"})
+		{ (1UL << RQ_SECURE),	"RQ_SECURE"},	\
+		{ (1UL << RQ_LOCAL),	"RQ_LOCAL"})
 
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 3f959c681885..74db5ca60b33 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1140,7 +1140,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
-	rqstp->rq_local	      = !!test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags);
+	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
+		set_bit(RQ_LOCAL, &rqstp->rq_flags);
+	else
+		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
 
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];
-- 
2.1.0

