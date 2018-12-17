Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73A62C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 35A132133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DBQc6kPR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388284AbeLQQld (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:33 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:55654 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:32 -0500
Received: by mail-it1-f196.google.com with SMTP id o19so19443813itg.5;
        Mon, 17 Dec 2018 08:41:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=P/q4RnJj2efKP18/p35VQ/p0eIvp2esguJVWydMCWg8=;
        b=DBQc6kPR1/LIY97opEJsiaBmbxcI2fT+saYpHXDhomoQKm/TlmRJxIoB2tSn129fXb
         qyuqZNxMWnyexvHZux+tuCp/aovwZDl44WpVxct6dHBdclcrm4KFgsc6n5Ka2V+bura5
         cDOJyS1sQnfPVCZED070K56HyE1QpLgdfo6eOWEYcQs4JvLRHKXeHZFCHBVBJyxossZM
         h7kOtNwVsZ1dHvTcYoKMzv4UTfSakjNHMZO7vJDjUn5eib5aRZnBVLBoupupsM3D5sF3
         z4U1gxZhh0apHXLcTmwMMj8iU6jW/yJmKvY/0OT9QYu91j3vmaK4QsLC/q2TweP9CkyA
         QQnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=P/q4RnJj2efKP18/p35VQ/p0eIvp2esguJVWydMCWg8=;
        b=fAnaah3s3YflDY8MCwBV9Kx99yZdpT8yWoUCu+tkNyE0KXoibL2KRNjqUcS77WzeRG
         XmVZPVUqOY9rfwSbnnTwFVMUWGruAXYeU2v9GlEAal78mDWVO9KtbykCumSzH6x76vOL
         vv5SE9NNDEvLA9bv2Mu4rvg0bksuJPye2y5TJ1GTrJwruNfnDl37bEoQfa8S7b4dV9ci
         6lyrYi3AwbdP/fS87+YA2OqkmfdSwjnLIi6QrmsHaYVAk+vgT8ieS/InKCd5eR/R1fpF
         lqjaIFBM4k8iGrYuD1rIsnf0ZDDp6Qa0cnzqb7HYYm7TOPU6T0Asz6S8xEHEutwAPn2R
         v7/g==
X-Gm-Message-State: AA+aEWYByZrGFjaIHtZbbjMq7ioIIcNiag+bRCnnlL11e5OSC+JvEPxl
        iSuQXHUsT1h2Nc3VBjwd+cq3M3fB
X-Google-Smtp-Source: AFSGD/Vbr+BrlWZ6Tfu564j+0fXmwPnlDaW3QFak1+qcus7aeJyqm5CE05ccHD9ABGvXcIVdEVhi0A==
X-Received: by 2002:a05:660c:10:: with SMTP id q16mr11496740itj.51.1545064891064;
        Mon, 17 Dec 2018 08:41:31 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l3sm7174992itb.43.2018.12.17.08.41.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:30 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfTMO018651;
        Mon, 17 Dec 2018 16:41:29 GMT
Subject: [PATCH v4 24/30] SUNRPC: Simplify defining common RPC trace events
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:29 -0500
Message-ID: <20181217164129.24133.88082.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up, no functional change is expected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |  172 ++++++++++++++++-------------------------
 1 file changed, 69 insertions(+), 103 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 28e3841..88bda93 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -16,40 +16,6 @@
 
 DECLARE_EVENT_CLASS(rpc_task_status,
 
-	TP_PROTO(struct rpc_task *task),
-
-	TP_ARGS(task),
-
-	TP_STRUCT__entry(
-		__field(unsigned int, task_id)
-		__field(unsigned int, client_id)
-		__field(int, status)
-	),
-
-	TP_fast_assign(
-		__entry->task_id = task->tk_pid;
-		__entry->client_id = task->tk_client->cl_clid;
-		__entry->status = task->tk_status;
-	),
-
-	TP_printk("task:%u@%u status=%d",
-		__entry->task_id, __entry->client_id,
-		__entry->status)
-);
-
-DEFINE_EVENT(rpc_task_status, rpc_call_status,
-	TP_PROTO(struct rpc_task *task),
-
-	TP_ARGS(task)
-);
-
-DEFINE_EVENT(rpc_task_status, rpc_bind_status,
-	TP_PROTO(struct rpc_task *task),
-
-	TP_ARGS(task)
-);
-
-TRACE_EVENT(rpc_connect_status,
 	TP_PROTO(const struct rpc_task *task),
 
 	TP_ARGS(task),
@@ -70,6 +36,16 @@
 		__entry->task_id, __entry->client_id,
 		__entry->status)
 );
