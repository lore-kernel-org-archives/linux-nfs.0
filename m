Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D3E5C433B4
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Apr 2021 08:38:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 742A26105A
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Apr 2021 08:38:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231669AbhDOIiz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Apr 2021 04:38:55 -0400
Received: from out30-56.freemail.mail.aliyun.com ([115.124.30.56]:34235 "EHLO
        out30-56.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S231491AbhDOIiy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2021 04:38:54 -0400
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=alimailimapcm10staff010182156082;MF=jiapeng.chong@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0UVdbPqg_1618475905;
Received: from j63c13417.sqa.eu95.tbsite.net(mailfrom:jiapeng.chong@linux.alibaba.com fp:SMTPD_---0UVdbPqg_1618475905)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 15 Apr 2021 16:38:31 +0800
From:   Jiapeng Chong <jiapeng.chong@linux.alibaba.com>
To:     bfields@fieldses.org
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jiapeng Chong <jiapeng.chong@linux.alibaba.com>
Subject: [PATCH] nfsd: remove unused function
Date:   Thu, 15 Apr 2021 16:38:24 +0800
Message-Id: <1618475904-104579-1-git-send-email-jiapeng.chong@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix the following clang warning:

fs/nfsd/nfs4state.c:6276:1: warning: unused function 'end_offset'
[-Wunused-function].

Reported-by: Abaci Robot <abaci@linux.alibaba.com>
Signed-off-by: Jiapeng Chong <jiapeng.chong@linux.alibaba.com>
---
 fs/nfsd/nfs4state.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 97447a6..32b11ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6272,15 +6272,6 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	return status;
 }
 
-static inline u64
-end_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	end = start + len;
-	return end >= start ? end: NFS4_MAX_UINT64;
-}
-
 /* last octet in a range */
 static inline u64
 last_byte_offset(u64 start, u64 len)
-- 
1.8.3.1

