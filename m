Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55898 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbaAGVFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 16:05:13 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] minor svcauth_gss.c cleanup
Date: Tue,  7 Jan 2014 16:04:32 -0500
Message-Id: <1389128674-16951-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1389128674-16951-1-git-send-email-bfields@redhat.com>
References: <1389128674-16951-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

---
 net/sunrpc/auth_gss/svcauth_gss.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 2a93540..0f73f45 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1591,8 +1591,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 	BUG_ON(integ_len % 4);
 	*p++ = htonl(integ_len);
 	*p++ = htonl(gc->gc_seq);
-	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset,
-				integ_len))
+	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
 		BUG();
 	if (resbuf->tail[0].iov_base == NULL) {
 		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
@@ -1600,10 +1599,8 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 		resbuf->tail[0].iov_base = resbuf->head[0].iov_base
 						+ resbuf->head[0].iov_len;
 		resbuf->tail[0].iov_len = 0;
-		resv = &resbuf->tail[0];
-	} else {
-		resv = &resbuf->tail[0];
 	}
+	resv = &resbuf->tail[0];
 	mic.data = (u8 *)resv->iov_base + resv->iov_len + 4;
 	if (gss_get_mic(gsd->rsci->mechctx, &integ_buf, &mic))
 		goto out_err;
-- 
1.7.9.5

