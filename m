Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1C27C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Mar 2021 14:32:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C5CBF64F53
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Mar 2021 14:32:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229941AbhCSObf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Mar 2021 10:31:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:35388 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229936AbhCSObS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Mar 2021 10:31:18 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 51D4464F1F;
        Fri, 19 Mar 2021 14:31:18 +0000 (UTC)
Subject: [PATCH v1 1/6] svcrdma: RPCDBG_FACILITY is no longer used
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Fri, 19 Mar 2021 10:31:17 -0400
Message-ID: <161616427748.173092.4718360961541077449.stgit@klimt.1015granger.net>
In-Reply-To: <161616413550.173092.13403865110684484953.stgit@klimt.1015granger.net>
References: <161616413550.173092.13403865110684484953.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 --
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |    2 --
 2 files changed, 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 7d34290e2ff8..215d2adadbdd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -107,8 +107,6 @@
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
 
-#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
-
 static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc);
 
 static inline struct svc_rdma_recv_ctxt *
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 52c759a8543e..e6fab5dd20d0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -111,8 +111,6 @@
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
 
-#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
-
 static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc);
 
 static inline struct svc_rdma_send_ctxt *


