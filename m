Return-Path: <SRS0=2rvl=36=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C104FC352A4
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Feb 2020 07:25:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 96D1220870
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Feb 2020 07:25:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726231AbgBJHZB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Feb 2020 02:25:01 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:47342 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726118AbgBJHZB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Feb 2020 02:25:01 -0500
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id BDF7FB350DFE91E5EC80;
        Mon, 10 Feb 2020 15:24:48 +0800 (CST)
Received: from euler.huawei.com (10.175.104.193) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.439.0; Mon, 10 Feb 2020 15:24:40 +0800
From:   Chen Wandun <chenwandun@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <trond.myklebust@hammerspace.com>, <Anna.Schumaker@Netapp.com>,
        <davem@davemloft.net>, <kuba@kernel.org>,
        <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC:     <chenwandun@huawei.com>
Subject: [PATCH next] xprtrdma: make the symbol 'xprt_rdma_slot_table_entries' static
Date:   Mon, 10 Feb 2020 15:39:27 +0800
Message-ID: <20200210073927.8769-1-chenwandun@huawei.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.104.193]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix the following sparse warning:
net/sunrpc/xprtrdma/transport.c:71:14: warning: symbol 'xprt_rdma_slot_table_entries' was not declared. Should it be static?

Fixes: 86c4ccd9b92b ("xprtrdma: Eliminate struct rpcrdma_create_data_internal")
Signed-off-by: Chen Wandun <chenwandun@huawei.com>
---
 net/sunrpc/xprtrdma/transport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 3cfeba68ee9a..14c2a852d2a1 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -68,7 +68,7 @@
  * tunables
  */
 
-unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
+static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
 unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRWR;
-- 
2.17.1

