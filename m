Return-Path: <SRS0=IGmK=6W=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1374AC35280
	for <linux-nfs@archiver.kernel.org>; Fri,  8 May 2020 01:39:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 000772051A
	for <linux-nfs@archiver.kernel.org>; Fri,  8 May 2020 01:39:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726542AbgEHBjM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 May 2020 21:39:12 -0400
Received: from szxga05-in.huawei.com ([45.249.212.191]:4284 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726514AbgEHBjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 May 2020 21:39:12 -0400
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 98546C53397FFD92BD33;
        Fri,  8 May 2020 09:39:10 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS404-HUB.china.huawei.com (10.3.19.204) with Microsoft SMTP Server id
 14.3.487.0; Fri, 8 May 2020 09:39:04 +0800
From:   Xiongfeng Wang <wangxiongfeng2@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <davem@davemloft.net>, <kuba@kernel.org>
CC:     <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <wangxiongfeng2@huawei.com>
Subject: [PATCH 2/2] sunrpc: add missing newline when printing parameter 'auth_hashtable_size' by sysfs
Date:   Fri, 8 May 2020 09:33:00 +0800
Message-ID: <1588901580-44687-3-git-send-email-wangxiongfeng2@huawei.com>
X-Mailer: git-send-email 1.7.12.4
In-Reply-To: <1588901580-44687-1-git-send-email-wangxiongfeng2@huawei.com>
References: <1588901580-44687-1-git-send-email-wangxiongfeng2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When I cat parameter
'/sys/module/sunrpc/parameters/auth_hashtable_size', it displays as
follows. It is better to add a newline for easy reading.

[root@hulk-202 ~]# cat /sys/module/sunrpc/parameters/auth_hashtable_size
16[root@hulk-202 ~]#

Signed-off-by: Xiongfeng Wang <wangxiongfeng2@huawei.com>
---
 net/sunrpc/auth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5748ad0..a9f0d17 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -81,7 +81,7 @@ static int param_get_hashtbl_sz(char *buffer, const struct kernel_param *kp)
 	unsigned int nbits;
 
 	nbits = *(unsigned int *)kp->arg;
-	return sprintf(buffer, "%u", 1U << nbits);
+	return sprintf(buffer, "%u\n", 1U << nbits);
 }
 
 #define param_check_hashtbl_sz(name, p) __param_check(name, p, unsigned int);
-- 
1.7.12.4

