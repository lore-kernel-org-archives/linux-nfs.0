Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81E4CC388F9
	for <linux-nfs@archiver.kernel.org>; Sat, 21 Nov 2020 07:20:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3CEB522240
	for <linux-nfs@archiver.kernel.org>; Sat, 21 Nov 2020 07:20:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726556AbgKUHUI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 21 Nov 2020 02:20:08 -0500
Received: from mail-m121143.qiye.163.com ([115.236.121.143]:39400 "EHLO
        mail-m121143.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726483AbgKUHUI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Nov 2020 02:20:08 -0500
X-Greylist: delayed 528 seconds by postgrey-1.27 at vger.kernel.org; Sat, 21 Nov 2020 02:20:07 EST
Received: from vivo-HP-ProDesk-680-G4-PCI-MT.vivo.xyz (unknown [58.251.74.231])
        by mail-m121143.qiye.163.com (Hmail) with ESMTPA id D5495540163;
        Sat, 21 Nov 2020 15:11:14 +0800 (CST)
From:   Wang Qing <wangqing@vivo.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Wang Qing <wangqing@vivo.com>
Subject: [PATCH] nfs: Only include nfs42.h when NFS_V4_2 enable
Date:   Sat, 21 Nov 2020 15:11:09 +0800
Message-Id: <1605942669-585-1-git-send-email-wangqing@vivo.com>
X-Mailer: git-send-email 2.7.4
X-HM-Spam-Status: e1kfGhgUHx5ZQUtXWQgYFAkeWUFZS1VLWVdZKFlBSE83V1ktWUFJV1kPCR
        oVCBIfWUFZSktLTx4ZGhkaHklKVkpNS05CT0lNTE5KTUxVEwETFhoSFyQUDg9ZV1kWGg8SFR0UWU
        FZT0tIVUpKS0hOT1VLWQY+
X-HM-Sender-Digest: e1kMHhlZQR0aFwgeV1kSHx4VD1lBWUc6Mjo6Ljo4Tz8ZNwI6AVYtMDQM
        HBcwCxFVSlVKTUtOQk9JTUxOTE1OVTMWGhIXVQwaFRwKEhUcOw0SDRRVGBQWRVlXWRILWUFZTkNV
        SU5KVUxPVUlISllXWQgBWUFKSUNCNwY+
X-HM-Tid: 0a75e9a48668b038kuuud5495540163
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Remove duplicate header unnecessary.
Only include nfs42.h when NFS_V4_2 enable.

Signed-off-by: Wang Qing <wangqing@vivo.com>
---
 fs/nfs/nfs4proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e0ca9b..a1321a5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -67,7 +67,6 @@
 #include "nfs4idmap.h"
 #include "nfs4session.h"
 #include "fscache.h"
-#include "nfs42.h"
 
 #include "nfs4trace.h"
 
-- 
2.7.4

