Return-Path: <SRS0=/o/9=ZI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3206C432C3
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Nov 2019 07:00:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B270720700
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Nov 2019 07:00:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726025AbfKPHAX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Nov 2019 02:00:23 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:6682 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725971AbfKPHAW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Nov 2019 02:00:22 -0500
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 723AFBAB6E498210B564;
        Sat, 16 Nov 2019 15:00:19 +0800 (CST)
Received: from localhost.localdomain (10.90.53.225) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.439.0; Sat, 16 Nov 2019 15:00:12 +0800
From:   Chen Wandun <chenwandun@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC:     <chenwandun@huawei.com>
Subject: [PATCH] NFS: remove redundant null pointer check before kfree
Date:   Sat, 16 Nov 2019 15:07:33 +0800
Message-ID: <1573888053-2358-1-git-send-email-chenwandun@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

kfree has taken null pointer check into account. so it is safe
to remove the unnecessary check.

Signed-off-by: Chen Wandun <chenwandun@huawei.com>
---
 fs/nfs/sysfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/sysfs.c b/fs/nfs/sysfs.c
index 4f3390b..c489496 100644
--- a/fs/nfs/sysfs.c
+++ b/fs/nfs/sysfs.c
@@ -121,8 +121,7 @@ static void nfs_netns_client_release(struct kobject *kobj)
 			struct nfs_netns_client,
 			kobject);
 
-	if (c->identifier)
-		kfree(c->identifier);
+	kfree(c->identifier);
 	kfree(c);
 }
 
-- 
2.7.4

