Return-Path: <SRS0=Jjwl=XS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 796E4C3A5A6
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 06:03:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4FAC22087C
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Sep 2019 06:03:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392066AbfIWGD5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Sep 2019 02:03:57 -0400
Received: from szxga06-in.huawei.com ([45.249.212.32]:51446 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2387519AbfIWGD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Sep 2019 02:03:57 -0400
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 7EA74DD58FF8F5F3B84D;
        Mon, 23 Sep 2019 14:03:55 +0800 (CST)
Received: from localhost (10.133.213.239) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.439.0; Mon, 23 Sep 2019
 14:03:47 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] nfsd: Make nfsd_reset_boot_verifier_locked static
Date:   Mon, 23 Sep 2019 13:58:59 +0800
Message-ID: <20190923055859.5616-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.10.2.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.133.213.239]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix sparse warning:

fs/nfsd/nfssvc.c:364:6: warning:
 symbol 'nfsd_reset_boot_verifier_locked' was not declared. Should it be static?

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfsd/nfssvc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 3caaf56..fdf7ed4 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -361,7 +361,7 @@ void nfsd_copy_boot_verifier(__be32 verf[2], struct nfsd_net *nn)
 	done_seqretry(&nn->boot_lock, seq);
 }
 
-void nfsd_reset_boot_verifier_locked(struct nfsd_net *nn)
+static void nfsd_reset_boot_verifier_locked(struct nfsd_net *nn)
 {
 	ktime_get_real_ts64(&nn->nfssvc_boot);
 }
-- 
2.7.4


