Return-Path: <SRS0=I3JF=XU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5FEBC432C2
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Sep 2019 13:09:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A689020640
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Sep 2019 13:09:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2405470AbfIYNJh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Sep 2019 09:09:37 -0400
Received: from youngberry.canonical.com ([91.189.89.112]:39733 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388199AbfIYNJh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Sep 2019 09:09:37 -0400
Received: from 1.general.cking.uk.vpn ([10.172.193.212] helo=localhost)
        by youngberry.canonical.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.86_2)
        (envelope-from <colin.king@canonical.com>)
        id 1iD72w-0002wK-EE; Wed, 25 Sep 2019 13:09:30 +0000
From:   Colin King <colin.king@canonical.com>
To:     "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc: clean up indentation issue
Date:   Wed, 25 Sep 2019 14:09:30 +0100
Message-Id: <20190925130930.13076-1-colin.king@canonical.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

There are statements that are indented incorrectly, remove the
extraneous spacing.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sunrpc/svc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 220b79988000..d11b70552c33 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1233,8 +1233,8 @@ svc_generic_init_request(struct svc_rqst *rqstp,
 
 	if (rqstp->rq_vers >= progp->pg_nvers )
 		goto err_bad_vers;
-	  versp = progp->pg_vers[rqstp->rq_vers];
-	  if (!versp)
+	versp = progp->pg_vers[rqstp->rq_vers];
+	if (!versp)
 		goto err_bad_vers;
 
 	/*
-- 
2.20.1

