Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D26D3C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 14:52:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A311A206BA
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 14:52:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729707AbfBROwn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 09:52:43 -0500
Received: from szxga07-in.huawei.com ([45.249.212.35]:46196 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729907AbfBROwn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Feb 2019 09:52:43 -0500
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 0AE5ABB45F012CD08AF4;
        Mon, 18 Feb 2019 22:52:40 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS406-HUB.china.huawei.com (10.3.19.206) with Microsoft SMTP Server id
 14.3.408.0; Mon, 18 Feb 2019 22:52:30 +0800
From:   ZhangXiaoxu <zhangxiaoxu5@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
CC:     <zhangxiaoxu5@huawei.com>
Subject: [PATCH] nfs: fix xfstest generic/099 failed on nfsv3
Date:   Mon, 18 Feb 2019 22:56:43 +0800
Message-ID: <1550501803-27999-1-git-send-email-zhangxiaoxu5@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After setxattr, the nfsv3 cached the acl which set by user.

But at the backend, the shared file system (eg. ext4) will check
the acl, if it can merged with mode, it won't add acl to the file.
So, the nfsv3 cached acl is redundant.

Don't 'set_cached_acl' when setxattr.

Signed-off-by: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
---
 fs/nfs/nfs3acl.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 9fce185..c5c3fc6 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -222,8 +222,6 @@ static int __nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	switch (status) {
 		case 0:
 			status = nfs_refresh_inode(inode, fattr);
-			set_cached_acl(inode, ACL_TYPE_ACCESS, acl);
-			set_cached_acl(inode, ACL_TYPE_DEFAULT, dfacl);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
-- 
2.7.4

