Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC54CC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 10:33:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A0A93206C2
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 10:33:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389365AbfAPKdE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 05:33:04 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:2176 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1731929AbfAPKdB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Jan 2019 05:33:01 -0500
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id E78A851A9D24C39C24EA;
        Wed, 16 Jan 2019 18:32:48 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS401-HUB.china.huawei.com (10.3.19.201) with Microsoft SMTP Server id
 14.3.408.0; Wed, 16 Jan 2019 18:32:38 +0800
From:   Wei Yongjun <weiyongjun1@huawei.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Jeff Layton" <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC:     Wei Yongjun <weiyongjun1@huawei.com>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
Subject: [PATCH net-next] xprtrdma: Fix error return code in rpcrdma_buffer_create()
Date:   Wed, 16 Jan 2019 10:38:44 +0000
Message-ID: <1547635124-62243-1-git-send-email-weiyongjun1@huawei.com>
X-Mailer: git-send-email 1.8.3.1
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix to return a negative error code -ENOMEM from the error handling
case instead of 0, as done elsewhere in this function.

Fixes: 6d2d0ee27c7a ("xprtrdma: Replace rpcrdma_receive_wq with a per-xprt workqueue")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/sunrpc/xprtrdma/verbs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7749a2b..3dde058 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1113,8 +1113,10 @@ struct rpcrdma_req *
 						WQ_MEM_RECLAIM | WQ_HIGHPRI,
 						0,
 			r_xprt->rx_xprt.address_strings[RPC_DISPLAY_ADDR]);
-	if (!buf->rb_completion_wq)
+	if (!buf->rb_completion_wq) {
+		rc = -ENOMEM;
 		goto out;
+	}
 
 	return 0;
 out:



