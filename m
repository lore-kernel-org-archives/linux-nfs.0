Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92057C53210
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Jan 2023 17:07:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236458AbjABRHZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Jan 2023 12:07:25 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53532 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236372AbjABRHY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jan 2023 12:07:24 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CB72364DB
        for <linux-nfs@vger.kernel.org>; Mon,  2 Jan 2023 09:07:23 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 84D67B80D0D
        for <linux-nfs@vger.kernel.org>; Mon,  2 Jan 2023 17:07:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 30450C433EF
        for <linux-nfs@vger.kernel.org>; Mon,  2 Jan 2023 17:07:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1672679241;
        bh=tGO/UCE9nXunwvfeQenLbU9rlISYH3eHKgnY7pczsi0=;
        h=Subject:From:To:Date:In-Reply-To:References:From;
        b=N9WfaLBHMDX2fUFMykVT8dKqCyPbfBUp9ybvjvI5Q49u78vchhibBvEiNNSEZa53C
         GUSEJW5UMaltg7RsFnfIYeyO21swONw9VjkOjQ686kixuSDrKPFyEcdKPqy+kpdLqI
         nH2rvhdI6ZptqWg6wYpJ8B92tI/IROxrFcBlnHn2k0uH6J9oCnyii3mzl+B0aqImHm
         EaX81kxeInuHTujqcIRNCH1B9enkMTACSAmt18NwZg9UN8POPQxJT0jlByagO3lwdO
         RmSrRBifxcAR4w2eJm2jLG2qHDDEm3XTDaRYec0oMx2OjnGvNJB1CYBB52BbUq8652
         ejFK6cjodWdUw==
Subject: [PATCH v1 18/25] SUNRPC: Clean up svcauth_gss_accept's NULL procedure
 check
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 02 Jan 2023 12:07:20 -0500
Message-ID: <167267924008.112521.3942024545854941445.stgit@manet.1015granger.net>
In-Reply-To: <167267753484.112521.4826748148788735127.stgit@manet.1015granger.net>
References: <167267753484.112521.4826748148788735127.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Micro-optimizations:

1. The value of rqstp->rq_auth_stat is replaced no matter which
   arm of the switch is taken, so the initial assignment can be
   safely removed.

2. Avoid checking the value of gc->gc_proc twice in the I/O
   (RPC_GSS_PROC_DATA) path.

The cost is a little extra code redundancy.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 8362fc143754..363c25198547 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1608,17 +1608,19 @@ svcauth_gss_accept(struct svc_rqst *rqstp)
 	if (crlen != round_up_to_quad(gc->gc_ctx.len) + 5 * 4)
 		goto auth_err;
 
-	if ((gc->gc_proc != RPC_GSS_PROC_DATA) && (rqstp->rq_proc != 0))
-		goto auth_err;
-
 	svcxdr_init_decode(rqstp);
-	rqstp->rq_auth_stat = rpc_autherr_badverf;
+
 	switch (gc->gc_proc) {
 	case RPC_GSS_PROC_INIT:
 	case RPC_GSS_PROC_CONTINUE_INIT:
+		if (rqstp->rq_proc != 0)
+			goto auth_err;
 		return svcauth_gss_proc_init(rqstp, gc);
-	case RPC_GSS_PROC_DATA:
 	case RPC_GSS_PROC_DESTROY:
+		if (rqstp->rq_proc != 0)
+			goto auth_err;
+		fallthrough;
+	case RPC_GSS_PROC_DATA:
 		/* Look up the context, and check the verifier: */
 		rqstp->rq_auth_stat = rpcsec_gsserr_credproblem;
 		rsci = gss_svc_searchbyctx(sn->rsc_cache, &gc->gc_ctx);
@@ -1634,6 +1636,8 @@ svcauth_gss_accept(struct svc_rqst *rqstp)
 		}
 		break;
 	default:
+		if (rqstp->rq_proc != 0)
+			goto auth_err;
 		rqstp->rq_auth_stat = rpc_autherr_rejectedcred;
 		goto auth_err;
 	}