+#define DEFINE_RPC_STATUS_EVENT(name) \
+	DEFINE_EVENT(rpc_task_status, rpc_##name##_status, \
+			TP_PROTO( \
+				const struct rpc_task *task \
+			), \
+			TP_ARGS(task))
+
+DEFINE_RPC_STATUS_EVENT(call);
+DEFINE_RPC_STATUS_EVENT(bind);
+DEFINE_RPC_STATUS_EVENT(connect);
 
 TRACE_EVENT(rpc_request,
 	TP_PROTO(const struct rpc_task *task),
@@ -134,30 +110,17 @@
 		__entry->action
 		)
 );
+#define DEFINE_RPC_RUNNING_EVENT(name) \
+	DEFINE_EVENT(rpc_task_running, rpc_task_##name, \
+			TP_PROTO( \
+				const struct rpc_task *task, \
+				const void *action \
+			), \
+			TP_ARGS(task, action))
 
-DEFINE_EVENT(rpc_task_running, rpc_task_begin,
-
-	TP_PROTO(const struct rpc_task *task, const void *action),
-
-	TP_ARGS(task, action)
-
-);
-
-DEFINE_EVENT(rpc_task_running, rpc_task_run_action,
-
-	TP_PROTO(const struct rpc_task *task, const void *action),
-
-	TP_ARGS(task, action)
-
-);
-
-DEFINE_EVENT(rpc_task_running, rpc_task_complete,
-
-	TP_PROTO(const struct rpc_task *task, const void *action),
-
-	TP_ARGS(task, action)
-
-);
+DEFINE_RPC_RUNNING_EVENT(begin);
+DEFINE_RPC_RUNNING_EVENT(run_action);
+DEFINE_RPC_RUNNING_EVENT(complete);
 
 DECLARE_EVENT_CLASS(rpc_task_queued,
 
@@ -195,22 +158,16 @@
 		__get_str(q_name)
 		)
 );
+#define DEFINE_RPC_QUEUED_EVENT(name) \
+	DEFINE_EVENT(rpc_task_queued, rpc_task_##name, \
+			TP_PROTO( \
+				const struct rpc_task *task, \
+				const struct rpc_wait_queue *q \
+			), \
+			TP_ARGS(task, q))
 
-DEFINE_EVENT(rpc_task_queued, rpc_task_sleep,
-
-	TP_PROTO(const struct rpc_task *task, const struct rpc_wait_queue *q),
-
-	TP_ARGS(task, q)
-
-);
-
-DEFINE_EVENT(rpc_task_queued, rpc_task_wakeup,
-
-	TP_PROTO(const struct rpc_task *task, const struct rpc_wait_queue *q),
-
-	TP_ARGS(task, q)
-
-);
+DEFINE_RPC_QUEUED_EVENT(sleep);
+DEFINE_RPC_QUEUED_EVENT(wakeup);
 
 TRACE_EVENT(rpc_stats_latency,
 
@@ -410,7 +367,11 @@
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
 
 DECLARE_EVENT_CLASS(rpc_xprt_event,
-	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
+	TP_PROTO(
+		const struct rpc_xprt *xprt,
+		__be32 xid,
+		int status
+	),
 
 	TP_ARGS(xprt, xid, status),
 
@@ -432,22 +393,19 @@
 			__get_str(port), __entry->xid,
 			__entry->status)
 );
