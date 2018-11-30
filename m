Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8C39C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 07:49:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5284A2146D
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 07:49:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5284A2146D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726562AbeK3S6V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 13:58:21 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:45130 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726551AbeK3S6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 13:58:21 -0500
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 858B2F3A521B4;
        Fri, 30 Nov 2018 15:49:54 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.408.0; Fri, 30 Nov 2018
 15:49:46 +0800
From:   zhengbin <zhengbin13@huawei.com>
To:     <bfields@fieldses.org>, <jlayton@kernel.org>,
        <linux-nfs@vger.kernel.org>
CC:     <zhengbin13@huawei.com>, <houtao1@huawei.com>,
        <zhaohongjiang@huawei.com>
Subject: [PATCH] nfsd: Return EPERM on utime/utimes/lutimes calls instead of EACCESS in some cases
Date:   Fri, 30 Nov 2018 15:51:30 +0800
Message-ID: <1543564290-147370-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

As the man(3) page for utime/utimes/lutimes, EPERM is returned
when the second parameter of utime/utimes/lutimes is not NULL,
the caller's effective UID does not match the owner of the file,
and the caller is not privileged.

However, in a NFS directory, it will return EACCESS(nfsd_setattr->
fh_verify->nfsd_permission), This patch fix this.

Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 fs/nfsd/vfs.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index eb67098..9824e32 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -396,10 +396,23 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	bool		get_write_count;
 	bool		size_change = (iap->ia_valid & ATTR_SIZE);

-	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
+	if (iap->ia_valid & ATTR_SIZE) {
 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
-	if (iap->ia_valid & ATTR_SIZE)
 		ftype = S_IFREG;
+	}
+
+	/*
+	 * If utimes(2) and friends are called with times not NULL, we should
+	 * not set NFSD_MAY_WRITE bit. Otherwise fh_verify->nfsd_permission
+	 * will return EACCESS, when the caller's effective UID does not match
+	 * the owner of the file, and the caller is not privileged. In this
+	 * situation, we should return EPERM(notify_change will return this).
+	 */
+	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME)) {
+		accmode |= NFSD_MAY_OWNER_OVERRIDE;
+		if (!(iap->ia_valid & (ATTR_ATIME_SET | ATTR_MTIME_SET)))
+			accmode |= NFSD_MAY_WRITE;
+	}

 	/* Callers that do fh_verify should do the fh_want_write: */
 	get_write_count = !fhp->fh_dentry;
--
2.7.4

