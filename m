Return-Path: <SRS0=Ptm/=RD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D409C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 14:42:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5B5CD2184A
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 14:42:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b="j21fGeYS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733028AbfB1OmR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Feb 2019 09:42:17 -0500
Received: from m12-15.163.com ([220.181.12.15]:58562 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725896AbfB1OmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Feb 2019 09:42:17 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
        s=s110527; h=From:Subject:Date:Message-Id; bh=M+u5m0qqD0rEVXvSVv
        u/489essjUlIufqN6foOKObqk=; b=j21fGeYSKApVnzhlMBUbdIWTS3hE9A/oq1
        7NJpZFdiUCYV+vBZb/BJ0wvJ9XY7SF9wYLblmxRUd/ccezC1TWkmdDAFPguSpiyc
        nRHv7v645KQKRUkFPNqvhIN8HVkHGwXhHWXYdRBW1bl7Da78gldPcy2xmUKSWOFa
        81vujxKoY=
Received: from yangwei-T440.lan (unknown [171.223.98.87])
        by smtp11 (Coremail) with SMTP id D8CowADHLkkN83dcuXkbFQ--.27937S3;
        Thu, 28 Feb 2019 22:41:19 +0800 (CST)
From:   Yang Wei <albin_yang@163.com>
To:     linux-nfs@vger.kernel.org
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        yang.wei9@zte.com.cn, albin_yang@163.com
Subject: [PATCH] fs: nfs: fix semicolon code style issue
Date:   Thu, 28 Feb 2019 22:41:16 +0800
Message-Id: <1551364876-4331-1-git-send-email-albin_yang@163.com>
X-Mailer: git-send-email 2.7.4
X-CM-TRANSID: D8CowADHLkkN83dcuXkbFQ--.27937S3
X-Coremail-Antispam: 1Uf129KBjvdXoWrtF4UKw17GF15WrW8XryDGFg_yoWxKrX_Zr
        40yw40g393Xr48Jrs0ka4Syrs3ZFn5KF13Z3yrCF4DJayqyr4DAFyDJFn8WF9xG3yxXr4a
        kryDC3yjyw4FgjkaLaAFLSUrUUUUUb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
        9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IU8pBTUUUUUU==
X-Originating-IP: [171.223.98.87]
X-CM-SenderInfo: pdoex0xb1d0wi6rwjhhfrp/1tbiSg9polPADNPVxwAAsQ
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Yang Wei <yang.wei9@zte.com.cn>

Delete a superfluous semicolon in nfs4_do_lookup_revalidate().

Signed-off-by: Yang Wei <yang.wei9@zte.com.cn>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6bf4471..96dd679 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1649,7 +1649,7 @@ nfs4_do_lookup_revalidate(struct inode *dir, struct dentry *dentry,
 reval_dentry:
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
-	return nfs_lookup_revalidate_dentry(dir, dentry, inode);;
+	return nfs_lookup_revalidate_dentry(dir, dentry, inode);
 
 full_reval:
 	return nfs_do_lookup_revalidate(dir, dentry, flags);
-- 
2.7.4


