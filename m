Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03C09C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AAD7F20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HPEXf9G/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAD7F20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727126AbeLJQbE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:31:04 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:44389 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727451AbeLJQbD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:31:03 -0500
Received: by mail-io1-f65.google.com with SMTP id r200so9196136iod.11;
        Mon, 10 Dec 2018 08:31:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=P/q4RnJj2efKP18/p35VQ/p0eIvp2esguJVWydMCWg8=;
        b=HPEXf9G/Xd2H/k5SKAle6UJ9KoOLlVclKVA6yh3i/ywLdl8f98FCy3G7geEjVCW2Kv
         HfUnaWRF9x3qUDc8s2ffu3wJHOdoyz/7hWi/u1ihL+J4V70G0JzEcRaWhXpbrLbQjCiC
         Pd4nW+WcBxrmo3OlGqAUHIlDDT2DY0Pf70KwEncUKYgojAIY5W7G3VP7vrXqbGgA34lA
         MW4rtMIdQKgJjuzEWhmlpPGu/vBMtmk2SYI6wTdW8yfvPb41wqIgg6pbb68Nh8RAdcjQ
         3BfqvTgrRKp5RmMQN1fBwN0x67ijnofneiowVKNphdCeiTe2wLjlH1YhMruvVOYcIB58
         Iq4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=P/q4RnJj2efKP18/p35VQ/p0eIvp2esguJVWydMCWg8=;
        b=WBplxM0Fe4K+RqtUhotdDSsh7/+sfpFU79W0/8b8U5WudLu9k1Kq36SQmZjMwp/1hJ
         FouyJp03rS2Yw+V6SBFX8X4VeD+LHeiOXbPAfSU6mTbtadCpHV8YYpiqoNjHxTfotGop
         3g/FBsXAVSWJSW5etQU0c/MptM45vS0NnFgUwoUmKFYckUIkopBIcX4ReI3jP3BRTxrS
         oQiMkwSazFHQW97j8/UyznleeS1uaRgyE6YhU6d7k/qE8cQv2d1AELPnwKViro7ULc3/
         b/AfnRcFySJWE9t1yDBDmMayyhfiiPrFi7UdDPZA+puvUvZP3GBjpECOvHgOBrtBEIbe
         K4kQ==
X-Gm-Message-State: AA+aEWaO6uyf4rK+HAwnxje10B0Di4fJn8y8dx1XQCVIm4d2eAlMy/Uz
        PtXWay+EX3SXKUjS2gCiTWk6AWRS
X-Google-Smtp-Source: AFSGD/WUlSKzzsA+QkSWOnNW5TN675W3XDXkOf1hRrqtNxvJZF+EnAe1QBpkweCkt75ArENIbDq9OQ==
X-Received: by 2002:a6b:3945:: with SMTP id g66mr10053605ioa.131.1544459462460;
        Mon, 10 Dec 2018 08:31:02 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id m37sm5868109iti.6.2018.12.10.08.31.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:31:01 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGV0eW031080;
        Mon, 10 Dec 2018 16:31:00 GMT
Subject: [PATCH v3 19/24] SUNRPC: Simplify defining common RPC trace events
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:31:00 -0500
Message-ID: <20181210163100.4198.71278.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
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

