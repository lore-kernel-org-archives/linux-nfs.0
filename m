Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AEB1C433F5
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Mar 2022 02:18:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1354572AbiCYCUH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Mar 2022 22:20:07 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47456 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1350834AbiCYCUH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2022 22:20:07 -0400
Received: from mail.meizu.com (edge07.meizu.com [112.91.151.210])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A5E633668F;
        Thu, 24 Mar 2022 19:18:32 -0700 (PDT)
Received: from IT-EXMB-1-125.meizu.com (172.16.1.125) by mz-mail11.meizu.com
 (172.16.1.15) with Microsoft SMTP Server (TLS) id 14.3.487.0; Fri, 25 Mar
 2022 10:18:25 +0800
Received: from meizu.meizu.com (172.16.137.70) by IT-EXMB-1-125.meizu.com
 (172.16.1.125) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2308.14; Fri, 25 Mar
 2022 10:18:24 +0800
From:   Haowen Bai <baihaowen@meizu.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>,
        <chuck.lever@oracle.com>, <davem@davemloft.net>, <kuba@kernel.org>,
        <pabeni@redhat.com>
CC:     <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Haowen Bai <baihaowen@meizu.com>
Subject: [PATCH V2] SUNRPC: Increase size of servername string
Date:   Fri, 25 Mar 2022 10:18:22 +0800
Message-ID: <1648174702-461-1-git-send-email-baihaowen@meizu.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [172.16.137.70]
X-ClientProxiedBy: IT-EXMB-1-125.meizu.com (172.16.1.125) To
 IT-EXMB-1-125.meizu.com (172.16.1.125)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch will fix the warning from smatch:

net/sunrpc/clnt.c:562 rpc_create() error: snprintf() chops off
the last chars of 'sun->sun_path': 108 vs 48

Signed-off-by: Haowen Bai <baihaowen@meizu.com>
---
V1->V2: it would be much nicer to use UNIX_PATH_MAX
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c83fe61..6e0209e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -526,7 +526,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.servername = args->servername,
 		.bc_xprt = args->bc_xprt,
 	};
-	char servername[48];
+	char servername[UNIX_PATH_MAX];
 	struct rpc_clnt *clnt;
 	int i;
 
-- 
2.7.4

