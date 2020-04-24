Return-Path: <SRS0=rM5g=6I=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3FFDC2BA1A
	for <linux-nfs@archiver.kernel.org>; Fri, 24 Apr 2020 08:10:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 97FCE20774
	for <linux-nfs@archiver.kernel.org>; Fri, 24 Apr 2020 08:10:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726347AbgDXIKZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 24 Apr 2020 04:10:25 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:37176 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726298AbgDXIKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Apr 2020 04:10:25 -0400
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 1F25DE1F2380B8AD7D23;
        Fri, 24 Apr 2020 16:10:20 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.487.0; Fri, 24 Apr 2020
 16:10:13 +0800
From:   Zheng Bin <zhengbin13@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
CC:     <zhengbin13@huawei.com>
Subject: [PATCH] nfs4: Remove unneeded semicolon
Date:   Fri, 24 Apr 2020 16:17:23 +0800
Message-ID: <20200424081723.53335-1-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.26.0.106.g9fadedd
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fixes coccicheck warning:

include/linux/nfs4.h:298:2-3: Unneeded semicolon

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: Zheng Bin <zhengbin13@huawei.com>
---
 include/linux/nfs4.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7c4b63561035..4dba3c948932 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -295,7 +295,7 @@ static inline bool seqid_mutating_err(u32 err)
 	case NFS4ERR_NOFILEHANDLE:
 	case NFS4ERR_MOVED:
 		return false;
-	};
+	}
 	return true;
 }

--
2.26.0.106.g9fadedd

