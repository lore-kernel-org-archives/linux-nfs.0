Return-Path: <SRS0=7k0R=WS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DB42C3A59D
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Aug 2019 04:11:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 162222145D
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Aug 2019 04:11:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725932AbfHVELN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 22 Aug 2019 00:11:13 -0400
Received: from szxga04-in.huawei.com ([45.249.212.190]:5186 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725294AbfHVELN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Aug 2019 00:11:13 -0400
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id DF899F01EACB5A0736F4;
        Thu, 22 Aug 2019 12:11:09 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Thu, 22 Aug 2019
 12:11:03 +0800
From:   zhengbin <zhengbin13@huawei.com>
To:     <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>
CC:     <yi.zhang@huawei.com>, <zhengbin13@huawei.com>
Subject: [PATCH] fs/nfsd/nfs4xdr.c: remove set but not used variables 'tmp'
Date:   Thu, 22 Aug 2019 12:17:34 +0800
Message-ID: <1566447454-16310-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fixes gcc '-Wunused-but-set-variable' warning:

fs/nfsd/nfs4xdr.c: In function nfsd4_decode_copy:
fs/nfsd/nfs4xdr.c:1751:15: warning: variable tmp set but not used [-Wunused-but-set-variable]

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 fs/nfsd/nfs4xdr.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4428118..5e66600 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1736,7 +1736,6 @@ static __be32
 nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 {
 	DECODE_HEAD;
-	unsigned int tmp;

 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1751,7 +1750,6 @@ nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	p++; /* ca_consecutive: we always do consecutive copies */
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = be32_to_cpup(p); /* Source server list not supported */

 	DECODE_TAIL;
 }
--
2.7.4

