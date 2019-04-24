Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 199BFC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFEA421773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PIs7pOcM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730492AbfDXNkR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:17 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:43196 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727335AbfDXNkR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:17 -0400
Received: by mail-io1-f66.google.com with SMTP id v9so10660iol.10;
        Wed, 24 Apr 2019 06:40:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=dhUB9L+RkxQd6b2jTNWjnh1CNrb+S7u3LIGrKYtcb3I=;
        b=PIs7pOcMCASOCf36LivFE1dRT/QYXOxyJaeOOAMwjwytzfZ2JnhuD9qfA44yrLTl3a
         NWq9rUcqF4UwIRwXbV8HG6X97bcitu+GdHqXIQc/wq/YxoF0xrLkHNacf42Tiy3kHbwX
         ai/p8UdZAsEAP4tAzDXatxxeidTbHHUb/QB6/NFJguwLsCxhOo830z3ihA3S3tAwVopa
         hIAIDxeAd9R0eQ3aqjM2hr9phPIRM5PivnfFrICfjN/vmp8T0i1hE3liC3D/JD6quNYx
         b64zI2tRXqluqq4gV/6LTMkrSafN8cYOup0GDVE/rBhSl/Qwr2J4cHMVE6yyZaAp8Ti0
         RDJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dhUB9L+RkxQd6b2jTNWjnh1CNrb+S7u3LIGrKYtcb3I=;
        b=jOPf4kJh3ODp9MLEdPLOoxDS7TUsNzTZkgUUbI2Fkpq3WY0ZCs7LFLm5NsUOAp4+y2
         0FzylXa0JPTHHWxU6mAxULlnHqJ9+kIoa+V0L8FFScKh8dZN1vbuAPbD6BK9uHeLrVUT
         Khuqce60kgMbDrMMzXCLuIMt9i/wYKl9rJYGj6qnC1XenmJ8S1N5Yt3pmvYToyzUe94j
         tpAlaCGD1mDlXkoQqOQglQOQyLyqwlh5MrmZNV9kqknCpaLhcO298/JcJcOF48SAnvaO
         tAhpLlJhXS9lfvbx+j13k1qJ0CaySd4RmuHP/qLkAVIz8BP8ZmlKLtaxCDWG1bv8APTe
         olVQ==
X-Gm-Message-State: APjAAAW/iZmt3Utqf+IEhbi/zdivVOFxwx9QEfTHxNrvLVs04F0d9II1
        Kapq20vhw5rHdQ4Iu8YwB3o=
X-Google-Smtp-Source: APXvYqx/LVSne128ETIe21Efw4eJ26ZdUl06KG49hDD3O3L+XHnjpZknibgDQW4Mm3pJDqaht7amZw==
X-Received: by 2002:a5e:9307:: with SMTP id k7mr10597iom.155.1556113216523;
        Wed, 24 Apr 2019 06:40:16 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q141sm2335942itc.2.2019.04.24.06.40.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:40:16 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODeFtE011325;
        Wed, 24 Apr 2019 13:40:15 GMT
Subject: [PATCH v3 16/21] xprtrdma: Remove
 rpcrdma_create_data_internal::rsize and wsize
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:40:15 -0400
Message-ID: <20190424134015.5077.23806.stgit@manet.1015granger.net>
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

