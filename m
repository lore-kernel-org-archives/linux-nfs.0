Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 513FBC4332F
	for <linux-nfs@archiver.kernel.org>; Sun, 20 Nov 2022 06:29:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229454AbiKTG3z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 20 Nov 2022 01:29:55 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50572 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229446AbiKTG3y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Nov 2022 01:29:54 -0500
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com [45.249.212.189])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7751BA65BF
        for <linux-nfs@vger.kernel.org>; Sat, 19 Nov 2022 22:29:53 -0800 (PST)
Received: from dggpeml500023.china.huawei.com (unknown [172.30.72.57])
        by szxga03-in.huawei.com (SkyGuard) with ESMTP id 4NFLC31qVYzFqLm;
        Sun, 20 Nov 2022 14:26:39 +0800 (CST)
Received: from localhost.localdomain (10.175.101.6) by
 dggpeml500023.china.huawei.com (7.185.36.114) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.31; Sun, 20 Nov 2022 14:29:51 +0800
From:   Zhang Xiaoxu <zhangxiaoxu5@huawei.com>
To:     <linux-nfs@vger.kernel.org>, <trond.myklebust@hammerspace.com>,
        <anna@kernel.org>, <chuck.lever@oracle.com>, <jlayton@kernel.org>,
        <zhangxiaoxu5@huawei.com>
Subject: [PATCH v2] xprtrdma: Fix regbuf data not freed in rpcrdma_req_create()
Date:   Sun, 20 Nov 2022 15:34:29 +0800
Message-ID: <20221120073429.2581160-1-zhangxiaoxu5@huawei.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.101.6]
X-ClientProxiedBy: dggems706-chm.china.huawei.com (10.3.19.183) To
 dggpeml500023.china.huawei.com (7.185.36.114)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If rdma receive buffer allocate failed, should call rpcrdma_regbuf_free()
to free the send buffer, otherwise, the buffer data will be leaked.

Fixes: bb93a1ae2bf4 ("xprtrdma: Allocate req's regbufs at xprt create time")
Signed-off-by: Zhang Xiaoxu <zhangxiaoxu5@huawei.com>
---
 net/sunrpc/xprtrdma/verbs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 44b87e4274b4..b098fde373ab 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -831,7 +831,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
 	return req;
 
 out3:
-	kfree(req->rl_sendbuf);
+	rpcrdma_regbuf_free(req->rl_sendbuf);
 out2:
 	kfree(req);
 out1:
-- 
2.31.1

