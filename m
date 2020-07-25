Return-Path: <SRS0=lN1T=BE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5522DC433E4
	for <linux-nfs@archiver.kernel.org>; Sat, 25 Jul 2020 08:53:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3566C206D8
	for <linux-nfs@archiver.kernel.org>; Sat, 25 Jul 2020 08:53:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726701AbgGYIxZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 25 Jul 2020 04:53:25 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:56608 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726613AbgGYIxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 25 Jul 2020 04:53:25 -0400
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 077BA79EE19677F73A12;
        Sat, 25 Jul 2020 16:53:22 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS404-HUB.china.huawei.com (10.3.19.204) with Microsoft SMTP Server id
 14.3.487.0; Sat, 25 Jul 2020 16:53:17 +0800
From:   Qinglang Miao <miaoqinglang@huawei.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH -next] nfsd: use DEFINE_SPINLOCK() for spinlock
Date:   Sat, 25 Jul 2020 16:56:42 +0800
Message-ID: <20200725085642.98356-1-miaoqinglang@huawei.com>
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

nfsd_drc_lock can be initialized automatically with
DEFINE_SPINLOCK() rather than explicitly calling spin_lock_init().

Signed-off-by: Qinglang Miao <miaoqinglang@huawei.com>
---
 fs/nfsd/nfssvc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b603dfcdd..20f0a27fe 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -88,7 +88,7 @@ DEFINE_MUTEX(nfsd_mutex);
  * version 4.1 DRC caches.
  * nfsd_drc_pages_used tracks the current version 4.1 DRC memory usage.
  */
-spinlock_t	nfsd_drc_lock;
+DEFINE_SPINLOCK(nfsd_drc_lock);
 unsigned long	nfsd_drc_max_mem;
 unsigned long	nfsd_drc_mem_used;
 
@@ -568,7 +568,6 @@ static void set_max_drc(void)
 	nfsd_drc_max_mem = (nr_free_buffer_pages()
 					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
 	nfsd_drc_mem_used = 0;
-	spin_lock_init(&nfsd_drc_lock);
 	dprintk("%s nfsd_drc_max_mem %lu \n", __func__, nfsd_drc_max_mem);
 }
 
-- 
2.25.1

