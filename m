Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 429C3C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF7FC2084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iMSDcIKv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726487AbfDIPsb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 11:48:31 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:37269 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726372AbfDIPsb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 11:48:31 -0400
Received: by mail-it1-f195.google.com with SMTP id u65so5702222itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 08:48:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SxIy68Uq5brnTn9OGyRPhtrdRMbTKy5uHQ92/MmTbsw=;
        b=iMSDcIKvFVNRQixat6a0PqY2WWmQ2ZcEWAtXYJRFKfmHkWXvaR1CrwfVY+iXQ2A0GW
         33wAFdR8mipX9gbRWevxgGcT4L/yzF+036XDpxLofFxCmHOmdVhXjZ7PfWAhXwbAXcl9
         pDdA8fgED9jYmngTO7OeUSKa2paQAzA54afMMLHjaD3INv81vgkT3T6eJGBSkQwsAzXc
         XAo6rjyCNSOA9J8GtDQ8TtDZpW2u+iXXCw6qftxU0WHWFJ1sGWX05V877hEixIsOjuxZ
         s7+1N5EkFgDSThZ30vMXW4Ax+snoENH5QnCZ4nsqnFKvrXkTpNqPNewTgvsXNNySoTai
         G8PA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=SxIy68Uq5brnTn9OGyRPhtrdRMbTKy5uHQ92/MmTbsw=;
        b=UfGx6yBKu7BNUZ+RQxE5/gdWg2SAzZ54nTcdzf8Qwr5XullNQUSTuSViuprNMV/rKU
         18SocMwpekzO5lAdOiTuvsq3zvx3nsylsNr0/E0kgELcvi/YT8Qdkteuw8cPEpEQjSTn
         Z/mVyYytC8AqufsjwzRa6o1xDjldH6UxIp6C+fqn7zYRuKcsHIQzGjNCNMkWT/praWNR
         vtpUjUGmuR58mrRpS2qdnfZrLS/iocQDrmRl6LDwEQQEMC88N88NyoVADbHCvmehWVYq
         5ue09veMDBnKdQ2X6MQgnId1g3MNmYnEjexahPGgdbDKdACw39fycpewJxzVO5j8R4+Y
         tjOg==
X-Gm-Message-State: APjAAAU+UBKGJ3D1raGPY20JKrWPX9Bxa1+F+TflKzR6RhWLZC9wYV2l
        1KAVPcOzhiI09xFXXKc7/Q==
X-Google-Smtp-Source: APXvYqzBtU+0jd6tyNVZQC77+jykwYvsUJKc1Em8EOzvna9ZVAYSPIQ2BLzaaKf8oUdIDS+oEKwPNg==
X-Received: by 2002:a02:6f55:: with SMTP id b21mr26815413jae.30.1554824909772;
        Tue, 09 Apr 2019 08:48:29 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 62sm7026910itx.41.2019.04.09.08.48.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 08:48:28 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/6] SUNRPC: Add a callback to initialise server requests
Date:   Tue,  9 Apr 2019 11:46:15 -0400
Message-Id: <20190409154619.33615-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409154619.33615-2-trond.myklebust@hammerspace.com>
References: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
 <20190409154619.33615-2-trond.myklebust@hammerspace.com>
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
 include/linux/sunrpc/svc.h |  16 ++++++
 net/sunrpc/svc.c           | 113 +++++++++++++++++++++++++------------
 5 files changed, 97 insertions(+), 38 deletions(-)

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
index 3d5dd6b86652..69f3b9e015ce 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1160,6 +1160,59 @@ svc_get_autherr(struct svc_rqst *rqstp, __be32 *statp)
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
@@ -1167,11 +1220,11 @@ static int
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
@@ -1203,8 +1256,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	svc_putnl(resv, 0);		/* ACCEPT */
 
 	rqstp->rq_prog = prog = svc_getnl(argv);	/* program number */
-	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
-	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */
+	rqstp->rq_vers = svc_getnl(argv);	/* version number */
+	rqstp->rq_proc = svc_getnl(argv);	/* procedure number */
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next)
 		if (prog == progp->pg_prog)
@@ -1242,29 +1295,22 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
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
@@ -1274,13 +1320,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	statp = resv->iov_base +resv->iov_len;
 	svc_putnl(resv, RPC_SUCCESS);
 
-	/* Bump per-procedure stats counter */
-	versp->vs_count[proc]++;
-
-	/* Initialize storage for argp and resp */
-	memset(rqstp->rq_argp, 0, procp->pc_argsize);
-	memset(rqstp->rq_resp, 0, procp->pc_ressize);
-
 	/* un-reserve some of the out-queue now that we have a
 	 * better idea of reply size
 	 */
@@ -1288,7 +1327,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		svc_reserve_auth(rqstp, procp->pc_xdrressize<<2);
 
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

