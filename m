Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E80DEC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B40EE21773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DpK+mxth"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730462AbfDXNkB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:01 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:38815 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727335AbfDXNkB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:01 -0400
Received: by mail-it1-f194.google.com with SMTP id q19so6213021itk.3;
        Wed, 24 Apr 2019 06:40:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tP4pZUD3EhubgbXGW6upqp4wbxuAQeIK8vS7zGZUQ+o=;
        b=DpK+mxthMl0B4nN3D2ceeYlx+nGd8tCMOTYCe5thgIc8HnxvlgGSq9QIELrJjQCzC8
         h1KUvNVwAjRD1hUVxy5xSD99+rEDA6Vl5yr4ByX2s1qIaqQ0z7pF2jVwiKUP4/Y62Xvx
         2KJKjhz8JxtwUFRSAlmitTLPn/7EMHGkP7QOTHr2utPbUPsyBCrveCb8dzOimAgcUjeP
         L1QknCKuzt1RX7/0TIffffdI1TmVo8ft808eQo6QFx8MgKzN96VUvC1yQ/l2MFYKl9gU
         LfcSN0ro+l9Xv+AEuZwmqxapZGroRpn+9IkttznYOjMLN2LpcicE4YIlfd9oZv0ly0V8
         dmaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tP4pZUD3EhubgbXGW6upqp4wbxuAQeIK8vS7zGZUQ+o=;
        b=CItmB0PxBS0Nn417BrdaxF6wP/888PCgZI7hpMo+EO3YokdCxvTfP0+BCzX60ta48G
         zzFNklnxjownmASXwd8S7pp1EnoUOkV12gLiqay0frfU2cAV38rzT76mtg7fZQmUX5CS
         twBF2JJbzd6wv7NBqnV2lyadM1sWCZjE1kjp75e2HQllyXCyxTGkvELkZI+E2hJB36AH
         i8rj8EgyfgkFrVZtgmgLSIroPdVNL3GDm1tkLa8M3FADMYFwKHk0sLHfyRF0JkA7g62E
         cgA7yMCHV0i0Z4psj6D2b5dMDBNy3MaX8N90eAqYYrA+dwG8d6yP+xglz8z8etGzsQQ+
         nL1Q==
X-Gm-Message-State: APjAAAUzc8nMRzSsw+ETuSC43ksHhMmNCLiHHbFC8SMnOuQpWZwud835
        npwaYh7Pvfg2dVZHvCshAVI=
X-Google-Smtp-Source: APXvYqzHMXj9hh3PnpKwcLhogXgWH51p86u6X1xcV7Edyz7rRt+rg0SPcJW5b6P8bIFJGdnhh2kVIw==
X-Received: by 2002:a02:6011:: with SMTP id i17mr23168646jac.64.1556113200363;
        Wed, 24 Apr 2019 06:40:00 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u16sm1288681iol.66.2019.04.24.06.39.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:59 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdxsi011307;
        Wed, 24 Apr 2019 13:39:59 GMT
Subject: [PATCH v3 13/21] xprtrdma: More Send completion batching
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:59 -0400
Message-ID: <20190424133958.5077.97566.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
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
index 1ad2519..1ed761a 100644
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
index 8afb5fc..f856393 100644
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

