Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2476C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C1033217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S9S0MSZ8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728658AbeLSP7r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:47 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:55936 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727847AbeLSP7q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:46 -0500
Received: by mail-it1-f196.google.com with SMTP id m62so10361852ith.5;
        Wed, 19 Dec 2018 07:59:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=StkroiHWqjwZDypuPifDbqaXAXLZOjOVYFFxVK/ZTNY=;
        b=S9S0MSZ8NjbX6GoX/RYgaLD93SpOytgCZujOrkwRtf/2M9nzhlx+6dEcw/4yyX5hT5
         yj0ZwSDwmcAKvHwSNMqu3wqQW8vs2cnAqXfYQqCSmpb1nr0yxHKd7jABH5GbjS/9ry0s
         2YKy5UV0z2c/voN73FL05dFYCmsSe6XW/ivaUEhh1YF3inMNonZ/H+zDI0+TltHfmS2u
         ElIcb6PejIFNid0wEXviB5sZePhFMAU98L3M6+SYCUwektKk7nw4frMYQe+7ApNLTjqg
         tbgsRBvyCMQ7UMPb/iwuGFHA96NjdFwx6umPLpFzuR5W+3k98iiJZebrMFpRi0z0HRJw
         t8gg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=StkroiHWqjwZDypuPifDbqaXAXLZOjOVYFFxVK/ZTNY=;
        b=UYQxh8mtRqZLlL1+3b6eYThKgIvMmhqcNPbUWqST+tUWJZYih5BzXKSHmDKcijNzLO
         Gyvdd2X7DTQzy49QiG5zi+NVcSiUOiOsNzOSyy8SuhyAQGrwfsmOpBGsrknTlJswGP8H
         XJh6bPvcSryf6Awp825n4Scs87SSdOLkbRY6ga8Vqa9gMYEBakt69w7O2AY64kYhPf6M
         IcGP03WIDXZR3AgSxMQIt1qE8Whw4zVysXQT5LeWcSaVtNacRaHi3tATT66CoEovyvQX
         mMDoGZdBu1UUgbx1g+Q5Je8y5eO08BqeLOh4oOQJGEu2aMz7+eSacgAx4yqiK3nLq5M+
         qq7w==
X-Gm-Message-State: AA+aEWYquLcxTX1UgyB+zJb6FLrgbn9hjoJB3N6J4xg/3VAkWvzY8uVx
        8iilqo2xzWumsGMHUiu3HLM=
X-Google-Smtp-Source: AFSGD/UzrqLl6L0KRY0FC+Q2bJek8876XTHcFb/7Q8M4MJDlaHWgxCRn6LQknrevZgyFATCz2eMaxA==
X-Received: by 2002:a24:c8d7:: with SMTP id w206mr7225901itf.56.1545235186132;
        Wed, 19 Dec 2018 07:59:46 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y3sm8440919iol.55.2018.12.19.07.59.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:45 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFximE025810;
        Wed, 19 Dec 2018 15:59:44 GMT
Subject: [PATCH v5 18/30] xprtrdma: Remove unused fields from rpcrdma_ia
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:44 -0500
Message-ID: <20181219155944.11602.77732.stgit@manet.1015granger.net>
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

Clean up. The last use of these fields was in commit 173b8f49b3af
("xprtrdma: Demote "connect" log messages") .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a1cdc85..90422a6 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -80,8 +80,6 @@ struct rpcrdma_ia {
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
 	unsigned long		ri_flags;
-	struct ib_qp_attr	ri_qp_attr;
-	struct ib_qp_init_attr	ri_qp_init_attr;
 };
 
 enum {

