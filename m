Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E63C1C433ED
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Apr 2021 03:47:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 99656613B3
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Apr 2021 03:47:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242347AbhDFDr2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Apr 2021 23:47:28 -0400
Received: from out30-130.freemail.mail.aliyun.com ([115.124.30.130]:53289 "EHLO
        out30-130.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S233639AbhDFDr2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Apr 2021 23:47:28 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R371e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=jiapeng.chong@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0UUea06T_1617680821;
Received: from j63c13417.sqa.eu95.tbsite.net(mailfrom:jiapeng.chong@linux.alibaba.com fp:SMTPD_---0UUea06T_1617680821)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 06 Apr 2021 11:47:19 +0800
From:   Jiapeng Chong <jiapeng.chong@linux.alibaba.com>
To:     bfields@fieldses.org
Cc:     chuck.lever@oracle.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, davem@davemloft.net, kuba@kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jiapeng Chong <jiapeng.chong@linux.alibaba.com>
Subject: [PATCH] sunrpc: Remove unused function ip_map_lookup
Date:   Tue,  6 Apr 2021 11:46:59 +0800
Message-Id: <1617680819-9058-1-git-send-email-jiapeng.chong@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix the following clang warnings:

net/sunrpc/svcauth_unix.c:306:30: warning: unused function
'ip_map_lookup' [-Wunused-function].

Reported-by: Abaci Robot <abaci@linux.alibaba.com>
Signed-off-by: Jiapeng Chong <jiapeng.chong@linux.alibaba.com>
---
 net/sunrpc/svcauth_unix.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 97c0bdd..35b7966 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -303,15 +303,6 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 		return NULL;
 }
 
-static inline struct ip_map *ip_map_lookup(struct net *net, char *class,
-		struct in6_addr *addr)
-{
-	struct sunrpc_net *sn;
-
-	sn = net_generic(net, sunrpc_net_id);
-	return __ip_map_lookup(sn->ip_map_cache, class, addr);
-}
-
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 		struct unix_domain *udom, time64_t expiry)
 {
-- 
1.8.3.1

