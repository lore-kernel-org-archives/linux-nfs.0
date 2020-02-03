Return-Path: <SRS0=+7wx=3X=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F79AC35247
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Feb 2020 16:04:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0BD4A2080C
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Feb 2020 16:04:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728404AbgBCQEW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Feb 2020 11:04:22 -0500
Received: from szxga07-in.huawei.com ([45.249.212.35]:43912 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728389AbgBCQEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Feb 2020 11:04:22 -0500
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 2956C9F6897AF4149922;
        Tue,  4 Feb 2020 00:04:19 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS411-HUB.china.huawei.com (10.3.19.211) with Microsoft SMTP Server id
 14.3.439.0; Tue, 4 Feb 2020 00:04:12 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
CC:     YueHaibing <yuehaibing@huawei.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
Subject: [PATCH -next] NFS: use correct 'verifier' in nfs_lookup_revalidate_dentry
Date:   Mon, 3 Feb 2020 15:58:45 +0000
Message-ID: <20200203155845.50239-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type:   text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

'verifier' is already set but not used in nfs_set_verifier().

Fixes: 1346d280eafa ("NFS: Revalidate once when holding a delegation")
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 289052c0ae93..882ea5337627 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1180,7 +1180,7 @@ nfs_lookup_revalidate_dentry(struct inode *dir, struct dentry *dentry,
 		verifier = nfs_save_change_attribute(dir);
 
 	nfs_setsecurity(inode, fattr, label);
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+	nfs_set_verifier(dentry, verifier);
 
 	/* set a readdirplus hint that we had a cache miss */
 	nfs_force_use_readdirplus(dir);



