Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7182C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 18:22:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9AD97206C2
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 18:22:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B+4iRPbI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728457AbfAPSWN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 13:22:13 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:35430 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728454AbfAPSWN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2019 13:22:13 -0500
Received: by mail-io1-f68.google.com with SMTP id f4so5691511ion.2;
        Wed, 16 Jan 2019 10:22:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=8quqRTuMsQSTo0L7IakZo+VVOCrf1yotFc0t9qJe8zk=;
        b=B+4iRPbIyUyt/WrIwJGb2TFvfNbVwxqdVgx6bQodso9bb95mvER3RbkcK3UkQF5s2X
         0uDyQaIENAx57eEa/ysPV5AXpC9QZL/T959tXuZN2t0fuEfZCAJKvL1TLRieNBjoWwrw
         I/GqDiauaZuA50DzLrPAwfyia8S34xAUczZqDHgkcpSgQLW5OgEICxTjylgD89Nd0Mro
         cKvs3v0q93W78lPaLCeevybXfpfCaoeHLLWqKCSXdCESpmZmZo4W++uO/ljEXnpf+fM4
         bsYvn21fElW0U5crSV9XfHtmm1Bz8LMIsGMYZuyxN5Eusp1ZbSN5xUk+q0ff1YC2yKQt
         zeBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8quqRTuMsQSTo0L7IakZo+VVOCrf1yotFc0t9qJe8zk=;
        b=N82w+Gl6MsjT50x2/ptQTrzrj6InEKvIupnDSbDDF7/tSa5lNsAiRCutl3Xffwsebp
         2Z74Sch+V0nKYI61sbjo7/Nl0Un4K1bJuYYcQc2ntIT0nV8koi5xp8gCIZoxLqv/9r4O
         5jxTE81UdlhHSDKZpqmSOV+PgiLIwwrx8eJoWD7DdOKmQ2KWrJWfU7EZ0ec3uEabPVoN
         F7QqE5XQc+Owt8372Y00vzdSbKK5wSCIoh7FvJ5tF9PNoDH2h64LvhLYMMvB/OwwrNG2
         UcbYhPqvkwyCkwR90tC63R6KCMj2vnp2CSggLy5vxKY+9jIdL43ufxmJOqRZQXMFxKe1
         Bgyg==
X-Gm-Message-State: AJcUukciWW9ndxMNCdYyfJVWcskOSAHgUEas1A8lPYbDKaTOmAaQ0hkO
        SrRMwF6aVAOElIoxq835VVjYWVQc
X-Google-Smtp-Source: ALg8bN6E6vFwGJHQocgPZIKnvwx39O0sECrYiVHIWll7EOzdDkdnh6cecG18va8eJU0kIyQu8b2zyA==
X-Received: by 2002:a5d:870b:: with SMTP id u11mr5583003iom.168.1547662932434;
        Wed, 16 Jan 2019 10:22:12 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o63sm3394874ita.8.2019.01.16.10.22.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:22:12 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x0GIMBjs013773;
        Wed, 16 Jan 2019 18:22:11 GMT
Subject: [PATCH RFC 2/2] xprtrdma: Reduce the doorbell rate (Receive)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 16 Jan 2019 13:22:11 -0500
Message-ID: <20190116182211.4345.14286.stgit@manet.1015granger.net>
In-Reply-To: <20190116181954.4345.87842.stgit@manet.1015granger.net>
References: <20190116181954.4345.87842.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Post RECV WRs in batches to reduce the hardware doorbell rate per
transport. This helps the RPC-over-RDMA client scale better in
number of transports.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    2 ++
 net/sunrpc/xprtrdma/xprt_rdma.h |   11 +++++++++++
 2 files changed, 13 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7749a2b..0d3ec6f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1482,6 +1482,8 @@ struct rpcrdma_regbuf *
 	if (ep->rep_receive_count > needed)
 		goto out;
 	needed -= ep->rep_receive_count;
+	if (!temp)
+		needed += RPCRDMA_MAX_RECV_BATCH;
 
 	count = 0;
 	wr = NULL;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 5a18472..47ded5c 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -205,6 +205,17 @@ struct rpcrdma_rep {
 	struct ib_recv_wr	rr_recv_wr;
 };
 
+/* To reduce the rate at which a transport invokes ib_post_recv
+ * (and thus the hardware doorbell rate), xprtrdma posts Receive
+ * WRs in batches.
+ *
+ * Setting this to zero disables Receive post batching.
+ */
+enum {
+	RPCRDMA_MAX_RECV_BATCH = 7,
+};
+
+
 /* struct rpcrdma_sendctx - DMA mapped SGEs to unmap after Send completes
  */
 struct rpcrdma_req;

