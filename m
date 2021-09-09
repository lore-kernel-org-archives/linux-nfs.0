Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D309C433F5
	for <linux-nfs@archiver.kernel.org>; Thu,  9 Sep 2021 12:22:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 881146115B
	for <linux-nfs@archiver.kernel.org>; Thu,  9 Sep 2021 12:22:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1352632AbhIIMX1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 9 Sep 2021 08:23:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:56612 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1346629AbhIIMRH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Sep 2021 08:17:07 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 9A5EE61A7F;
        Thu,  9 Sep 2021 11:49:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1631188187;
        bh=41UfQEK4ce4MZ7sHLRplv66BOBkYxe3i9+V1wNuOllM=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=FWuXcEZSdS36SKM0TLvxeIIEl9/1l8PwtweKQoxdvGP3Cc471dOvrcNBVgLtdAZyO
         AsvjCZ0PqaCkSex9f+QLRTVO1bIflLPjIEEpL6B4/zFKoCKQkmW2IyjGd7F/XT8y6Y
         4MDCXhgfnA78rgLOjtRdT4NWUc89Vke4YUgRdosW5Q32iDiPHhLjlyELeSArXhP77P
         uEzCtD7aXeYY9oVMkbUWO96H4SEFq9jH+eXdbL4qBQS7lrhEoppOCFR1TNtXtlj3rc
         rYxl/mKq/6Q1AjMdq8E1TSyz18cgSFjzsZGjGijQv6Lc4Ztk507Pp7eF70c2coJgbQ
         Ks1+KqI1GixBw==
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 5.13 148/219] rpc: fix gss_svc_init cleanup on failure
Date:   Thu,  9 Sep 2021 07:45:24 -0400
Message-Id: <20210909114635.143983-148-sashal@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210909114635.143983-1-sashal@kernel.org>
References: <20210909114635.143983-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit 5a4753446253a427c0ff1e433b9c4933e5af207c ]

The failure case here should be rare, but it's obviously wrong.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 6dff64374bfe..e22f2d65457d 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1980,7 +1980,7 @@ gss_svc_init_net(struct net *net)
 		goto out2;
 	return 0;
 out2:
-	destroy_use_gss_proxy_proc_entry(net);
+	rsi_cache_destroy_net(net);
 out1:
 	rsc_cache_destroy_net(net);
 	return rv;
-- 
2.30.2

