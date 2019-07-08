Return-Path: <SRS0=7JSz=VF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F2DAC606AF
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Jul 2019 12:54:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4CBEE2064B
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Jul 2019 12:54:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728615AbfGHMy1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Jul 2019 08:54:27 -0400
Received: from szxga07-in.huawei.com ([45.249.212.35]:43508 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728117AbfGHMy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jul 2019 08:54:27 -0400
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id B35FCDBAD8ECC974D6EF;
        Mon,  8 Jul 2019 20:54:19 +0800 (CST)
Received: from localhost (10.133.213.239) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.439.0; Mon, 8 Jul 2019
 20:54:11 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>
CC:     <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] nfsd: Make __get_nfsdfs_client() static
Date:   Mon, 8 Jul 2019 20:54:08 +0800
Message-ID: <20190708125408.56016-1-yuehaibing@huawei.com>
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

fs/nfsd/nfsctl.c:1221:22: warning:
 symbol '__get_nfsdfs_client' was not declared. Should it be static?

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfsd/nfsctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 53833b3..0a9a49d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1218,7 +1218,7 @@ static void clear_ncl(struct inode *inode)
 }
 
 
-struct nfsdfs_client *__get_nfsdfs_client(struct inode *inode)
+static struct nfsdfs_client *__get_nfsdfs_client(struct inode *inode)
 {
 	struct nfsdfs_client *nc = inode->i_private;
 
-- 
2.7.4


