Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E87EDC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B5EB4217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iwDcZXF+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729060AbfDPNiT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:19 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:38293 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbfDPNiS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:18 -0400
Received: by mail-it1-f194.google.com with SMTP id f22so32536959ita.3;
        Tue, 16 Apr 2019 06:38:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=dhUB9L+RkxQd6b2jTNWjnh1CNrb+S7u3LIGrKYtcb3I=;
        b=iwDcZXF+MjKZEQnJ65nf3DHANhnnMOYx2+Iy8uWTjEpQmYoEZhM+xZRRnr4WTXrq60
         RpEcsooOtM7owD4HQaaJuigT4IWbWn3uSPwD11rQMBw4Q/oCyBb34IXhVw/ueBfROrFv
         bu/zFN3fWcIOqOVcdrGQqxvgkcW0I9eC7J0AKR/g5Cppor3nkiFfDx3/oqLZU4P4OorY
         eXtncoxEjZQt3aPS02J6eAMUxRRo05apNyhjTL+x9H0YjYC5XW/rR1iWsaUN7Fn4ImpO
         Llz2p3EsAz7lFOlhS1/udtR3km6JYqM7ITstt+7VQmgdiuVkrF/f+yZr2t0P5tftAUv1
         8jzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dhUB9L+RkxQd6b2jTNWjnh1CNrb+S7u3LIGrKYtcb3I=;
        b=neqBVPLvNqu7ZtZDW5rEnNAz8110jIGrJg7pobUeNO2oNMk3g4DkCNLhIDvBKp3i+r
         NXbK6FUxpWJVfAZfCNq/RBEZD+/rpTHIUKoFhvM2CNxx7wfTzOhQbnzTdFxDcxUyLiZ6
         tXCBKkyCV1Jfx8GvPAkUojD9onFeQFX7xGuj1bNHfGB5pkdgsmASAl6Jfq9G4CkwDbnK
         lhiN521+FyvbQaxYFTdh6Ld2dqEMJzaIffU5b9SvggQRIZsKd9L+WElxgvMDUj86gR3E
         eSWqju6G02/kNdGg8i0qGeVJOPNVeNVcGvULT+TF9La/5GDS8VQQ6yM15WkM7njCtrk3
         YTlQ==
X-Gm-Message-State: APjAAAVuyhRBu/bnFcIFnM7kYJBFZUrsf4zEtXFww0faiQHZZOLwlaxP
        HqU9EfN6HBXH1wZtIR2RkxoPXvdg
X-Google-Smtp-Source: APXvYqz+o9Bj3/pxUz8m3CafRQk2mNscnL1cAgdu5DpWS0MIij2X5T3yHhWy4iD/zgY/dLA5T4g82Q==
X-Received: by 2002:a24:1908:: with SMTP id b8mr29549139itb.136.1555421897928;
        Tue, 16 Apr 2019 06:38:17 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b8sm9836843itb.20.2019.04.16.06.38.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:17 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDcG9I021244;
        Tue, 16 Apr 2019 13:38:16 GMT
Subject: [PATCH v2 16/21] xprtrdma: Remove
 rpcrdma_create_data_internal::rsize and wsize
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:16 -0400
Message-ID: <20190416133816.23113.56168.stgit@manet.1015granger.net>
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
index 40912bb..d34371d 100644
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

