Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A21F3C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 07:03:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 72BCB2171F
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 07:03:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728570AbfABHDL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 02:03:11 -0500
Received: from out30-131.freemail.mail.aliyun.com ([115.124.30.131]:59409 "EHLO
        out30-131.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727558AbfABHDL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 02:03:11 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04392;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0THInvh5_1546412554;
Received: from localhost(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0THInvh5_1546412554)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 02 Jan 2019 15:02:44 +0800
From:   zhangliguang <zhangliguang@linux.alibaba.com>
To:     linux-nfs@vger.kernel.org
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        shan.gavin@linux.alibaba.com
Subject: [PATCH] fs/nfs: Fix typo in comments of nfs_readdir_alloc_pages()
Date:   Wed,  2 Jan 2019 15:02:34 +0800
Message-Id: <1546412554-18275-1-git-send-email-zhangliguang@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This fixes the typo in comments of nfs_readdir_alloc_pages().

Signed-off-by: Liguang Zhang <zhangliguang@linux.alibaba.com>
---
 fs/nfs/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 71b2e39..0b33125 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -579,8 +579,8 @@ void nfs_readdir_free_pages(struct page **pages, unsigned int npages)
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

