Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A619ECAAD5
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Aug 2022 18:50:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229579AbiH1Su1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Aug 2022 14:50:27 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36504 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229547AbiH1Su1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2022 14:50:27 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A4605B7E7
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 11:50:25 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 51D26B8076E
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 18:50:24 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED53EC433D6;
        Sun, 28 Aug 2022 18:50:22 +0000 (UTC)
Subject: [PATCH v2 1/7] SUNRPC: Fix svcxdr_init_decode's end-of-buffer
 calculation
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 28 Aug 2022 14:50:22 -0400
Message-ID: <166171262197.21449.2261873517844800915.stgit@manet.1015granger.net>
In-Reply-To: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
References: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure that stream-based argument decoding can't go past the actual
end of the receive buffer. xdr_init_decode's calculation of the
value of xdr->end over-estimates the end of the buffer because the
Linux kernel RPC server code does not remove the size of the RPC
header from rqstp->rq_arg before calling the upper layer's
dispatcher.

The server-side still uses the svc_getnl() macros to decode the
RPC call header. These macros reduce the length of the head iov
but do not update the total length of the message in the buffer
(buf->len).

A proper fix for this would be to replace the use of svc_getnl() and
friends in the RPC header decoder, but that would be a large and
invasive change that would be difficult to backport.

Fixes: 5191955d6fc6 ("SUNRPC: Prepare for xdr_stream-style decoding on the server-side")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc.h |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index daecb009c05b..5a830b66f059 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -544,16 +544,27 @@ static inline void svc_reserve_auth(struct svc_rqst *rqstp, int space)
 }
 
 /**
- * svcxdr_init_decode - Prepare an xdr_stream for svc Call decoding
+ * svcxdr_init_decode - Prepare an xdr_stream for Call decoding
  * @rqstp: controlling server RPC transaction context
  *
+ * This function currently assumes the RPC header in rq_arg has
+ * already been decoded. Upon return, xdr->p points to the
+ * location of the upper layer header.
  */
 static inline void svcxdr_init_decode(struct svc_rqst *rqstp)
 {
 	struct xdr_stream *xdr = &rqstp->rq_arg_stream;
-	struct kvec *argv = rqstp->rq_arg.head;
+	struct xdr_buf *buf = &rqstp->rq_arg;
+	struct kvec *argv = buf->head;
 
-	xdr_init_decode(xdr, &rqstp->rq_arg, argv->iov_base, NULL);
+	/*
+	 * svc_getnl() and friends do not keep the xdr_buf's ::len
+	 * field up to date. Refresh that field before initializing
+	 * the argument decoding stream.
+	 */
+	buf->len = buf->head->iov_len + buf->page_len + buf->tail->iov_len;
+
+	xdr_init_decode(xdr, buf, argv->iov_base, NULL);
 	xdr_set_scratch_page(xdr, rqstp->rq_scratch_page);
 }
 


