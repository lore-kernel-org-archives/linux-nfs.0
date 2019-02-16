Return-Path: <SRS0=NyTm=QX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70F37C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Feb 2019 00:31:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3E4A6218D9
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Feb 2019 00:31:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391582AbfBPAbZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 19:31:25 -0500
Received: from out30-45.freemail.mail.aliyun.com ([115.124.30.45]:59237 "EHLO
        out30-45.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2389118AbfBPAbZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2019 19:31:25 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04452;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TKBxR-7_1550277075;
Received: from localhost(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0TKBxR-7_1550277075)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 16 Feb 2019 08:31:23 +0800
From:   zhangliguang <zhangliguang@linux.alibaba.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     zhangliguang@linux.alibaba.com, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Remove redundant semicolon
Date:   Sat, 16 Feb 2019 08:31:15 +0800
Message-Id: <1550277075-120448-1-git-send-email-zhangliguang@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This removes redundant semicolon for ending code.

Fixes: c7944ebb9ce9 ("NFSv4: Fix lookup revalidate of regular files")
Signed-off-by: Liguang Zhang <zhangliguang@linux.alibaba.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6bf4471..96dd679 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1649,7 +1649,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 reval_dentry:
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
-	return nfs_lookup_revalidate_dentry(dir, dentry, inode);;
+	return nfs_lookup_revalidate_dentry(dir, dentry, inode);
 
 full_reval:
 	return nfs_do_lookup_revalidate(dir, dentry, flags);
-- 
1.8.3.1

