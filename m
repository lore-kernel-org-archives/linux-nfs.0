Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F117C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1C2142075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o+E9TYNz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726712AbfDJUHs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:07:48 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:44045 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726023AbfDJUHs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:07:48 -0400
Received: by mail-io1-f65.google.com with SMTP id u12so3265450iop.11;
        Wed, 10 Apr 2019 13:07:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=mC/IJvzXc0Q60See7Yv3rAr29/a24UFvFcDPZ5PzIeo=;
        b=o+E9TYNzl8yoqiEgGzH1ZVeMrHCTApKIzlKtKPJdxcQzSc0Z+SfJngF5XCm1F6WZcR
         JJw8Yo+I9VcCxOmbmdB9pRWyi75IUvJ9XUESAXp0hUe5ZALb5u4YBX4/5upMRJcy3dxP
         tqi7k0jfiIYAuLrWS2Nzsi9d3Khh8QOxxfNsofNL40fa3Izvt4ngF63sB/6kv8tHt5NE
         aMmbRVNN60cpgzGJo+/loynBhbuD7xQiNmaYWPYk9w0pQFYl2hfsrbtqA/HcfyrGIV/z
         o5m1MyYqgnSgxSGkpI5E3LVzZ0dzW2/jmGhevxecOmM+86rH7T3ifVNiLarL6JNfJaKq
         UYmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=mC/IJvzXc0Q60See7Yv3rAr29/a24UFvFcDPZ5PzIeo=;
        b=SF86WFIjRyOP2SPPtHD7ckA8f08+n7NiUT/cMYHcZ7Np7+rx5D9oIOoWDGRqaKMnRX
         8nLHQh4hA5zZp3Av4Nq+I9mo1cOeF5PfbIdBMiD4UTAB1NenLsbn/Q+ZJZp1b8Wzk8pE
         eFrzO3u49gxHVqY27OR73/7aj6+ayL2nxEfLD4bJuh6ODaP9x2yx0b7ap8YNfisTTeqL
         SQy2MkWqzv9LEFtzZIyTXVOpbj38Wx+ZAD+NfMZ24yjW0hClFI3BxQqiuKs8rSVZJeMP
         YkR4nQjm7f4folb5JKCa1OK4vKfY3tFDBpPj4fIlDLX6j3IAGg5CjIRCI4TPARQOrPsx
         tYEg==
X-Gm-Message-State: APjAAAVxcTw75A7vzTNvMD5W1dp0nvuK5kvnKTn/rAFOlDrDt3P+Yjd9
        xONntKYuabA9iY2VKHJigWQGyDHC
X-Google-Smtp-Source: APXvYqx5GvfICK+H7wsY5mpwyncT+wuqv2Ip502hxRg39JxFvvdKjcPETEAIJeGeGACCu9O2nEZndg==
X-Received: by 2002:a6b:7e04:: with SMTP id i4mr30443419iom.137.1554926867523;
        Wed, 10 Apr 2019 13:07:47 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c92sm1446779itd.26.2019.04.10.13.07.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:07:47 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK7ks7004546;
        Wed, 10 Apr 2019 20:07:46 GMT
Subject: [PATCH v1 14/19] xprtrdma: More Send completion batching
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:07:46 -0400
Message-ID: <20190410200746.11522.64034.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Instead of using a fixed number, allow the amount of Send completion
batching to vary based on the client's maximum credit limit.

- A larger default gives a small boost to IOPS throughput

- Reducing it based on max_requests gives a safe result when the
  max credit limit is cranked down (eg. when the device has a small
  max_qp_wr).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    4 +---
 net/sunrpc/xprtrdma/xprt_rdma.h |   10 ----------
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 378b460..f65d17a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -521,9 +521,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		ep->rep_attr.cap.max_send_sge,
 		ep->rep_attr.cap.max_recv_sge);
 
-	/* set trigger for requesting send completion */
-	ep->rep_send_batch = min_t(unsigned int, RPCRDMA_MAX_SEND_BATCH,
-				   cdata->max_requests >> 2);
+	ep->rep_send_batch = cdata->max_requests >> 3;
 	ep->rep_send_count = ep->rep_send_batch;
 	init_waitqueue_head(&ep->rep_connect_wait);
 	ep->rep_receive_count = 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7d82c91..5063fa7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -232,16 +232,6 @@ struct rpcrdma_sendctx {
 	struct ib_sge		sc_sges[];
 };
 
-/* Limit the number of SGEs that can be unmapped during one
- * Send completion. This caps the amount of work a single
- * completion can do before returning to the provider.
- *
- * Setting this to zero disables Send completion batching.
- */
-enum {
-	RPCRDMA_MAX_SEND_BATCH = 7,
-};
-
 /*
  * struct rpcrdma_mr - external memory region metadata
  *

