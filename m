Return-Path: <SRS0=NyTm=QX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C50D7C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Feb 2019 00:38:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 98F73222A1
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Feb 2019 00:38:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728174AbfBPAiv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 19:38:51 -0500
Received: from out30-56.freemail.mail.aliyun.com ([115.124.30.56]:59812 "EHLO
        out30-56.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726145AbfBPAiv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2019 19:38:51 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R821e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TKBxoFw_1550277520;
Received: from localhost(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0TKBxoFw_1550277520)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 16 Feb 2019 08:38:49 +0800
From:   zhangliguang <zhangliguang@linux.alibaba.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     zhangliguang@linux.alibaba.com, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix typo in comments of nfs_readdir_alloc_pages()
Date:   Sat, 16 Feb 2019 08:38:40 +0800
Message-Id: <1550277520-124666-1-git-send-email-zhangliguang@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This fixes the typo in comments of nfs_readdir_alloc_pages().
Because nfs_readdir_large_page and nfs_readdir_free_pagearray had been
renamed.

Signed-off-by: Liguang Zhang <zhangliguang@linux.alibaba.com>
---
 fs/nfs/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6bf4471..051c173 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -574,8 +574,8 @@ void nfs_readdir_free_pages(struct page **pages, unsigned int npages)
 }
 
 /*
- * nfs_readdir_large_page will allocate pages that must be freed with a call
- * to nfs_readdir_free_pagearray
+ * nfs_readdir_alloc_pages() will allocate pages that must be freed with a call
+ * to nfs_readdir_free_pages()
  */
 static
 int nfs_readdir_alloc_pages(struct page **pages, unsigned int npages)
-- 
1.8.3.1

