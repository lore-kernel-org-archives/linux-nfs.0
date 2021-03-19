Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFE8FC433E6
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Mar 2021 14:32:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 91B4364F18
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Mar 2021 14:32:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229936AbhCSObg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Mar 2021 10:31:36 -0400
Received: from mail.kernel.org ([198.145.29.99]:35402 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229965AbhCSObY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Mar 2021 10:31:24 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 7DC4D64F18;
        Fri, 19 Mar 2021 14:31:24 +0000 (UTC)
Subject: [PATCH v1 2/6] svcrdma: Provide an explanatory comment in CMA event
 handler
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Fri, 19 Mar 2021 10:31:23 -0400
Message-ID: <161616428372.173092.10583540525824083447.stgit@klimt.1015granger.net>
In-Reply-To: <161616413550.173092.13403865110684484953.stgit@klimt.1015granger.net>
References: <161616413550.173092.13403865110684484953.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: explain why svc_xprt_enqueue() is invoked in the event
handler even though no xpt_flags bits are toggled here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index c895f80df659..046a07da5cf9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -279,6 +279,9 @@ static int svc_rdma_cma_handler(struct rdma_cm_id *cma_id,
 	switch (event->event) {
 	case RDMA_CM_EVENT_ESTABLISHED:
 		clear_bit(RDMAXPRT_CONN_PENDING, &rdma->sc_flags);
+
+		/* Handle any requests that were received while
+		 * CONN_PENDING was set. */
 		svc_xprt_enqueue(xprt);
 		break;
 	case RDMA_CM_EVENT_DISCONNECTED:


