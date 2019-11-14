Return-Path: <SRS0=CTqf=ZG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7C55C432C3
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Nov 2019 14:03:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A788420672
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Nov 2019 14:03:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726674AbfKNODJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Nov 2019 09:03:09 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:6667 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726327AbfKNODI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Nov 2019 09:03:08 -0500
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 1EF462163F473CA96966;
        Thu, 14 Nov 2019 22:02:58 +0800 (CST)
Received: from localhost (10.133.213.239) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.439.0; Thu, 14 Nov 2019
 22:02:51 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <kolga@netapp.com>
CC:     <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] NFSv4: Make _nfs42_proc_copy_notify() static
Date:   Thu, 14 Nov 2019 22:01:41 +0800
Message-ID: <20191114140141.30612-1-yuehaibing@huawei.com>
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

fs/nfs/nfs42proc.c:527:5: warning:
 symbol '_nfs42_proc_copy_notify' was not declared. Should it be static?

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfs/nfs42proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index aab6b7b..639aff8 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -524,9 +524,9 @@ static int nfs42_do_offload_cancel_async(struct file *dst,
 	return status;
 }
 
-int _nfs42_proc_copy_notify(struct file *src, struct file *dst,
-			    struct nfs42_copy_notify_args *args,
-			    struct nfs42_copy_notify_res *res)
+static int _nfs42_proc_copy_notify(struct file *src, struct file *dst,
+				   struct nfs42_copy_notify_args *args,
+				   struct nfs42_copy_notify_res *res)
 {
 	struct nfs_server *src_server = NFS_SERVER(file_inode(src));
 	struct rpc_message msg = {
-- 
2.7.4


