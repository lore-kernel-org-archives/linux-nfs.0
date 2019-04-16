Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9949AC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 69781217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p7OzWUj0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727233AbfDPNiC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:02 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:51691 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727136AbfDPNiC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:02 -0400
Received: by mail-it1-f193.google.com with SMTP id s3so18259656itk.1;
        Tue, 16 Apr 2019 06:38:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tP4pZUD3EhubgbXGW6upqp4wbxuAQeIK8vS7zGZUQ+o=;
        b=p7OzWUj0B3Jj506AmHj+1AZLj6ztVNI4kGMxlCHHAm71rpoSk4fdehpy9hkn3IPo7C
         o69v/6ZYrEuLKZvVyTkGdUjSUHpGVEAStRPM46rv0Ho4wRHrVP5ocxyNYD7wp8p5cJkE
         IjbuSV/I+QdxWXs1eEI2JmUnHAwAoyy4+H/JZfTwe1dVceDok5Bkxfdqgq5qU/KMvG0c
         mCS4vyAwT55ephIcZaHPVgiiAWqq0KamVHoZxcXeKt6078LKJw72GVj6knCteTyCJuli
         GcsaWZOEeMq2A0fksgK4voz0d3TsxgIIvYX93msalorV2dtKFaZ0zX13P1d0MPI+pLaI
         EoLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tP4pZUD3EhubgbXGW6upqp4wbxuAQeIK8vS7zGZUQ+o=;
        b=hp+a0b3ezzjgh2pLiSjp5cJMk+jzPf/H2q742t9FpmE3wNmZVY4wKo5jswzvjWUw86
         CTe7cvQlsAKeIbCsPD2o7gy+Qy6UN3j9O86OGrh+rRvc83xQeSZ7TXEXszwqV6meVnBO
         y0z8Blx7kDP277DjKTUohV1XDzfMv2aNRONjMRMLeteAkeqLTxuI9s4EDt2moG2YRp0e
         DL9nF3vhFEGpBQv4ncjDyCXgld7UZ1XURUQFkFy1Jm1DsmxdmzQMRiKHUqFs8jsjYL2a
         1tiu+DYoIy7Z10jD1na6lUxGZsGEU9H8QqG8yt1JvcLf99AXJMX6sK0Pcuw26gPAJoaI
         VDoA==
X-Gm-Message-State: APjAAAX6tg1aijmkBnEbdWl7fHPJeujEx2fuV5OjgcA5rBOSTQFvVcQd
        TG3mV9acFL8rxtp9Z3xyDH7aIJ6H
X-Google-Smtp-Source: APXvYqx7IszEk1pYOL29HPzulpEjGxsQm+op+p/ytdOIE//fSwuoT0TLw/3U0yLhcOfX8JFCjao/TA==
X-Received: by 2002:a24:4d:: with SMTP id 74mr31379440ita.6.1555421881589;
        Tue, 16 Apr 2019 06:38:01 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c200sm9261818itc.43.2019.04.16.06.38.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:01 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDc0SI021235;
        Tue, 16 Apr 2019 13:38:00 GMT
Subject: [PATCH v2 13/21] xprtrdma: More Send completion batching
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:00 -0400
Message-ID: <20190416133800.23113.21675.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
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

