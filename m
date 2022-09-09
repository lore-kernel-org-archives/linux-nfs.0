Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7FCAECAAD3
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Sep 2022 06:46:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229940AbiIIGqp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Sep 2022 02:46:45 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59904 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229925AbiIIGqn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2022 02:46:43 -0400
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0F295114A66;
        Thu,  8 Sep 2022 23:46:43 -0700 (PDT)
Received: from kwepemi500012.china.huawei.com (unknown [172.30.72.54])
        by szxga01-in.huawei.com (SkyGuard) with ESMTP id 4MP5yx5zDQzlVvG;
        Fri,  9 Sep 2022 14:42:49 +0800 (CST)
Received: from cgs.huawei.com (10.244.148.83) by
 kwepemi500012.china.huawei.com (7.221.188.12) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.24; Fri, 9 Sep 2022 14:46:40 +0800
From:   Gaosheng Cui <cuigaosheng1@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>,
        <Trond.Myklebust@netapp.com>, <cuigaosheng1@huawei.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] NFSv4: remove nfs4_renewd_prepare_shutdown() declaration
Date:   Fri, 9 Sep 2022 14:46:40 +0800
Message-ID: <20220909064640.1152061-1-cuigaosheng1@huawei.com>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.244.148.83]
X-ClientProxiedBy: dggems702-chm.china.huawei.com (10.3.19.179) To
 kwepemi500012.china.huawei.com (7.221.188.12)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfs4_renewd_prepare_shutdown() has been removed since
commit 3050141bae57 ("NFSv4: Kill nfs4_renewd_prepare_shutdown()"),
so remove it.

Signed-off-by: Gaosheng Cui <cuigaosheng1@huawei.com>
---
 fs/nfs/nfs4_fs.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 79df6e83881b..400a71e75238 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -459,7 +459,6 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *);
 
 /* nfs4renewd.c */
 extern void nfs4_schedule_state_renewal(struct nfs_client *);
-extern void nfs4_renewd_prepare_shutdown(struct nfs_server *);
 extern void nfs4_kill_renewd(struct nfs_client *);
 extern void nfs4_renew_state(struct work_struct *);
 extern void nfs4_set_lease_period(struct nfs_client *clp, unsigned long lease);
-- 
2.25.1

