Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B5FFC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0BD27217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LbcmEpST"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729507AbeLSP71 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:27 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:55875 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP70 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:26 -0500
Received: by mail-it1-f195.google.com with SMTP id m62so10360278ith.5;
        Wed, 19 Dec 2018 07:59:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ZiDd9RCmQU8CJXpqpGBxGDa6t1ND1vxS8BmAbpd1q9M=;
        b=LbcmEpST/hd6zhX2obk5SoKlGPnJ9RyopgWoM+m63/HhaaKZkscjfXq36g2jm9pRYo
         TQYVVDoFC37ZajCof/29FIMT+q9KKExDTJd1gz6R6jdHtT9ZjN0HPjRw51FG2328V/ui
         z6WIqKPOdesE6JRJQ49HLOgjgMDjR8apjREtYm6xzZy6TZUxwmtdmOvXaOODAdD/+bQV
         B0bk0AYD39ARRyPD2MmUt8H+iGmX52Sj3+leXLKlv3n+VT8Wkh4iuKuDVR7Gu+jywpSD
         d1MB3Mlfx8CKAzkLxJX5PLtbz+BdC7VfA9jN/0HFtMkrzfmDDJ+AMdZuzr1sVsTfDyo2
         aKEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ZiDd9RCmQU8CJXpqpGBxGDa6t1ND1vxS8BmAbpd1q9M=;
        b=KlrXvEnTHfCP4rsulyFM3I0/J6FwBGvqpdynmsI9w6rukqpMvEvK6760rvI57eJPl8
         CC42kqGv+ee7L9racYzre70N3sfnmfy0UvkMPEfgcyBmu/tND2uyqocYMocjYdFHC3ro
         UMlzyLMjaE7dof6OJOajoqoXuBgoeXQmqJBr3g7MT2+nXyuZh2wg0jFMZWWSjfzlcjsA
         tyKUCWKJWq4omzw0YTzRAxX2chhv/8tB4H4SBEjgQec1KUVCWBDnWgNWi3F1aaXREO1A
         35o4Aiq9rJGy7w0aTtf93xPPhOvm+az/5BwukqHaOBPHmQmIPJHLqQfkD5RDv0YwRRmp
         +y7Q==
X-Gm-Message-State: AA+aEWa5hWpatblO72zEsKvPIcSCgj4ELNprbCH86pF/O+Act4wSd6mB
        i5lqzeChAntPCWYzRye0Y/an5xd5
X-Google-Smtp-Source: AFSGD/XhaF4ZlAhFeflxcXNhYyuq68t0NT7Cwam5Aw4XrvzcDmIL2dwatq9FFxh61uCipZHKg8yLAg==
X-Received: by 2002:a02:b015:: with SMTP id p21mr20608939jah.17.1545235164468;
        Wed, 19 Dec 2018 07:59:24 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id a8sm530915ios.9.2018.12.19.07.59.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:23 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFxNOt025798;
        Wed, 19 Dec 2018 15:59:23 GMT
Subject: [PATCH v5 14/30] xprtrdma: Remove request_module from backchannel
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:23 -0500
Message-ID: <20181219155923.11602.64778.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
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
index 79a55fc..e2704db 100644
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
 

