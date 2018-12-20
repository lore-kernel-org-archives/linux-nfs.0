Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA355C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 09:49:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7FD0B20811
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 09:49:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729447AbeLTJtr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 04:49:47 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:16614 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727972AbeLTJtq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 04:49:46 -0500
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id A625CB4F37898;
        Thu, 20 Dec 2018 17:49:42 +0800 (CST)
Received: from localhost (10.177.31.96) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.408.0; Thu, 20 Dec 2018
 17:49:34 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     <davem@davemloft.net>, <bfields@fieldses.org>,
        <jlayton@kernel.org>, <trond.myklebust@hammerspace.com>,
        <anna.schumaker@netapp.com>
CC:     <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <jgg@ziepe.ca>,
        <chuck.lever@oracle.com>, <bvanassche@acm.org>,
        YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH net-next] svcrdma: Fix an uninitialized variable false warning
Date:   Thu, 20 Dec 2018 17:49:21 +0800
Message-ID: <20181220094921.3396-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.10.2.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.177.31.96]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

smatch warning this:
net/sunrpc/xprtrdma/svc_rdma_rw.c:351 svc_rdma_post_chunk_ctxt() error: uninitialized symbol 'bad_wr'
net/sunrpc/xprtrdma/verbs.c:1569 rpcrdma_post_recvs() error: uninitialized symbol 'bad_wr'

'bad_wr' is initialized in ib_post_send. But smatch
doesn't know that and warns this.

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c | 2 +-
 net/sunrpc/xprtrdma/verbs.c       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index dc19517..0954b25 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -308,7 +308,7 @@ static int svc_rdma_post_chunk_ctxt(struct svc_rdma_chunk_ctxt *cc)
 	struct svcxprt_rdma *rdma = cc->cc_rdma;
 	struct svc_xprt *xprt = &rdma->sc_xprt;
 	struct ib_send_wr *first_wr;
-	const struct ib_send_wr *bad_wr;
+	const struct ib_send_wr *bad_wr = NULL;
 	struct list_head *tmp;
 	struct ib_cqe *cqe;
 	int ret;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3ddba94..37be70f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1518,7 +1518,7 @@ void
 rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct ib_recv_wr *wr, *bad_wr;
+	struct ib_recv_wr *wr, *bad_wr = NULL;
 	int needed, count, rc;
 
 	rc = 0;
-- 
2.7.0


