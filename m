Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12C45C54EBD
	for <linux-nfs@archiver.kernel.org>; Sun,  8 Jan 2023 16:30:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236163AbjAHQaY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 8 Jan 2023 11:30:24 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35920 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236213AbjAHQaW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2023 11:30:22 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5B20F3889
        for <linux-nfs@vger.kernel.org>; Sun,  8 Jan 2023 08:30:19 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 269E6B80B36
        for <linux-nfs@vger.kernel.org>; Sun,  8 Jan 2023 16:30:18 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6F4FC433EF
        for <linux-nfs@vger.kernel.org>; Sun,  8 Jan 2023 16:30:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1673195416;
        bh=YHHvEm9US4fxdWSlhM2UIXg3vRA1UA9KlvMeKXgZ2Gw=;
        h=Subject:From:To:Date:In-Reply-To:References:From;
        b=VltanQz1/ItKScIKk2PcY39JxlRg+cJfYmzn+PVbZT/CgzCWmg74wdEFHZu285F9Q
         dZkwQQjt3LAOwwZdGHOq0w5O4cakjtOw9kKtEm1jCvJEDdVaN+NUL28X4UvixlFYv7
         C3ZoYlScaNNETZDYMdEn3VOnwXQRARj+FC/bbgsyJZQ0RlULG8OK8uloICAmrRnTsB
         /oo+Z3mGS5quxAAEcVVlP0oG87eIcZ1DdRbPatcUGf/i9gtQDNAteFsmnUzxXno3e1
         K9kHB98ey4/0sCZ2mKjMjPhxfj/23PaK+1WkEeirX1UWq3oUDAOclxobKPu1JpuUEC
         E0W49IBbkZ0Iw==
Subject: [PATCH v1 18/27] SUNRPC: Convert unwrap data paths to use xdr_stream
 for replies
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 08 Jan 2023 11:30:15 -0500
Message-ID: <167319541584.7490.2761785202452013247.stgit@bazille.1015granger.net>
In-Reply-To: <167319499150.7490.2294168831574653380.stgit@bazille.1015granger.net>
References: <167319499150.7490.2294168831574653380.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

We're now moving svcxdr_init_encode() to /before/ the flavor's
->accept method has set rq_auth_slack. Add a helper that can
set rq_auth_slack /after/ svcxdr_init_encode() has been called.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc.h        |   26 ++++++++++++++++++++++++--
 net/sunrpc/auth_gss/svcauth_gss.c |   18 ++++++++----------
 2 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index ed722dd33b46..dd9f68acd9f1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -577,12 +577,34 @@ static inline void svcxdr_init_encode(struct svc_rqst *rqstp)
 	xdr->buf = buf;
 	xdr->iov = resv;
 	xdr->p   = resv->iov_base + resv->iov_len;
-	xdr->end = resv->iov_base + PAGE_SIZE - rqstp->rq_auth_slack;
+	xdr->end = resv->iov_base + PAGE_SIZE;
 	buf->len = resv->iov_len;
 	xdr->page_ptr = buf->pages - 1;
 	buf->buflen = PAGE_SIZE * (rqstp->rq_page_end - buf->pages);
-	buf->buflen -= rqstp->rq_auth_slack;
 	xdr->rqst = NULL;
 }
 
+/**
+ * svcxdr_set_auth_slack -
+ * @rqstp: RPC transaction
+ * @slack: buffer space to reserve for the transaction's security flavor
+ *
+ * Set the request's slack space requirement, and set aside that much
+ * space in the rqstp's rq_res.head for use when the auth wraps the Reply.
+ */
+static inline void svcxdr_set_auth_slack(struct svc_rqst *rqstp, int slack)
+{
+	struct xdr_stream *xdr = &rqstp->rq_res_stream;
+	struct xdr_buf *buf = &rqstp->rq_res;
+	struct kvec *resv = buf->head;
+
+	rqstp->rq_auth_slack = slack;
+
+	xdr->end -= XDR_QUADLEN(slack);
+	buf->buflen -= rqstp->rq_auth_slack;
+
+	WARN_ON(xdr->iov != resv);
+	WARN_ON(xdr->p > xdr->end);
+}
+
 #endif /* SUNRPC_SVC_H */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 759169baa52f..fd1fd4143a8e 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1685,24 +1685,22 @@ svcauth_gss_accept(struct svc_rqst *rqstp)
 			svcxdr_init_encode(rqstp);
 			break;
 		case RPC_GSS_SVC_INTEGRITY:
-			/* placeholders for length and seq. number: */
-			svc_putnl(resv, 0);
-			svc_putnl(resv, 0);
+			svcxdr_init_encode(rqstp);
+			/* placeholders for body length and seq. number: */
+			xdr_reserve_space(&rqstp->rq_res_stream, XDR_UNIT * 2);
 			if (svcauth_gss_unwrap_integ(rqstp, gc->gc_seq,
 						     rsci->mechctx))
 				goto garbage_args;
-			rqstp->rq_auth_slack = RPC_MAX_AUTH_SIZE;
-			svcxdr_init_encode(rqstp);
+			svcxdr_set_auth_slack(rqstp, RPC_MAX_AUTH_SIZE);
 			break;
 		case RPC_GSS_SVC_PRIVACY:
-			/* placeholders for length and seq. number: */
-			svc_putnl(resv, 0);
-			svc_putnl(resv, 0);
+			svcxdr_init_encode(rqstp);
+			/* placeholders for body length and seq. number: */
+			xdr_reserve_space(&rqstp->rq_res_stream, XDR_UNIT * 2);
 			if (svcauth_gss_unwrap_priv(rqstp, gc->gc_seq,
 						    rsci->mechctx))
 				goto garbage_args;
-			rqstp->rq_auth_slack = RPC_MAX_AUTH_SIZE * 2;
-			svcxdr_init_encode(rqstp);
+			svcxdr_set_auth_slack(rqstp, RPC_MAX_AUTH_SIZE * 2);
 			break;
 		default:
 			goto auth_err;


