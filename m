Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D380C5519F
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Nov 2020 08:28:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 16CCC206CA
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Nov 2020 08:28:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725875AbgKYI2h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Nov 2020 03:28:37 -0500
Received: from szxga05-in.huawei.com ([45.249.212.191]:8583 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725287AbgKYI2h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2020 03:28:37 -0500
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.58])
        by szxga05-in.huawei.com (SkyGuard) with ESMTP id 4CgvCm6WDTzLv7N;
        Wed, 25 Nov 2020 16:28:04 +0800 (CST)
Received: from huawei.com (10.175.104.82) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.487.0; Wed, 25 Nov 2020
 16:28:30 +0800
From:   Huang Guobin <huangguobin4@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <trond.myklebust@primarydata.com>,
        <richard.sharpe@primarydata.com>, <dros@primarydata.com>,
        <jeff.layton@primarydata.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] nfsd: Fix error return code in nfsd_file_cache_init()
Date:   Wed, 25 Nov 2020 03:39:33 -0500
Message-ID: <20201125083933.2386059-1-huangguobin4@huawei.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.104.82]
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix to return PTR_ERR() error code from the error handling case instead of
0 in function nfsd_file_cache_init(), as done elsewhere in this function.

Fixes: 65294c1f2c5e7("nfsd: add a new struct file caching facility to nfsd")
Signed-off-by: Huang Guobin <huangguobin4@huawei.com>
---
 fs/nfsd/filecache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index c8b9d2667ee6..a8a5b555f08b 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -686,6 +686,7 @@ nfsd_file_cache_init(void)
 		pr_err("nfsd: unable to create fsnotify group: %ld\n",
 			PTR_ERR(nfsd_file_fsnotify_group));
 		nfsd_file_fsnotify_group = NULL;
+		ret = PTR_ERR(nfsd_file_fsnotify_group);
 		goto out_notifier;
 	}
 
-- 
2.22.0

