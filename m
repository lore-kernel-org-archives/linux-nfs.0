Return-Path: <SRS0=VKO3=OY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB8FBC43387
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Dec 2018 06:42:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8AB27206A2
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Dec 2018 06:42:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728675AbeLOGmO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 15 Dec 2018 01:42:14 -0500
Received: from szxga05-in.huawei.com ([45.249.212.191]:16139 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727757AbeLOGmO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 15 Dec 2018 01:42:14 -0500
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 0D671DB813E4;
        Sat, 15 Dec 2018 14:42:11 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Sat, 15 Dec 2018
 14:42:05 +0800
From:   zhengbin <zhengbin13@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <bfields@fieldses.org>, <jlayton@kernel.org>,
        <davem@davemloft.net>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>
CC:     <houtao1@huawei.com>, <zhaohongjiang@huawei.com>
Subject: [PATCH] SUNRPC: fix comment style
Date:   Sat, 15 Dec 2018 14:45:16 +0800
Message-ID: <1544856316-110134-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If there is only one line comment, we should use /* ... */

Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 net/sunrpc/xprt.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce92700..68a80eb 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1875,9 +1875,7 @@ static void xprt_destroy_cb(struct work_struct *work)
 	rpc_destroy_wait_queue(&xprt->sending);
 	rpc_destroy_wait_queue(&xprt->backlog);
 	kfree(xprt->servername);
-	/*
-	 * Tear down transport state and free the rpc_xprt
-	 */
+	/* Tear down transport state and free the rpc_xprt */
 	xprt->ops->destroy(xprt);
 }

@@ -1890,9 +1888,7 @@ static void xprt_destroy(struct rpc_xprt *xprt)
 {
 	dprintk("RPC:       destroying transport %p\n", xprt);

-	/*
-	 * Exclude transport connect/disconnect handlers and autoclose
-	 */
+	/* Exclude transport connect/disconnect handlers and autoclose */
 	wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_UNINTERRUPTIBLE);

 	del_timer_sync(&xprt->timer);
--
2.7.4

