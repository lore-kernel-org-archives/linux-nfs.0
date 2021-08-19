Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4035C4338F
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Aug 2021 12:34:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C1C6E60551
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Aug 2021 12:34:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232676AbhHSMex (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 Aug 2021 08:34:53 -0400
Received: from mail.kernel.org ([198.145.29.99]:48474 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230505AbhHSMew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Aug 2021 08:34:52 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 8EE5660551;
        Thu, 19 Aug 2021 12:34:16 +0000 (UTC)
Subject: [PATCH v1] svcrdma: xpt_bc_xprt is already clear in __svc_rdma_free()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Thu, 19 Aug 2021 08:34:15 -0400
Message-ID: <162937645573.2555.8321367440838840185.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

svc_xprt_free() already "puts" the bc_xprt before calling the
transport's "free" method. No need to do it twice.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index d1faa522c3dd..94b20fb47135 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -545,7 +545,6 @@ static void __svc_rdma_free(struct work_struct *work)
 {
 	struct svcxprt_rdma *rdma =
 		container_of(work, struct svcxprt_rdma, sc_work);
-	struct svc_xprt *xprt = &rdma->sc_xprt;
 
 	/* This blocks until the Completion Queues are empty */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
@@ -553,12 +552,6 @@ static void __svc_rdma_free(struct work_struct *work)
 
 	svc_rdma_flush_recv_queues(rdma);
 
-	/* Final put of backchannel client transport */
-	if (xprt->xpt_bc_xprt) {
-		xprt_put(xprt->xpt_bc_xprt);
-		xprt->xpt_bc_xprt = NULL;
-	}
-
 	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_send_ctxts_destroy(rdma);
 	svc_rdma_recv_ctxts_destroy(rdma);


