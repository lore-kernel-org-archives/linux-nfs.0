Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D189BC43461
	for <linux-nfs@archiver.kernel.org>; Mon,  3 May 2021 15:23:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9A31A611CE
	for <linux-nfs@archiver.kernel.org>; Mon,  3 May 2021 15:23:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230283AbhECPY0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 May 2021 11:24:26 -0400
Received: from mail.kernel.org ([198.145.29.99]:39296 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230373AbhECPYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 May 2021 11:24:25 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id A779D61208
        for <linux-nfs@vger.kernel.org>; Mon,  3 May 2021 15:23:31 +0000 (UTC)
Subject: [PATCH v1 07/29] lockd: Update the NLMv1 CANCEL arguments decoder to
 use struct xdr_stream
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 03 May 2021 11:23:30 -0400
Message-ID: <162005541071.23028.9129621738975184213.stgit@klimt.1015granger.net>
In-Reply-To: <162005520101.23028.15766816408658851498.stgit@klimt.1015granger.net>
References: <162005520101.23028.15766816408658851498.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/xdr.c |   34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 8a9f02e45df2..ef38f07d1224 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -294,30 +294,34 @@ nlmsvc_decode_lockargs(struct svc_rqst *rqstp, __be32 *p)
 }
 
 int
-nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p)
+nlmsvc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p)
 {
-	struct nlm_res *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = &rqstp->rq_arg_stream;
+	struct nlm_args *argp = rqstp->rq_argp;
+	u32 exclusive;
 
-	if (!(p = nlm_encode_testres(p, resp)))
+	if (!svcxdr_decode_cookie(xdr, &argp->cookie))
 		return 0;
-	return xdr_ressize_check(rqstp, p);
+	if (xdr_stream_decode_bool(xdr, &argp->block) < 0)
+		return 0;
+	if (xdr_stream_decode_bool(xdr, &exclusive) < 0)
+		return 0;
+	if (!svcxdr_decode_lock(xdr, &argp->lock))
+		return 0;
+	if (exclusive)
+		argp->lock.fl.fl_type = F_WRLCK;
+
+	return 1;
 }
 
 int
-nlmsvc_decode_cancargs(struct svc_rqst *rqstp, __be32 *p)
+nlmsvc_encode_testres(struct svc_rqst *rqstp, __be32 *p)
 {
-	struct nlm_args *argp = rqstp->rq_argp;
-	u32	exclusive;
+	struct nlm_res *resp = rqstp->rq_resp;
 
-	if (!(p = nlm_decode_cookie(p, &argp->cookie)))
-		return 0;
-	argp->block = ntohl(*p++);
-	exclusive = ntohl(*p++);
-	if (!(p = nlm_decode_lock(p, &argp->lock)))
+	if (!(p = nlm_encode_testres(p, resp)))
 		return 0;
-	if (exclusive)
-		argp->lock.fl.fl_type = F_WRLCK;
-	return xdr_argsize_check(rqstp, p);
+	return xdr_ressize_check(rqstp, p);
 }
 
 int


