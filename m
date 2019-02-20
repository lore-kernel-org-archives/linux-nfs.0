Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94A60C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 07:25:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E9FD2146E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 07:25:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729770AbfBTHZS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 02:25:18 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:57740 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726315AbfBTHZS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 02:25:18 -0500
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 95B3741B1C8DFD95B5EB;
        Wed, 20 Feb 2019 15:25:14 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Wed, 20 Feb 2019 15:25:07 +0800
From:   yangerkun <yangerkun@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC:     <houtao1@huawei.com>, <zhangxiaoxu5@huawei.com>,
        <yi.zhang@huawei.com>, <yangerkun@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: drop acl cache in __nfs3_proc_setacls
Date:   Wed, 20 Feb 2019 15:29:25 +0800
Message-ID: <20190220072925.103352-1-yangerkun@huawei.com>
X-Mailer: git-send-email 2.9.5
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since server may call posix_acl_update_mode which can lead acl been
NULL. So,just drop acl cache after rpc_call_sync, and if anyone want to
use acl, they can get the correct acl by send a msg to server themselves.
This can fix xfstests generic/099 over nfsv3.

Signed-off-by: yangerkun <yangerkun@huawei.com>
---
 fs/nfs/nfs3acl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 9fce185..6c07ebc 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -222,8 +222,8 @@ static int __nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	switch (status) {
 		case 0:
 			status = nfs_refresh_inode(inode, fattr);
-			set_cached_acl(inode, ACL_TYPE_ACCESS, acl);
-			set_cached_acl(inode, ACL_TYPE_DEFAULT, dfacl);
+			/* Sever may call posix_acl_update_mode */
+			forget_all_cached_acls(inode);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
-- 
2.9.5

