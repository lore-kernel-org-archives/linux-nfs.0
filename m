Return-Path: <SRS0=I+ZC=IE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4F52C433E9
	for <linux-nfs@archiver.kernel.org>; Sat,  6 Mar 2021 22:33:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CC5F3650CF
	for <linux-nfs@archiver.kernel.org>; Sat,  6 Mar 2021 22:33:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229977AbhCFWdV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 6 Mar 2021 17:33:21 -0500
Received: from mail.kernel.org ([198.145.29.99]:34682 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229816AbhCFWc4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 6 Mar 2021 17:32:56 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 7C504650D0
        for <linux-nfs@vger.kernel.org>; Sat,  6 Mar 2021 22:32:56 +0000 (UTC)
Subject: [PATCH v2 37/43] NFSD: Update the NFSv2 ACL ACCESS result encoder to
 use struct xdr_stream
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sat, 06 Mar 2021 17:32:55 -0500
Message-ID: <161506997576.4312.12362729321049881183.stgit@klimt.1015granger.net>
In-Reply-To: <161506956174.4312.17478383686779759287.stgit@klimt.1015granger.net>
References: <161506956174.4312.17478383686779759287.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs2acl.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 9270530a0c2f..4b43929c1f25 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -282,16 +282,21 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p)
 /* ACCESS */
 static int nfsaclsvc_encode_accessres(struct svc_rqst *rqstp, __be32 *p)
 {
+	struct xdr_stream *xdr = &rqstp->rq_res_stream;
 	struct nfsd3_accessres *resp = rqstp->rq_resp;
 
-	*p++ = resp->status;
-	if (resp->status != nfs_ok)
-		goto out;
+	if (!svcxdr_encode_stat(xdr, resp->status))
+		return 0;
+	switch (resp->status) {
+	case nfs_ok:
+		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
+			return 0;
+		if (xdr_stream_encode_u32(xdr, resp->access) < 0)
+			return 0;
+		break;
+	}
 
-	p = nfs2svc_encode_fattr(rqstp, p, &resp->fh, &resp->stat);
-	*p++ = htonl(resp->access);
-out:
-	return xdr_ressize_check(rqstp, p);
+	return 1;
 }
 
 /*


