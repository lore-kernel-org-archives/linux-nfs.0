Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E02C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8D05205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dHvxGuNx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8D05205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726665AbeK0HBm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:42 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:39973 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:42 -0500
Received: by mail-it1-f196.google.com with SMTP id h193so29946240ita.5;
        Mon, 26 Nov 2018 12:06:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Yg+KpYerdb4ZgC+4/9tk/p+8dDsazTNW2qtu6AT1QBU=;
        b=dHvxGuNxdnhrM8bH/nArVCOp04Z1uYlNOjbhlEoL/hgza0O1xMZuCXR0X3QOJXV/ta
         i2H8PqLJ79aqoJc/93F1Alx0cima3K6X31gxYUQPAoCj73/WrBMHJu/QAgc2zqbhsstc
         v2DV3QQpZSrcFE//gPmePm1fYtf59J7vwQ2tZrEXZOdMnMyP5QXSEkrfFEm8VOz4z2hK
         NbOiELSSFpjj2IEtazMUbFCUR+nfidq7T77PeCUahQ4zapLBdgyZpogm8NlOH1TszdoX
         HcVKhWalXxRVaARXNuu8MIqWAOAkJrPeKr9snfDoyr4K5QMHFmWt2W5XHGNRFkad4oFu
         fbhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Yg+KpYerdb4ZgC+4/9tk/p+8dDsazTNW2qtu6AT1QBU=;
        b=lGthvybbTs4JWPneyBrZazqT8Sj0EXf+rS6MbP7N13pYf6dxhxtyMOEof+zLf82FE7
         oq14h6lNofnatEVaXK6Woke5Q0bkCWwbEWD+dLo+DNHwOIV/0Zjb4fRHQGwpUWnc5cub
         9bkFF/sevUtaGU9JR0BV15JSNFbXRwzxE68R35kEHeZukB+pTAS5evHp87+zZqtX8+oM
         rsHNM96afNnplcHXYT/NrAWlYbFFwJMGPx+EJVwPBQx7g2+RqTVWj6LZ6ABtz030Bcr8
         AhxD85CtMbf+nDfRZ+V2KqufA6TAyDYgKGqmmNaUSEW/7JB6dMYnE3lGFhRJ4Dr0XsBd
         QCng==
X-Gm-Message-State: AA+aEWZ/VSbk1A+pL02tVxcldtYIemvfJVZWuY40f9BXlHKMBymyz5DV
        flr+H7CmwqWidynisJJ5UXL4ythF
X-Google-Smtp-Source: AJdET5eNAQjwGpTNsuJowli/J0qioUjA6mEwhLtnlO1P2xDXFfY5BnmZ4DpNEQWpBv4L/JRMTRFODg==
X-Received: by 2002:a24:8244:: with SMTP id t65-v6mr24134745itd.3.1543262787052;
        Mon, 26 Nov 2018 12:06:27 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id z1sm454237iog.57.2018.11.26.12.06.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:25 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6Oeq010663;
        Mon, 26 Nov 2018 20:06:24 GMT
Subject: [PATCH v2 07/20] xprtrdma: Remove request_module from backchannel
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:24 -0500
Message-ID: <20181126200624.10321.77804.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since commit ffe1f0df5862 ("rpcrdma: Merge svcrdma and xprtrdma
modules into one"), the forward and backchannel components are part
of the same kernel module. A separate request_module() call in the
backchannel code is no longer necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a..e31cf26 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -5,7 +5,6 @@
  * Support for backward direction RPCs on RPC/RDMA.
  */
 
-#include <linux/module.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
@@ -101,7 +100,6 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 		goto out_free;
 
 	r_xprt->rx_buf.rb_bc_srv_max_requests = reqs;
-	request_module("svcrdma");
 	trace_xprtrdma_cb_setup(r_xprt, reqs);
 	return 0;
 

