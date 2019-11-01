Return-Path: <SRS0=Ln1C=YZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3B5ACA9ECF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Nov 2019 11:41:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8517E20656
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Nov 2019 11:41:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728996AbfKALll (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Nov 2019 07:41:41 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:44938 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726710AbfKALlk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Nov 2019 07:41:40 -0400
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 76BFF4D15B998DB7EA0E;
        Fri,  1 Nov 2019 19:41:38 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.439.0; Fri, 1 Nov 2019 19:41:28 +0800
From:   Mao Wenan <maowenan@huawei.com>
To:     <bfields@redhat.com>, <chuck.lever@oracle.com>,
        <trond.myklebust@primarydata.com>, <dros@primarydata.com>,
        <jeff.layton@primarydata.com>, <richard.sharpe@primarydata.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>, Mao Wenan <maowenan@huawei.com>
Subject: [PATCH -next] nfsd: Drop LIST_HEAD where the variable it declares is never used.
Date:   Fri, 1 Nov 2019 19:40:54 +0800
Message-ID: <20191101114054.50225-1-maowenan@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The declarations were introduced with the file, but the declared
variables were not used.

Fixes: 65294c1f2c5e ("nfsd: add a new struct file caching facility to nfsd")
Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 fs/nfsd/filecache.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index ef55e9b..32a9bf2 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -685,8 +685,6 @@ nfsd_file_cache_purge(struct net *net)
 void
 nfsd_file_cache_shutdown(void)
 {
-	LIST_HEAD(dispose);
-
 	set_bit(NFSD_FILE_SHUTDOWN, &nfsd_file_lru_flags);
 
 	lease_unregister_notifier(&nfsd_file_lease_notifier);
-- 
2.7.4

