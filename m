Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F7A4C47082
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jun 2021 20:51:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 57E5161263
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jun 2021 20:51:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230037AbhFCUxi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jun 2021 16:53:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:44846 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229576AbhFCUxi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jun 2021 16:53:38 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 35B7B60C3D;
        Thu,  3 Jun 2021 20:51:53 +0000 (UTC)
Subject: [PATCH 13/29] lockd: Update the NLMv1 void results encoder to use
 struct xdr_stream
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Date:   Thu, 03 Jun 2021 16:51:52 -0400
Message-ID: <162275351250.32691.5615195640526977706.stgit@klimt.1015granger.net>
In-Reply-To: <162275337584.32691.3943139351165347555.stgit@klimt.1015granger.net>
References: <162275337584.32691.3943139351165347555.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/xdr.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 091c8c463ab4..840fa8ff8426 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -331,6 +331,17 @@ nlmsvc_decode_notify(struct svc_rqst *rqstp, __be32 *p)
 	return 1;
 }
 
+
+/*
+ * Encode Reply results
+ */
+
+int
+nlmsvc_encode_void(struct svc_rqst *rqstp, __be32 *p)
+{
+	return 1;
+}
+
 int
 nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p)
 {
@@ -363,9 +374,3 @@ nlmsvc_encode_res(struct svc_rqst *rqstp, __be32 *p)
 	*p++ = resp->status;
 	return xdr_ressize_check(rqstp, p);
 }
-
-int
-nlmsvc_encode_void(struct svc_rqst *rqstp, __be32 *p)
-{
-	return xdr_ressize_check(rqstp, p);
-}


