Return-Path: <SRS0=g2DM=C2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6588C43461
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Sep 2020 02:24:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A07FD2072E
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Sep 2020 02:24:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726043AbgIQCYW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Sep 2020 22:24:22 -0400
Received: from m17618.mail.qiye.163.com ([59.111.176.18]:64313 "EHLO
        m17618.mail.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725267AbgIQCYV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2020 22:24:21 -0400
X-Greylist: delayed 310 seconds by postgrey-1.27 at vger.kernel.org; Wed, 16 Sep 2020 22:24:21 EDT
Received: from vivo-HP-ProDesk-680-G4-PCI-MT.vivo.xyz (unknown [58.251.74.227])
        by m17618.mail.qiye.163.com (Hmail) with ESMTPA id 157C14E16DF;
        Thu, 17 Sep 2020 10:19:09 +0800 (CST)
From:   Wang Qing <wangqing@vivo.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Wang Qing <wangqing@vivo.com>
Subject: [PATCH] nfs: fix spellint typo in pnfs.c
Date:   Thu, 17 Sep 2020 10:19:00 +0800
Message-Id: <1600309143-5483-1-git-send-email-wangqing@vivo.com>
X-Mailer: git-send-email 2.7.4
X-HM-Spam-Status: e1kfGhgUHx5ZQUpXWQgYFAkeWUFZS1VLWVdZKFlBSE83V1ktWUFJV1kPCR
        oVCBIfWUFZT0lIS0JPS09PGEkaVkpNS0tIS0JKT0JITE1VEwETFhoSFyQUDg9ZV1kWGg8SFR0UWU
        FZT0tIVUpKS0hKQ1VKS0tZBg++
X-HM-Sender-Digest: e1kMHhlZQR0aFwgeV1kSHx4VD1lBWUc6OBw6Iio*NT8pDhQaFw0jHywf
        GiJPCwJVSlVKTUtLSEtCSk9CQk9DVTMWGhIXVQwaFRwKEhUcOw0SDRRVGBQWRVlXWRILWUFZTkNV
        SU5KVUxPVUlJTFlXWQgBWUFKSE9INwY+
X-HM-Tid: 0a7499dbbe489376kuws157c14e16df
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Change the comment typo: "manger" -> "manager".

Signed-off-by: Wang Qing <wangqing@vivo.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 71f7741..0e50b9d
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -902,7 +902,7 @@ pnfs_destroy_layouts_byclid(struct nfs_client *clp,
 }
 
 /*
- * Called by the state manger to remove all layouts established under an
+ * Called by the state manager to remove all layouts established under an
  * expired lease.
  */
 void
-- 
2.7.4

