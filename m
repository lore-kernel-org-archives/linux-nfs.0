Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 846B2C10F00
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 13:47:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 535F92087C
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 13:47:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726411AbfCFNrU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 08:47:20 -0500
Received: from out30-133.freemail.mail.aliyun.com ([115.124.30.133]:35764 "EHLO
        out30-133.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726409AbfCFNrU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 08:47:20 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04452;MF=wuyihao@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TM6kbx8_1551880034;
Received: from ali-186590dcce93-2.local(mailfrom:wuyihao@linux.alibaba.com fp:SMTPD_---0TM6kbx8_1551880034)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 06 Mar 2019 21:47:14 +0800
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Cc:     stable@vger.kernel.org, Joseph Qi <joseph.qi@linux.alibaba.com>
From:   Yihao Wu <wuyihao@linux.alibaba.com>
Subject: [PATCH] nfsd: fix wrong check in write_v4_end_grace()
Message-ID: <22af6507-782d-d2fb-77f7-455dad27697f@linux.alibaba.com>
Date:   Wed, 6 Mar 2019 21:47:14 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From 04ddefd79a5cd410d65b7a30593ac915b9fab687 Mon Sep 17 00:00:00 2001
From: Yihao Wu <wuyihao@linux.alibaba.com>
Date: Wed, 6 Mar 2019 21:03:50 +0800
Subject: [PATCH] nfsd: fix wrong check in write_v4_end_grace()

Commit 62a063b8e7d1 "nfsd4: fix crash on writing v4_end_grace before
nfsd startup" is trying to fix a NULL dereference issue, but it
mistakenly checks if the nfsd server is started. So fix it.

Fixes: 62a063b8e7d1 "nfsd4: fix crash on writing v4_end_grace before nfsd startup"
Cc: stable@vger.kernel.org
Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>
Signed-off-by: Yihao Wu <wuyihao@linux.alibaba.com>
---
 fs/nfsd/nfsctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 72a7681..f2feb2d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1126,7 +1126,7 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
 		case 'Y':
 		case 'y':
 		case '1':
-			if (nn->nfsd_serv)
+			if (!nn->nfsd_serv)
 				return -EBUSY;
 			nfsd4_end_grace(nn);
 			break;
-- 
1.8.3.1

