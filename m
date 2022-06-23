Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3AC7C43334
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Jun 2022 01:46:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1358657AbiFWBqS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jun 2022 21:46:18 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33740 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1358911AbiFWBqP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2022 21:46:15 -0400
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com [45.249.212.188])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id EC38F434BE;
        Wed, 22 Jun 2022 18:46:12 -0700 (PDT)
Received: from dggemv703-chm.china.huawei.com (unknown [172.30.72.56])
        by szxga02-in.huawei.com (SkyGuard) with ESMTP id 4LT30k1zyWzSgpw;
        Thu, 23 Jun 2022 09:42:46 +0800 (CST)
Received: from kwepemm600015.china.huawei.com (7.193.23.52) by
 dggemv703-chm.china.huawei.com (10.3.19.46) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.24; Thu, 23 Jun 2022 09:46:10 +0800
Received: from huawei.com (10.175.127.227) by kwepemm600015.china.huawei.com
 (7.193.23.52) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2375.24; Thu, 23 Jun
 2022 09:46:10 +0800
From:   ChenXiaoSong <chenxiaosong2@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <chenxiaosong2@huawei.com>, <liuyongqiang13@huawei.com>,
        <yi.zhang@huawei.com>, <zhangxiaoxu5@huawei.com>
Subject: [PATCH] NFS: remove redundant code in nfs_file_write()
Date:   Thu, 23 Jun 2022 09:58:58 +0800
Message-ID: <20220623015858.1728497-1-chenxiaosong2@huawei.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.127.227]
X-ClientProxiedBy: dggems703-chm.china.huawei.com (10.3.19.180) To
 kwepemm600015.china.huawei.com (7.193.23.52)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

filemap_fdatawait_range() will always return 0, after patch 6c984083ec24
("NFS: Use of mapping_set_error() results in spurious errors"), it will not
save the wb err in struct address_space->flags:

  result = filemap_fdatawait_range(file->f_mapping, ...) = 0
    filemap_check_errors(mapping) = 0
      test_bit(..., &mapping->flags) // flags is 0

Signed-off-by: ChenXiaoSong <chenxiaosong2@huawei.com>
---
 fs/nfs/file.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2d72b1b7ed74..54237a231687 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -663,8 +663,6 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 		result = filemap_fdatawait_range(file->f_mapping,
 						 iocb->ki_pos - written,
 						 iocb->ki_pos - 1);
-		if (result < 0)
-			goto out;
 	}
 	result = generic_write_sync(iocb, written);
 	if (result < 0)
-- 
2.31.1

