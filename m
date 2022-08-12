Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BAD4C25B06
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Aug 2022 01:03:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235116AbiHLBDD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Aug 2022 21:03:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49720 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231131AbiHLBDC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2022 21:03:02 -0400
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com [45.249.212.188])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2981774DF3;
        Thu, 11 Aug 2022 18:03:01 -0700 (PDT)
Received: from dggemv711-chm.china.huawei.com (unknown [172.30.72.53])
        by szxga02-in.huawei.com (SkyGuard) with ESMTP id 4M3lfy5LGkzXdNB;
        Fri, 12 Aug 2022 08:58:50 +0800 (CST)
Received: from kwepemm600010.china.huawei.com (7.193.23.86) by
 dggemv711-chm.china.huawei.com (10.1.198.66) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2375.24; Fri, 12 Aug 2022 09:02:58 +0800
Received: from huawei.com (10.175.127.227) by kwepemm600010.china.huawei.com
 (7.193.23.86) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2375.24; Fri, 12 Aug
 2022 09:02:57 +0800
From:   Sun Ke <sunke32@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna@kernel.org>
CC:     <linux-nfs@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
        <sunke32@huawei.com>
Subject: [PATCH] NFS: Fix missing unlock in nfs_unlink()
Date:   Fri, 12 Aug 2022 09:14:40 +0800
Message-ID: <20220812011440.3602849-1-sunke32@huawei.com>
X-Mailer: git-send-email 2.31.1
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.175.127.227]
X-ClientProxiedBy: dggems704-chm.china.huawei.com (10.3.19.181) To
 kwepemm600010.china.huawei.com (7.193.23.86)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add the missing unlock before goto.

Fixes: 3c59366c207e ("NFS: don't unhash dentry during unlink/rename")
Signed-off-by: Sun Ke <sunke32@huawei.com>
---
 fs/nfs/dir.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index dbab3caa15ed..1b879584d4fe 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2484,8 +2484,10 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 	 */
 	error = -ETXTBSY;
 	if (WARN_ON(dentry->d_flags & DCACHE_NFSFS_RENAMED) ||
-	    WARN_ON(dentry->d_fsdata == NFS_FSDATA_BLOCKED))
+	    WARN_ON(dentry->d_fsdata == NFS_FSDATA_BLOCKED)) {
+		spin_unlock(&dentry->d_lock);
 		goto out;
+	}
 	if (dentry->d_fsdata)
 		/* old devname */
 		kfree(dentry->d_fsdata);
-- 
2.31.1

