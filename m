Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F5D4C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E984205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QaxrPxJs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E984205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727207AbeK0HBr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:47 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:37861 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:46 -0500
Received: by mail-it1-f193.google.com with SMTP id b5so29969247iti.2;
        Mon, 26 Nov 2018 12:06:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=WJCft5FxDer32qZ3DbsvQc/5A3WwRFsRVapIvLbxt/8=;
        b=QaxrPxJsyH85aW3CdNH964rVDDS38eacLAjb76m5sFbXrF5B+GgnhjmcNDLjhacZj2
         HLwXETMVyqZToTco7ULjtUbWGaYQG5iZqUljqDL1BsjkmNCghjF2uWY2lYOTqTa5lEZb
         4mz71T+NJFJG+R7asyUrI1/bJroZVwR4fsnzJS9YyHcOXy43QKYeWya7QMfBTCiOe5y6
         vCwmYY2Wn+th0wlTGf8CCi8LzN9u1AN2ReSAvnwR69HqHco9UBz3gudMV74UsWI/VemK
         9Ru/5i80Ya43gRvaP6lTPEuMOIvwwEVypuehOSvbys+PfcWp/uKllX2SUtdCehiy99W1
         MWJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WJCft5FxDer32qZ3DbsvQc/5A3WwRFsRVapIvLbxt/8=;
        b=HB2QiEexY0f3fztCaiu8j5fc0ANQjQr0Y7bImwG4b9lxAs+TfGJzXWvgs1ld5+xVoK
         o1VE79ME2uspxqrizACBEM90RTc6GicIHP6qylAQpIg3fsfp65Z2zV8ZhgkoqEmeeuuY
         3C3w5ZkXzKvF8ODXgnT59ZY5ZegKjS8jLhx24KNBaOW4TF+OaUdwf7axJCjcmw6+775+
         rymUH1Bt7qCZCDogHpUgyLGkJZhnwKxf4KL0TsY+qA07Kbvd6S+kj+xzbuwsZ0UXLrcv
         vXds7T8diXQTA9h20945pzYxAjGmKukdoLDAFeDoCL2XzSfrVcMZS4lZGocEwyrs1iap
         1kRQ==
X-Gm-Message-State: AA+aEWZeypJRRc4aVaAeT5XPLdtB4nDrhY9DOlVxB1z20hfXgY09OrU6
        1I8V3k5KKzYZHQjB1/veWb3XGc9j
X-Google-Smtp-Source: AJdET5ecKbxbT852ow0zUptLmvnW1L/IfBLq0CsnPJ7SW3SZZLJSX/7TkpDDCixjXXXOcO2hDazmRg==
X-Received: by 2002:a02:93c2:: with SMTP id z60mr24194507jah.51.1543262792175;
        Mon, 26 Nov 2018 12:06:32 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id z23sm442254iob.19.2018.11.26.12.06.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:30 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6T15010666;
        Mon, 26 Nov 2018 20:06:29 GMT
Subject: [PATCH v2 08/20] xprtrdma: Expose transport header errors
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:29 -0500
Message-ID: <20181126200629.10321.52425.stgit@manet.1015granger.net>
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

For better observability of parsing errors, return the error code
generated in the decoders to the upper layer consumer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c87e0c1..9993654 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1249,7 +1249,6 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 out_badheader:
 	trace_xprtrdma_reply_hdr(rep);
 	r_xprt->rx_stats.bad_reply_count++;
-	status = -EIO;
 	goto out;
 }
 

