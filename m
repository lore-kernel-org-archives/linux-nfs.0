Return-Path: <SRS0=hL3P=2J=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E8E9C43603
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Dec 2019 09:22:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5A7472465E
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Dec 2019 09:22:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726652AbfLSJWQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 Dec 2019 04:22:16 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:32896 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726599AbfLSJWQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Dec 2019 04:22:16 -0500
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 51879F00AA723745A28E;
        Thu, 19 Dec 2019 17:22:12 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.439.0; Thu, 19 Dec 2019
 17:22:04 +0800
From:   zhengbin <zhengbin13@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>
CC:     <zhengbin13@huawei.com>
Subject: [PATCH] nfsd4: Remove unneeded semicolon
Date:   Thu, 19 Dec 2019 17:29:20 +0800
Message-ID: <1576747760-120195-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fixes coccicheck warning:

fs/nfsd/nfs4state.c:3376:2-3: Unneeded semicolon

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 369e574..54c2917 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3373,7 +3373,7 @@ static __be32 nfsd4_map_bcts_dir(u32 *dir)
 	case NFS4_CDFC4_BACK_OR_BOTH:
 		*dir = NFS4_CDFC4_BOTH;
 		return nfs_ok;
-	};
+	}
 	return nfserr_inval;
 }

--
2.7.4

