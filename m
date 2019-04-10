Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC447C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB5FA2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l1PSeR9M"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726527AbfDJUHh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:07:37 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:37077 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726041AbfDJUHh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:07:37 -0400
Received: by mail-io1-f65.google.com with SMTP id x7so3317005ioh.4;
        Wed, 10 Apr 2019 13:07:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=sVsWomdvb2KsEbnQQRQDATsMY0fxPPPWJG8nZv6v2HY=;
        b=l1PSeR9MAJKYpEA2z6tF/q93+U6gzPVEkWprKg7Uv5Lv3jF3Zb0FxnCtYZ/ilKwm6t
         IeXyuQmjwb3he58rTjcixtt4v3ovAVwabEOogIEwzfmtQ9opnU8QPtJ+UuZdsZcLAscH
         k9em19DxrGHPXP/YY/1ZwNMXkbcYMHp6//6cBNDljIPcWyHK+SdwPxcWMmWKx0Yb+Gfl
         SFeZyezsm6GPjz1lWPY9oTWCMG2y1khqjVdEQZpYQ3FLPCpRt0UvQQSqz7FMe4+dmeBh
         Lb+gvMd7tpxF9bQ8Z8Ii2iBG3T5ufaY3jV7YJI3bASLm5dgwTfwfDn38s+tc5COMsCx7
         juUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=sVsWomdvb2KsEbnQQRQDATsMY0fxPPPWJG8nZv6v2HY=;
        b=uC2wk2s/pPfcreo1yjLMZNX+UvHw2w4sFOTzlgnR02rKE+rnM4h+ktZGHYVr/O3LIe
         AU56VD4WjXQHGWtkdF4rKiovvSvpE+SdldS1OsIqZGmqraQRWI6Wpv3W2XRXyef3KdUJ
         2TYRYPztkqsqCPtxRRXrLGYajPO6ZepOVSnWXXeLKXik08fD0t7dT75ScoF+nJ66ltn0
         oCKZqd2kdslFGCgVN95A8e9xiEk9nR+1EMRCOl6UWFK5LG3pGohhRvwYy/V2EQ/lTIGG
         5oR8H9IsfTfh4U/zMLo1ZQF/ZipUjTiCqTVy9AzGdXn30edCCzfdD/vQcArCfeDBI1B1
         qdfg==
X-Gm-Message-State: APjAAAXOl96QQTbsMDyKY4p+eo2mITWBmFUm/RE1NVk5aohutNkX4FGf
        q3Zkl+UTQKRVWkTx4AUAmTpJq8mD
X-Google-Smtp-Source: APXvYqxwcsKIKcUITvbyHlKiOeG73wUACtJCWNvdQ+XVD1u4JzkGPMP+EY7UrNzkTdpXQA3hdt+aBA==
X-Received: by 2002:a5d:81c2:: with SMTP id t2mr27344884iol.183.1554926856738;
        Wed, 10 Apr 2019 13:07:36 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id i11sm14066509ioh.58.2019.04.10.13.07.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:07:36 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK7ZiC004540;
        Wed, 10 Apr 2019 20:07:35 GMT
Subject: [PATCH v1 12/19] xprtrdma: Trace marshaling failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:07:35 -0400
Message-ID: <20190410200735.11522.54541.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
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
index 20b0df7..a3eb299 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -875,6 +875,7 @@ static bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt,
 	return 0;
 
 out_err:
+	trace_xprtrdma_marshal_failed(rqst, ret);
 	switch (ret) {
 	case -EAGAIN:
 		xprt_wait_for_buffer_space(rqst->rq_xprt);

