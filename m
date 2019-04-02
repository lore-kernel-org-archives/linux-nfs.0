Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A59DC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 27A2A20700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pEN7U5Xn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726463AbfDBXRA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:17:00 -0400
Received: from mail-pl1-f196.google.com ([209.85.214.196]:40074 "EHLO
        mail-pl1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXRA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:17:00 -0400
Received: by mail-pl1-f196.google.com with SMTP id b3so4038445plr.7
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:16:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=R1lA2IA2bW1xX2yzXQ19oLoYttZsX6qUDPHS93t/P9A=;
        b=pEN7U5XnBxiA4L46D7Ug/OsXFvGzwNwi4+HYKDjdQxltx9mnxjSZz4ImTjWnfFyy67
         t2SnrxgbbkRmFx43lc1krK8MaKkKfoIpKMERElGfn78UuqWBgcTSEZtNIHIa8GO2qU0Q
         GX2ANJ+4ZN/hA2hckXibNWdg3oDj2MEb9JVWMfdK2GMODJj91/P6XXHNjSy4VQZBKJYQ
         Fs4dPgdP+CuYddL/1lg/rRFfLkw0VYKWvsVrUTwfbDFqrCRR9NSDuy3N+CY+vcck1CRD
         mwtjIXuYwU3hDW/rO6tIQmBY82gUxGBq5G+kX4YEoObjH4u8NWfyiYsictITx5QV0s8E
         JBuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=R1lA2IA2bW1xX2yzXQ19oLoYttZsX6qUDPHS93t/P9A=;
        b=G/4bBIhENEckETYhCFinY+0ZxfegaaywE9+mmkY6knKGAMiwAP6yjTRJbMeyT5ZHU8
         AoWk9JpotABMlzXIDz5GsFM2rPNsgIgBEyfnOcMkfRZfgl2AsvWsq7hSed0fTpxE5TIF
         mM9qqcZ9326cX9m8/+wQN6J5qhcXfZW4knsF34xyiIdXFxM99+jt5QDFEKh3vmYpncxu
         LA17f8Wgu1ZoWWoHzMtx53jvKpmtPU8lmxgfe1Glyjy21ZN5vsiJxb3BxXUeSK+vN7Xt
         ats7fNmwN5umJEeqb94odzyPNOi+rk0jsxvlm+MGAF4nq4I6UYJDMpc/oRPXYeDuOACp
         qxxw==
X-Gm-Message-State: APjAAAWoIJNNqmwEo/WSRaFAatv7+xZxKr90ywhgV7Pv85442hxZfO6c
        XTOpF7YnlBp/PaYmkeDFLfswUAU=
X-Google-Smtp-Source: APXvYqyoVqhWVY0yp4V9cpuS2etYH2LAMJOCY+AQonWXiBCDXgWKbL4Ok48jlT+Te2EfFdrQuESiDA==
X-Received: by 2002:a17:902:599d:: with SMTP id p29mr38267311pli.156.1554247019227;
        Tue, 02 Apr 2019 16:16:59 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.16.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:16:58 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] SUNRPC: Add a callback to initialise server requests
Date:   Tue,  2 Apr 2019 16:14:44 -0700
Message-Id: <20190402231448.27743-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402231448.27743-2-trond.myklebust@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
 <20190402231448.27743-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a callback to help initialise server requests before they are
