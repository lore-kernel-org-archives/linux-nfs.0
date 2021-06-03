Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E68C47096
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jun 2021 20:52:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 66E9B61263
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jun 2021 20:52:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229707AbhFCUxu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jun 2021 16:53:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:44892 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229576AbhFCUxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jun 2021 16:53:50 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 4AC3061263;
        Thu,  3 Jun 2021 20:52:05 +0000 (UTC)
Subject: [PATCH 15/29] lockd: Update the NLMv1 nlm_res results encoder to use
 struct xdr_stream
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Date:   Thu, 03 Jun 2021 16:52:04 -0400
Message-ID: <162275352459.32691.5975537127331266243.stgit@klimt.1015granger.net>
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
 fs/lockd/xdr.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index daf3524040d6..4fb6090bc915 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -349,24 +349,23 @@ nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlmsvc_encode_shareres(struct svc_rqst *rqstp, __be32 *p)
+nlmsvc_encode_res(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct xdr_stream *xdr = &rqstp->rq_res_stream;
 	struct nlm_res *resp = rqstp->rq_resp;
 
-	if (!(p = nlm_encode_cookie(p, &resp->cookie)))
-		return 0;
-	*p++ = resp->status;
-	*p++ = xdr_zero;		/* sequence argument */
-	return xdr_ressize_check(rqstp, p);
+	return svcxdr_encode_cookie(xdr, &resp->cookie) &&
+		svcxdr_encode_stats(xdr, resp->status);
 }
 
 int
-nlmsvc_encode_res(struct svc_rqst *rqstp, __be32 *p)
+nlmsvc_encode_shareres(struct svc_rqst *rqstp, __be32 *p)
 {
 	struct nlm_res *resp = rqstp->rq_resp;
 
 	if (!(p = nlm_encode_cookie(p, &resp->cookie)))
 		return 0;
 	*p++ = resp->status;
+	*p++ = xdr_zero;		/* sequence argument */
 	return xdr_ressize_check(rqstp, p);
 }