+#define DEFINE_RPC_XPRT_EVENT(name) \
+	DEFINE_EVENT(rpc_xprt_event, xprt_##name, \
+			TP_PROTO( \
+				const struct rpc_xprt *xprt, \
+				__be32 xid, \
+				int status \
+			), \
+			TP_ARGS(xprt, xid, status))
 
-DEFINE_EVENT(rpc_xprt_event, xprt_timer,
-	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
-	TP_ARGS(xprt, xid, status));
-
-DEFINE_EVENT(rpc_xprt_event, xprt_lookup_rqst,
-	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
-	TP_ARGS(xprt, xid, status));
-
-DEFINE_EVENT(rpc_xprt_event, xprt_transmit,
-	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
-	TP_ARGS(xprt, xid, status));
-
-DEFINE_EVENT(rpc_xprt_event, xprt_complete_rqst,
-	TP_PROTO(struct rpc_xprt *xprt, __be32 xid, int status),
-	TP_ARGS(xprt, xid, status));
+DEFINE_RPC_XPRT_EVENT(timer);
+DEFINE_RPC_XPRT_EVENT(lookup_rqst);
+DEFINE_RPC_XPRT_EVENT(transmit);
+DEFINE_RPC_XPRT_EVENT(complete_rqst);
 
 TRACE_EVENT(xprt_ping,
 	TP_PROTO(const struct rpc_xprt *xprt, int status),
@@ -587,7 +545,9 @@
 
 DECLARE_EVENT_CLASS(svc_rqst_event,
 
-	TP_PROTO(struct svc_rqst *rqst),
+	TP_PROTO(
+		const struct svc_rqst *rqst
+	),
 
 	TP_ARGS(rqst),
 
@@ -607,14 +567,15 @@
 			__get_str(addr), __entry->xid,
 			show_rqstp_flags(__entry->flags))
 );
+#define DEFINE_SVC_RQST_EVENT(name) \
+	DEFINE_EVENT(svc_rqst_event, svc_##name, \
+			TP_PROTO( \
+				const struct svc_rqst *rqst \
+			), \
+			TP_ARGS(rqst))
 
-DEFINE_EVENT(svc_rqst_event, svc_defer,
-	TP_PROTO(struct svc_rqst *rqst),
-	TP_ARGS(rqst));
-
-DEFINE_EVENT(svc_rqst_event, svc_drop,
-	TP_PROTO(struct svc_rqst *rqst),
-	TP_ARGS(rqst));
+DEFINE_SVC_RQST_EVENT(defer);
+DEFINE_SVC_RQST_EVENT(drop);
 
 DECLARE_EVENT_CLASS(svc_rqst_status,
 
@@ -801,7 +762,9 @@
 );
 
 DECLARE_EVENT_CLASS(svc_deferred_event,
-	TP_PROTO(struct svc_deferred_req *dr),
+	TP_PROTO(
+		const struct svc_deferred_req *dr
+	),
 
 	TP_ARGS(dr),
 
@@ -818,13 +781,16 @@
 
 	TP_printk("addr=%s xid=0x%08x", __get_str(addr), __entry->xid)
 );
+#define DEFINE_SVC_DEFERRED_EVENT(name) \
+	DEFINE_EVENT(svc_deferred_event, svc_##name##_deferred, \
+			TP_PROTO( \
+				const struct svc_deferred_req *dr \
+			), \
+			TP_ARGS(dr))
+
+DEFINE_SVC_DEFERRED_EVENT(drop);
+DEFINE_SVC_DEFERRED_EVENT(revisit);
 
-DEFINE_EVENT(svc_deferred_event, svc_drop_deferred,
-	TP_PROTO(struct svc_deferred_req *dr),
-	TP_ARGS(dr));
-DEFINE_EVENT(svc_deferred_event, svc_revisit_deferred,
-	TP_PROTO(struct svc_deferred_req *dr),
-	TP_ARGS(dr));
 #endif /* _TRACE_SUNRPC_H */
 
 #include <trace/define_trace.h>

