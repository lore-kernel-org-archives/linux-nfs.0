Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:4453 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751375AbdCWI40 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Mar 2017 04:56:26 -0400
From: Jason Yan <yanaijie@huawei.com>
To: <bfields@fieldses.org>, <jlayton@poochiereds.net>,
        <linux-nfs@vger.kernel.org>
CC: <miaoxie@huawei.com>, <zhaohongjiang@huawei.com>,
        Jason Yan <yanaijie@huawei.com>
Subject: [PATCH] nfsd: make strdup_if_nonnull static
Date: Thu, 23 Mar 2017 16:57:36 +0800
Message-ID: <1490259456-15858-1-git-send-email-yanaijie@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes the following sparse warning:

fs/nfsd/nfs4state.c:1915:5: warning: symbol 'strdup_if_nonnull' was not
declared. Should it be static?

Signed-off-by: Jason Yan <yanaijie@huawei.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9ef50a..59a9e30 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1912,7 +1912,7 @@ static void copy_clid(struct nfs4_client *target, struct nfs4_client *source)
 	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
 }
 
-int strdup_if_nonnull(char **target, char *source)
+static int strdup_if_nonnull(char **target, char *source)
 {
 	if (source) {
 		*target = kstrdup(source, GFP_KERNEL);
-- 
2.5.0

