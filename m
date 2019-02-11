Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E22E0C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:23:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AE492218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:23:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gju1/s++"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728192AbfBKQXw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:23:52 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:56218 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726896AbfBKQXw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:23:52 -0500
Received: by mail-it1-f193.google.com with SMTP id f18so16695056itb.5;
        Mon, 11 Feb 2019 08:23:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6TZHtKz2h63GVa4tuN3vPjm4MJ/vWya8s9u5ssFl6To=;
        b=Gju1/s++9au8WsidN06MaNjwhhletQp49fxnTh4J3DWHttGWuoyfxOOc1HP/ZNzukq
         /Ep7X8Pm86BJ+cX2QkBee3B2OsmEWn0rMPnXW0MY/PCs7oKximDc2KML3kfYFRfpt0IU
         G9Qy+BW9Z8CLlGWdQ90hQycQZpqb26SGkxvoGJlFQ1hszm0lHmBgwrdQ7yvMuIlS58dy
         ZYfPx3m+ABP4/yOVadlwbXIDr6POAFaPqKExhFC3r4imI3W5af+pBgNXBtku5fiElgxA
         oFINdhoCklFLHgnxsiadbtV7vZ4uUx9TgXEiMS5z4pw96h2BRTayRhy1UtGNvWEtc6OT
         3z1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6TZHtKz2h63GVa4tuN3vPjm4MJ/vWya8s9u5ssFl6To=;
        b=V3yyQm+8ba38SLmb4m8vj1uD6Ye7aResQhhIVFPvWRvEdbvUR+SEg3AVtkFviWfkhu
         dm/ujk3oV+k7kJkup070DTxc8L/15Pahce4zhEQhd3OLI+8uv1OMlxzTYP5l3JvEF98w
         UjQwJxLDMNA0e/yZFV63cTCdzCWjdwoVroGbFhoWFlQj6eFl6hcWZN6cHwcQtXmLZ1Yq
         ZyrH5pVTfG4XHmtrE44CfOeW5i5oqAtV/cQyLEz/zxF5WjLDw9toAFkz55Cx5HfEHVf+
         Ki9opJr2IawDFi1mt1FGH0ZnDVXnOOVO99JDl2aZgF/kb/uZoz5pKdBwBgQViM3Kzchi
         z0zA==
X-Gm-Message-State: AHQUAuaqsLs/eN/FEZRHId8L3Is57O7daJBcgiJRPIfiI0OpZf65dy4j
        QYT5eDT2oaY0KjMBMvArde4=
X-Google-Smtp-Source: AHgI3IZnru1hbDGK/fGFtsO6Da9ba+1JcMfsNkbp89uEZa6MPiX6Cdbm9mLHlatv6eVDjdax6t1LiQ==
X-Received: by 2002:a05:660c:30e:: with SMTP id u14mr185292itj.13.1549902231161;
        Mon, 11 Feb 2019 08:23:51 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t70sm5287343ita.17.2019.02.11.08.23.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:23:50 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGNndF029958;
        Mon, 11 Feb 2019 16:23:49 GMT
Subject: [PATCH v1 02/23] xprtrdma: Check inline size before providing a
 Write chunk
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:23:49 -0500
Message-ID: <20190211162349.2817.19297.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
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

