Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA411C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 88C1921773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QvrhxT77"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730461AbfDXNju (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:50 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:38518 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730462AbfDXNju (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:50 -0400
Received: by mail-io1-f67.google.com with SMTP id y6so8166217ior.5;
        Wed, 24 Apr 2019 06:39:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=RT9Sg459fsFTtdhFb8str0/xgzsx8G+CkmZbn9FgrUQ=;
        b=QvrhxT77oOEUthl4nX/VtiTfLMCsJ8gAAS7LkU/SIJBKMwd79SBfKDEdkcBuo27taz
         oiOW8Fd/r+bcRB9BqxjFo5eyKmN7Npe9eBVbhF+p0rNoIcSgBWKoKpqclU1a8nt591f9
         1ixgfPjY2WA5WaJ1N8kuEQn4CUGT7Ca+MgghfsT7bVIrhRTwk7KWcT9WXnKCUvJH5kI/
         kdK65d56i7CpIgDPImtszOfjrRGAS/O09RlYa7kqqH0PTvt4/pMSjRBcQclHY8PhCpRH
         Pya7xwJMrvouWvBqqI8WR/s6bIE7LxXbVfBWMatDJ9w6d8WmTAmCRKJDnHAQlwPMyyrB
         MayQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=RT9Sg459fsFTtdhFb8str0/xgzsx8G+CkmZbn9FgrUQ=;
        b=aEGeHvjDImdtNLDkgENJ6wB2R+GUb10G2DgBbau+2x5SB0LlNl4cvgEbhXdKmMYt+8
         tYXeBPzB00PAETwzNUKvoL9IQh3sHrcv32MnK9BbztyEMbteeuHpwIg0PBzKu//2pcWk
         9DSQoqHMJstcMpvBm1zbwUsFN/W1XQ1wmgzLWxOjXKh8YXIslWOoBFWXq4bP8HVj56pr
         gLtKDVKADqUJf8TqhJqpfBt/EXPkO+JSBMr6LrXEzxoFshaneloypZvaJIA1gHz47k3B
         s6qwXsfqa3c9hwFNQIrh9GKPhpjEtANZ9TNoL4O+FpPhHHsDBgKsn014BjTYea53CfpT
         jKTA==
X-Gm-Message-State: APjAAAXNYfvgDSdpnkWCa4Lsvz9KB+4f8ilZvwHbR+WZNWYV9tgJ7N9b
        f2NFttwRnvEtFHsX9B1ffAqe3bMq
X-Google-Smtp-Source: APXvYqyfudD8++Ee74kMZHPXMJUQO7XKshsiBBfNBThNtymR2W75RRxlsgESCrct2H5J2vxG7LtcsQ==
X-Received: by 2002:a5d:9285:: with SMTP id s5mr3221347iom.16.1556113189529;
        Wed, 24 Apr 2019 06:39:49 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e15sm261039ios.19.2019.04.24.06.39.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:49 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdmRp011301;
        Wed, 24 Apr 2019 13:39:48 GMT
Subject: [PATCH v3 11/21] xprtrdma: Trace marshaling failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:48 -0400
Message-ID: <20190424133948.5077.73761.stgit@manet.1015granger.net>
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

