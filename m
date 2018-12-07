Return-Path: <SRS0=0ybF=OQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA7ECC07E85
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 16:11:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 85F082083D
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 16:11:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F1Q+ZENy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F082083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726055AbeLGQLr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Dec 2018 11:11:47 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:32957 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726053AbeLGQLr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2018 11:11:47 -0500
Received: by mail-it1-f193.google.com with SMTP id m8so1896668itk.0;
        Fri, 07 Dec 2018 08:11:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=QN7bGha7qbfgCpb9IluQxWRkbuKPO03YDrqWYdpMmTs=;
        b=F1Q+ZENy9XfeN6kApmNF9prazwlkzA7jTQiIZtcUAMHnhveWkvhwYKi9RkYXJZbAQ2
         HKaPMMhLJF/AsEm3ALXlV+sLl2Ajb+qfTjphuStTcjzFPikSD7qvNWr9iWxFq7zp+8ng
         wIFrqSADEC8dvyKkO5uaQS7aUM2vrD3hai85nT5gcL1Ws/MDRSupYjqGACQwKbASzQZx
         ec8vBCeFD26E7szdojcoi751z3vKJWA09nbNhCojUMVTpu9Z3zQ02imU05m31frO4uEy
         6mY0nUHe0QQGeVZgBP0lG/AnUA8GcqDyyu1/FZNzA7BFsB2A8rqvbz82y3HknoG4VKH+
         Nclw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=QN7bGha7qbfgCpb9IluQxWRkbuKPO03YDrqWYdpMmTs=;
        b=Kq89QogynPDkHa8bNU4a8vnaA1wObTeqwlM1Ygw3dh8UdiNy9K3xf4/MEfwP0KBEB9
         Hfmwjz1xyX18QxVv28kig4iHmx/LyDDFoLH2/cg24z01H4AyJMr89vqVII6iGwMUy8cr
         ir87sf5cr48R50FbrzYf31lZ4w/VaNKAgHqRefz+mIpKbfF2w3iXDqDP0GVx6y6VutLR
         kgOOvO6IPb0JCq7IQPxaAiueAktg3TdJC4CiEoFlhz9cuxAwbSfh1kbvBfQBv9gylUWc
         zqKOBj3kF2cZD4CpfdyjmVcOEjGNgeTnrbTCLOpbyZIi7qR/RithEb2UdSHOwOrMCGf3
         F5Ug==
X-Gm-Message-State: AA+aEWaU1P+M+cSbkJ5dgC2A/PxbZJh5WyUartzZw0fJzQLjyeW4ehzy
        JQ6+00bLUmtEAHAu/OV41Jk=
X-Google-Smtp-Source: AFSGD/X5OQ9xGGLyIUcHG+7KSmkA64l8hlqLV9juAI2U0LYDsF7OkmQBWEH7wiCWiTm75wD8v/pYUg==
X-Received: by 2002:a02:5ec9:: with SMTP id h192mr2275889jab.112.1544199106810;
        Fri, 07 Dec 2018 08:11:46 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l186sm2013249itl.22.2018.12.07.08.11.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 08:11:46 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wB7GBi0b022504;
        Fri, 7 Dec 2018 16:11:44 GMT
Subject: [PATCH] xprtrdma: Prevent leak of rpcrdma_rep objects
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Fri, 07 Dec 2018 11:11:44 -0500
Message-ID: <20181207160645.5494.42006.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a reply has been processed but the RPC is later retransmitted
anyway, the req->rl_reply field still contains the only pointer to
the old rpcrdma rep. When the next reply comes in, the reply handler
will stomp on the rl_reply field, leaking the old rep.

A trace event is added to capture such leaks.

This problem seems to be worsened by the restructuring of the RPC
Call path in v4.20. Fully addressing this issue will require at
least a re-architecture of the disconnect logic, which is not
appropriate during -rc.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Anna-

Would you consider this fix for v4.20-rc please?


 include/trace/events/rpcrdma.h |   28 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c |    4 ++++
 2 files changed, 32 insertions(+)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index b093058..602972d 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -917,6 +917,34 @@
 DEFINE_CB_EVENT(xprtrdma_cb_call);
 DEFINE_CB_EVENT(xprtrdma_cb_reply);
 
+TRACE_EVENT(xprtrdma_leaked_rep,
+	TP_PROTO(
+		const struct rpc_rqst *rqst,
+		const struct rpcrdma_rep *rep
+	),
+
+	TP_ARGS(rqst, rep),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(const void *, rep)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->rep = rep;
+	),
+
+	TP_printk("task:%u@%u xid=0x%08x rep=%p",
+		__entry->task_id, __entry->client_id, __entry->xid,
+		__entry->rep
+	)
+);
+
 /**
  ** Server-side RPC/RDMA events
  **/
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9f53e02..a2eb647 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1356,6 +1356,10 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	}
 
 	req = rpcr_to_rdmar(rqst);
+	if (req->rl_reply) {
+		trace_xprtrdma_leaked_rep(rqst, req->rl_reply);
+		rpcrdma_recv_buffer_put(req->rl_reply);
+	}
 	req->rl_reply = rep;
 	rep->rr_rqst = rqst;
 	clear_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);

