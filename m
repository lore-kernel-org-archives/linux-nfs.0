Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F8E1C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 51FEC218FE
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RvhzSI+K"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727049AbfDPNhw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:52 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:34451 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728378AbfDPNhv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:51 -0400
Received: by mail-io1-f68.google.com with SMTP id n11so17631871ioh.1;
        Tue, 16 Apr 2019 06:37:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=RT9Sg459fsFTtdhFb8str0/xgzsx8G+CkmZbn9FgrUQ=;
        b=RvhzSI+KH+dO4QrsLn7GWOxJpQZRAUcN5349Sswjf1dhYv6Wz+BTNae+nRMjkwGskO
         ARihWP0K6Oc1IJaq8jGgsX4TUUo2d9hTgvDt96Rl7m/mbMxbqRbgEO+4dKo2f5VYr9xz
         +OzfBqEyaFNjJQrcq4m59194q+sgZRuJoMxZgbwaKFauA0g/t8mFwz7OyOONB0cHWI+g
         QT7JJ2Tm1pPU1IrE5UxxRQaMFNjQnWneXrnchVhDHW75S0M4dP8UWapDsYfh07lY3sNc
         ikAv5ePRWPBDiCRdZGXpzBEEWQf5UsogQIWlJcyJexUj8oF496WcGLBrFeAgu2NIrO0d
         NXGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=RT9Sg459fsFTtdhFb8str0/xgzsx8G+CkmZbn9FgrUQ=;
        b=f9S++Cedp6A5M0dKP9lcE5cJCpQWqhnZqI49h4o2qIf9p/4vQ1+4fZCik/G5GZMxcw
         b9s6xsC7PNHYkKu6MbylU8m2BTgg4g4rOtWVurnPRK/M97dn97Z7qSK7QE3L7e2xZOXg
         l1mvWgRcyGrL4wK78w+p4UWUooszIeW+Bjue/duYDPOUEwjxsPHOMt4NXd97qDEnpqhx
         kW4tUKRCMGivT0fiIS55nQmEg1ZtXi6znjg9gpKaQYtDvT/fF5K/kVcQjTFVMlLSoqNW
         y6sBJn93I2HeZCg6HX6yfb4X9jjRQ4Nlj3UY7kFwHRpBtM8s4a3n+k/CGDaL6UsrbVy3
         5LgA==
X-Gm-Message-State: APjAAAVsFOpWRuOuKzu28rdvdR2TiafqdysYVtSJSXdKhqPYbkCENXO9
        NS/uKk15S64d+lHSmmUQy208JXl/
X-Google-Smtp-Source: APXvYqwqa7j0n5nIkwZMHSAB2GOEOXATzFICvtdmcR0+d8//3c1gdYKTOXW8m8JMMUaXv7anyAl/RQ==
X-Received: by 2002:a6b:510f:: with SMTP id f15mr51011470iob.59.1555421870816;
        Tue, 16 Apr 2019 06:37:50 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l8sm19876317iob.39.2019.04.16.06.37.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:50 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDbniR021229;
        Tue, 16 Apr 2019 13:37:49 GMT
Subject: [PATCH v2 11/21] xprtrdma: Trace marshaling failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:49 -0400
Message-ID: <20190416133749.23113.10719.stgit@manet.1015granger.net>
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

Record an event when rpcrdma_marshal_req returns a non-zero return
value to help track down why an xprt close might have occurred.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   27 +++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c |    1 +
 2 files changed, 28 insertions(+)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 962975b..df9851cb 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -511,6 +511,33 @@
 	)
 );
 
+TRACE_EVENT(xprtrdma_marshal_failed,
+	TP_PROTO(const struct rpc_rqst *rqst,
+		 int ret
+	),
+
+	TP_ARGS(rqst, ret),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->ret = ret;
+	),
+
+	TP_printk("task:%u@%u xid=0x%08x: ret=%d",
+		__entry->task_id, __entry->client_id, __entry->xid,
+		__entry->ret
+	)
+);
+
 TRACE_EVENT(xprtrdma_post_send,
 	TP_PROTO(
 		const struct rpcrdma_req *req,
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 231a44b..45cba06 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -875,6 +875,7 @@ static bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt,
 	return 0;
 
 out_err:
+	trace_xprtrdma_marshal_failed(rqst, ret);
 	switch (ret) {
 	case -EAGAIN:
 		xprt_wait_for_buffer_space(rqst->rq_xprt);

