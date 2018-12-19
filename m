Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4A22C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9431A217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AIvuUtAt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729503AbeLSQAk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:40 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:54938 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728222AbeLSQAj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:39 -0500
Received: by mail-it1-f195.google.com with SMTP id i145so10389900ita.4;
        Wed, 19 Dec 2018 08:00:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ea5IaX7FdfMfgKFJZJOKeKRVfqNhaR9riT4maJPGG2Y=;
        b=AIvuUtAtyonr+v9DCHN+LPCDJHHMhv09UO+HnYVIXvVlrV8Kh8qNmpXgOlls0eJK1D
         g5lqo+VG4eoSFEcxXVbF2UttP6lgU4/nItRoSLkCkOSBv6SraV3TTwc72zRa/4FdgksV
         uNGRUSuuHVKBKRomWL+cO4APJyy71Y8ayNYccU4FB5RVzUBEYdaePZLtdbADdp17CPUl
         Vp08DLkD7TwmSjttJg+4/myzJ/yOoWx1bocG6V0ZdhrIpAKF7kvyRPGHfPd6FE+IYg3x
         UkiPRvEZVvaB7lSxxvBfUYEcuU2xvUVm+cF9RKQsJAPma3DN66+dYSAWiQQm1qKPBKbp
         h+fg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ea5IaX7FdfMfgKFJZJOKeKRVfqNhaR9riT4maJPGG2Y=;
        b=dFZ+P+Cj0kP+z0D9a+c/HhtzwBXpqqBC+ZWIBpUaM+z+aiR6g4OLzWn4ZqUh+G9wRx
         YsC7vTShKfCPL2m0y5rSsb7fHvLD2lCFrJFJmqdCpr9a1nbRNSS5lQFviR9SUehrILAA
         M2kpPNDmNTd55E2xXfifBnHwGOLkFEhp2WgN5naxvjgk4UvywqlE0LJXphg5pfAdVOpn
         yKqd5ipOMZL79gfXWKseD9UuOUUxvOfbgkx6lqcP+F0rtQ/HXVsYDjm9z4VvhELICESf
         5+kzFogCdFnVuJ2rhMlWxQ3gsg8ZyBOoO1wcVrLkUj/1MCDdpWrHFwz1iHe4qw44wzv6
         I2bQ==
X-Gm-Message-State: AA+aEWZornKvXsnh/mqHITKw3eYarf68NkStdWqY3vHLqoCPzl0VAys5
        rMvmxjnk4fhrmynIvmx0Yzs=
X-Google-Smtp-Source: AFSGD/UQ0egqMkM6N9mRvZRVviP0WVniQht+osppbgWAKqLY03GaPX/LM/zMmrOYbvJOGA4iHHi9LA==
X-Received: by 2002:a24:2c42:: with SMTP id i63mr6989756iti.22.1545235238912;
        Wed, 19 Dec 2018 08:00:38 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t129sm3411307ita.4.2018.12.19.08.00.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:38 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG0bct025850;
        Wed, 19 Dec 2018 16:00:37 GMT
Subject: [PATCH v5 28/30] xprtrdma: Add documenting comment for
 rpcrdma_buffer_destroy
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:37 -0500
Message-ID: <20181219160037.11602.90097.stgit@manet.1015granger.net>
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

Make a note of the function's dependency on an earlier ib_drain_qp.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 11976c3..7749a2b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1177,6 +1177,14 @@ struct rpcrdma_req *
 	dprintk("RPC:       %s: released %u MRs\n", __func__, count);
 }
 
+/**
+ * rpcrdma_buffer_destroy - Release all hw resources
+ * @buf: root control block for resources
+ *
+ * ORDERING: relies on a prior ib_drain_qp :
+ * - No more Send or Receive completions can occur
+ * - All MRs, reps, and reqs are returned to their free lists
+ */
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {

