Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2C70C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:42:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C1E342133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:42:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a/Znnd8m"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388331AbeLQQmA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:42:00 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:35176 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQl7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:59 -0500
Received: by mail-io1-f67.google.com with SMTP id o13so10494636ioh.2;
        Mon, 17 Dec 2018 08:41:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Hg+/62w4wVOPn0SmI/QIaJsKJ5mlxxB+x5Gu8gJqcDo=;
        b=a/Znnd8mn+JEb7fwLisp4e4zhqoizQuIpDCh1vInFW1C1nf7AFqtNV1n5UCyTsW9c7
         bU9peQpQrQlKpOSWw5KRt6ifsMTuY7f8NzR/cKLqv/vd3sQBgP1GfF5TvFEzIvBFhw6X
         KuFLDZLSIKbs/cAnUxl/sTZ/TNRW5u0jZEp/0T518beDX4z40ZRtCoWd4EGG9cRIYsa/
         Rph8+Lo2uDu6R7kMkoPgCCoSRWY13ivfNjP3JJz9qa/7ZUDVjnnyJpOGMeKstEa0MngW
         WOM4+zIZ/M5QpRv+I/x7VwjeE/XAPkO5NU4RF7USk063U8f35tgATCy1MT/z5VQCvzJZ
         26eQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Hg+/62w4wVOPn0SmI/QIaJsKJ5mlxxB+x5Gu8gJqcDo=;
        b=Emd02x2G9VzRGt6gg5ZLhfWTJtgZPs/NJG+CXcu7RuifNdTI3bO9Wg451zbwtPCh09
         6UZ3TV9ZNekn/EdmcrRKPyYVX4UGGNKuILpPRe0dgR6chS8pkKQ5tuYR7l5r9bCjaaLa
         fSyay1WN7ZwLQ/Z5vzSJTcRXWCFW8k6LmkqcW9a/Ddat1QsoHslSz/es8sIaUAcaSkEr
         AfkaOQXjrReRrh+iP+GB1yMID4pQ8RcddfqXCV16vU4zICN55wkeOZK2ulheju1R7ynn
         qU/J8rCwAFWtSt+Rtru+XgJehgYwZMDSQfQlgjoczMGHWRx3ovW1FOCkt+X1SWJlRc6x
         EkPQ==
X-Gm-Message-State: AA+aEWZP6yDQ5t3boUpXr96HMc6XloSfddsWoBsJRTdZ2tnXvN1LrrNW
        N8sn13KKXijyQwkBehhZ+eLFukoK
X-Google-Smtp-Source: AFSGD/XtWLsXtqTcpRWWXiGcgM0qdeSWl4SSbOISjhsVjfWHrrb1zOyhnMK711oKkWD0XwAYtlCPpQ==
X-Received: by 2002:a5e:9902:: with SMTP id t2mr11921118ioj.153.1545064917361;
        Mon, 17 Dec 2018 08:41:57 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o128sm7702159itb.39.2018.12.17.08.41.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:56 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfuaW018666;
        Mon, 17 Dec 2018 16:41:56 GMT
Subject: [PATCH v4 29/30] xprtrdma: Clarify comments in rpcrdma_ia_remove
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:56 -0500
Message-ID: <20181217164156.24133.2578.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Comments are clarified to note how transport data structures are
protected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 339c40e..b700ade 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -402,8 +402,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
  * rpcrdma_ia_remove - Handle device driver unload
  * @ia: interface adapter being removed
  *
- * Divest transport H/W resources associated with this adapter,
- * but allow it to be restored later.
+ * Callers must serialize calls to this function.
  */
 void
 rpcrdma_ia_remove(struct rpcrdma_ia *ia)
@@ -434,16 +433,23 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	ib_free_cq(ep->rep_attr.send_cq);
 	ep->rep_attr.send_cq = NULL;
 
-	/* The ULP is responsible for ensuring all DMA
-	 * mappings and MRs are gone.
+	/* The ib_drain_qp above guarantees that all posted
+	 * Receives have flushed, which returns the transport's
+	 * rpcrdma_reps to the rb_recv_bufs list.
 	 */
 	list_for_each_entry(rep, &buf->rb_recv_bufs, rr_list)
 		rpcrdma_dma_unmap_regbuf(rep->rr_rdmabuf);
+
+	/* DMA mapping happens in ->send_request with the
+	 * transport send lock held. Our caller is holding
+	 * the transport send lock.
+	 */
 	list_for_each_entry(req, &buf->rb_allreqs, rl_all) {
 		rpcrdma_dma_unmap_regbuf(req->rl_rdmabuf);
 		rpcrdma_dma_unmap_regbuf(req->rl_sendbuf);
 		rpcrdma_dma_unmap_regbuf(req->rl_recvbuf);
 	}
+
 	rpcrdma_mrs_destroy(buf);
 	ib_dealloc_pd(ia->ri_pd);
 	ia->ri_pd = NULL;