processed. This will allow us to clean up the NFS server version
support, and to make it container safe.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/svc.c             |   3 +-
 fs/nfs/callback.c          |   1 +
 fs/nfsd/nfssvc.c           |   2 +
 include/linux/sunrpc/svc.h |  16 +++++
 net/sunrpc/svc.c           | 125 ++++++++++++++++++++++++-------------
 5 files changed, 103 insertions(+), 44 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 346ed161756d..75415b21efda 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -807,5 +807,6 @@ static struct svc_program	nlmsvc_program = {
 	.pg_name		= "lockd",		/* service name */
 	.pg_class		= "nfsd",		/* share authentication with nfsd */
 	.pg_stats		= &nlmsvc_stats,	/* stats table */
-	.pg_authenticate = &lockd_authenticate	/* export authentication */
+	.pg_authenticate	= &lockd_authenticate,	/* export authentication */
+	.pg_init_request	= svc_generic_init_request,
 };
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 0b602a39dd71..a9510374bad7 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -457,4 +457,5 @@ static struct svc_program nfs4_callback_program = {
 	.pg_class = "nfs",				/* authentication class */
 	.pg_stats = &nfs4_callback_stats,
 	.pg_authenticate = nfs_callback_authenticate,
+	.pg_init_request = svc_generic_init_request,
 };
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 89cb484f1cfb..e26762e84798 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -86,6 +86,7 @@ static struct svc_program	nfsd_acl_program = {
 	.pg_class		= "nfsd",
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
+	.pg_init_request	= svc_generic_init_request,
 };
 
 static struct svc_stat	nfsd_acl_svcstats = {
@@ -118,6 +119,7 @@ struct svc_program		nfsd_program = {
 	.pg_class		= "nfsd",		/* authentication class */
 	.pg_stats		= &nfsd_svcstats,	/* version table */
 	.pg_authenticate	= &svc_set_client,	/* export authentication */
+	.pg_init_request	= svc_generic_init_request,
 
 };
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7ff12c9dbeaf..f43d5765acff 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -383,6 +383,16 @@ struct svc_deferred_req {
 	__be32			args[0];
 };
 
+struct svc_process_info {
+	union {
+		int  (*dispatch)(struct svc_rqst *, __be32 *);
+		struct {
+			unsigned int lovers;
+			unsigned int hivers;
+		} mismatch;
+	};
+};
+
 /*
  * List of RPC programs on the same transport endpoint
  */
@@ -397,6 +407,9 @@ struct svc_program {
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
 	int			(*pg_authenticate)(struct svc_rqst *);
+	__be32			(*pg_init_request)(struct svc_rqst *,
+						   const struct svc_program *,
+						   struct svc_process_info *);
 };
 
 /*
@@ -506,6 +519,9 @@ char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
 					     struct kvec *first, void *p,
 					     size_t total);
 __be32		   svc_return_autherr(struct svc_rqst *rqstp, __be32 auth_err);
+__be32		   svc_generic_init_request(struct svc_rqst *rqstp,
+					    const struct svc_program *progp,
+					    struct svc_process_info *procinfo);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3d5dd6b86652..5f87c0f1e4e0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1160,6 +1160,65 @@ svc_get_autherr(struct svc_rqst *rqstp, __be32 *statp)
 	return rpc_auth_ok;
 }
 
+__be32
+svc_generic_init_request(struct svc_rqst *rqstp,
+		const struct svc_program *progp,
+		struct svc_process_info *ret)
+{
+	const struct svc_version *versp = NULL;	/* compiler food */
+	const struct svc_procedure *procp = NULL;
+
+	if (rqstp->rq_vers >= progp->pg_nvers )
+		goto err_bad_vers;
+	  versp = progp->pg_vers[rqstp->rq_vers];
+	  if (!versp)
+		goto err_bad_vers;
+
+	/*
+	 * Some protocol versions (namely NFSv4) require some form of
+	 * congestion control.  (See RFC 7530 section 3.1 paragraph 2)
+	 * In other words, UDP is not allowed. We mark those when setting
+	 * up the svc_xprt, and verify that here.
+	 *
+	 * The spec is not very clear about what error should be returned
+	 * when someone tries to access a server that is listening on UDP
+	 * for lower versions. RPC_PROG_MISMATCH seems to be the closest
+	 * fit.
+	 */
+	if (versp->vs_need_cong_ctrl && rqstp->rq_xprt &&
+	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
+		goto err_bad_vers;
+
+	if (rqstp->rq_proc >= versp->vs_nproc)
+		goto err_bad_proc;
+	rqstp->rq_procinfo = procp = &versp->vs_proc[rqstp->rq_proc];
+	if (!procp)
+		goto err_bad_proc;
+
+	/* Initialize storage for argp and resp */
+	memset(rqstp->rq_argp, 0, procp->pc_argsize);
+	memset(rqstp->rq_resp, 0, procp->pc_ressize);
+
+	/* un-reserve some of the out-queue now that we have a
+	 * better idea of reply size
+	 */
+	if (procp->pc_xdrressize)
+		svc_reserve_auth(rqstp, procp->pc_xdrressize<<2);
+
+	/* Bump per-procedure stats counter */
+	versp->vs_count[rqstp->rq_proc]++;
+
+	ret->dispatch = versp->vs_dispatch;
+	return rpc_success;
+err_bad_vers:
+	ret->mismatch.lovers = progp->pg_lovers;
+	ret->mismatch.hivers = progp->pg_hivers;
+	return rpc_prog_mismatch;
+err_bad_proc:
+	return rpc_proc_unavail;
+}
+EXPORT_SYMBOL_GPL(svc_generic_init_request);
+
 /*
  * Common routine for processing the RPC request.
  */
@@ -1167,11 +1226,11 @@ static int
 svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 {
 	struct svc_program	*progp;
-	const struct svc_version *versp = NULL;	/* compiler food */
 	const struct svc_procedure *procp = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
+	struct svc_process_info process;
 	__be32			*statp;
-	u32			prog, vers, proc;
+	u32			prog, vers;
 	__be32			auth_stat, rpc_stat;
 	int			auth_res;
 	__be32			*reply_statp;
@@ -1203,8 +1262,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	svc_putnl(resv, 0);		/* ACCEPT */
 
 	rqstp->rq_prog = prog = svc_getnl(argv);	/* program number */
-	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
-	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */
+	rqstp->rq_vers = svc_getnl(argv);	/* version number */
+	rqstp->rq_proc = svc_getnl(argv);	/* procedure number */
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next)
 		if (prog == progp->pg_prog)
@@ -1242,29 +1301,22 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	if (progp == NULL)
 		goto err_bad_prog;
 
-	if (vers >= progp->pg_nvers ||
-	  !(versp = progp->pg_vers[vers]))
-		goto err_bad_vers;
-
-	/*
-	 * Some protocol versions (namely NFSv4) require some form of
-	 * congestion control.  (See RFC 7530 section 3.1 paragraph 2)
-	 * In other words, UDP is not allowed. We mark those when setting
-	 * up the svc_xprt, and verify that here.
-	 *
-	 * The spec is not very clear about what error should be returned
-	 * when someone tries to access a server that is listening on UDP
-	 * for lower versions. RPC_PROG_MISMATCH seems to be the closest
-	 * fit.
-	 */
-	if (versp->vs_need_cong_ctrl && rqstp->rq_xprt &&
-	    !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
+	rpc_stat = progp->pg_init_request(rqstp, progp, &process);
+	switch (rpc_stat) {
+	case rpc_success:
+		break;
+	case rpc_prog_unavail:
+		goto err_bad_prog;
+	case rpc_prog_mismatch:
 		goto err_bad_vers;
+	case rpc_proc_unavail:
+		goto err_bad_proc;
+	}
 
-	procp = versp->vs_proc + proc;
-	if (proc >= versp->vs_nproc || !procp->pc_func)
+	procp = rqstp->rq_procinfo;
+	/* Should this check go into the dispatcher? */
+	if (!procp || !procp->pc_func)
 		goto err_bad_proc;
-	rqstp->rq_procinfo = procp;
 
 	/* Syntactic check complete */
 	serv->sv_stats->rpccnt++;
@@ -1274,21 +1326,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	statp = resv->iov_base +resv->iov_len;
 	svc_putnl(resv, RPC_SUCCESS);
 
-	/* Bump per-procedure stats counter */
-	versp->vs_count[proc]++;
-
-	/* Initialize storage for argp and resp */
-	memset(rqstp->rq_argp, 0, procp->pc_argsize);
-	memset(rqstp->rq_resp, 0, procp->pc_ressize);
-
-	/* un-reserve some of the out-queue now that we have a
-	 * better idea of reply size
-	 */
-	if (procp->pc_xdrressize)
-		svc_reserve_auth(rqstp, procp->pc_xdrressize<<2);
-
 	/* Call the function that processes the request. */
-	if (!versp->vs_dispatch) {
+	if (!process.dispatch) {
 		/*
 		 * Decode arguments
 		 * XXX: why do we ignore the return value?
@@ -1317,7 +1356,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		}
 	} else {
 		dprintk("svc: calling dispatcher\n");
-		if (!versp->vs_dispatch(rqstp, statp)) {
+		if (!process.dispatch(rqstp, statp)) {
 			/* Release reply info */
 			if (procp->pc_release)
 				procp->pc_release(rqstp);
@@ -1386,16 +1425,16 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 
 err_bad_vers:
 	svc_printk(rqstp, "unknown version (%d for prog %d, %s)\n",
-		       vers, prog, progp->pg_name);
+		       rqstp->rq_vers, rqstp->rq_prog, progp->pg_name);
 
 	serv->sv_stats->rpcbadfmt++;
 	svc_putnl(resv, RPC_PROG_MISMATCH);
-	svc_putnl(resv, progp->pg_lovers);
-	svc_putnl(resv, progp->pg_hivers);
+	svc_putnl(resv, process.mismatch.lovers);
+	svc_putnl(resv, process.mismatch.hivers);
 	goto sendit;
 
 err_bad_proc:
-	svc_printk(rqstp, "unknown procedure (%d)\n", proc);
+	svc_printk(rqstp, "unknown procedure (%d)\n", rqstp->rq_proc);
 
 	serv->sv_stats->rpcbadfmt++;
 	svc_putnl(resv, RPC_PROC_UNAVAIL);
-- 
2.20.1

