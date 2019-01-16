Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0839C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 18:22:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 946D0206C2
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 18:22:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J+GMNTfC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728455AbfAPSWI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 13:22:08 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:56075 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728454AbfAPSWI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2019 13:22:08 -0500
Received: by mail-it1-f195.google.com with SMTP id m62so4541846ith.5;
        Wed, 16 Jan 2019 10:22:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6TZHtKz2h63GVa4tuN3vPjm4MJ/vWya8s9u5ssFl6To=;
        b=J+GMNTfCvH0tThKXNNZRw7mjG7rr5PzHByoSI4NtDcUSg3XUw8Mtkm+P1OFHYIQ39b
         OxgEEJJrHbEnj4j6VoAshnHP2dNI3GGYviVWaS3ph3WJr49CBrMSFdyIf0wckJ4wtD8u
         P35N2O7rHY6iqyQLE3fIO6VeoDtiRI/MIv5jbrYS6SUOJx0lk324YofEqmO/9sQOyZMk
         4rSjTZPlY7dWsjWIFIhavOWBSUuzxg5YU/xvCVP4XVoAizGyNXO3r9GvOVHw4DLoP/kp
         N6YqO6LUKxAExWeOI48oriWpEjAl1cASbk2seJzgy4huFc2kUrUhK1ihLs+NCoPCVwXv
         M7+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6TZHtKz2h63GVa4tuN3vPjm4MJ/vWya8s9u5ssFl6To=;
        b=kaDyJhc729td6nUob5If39/64XgPwqxonzLI865vf4EMJfogKy/q7KWwkvuqie/0Av
         E2UnxWoTIL2PXQryJDGUcQneW5UNg0HqB1pgHNpYawkMjhCDA32e4K27E93fwsYoIVUG
         wntkc5fL2I1kSzZjYh4voY5bTr7m75FXzYmMVTq4p1R0wVXcn2Q7WHJsZ5x4t/tHzG0f
         bclVTcOtNUaXsriNK9JllvlUAQc1AgLOJITT/pAx5NT0ZiR3VsPCVsR9fQpDOazH1mi0
         NiVPVd2+jG+CIBmGOLgZb2QjL4JJwT2ZuT41CEhPgFwJ7iwVwxosOGh/H92a1DeKT9ie
         M9eg==
X-Gm-Message-State: AJcUukc1kMB0OZKbfROf0CWJM9gpENMefV1Voc3mdIdqzsOxP6tavbVl
        hO4rH5AKqxAIwbGKDG/YKgXzy7wA
X-Google-Smtp-Source: ALg8bN4ukTh29cUkQjSfvdGrktPfPs4OXmzPoL9dJSWCzv5MASXCKzfexMZvf0GtjDfDABLoHcQUWw==
X-Received: by 2002:a24:3e43:: with SMTP id s64mr6835087its.111.1547662927103;
        Wed, 16 Jan 2019 10:22:07 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r16sm2720309ioa.16.2019.01.16.10.22.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:22:06 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x0GIM5OO013770;
        Wed, 16 Jan 2019 18:22:05 GMT
Subject: [PATCH RFC 1/2] xprtrdma: Check inline size before providing a
 Write chunk
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 16 Jan 2019 13:22:05 -0500
Message-ID: <20190116182205.4345.73732.stgit@manet.1015granger.net>
In-Reply-To: <20190116181954.4345.87842.stgit@manet.1015granger.net>
References: <20190116181954.4345.87842.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In very rare cases, an NFS READ operation might predict that the
non-payload part of the RPC Call is large. For instance, an
NFSv4 COMPOUND with a large GETATTR result, in combination with a
large Kerberos credential, could push the non-payload part to be
several kilobytes.

If the non-payload part is larger than the connection's inline
threshold, the client is required to provision a Reply chunk. The
current Linux client does not check for this case. There are two
obvious ways to handle it:

a. Provision a Write chunk for the payload and a Reply chunk for
   the non-payload part

b. Provision a Reply chunk for the whole RPC Reply

Some testing at a recent NFS bake-a-thon showed that servers can
mostly handle a. but there are some corner cases that do not work
yet. b. already works (it has to, to handle krb5i/p), but could be
somewhat less efficient. However, I expect this scenario to be very
rare -- no-one has reported a problem yet.

So I'm going to implement b. Sometime later I will provide some
patches to help make b. a little more efficient by more carefully
choosing the Reply chunk's segment sizes to ensure the payload is
optimally aligned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d18614e..7774aee 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -164,6 +164,21 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return rqst->rq_rcv_buf.buflen <= ia->ri_max_inline_read;
 }
 
+/* The client is required to provide a Reply chunk if the maximum
+ * size of the non-payload part of the RPC Reply is larger than
+ * the inline threshold.
+ */
+static bool
+rpcrdma_nonpayload_inline(const struct rpcrdma_xprt *r_xprt,
+			  const struct rpc_rqst *rqst)
+{
+	const struct xdr_buf *buf = &rqst->rq_rcv_buf;
+	const struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+
+	return buf->head[0].iov_len + buf->tail[0].iov_len <
+		ia->ri_max_inline_read;
+}
+
 /* Split @vec on page boundaries into SGEs. FMR registers pages, not
  * a byte range. Other modes coalesce these SGEs into a single MR
  * when they can.
@@ -762,7 +777,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 */
 	if (rpcrdma_results_inline(r_xprt, rqst))
 		wtype = rpcrdma_noch;
-	else if (ddp_allowed && rqst->rq_rcv_buf.flags & XDRBUF_READ)
+	else if ((ddp_allowed && rqst->rq_rcv_buf.flags & XDRBUF_READ) &&
+		 rpcrdma_nonpayload_inline(r_xprt, rqst))
 		wtype = rpcrdma_writech;
 	else
 		wtype = rpcrdma_replych;

