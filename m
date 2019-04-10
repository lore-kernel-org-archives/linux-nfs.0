Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F1CC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:08:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 46F1F2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:08:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EySTM4xC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726770AbfDJUIE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:08:04 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:36027 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726023AbfDJUIE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:08:04 -0400
Received: by mail-it1-f194.google.com with SMTP id y10so5638673itc.1;
        Wed, 10 Apr 2019 13:08:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=B6A8zHm3un0ofqbatgyyr9CCSvtki4bJSw6ryOCrB9Y=;
        b=EySTM4xC2VlAxURfIY5thraGUlSNDK8IiKaEPz0Mucr0+OrbYip2IakYdsEPKgge/M
         RkvzOtY0ktRolJb5V/zPipfAQ9or1VQNSLfQNEbwt6mOyd3J3NQULPc3bSsvuUXWLh7s
         o68bLmFYl7vLNYouOSuM/3epemWMG5AyKPGHqaK4uoDFEI+pem0kgJrDf8GzXirlO+DO
         6jThmLgJ/UENzm7t+zJ9e0oiYSsS/USGTHtnc9SnOKCaDfhnML9eRl5+yAu/mh+9kt1n
         T8xk4TXCN7/zQklztk7IfJnW3eN9ayorXVz9pW627B4VGghBaUapqFi3ChCYfZxL+PkD
         VKnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=B6A8zHm3un0ofqbatgyyr9CCSvtki4bJSw6ryOCrB9Y=;
        b=oZocIeQTqxHd3FKoecsX0fw9XTW5ib9byHDrhOKY475T02FVzP4H5J7vXYsx1KVX3L
         bkvEsoEYbgT4Cls7PMUMXrnXmtozZTTVRcQFWv6ZmvWmvrSBdH1Ba8/p5Mj56+vWIQkS
         RWm10C0UF9sVXppFhKSw16kDsG1qIZiEC53OpCmXABMoYiNcMtnN7iT2s+BgWmE3R4NN
         xVqfFHG6LtUULM8hB2dQaGFpD7C1WApIy/lNGYWwC9+GYV3jn2XhSN0ZSwkib5+Xpu6P
         wM4cOJrqWkEVdsUv1OGkdcWSnwyeu9h8WXuBzBWADn8/AFnr/vGOTbd+V5AEV+QeYA6x
         Bpew==
X-Gm-Message-State: APjAAAUZ/LdIEoooXOSjGMAns3kqRtGcXlKHY5pXSNR0M1H63ezAxL/X
        nlWx7EcDwzafWfAbbIS7cDeFiyik
X-Google-Smtp-Source: APXvYqwvqyolo8H9yH62NfGWt0NuMF+6ixqdvUqJKcEZkhKcfPIcCssZS7K3IW7f7QffWH6nwUt87Q==
X-Received: by 2002:a24:438e:: with SMTP id s136mr4934754itb.110.1554926883658;
        Wed, 10 Apr 2019 13:08:03 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x6sm14010802ioa.50.2019.04.10.13.08.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:08:03 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK82Xn004555;
        Wed, 10 Apr 2019 20:08:02 GMT
Subject: [PATCH v1 17/19] xprtrdma: Remove
 rpcrdma_create_data_internal::rsize and wsize
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:08:02 -0400
Message-ID: <20190410200802.11522.24875.stgit@manet.1015granger.net>
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

Clean up.

xprt_rdma_max_inline_{read,write} cannot be set to large values
by virtue of proc_dointvec_minmax. The current maximum is
RPCRDMA_MAX_INLINE, which is much smaller than RPCRDMA_MAX_SEGS *
PAGE_SIZE.

The .rsize and .wsize fields are otherwise unused in the current
code base, and thus can be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    9 ---------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 --
 2 files changed, 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 47d2e00..f362642 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -350,17 +350,8 @@
 	xprt_rdma_format_addresses(xprt, sap);
 
 	cdata.max_requests = xprt_rdma_slot_table_entries;
-
-	cdata.rsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA write max */
-	cdata.wsize = RPCRDMA_MAX_SEGS * PAGE_SIZE; /* RDMA read max */
-
 	cdata.inline_wsize = xprt_rdma_max_inline_write;
-	if (cdata.inline_wsize > cdata.wsize)
-		cdata.inline_wsize = cdata.wsize;
-
 	cdata.inline_rsize = xprt_rdma_max_inline_read;
-	if (cdata.inline_rsize > cdata.rsize)
-		cdata.inline_rsize = cdata.rsize;
 
 	/*
 	 * Create new transport instance, which includes initialized
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 99f7e54..c1e265a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -419,8 +419,6 @@ enum {
  */
 struct rpcrdma_create_data_internal {
 	unsigned int	max_requests;	/* max requests (slots) in flight */
-	unsigned int	rsize;		/* mount rsize - max read hdr+data */
-	unsigned int	wsize;		/* mount wsize - max write hdr+data */
 	unsigned int	inline_rsize;	/* max non-rdma read data payload */
 	unsigned int	inline_wsize;	/* max non-rdma write data payload */
 };

