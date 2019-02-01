Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB118C282DA
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:58:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 55930218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:58:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c8VjzGVa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730259AbfBAT6M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:58:12 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:52616 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730301AbfBAT6M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:58:12 -0500
Received: by mail-it1-f193.google.com with SMTP id d11so11114317itf.2
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:58:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=+Ng50ncVyITL3HujXOS57jtncgKmcZiZPbCjensdXpE=;
        b=c8VjzGVaP36GjQ+spgkr6BuCZdZllPKjERZ5hw4cRAh4QQn/a+sj7nL48VoYrb1w9x
         psCZZ3VQCVSI/FDSAmIg9ttHlm+crkacyQODtPBrc9RuHAdiEsqwFowpOWKU/DoEL8mS
         oHoey4KdP6tKafYi/vYtYkMH3UVqOqJHXSnf6sMAZx6y7wMZyI64/p4rkI33VcpIAJo9
         8/SkbySeXgFrEdDR9Oh9bBK/QEHyAsWHHPbc3+6mdhCuvWEu1CtKu2nk8scwypV9rjNN
         ge2BmskIzucae+Zylse8UKmWLkFawozvts9brOYXgHGFEn8KSGoPx/T/ueSOL9/IOmf3
         GwqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=+Ng50ncVyITL3HujXOS57jtncgKmcZiZPbCjensdXpE=;
        b=EXL6M/DXk9ejR918pNhlpw3UYRLJMu8astv90v+na/DERXSBAYRsn3fRtQl4veseI8
         d9fUAV10DzhEj4J+j8UcV9zlgN4PP4MCaWtiXUXEzx7CaH0DLUoo/5mWKgr1sjzJ2j0S
         t3jA9R2fx1UwoythSvR1+lU4GgYPkgNuX7KiuYfam0I85xZLoI1mb3r1oDyhD9o+J2YG
         m7wXud+6AGlP/2FA9CPQjJJ/n/3JaTHIRyC6l6KgHrmrA2fiBwh4bHcj1Rqu/I/ZFEWR
         /wCLvEVlOdpozhQj+a0Me/bTLtHvHzwLhuNZm3ZfUIfo9vtK6+Y+XHuA1NStchO+G+Ze
         xXmg==
X-Gm-Message-State: AHQUAubIyaUIHJE0RjhDqDVl1bCBtCE3e9C432dqvNlfRJMWfv4cPJqF
        y/Zo+U+vSBKC/VmewLFfKt0=
X-Google-Smtp-Source: AHgI3IZKSw25Dn6tu9oEW7fsG02pDZIAkqf9MGVI/cnWM0oPFfxk+/WAc95QtHXNKYjXt33DRuhBYg==
X-Received: by 2002:a24:6293:: with SMTP id d141mr2451168itc.124.1549051090351;
        Fri, 01 Feb 2019 11:58:10 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l25sm3545791ioj.68.2019.02.01.11.58.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:58:09 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11Jw83q008717;
        Fri, 1 Feb 2019 19:58:08 GMT
Subject: [PATCH RFC 08/10] SUNRPC: Introduce trace points in rpc_auth_gss.ko
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:58:08 -0500
Message-ID: <20190201195808.11389.68065.stgit@manet.1015granger.net>
In-Reply-To: <20190201195538.11389.96106.stgit@manet.1015granger.net>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add infrastructure for trace points in the RPC_AUTH_GSS kernel
module, and add a few sample trace points. These report exceptional
or unexpected events, and observe the assignment of GSS sequence
numbers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcgss.h  |  361 ++++++++++++++++++++++++++++++++++++++++
 include/trace/events/rpcrdma.h |   12 +
 include/trace/events/sunrpc.h  |   61 +++++++
 net/sunrpc/auth_gss/Makefile   |    2 
 net/sunrpc/auth_gss/auth_gss.c |  165 +++++++++---------
 net/sunrpc/auth_gss/trace.c    |   11 +
 net/sunrpc/xprt.c              |   10 +
 7 files changed, 530 insertions(+), 92 deletions(-)
 create mode 100644 include/trace/events/rpcgss.h
 create mode 100644 net/sunrpc/auth_gss/trace.c

diff --git a/include/trace/events/rpcgss.h b/include/trace/events/rpcgss.h
new file mode 100644
index 0000000..d1f7fe1
--- /dev/null
+++ b/include/trace/events/rpcgss.h
@@ -0,0 +1,361 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (c) 2018 Oracle.  All rights reserved.
+ *
+ * Trace point definitions for the "rpcgss" subsystem.
+ */
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM rpcgss
+
+#if !defined(_TRACE_RPCRDMA_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_RPCGSS_H
+
+#include <linux/tracepoint.h>
+
+/**
+ ** GSS-API related trace events
+ **/
+
+TRACE_DEFINE_ENUM(GSS_S_BAD_MECH);
+TRACE_DEFINE_ENUM(GSS_S_BAD_NAME);
+TRACE_DEFINE_ENUM(GSS_S_BAD_NAMETYPE);
+TRACE_DEFINE_ENUM(GSS_S_BAD_BINDINGS);
+TRACE_DEFINE_ENUM(GSS_S_BAD_STATUS);
+TRACE_DEFINE_ENUM(GSS_S_BAD_SIG);
+TRACE_DEFINE_ENUM(GSS_S_NO_CRED);
+TRACE_DEFINE_ENUM(GSS_S_NO_CONTEXT);
+TRACE_DEFINE_ENUM(GSS_S_DEFECTIVE_TOKEN);
+TRACE_DEFINE_ENUM(GSS_S_DEFECTIVE_CREDENTIAL);
+TRACE_DEFINE_ENUM(GSS_S_CREDENTIALS_EXPIRED);
+TRACE_DEFINE_ENUM(GSS_S_CONTEXT_EXPIRED);
+TRACE_DEFINE_ENUM(GSS_S_FAILURE);
+TRACE_DEFINE_ENUM(GSS_S_BAD_QOP);
+TRACE_DEFINE_ENUM(GSS_S_UNAUTHORIZED);
+TRACE_DEFINE_ENUM(GSS_S_UNAVAILABLE);
+TRACE_DEFINE_ENUM(GSS_S_DUPLICATE_ELEMENT);
+TRACE_DEFINE_ENUM(GSS_S_NAME_NOT_MN);
+TRACE_DEFINE_ENUM(GSS_S_CONTINUE_NEEDED);
+TRACE_DEFINE_ENUM(GSS_S_DUPLICATE_TOKEN);
+TRACE_DEFINE_ENUM(GSS_S_OLD_TOKEN);
+TRACE_DEFINE_ENUM(GSS_S_UNSEQ_TOKEN);
+TRACE_DEFINE_ENUM(GSS_S_GAP_TOKEN);
+
+#define show_gss_status(x)						\
+	__print_flags(x, "|",						\
+		{ GSS_S_BAD_MECH, "GSS_S_BAD_MECH" },			\
+		{ GSS_S_BAD_NAME, "GSS_S_BAD_NAME" },			\
+		{ GSS_S_BAD_NAMETYPE, "GSS_S_BAD_NAMETYPE" },		\
+		{ GSS_S_BAD_BINDINGS, "GSS_S_BAD_BINDINGS" },		\
+		{ GSS_S_BAD_STATUS, "GSS_S_BAD_STATUS" },		\
+		{ GSS_S_BAD_SIG, "GSS_S_BAD_SIG" },			\
+		{ GSS_S_NO_CRED, "GSS_S_NO_CRED" },			\
+		{ GSS_S_NO_CONTEXT, "GSS_S_NO_CONTEXT" },		\
+		{ GSS_S_DEFECTIVE_TOKEN, "GSS_S_DEFECTIVE_TOKEN" },	\
+		{ GSS_S_DEFECTIVE_CREDENTIAL, "GSS_S_DEFECTIVE_CREDENTIAL" }, \
+		{ GSS_S_CREDENTIALS_EXPIRED, "GSS_S_CREDENTIALS_EXPIRED" }, \
+		{ GSS_S_CONTEXT_EXPIRED, "GSS_S_CONTEXT_EXPIRED" },	\
+		{ GSS_S_FAILURE, "GSS_S_FAILURE" },			\
+		{ GSS_S_BAD_QOP, "GSS_S_BAD_QOP" },			\
+		{ GSS_S_UNAUTHORIZED, "GSS_S_UNAUTHORIZED" },		\
+		{ GSS_S_UNAVAILABLE, "GSS_S_UNAVAILABLE" },		\
+		{ GSS_S_DUPLICATE_ELEMENT, "GSS_S_DUPLICATE_ELEMENT" },	\
+		{ GSS_S_NAME_NOT_MN, "GSS_S_NAME_NOT_MN" },		\
+		{ GSS_S_CONTINUE_NEEDED, "GSS_S_CONTINUE_NEEDED" },	\
+		{ GSS_S_DUPLICATE_TOKEN, "GSS_S_DUPLICATE_TOKEN" },	\
+		{ GSS_S_OLD_TOKEN, "GSS_S_OLD_TOKEN" },			\
+		{ GSS_S_UNSEQ_TOKEN, "GSS_S_UNSEQ_TOKEN" },		\
+		{ GSS_S_GAP_TOKEN, "GSS_S_GAP_TOKEN" })
+
+
+DECLARE_EVENT_CLASS(rpcgss_gssapi_event,
+	TP_PROTO(
+		const struct rpc_task *task,
+		u32 maj_stat
+	),
+
+	TP_ARGS(task, maj_stat),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, maj_stat)
+
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->maj_stat = maj_stat;
+	),
+
+	TP_printk("task:%u@%u maj_stat=%s",
+		__entry->task_id, __entry->client_id,
+		__entry->maj_stat == 0 ?
+		"GSS_S_COMPLETE" : show_gss_status(__entry->maj_stat))
+);
+
+#define DEFINE_GSSAPI_EVENT(name)					\
+	DEFINE_EVENT(rpcgss_gssapi_event, rpcgss_##name,		\
+			TP_PROTO(					\
+				const struct rpc_task *task,		\
+				u32 maj_stat				\
+			),						\
+			TP_ARGS(task, maj_stat))
+
+TRACE_EVENT(rpcgss_import_ctx,
+	TP_PROTO(
+		int status
+	),
+
+	TP_ARGS(status),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->status = status;
+	),
+
+	TP_printk("status=%d", __entry->status)
+);
+
+DEFINE_GSSAPI_EVENT(get_mic);
+DEFINE_GSSAPI_EVENT(verify_mic);
+DEFINE_GSSAPI_EVENT(wrap);
+DEFINE_GSSAPI_EVENT(unwrap);
+
+
+/**
+ ** GSS auth unwrap failures
+ **/
+
+TRACE_EVENT(rpcgss_unwrap_failed,
+	TP_PROTO(
+		const struct rpc_task *task
+	),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+	),
+
+	TP_printk("task:%u@%u", __entry->task_id, __entry->client_id)
+);
+
+TRACE_EVENT(rpcgss_bad_seqno,
+	TP_PROTO(
+		const struct rpc_task *task,
+		u32 expected,
+		u32 received
+	),
+
+	TP_ARGS(task, expected, received),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, expected)
+		__field(u32, received)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->expected = expected;
+		__entry->received = received;
+	),
+
+	TP_printk("task:%u@%u expected seqno %u, received seqno %u",
+		__entry->task_id, __entry->client_id,
+		__entry->expected, __entry->received)
+);
+
+TRACE_EVENT(rpcgss_seqno,
+	TP_PROTO(
+		const struct rpc_task *task
+	),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(u32, seqno)
+	),
+
+	TP_fast_assign(
+		const struct rpc_rqst *rqst = task->tk_rqstp;
+
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->seqno = rqst->rq_seqno;
+	),
+
+	TP_printk("task:%u@%u xid=0x%08x seqno=%u",
+		__entry->task_id, __entry->client_id,
+		__entry->xid, __entry->seqno)
+);
+
+TRACE_EVENT(rpcgss_need_reencode,
+	TP_PROTO(
+		const struct rpc_task *task,
+		u32 seq_xmit,
+		bool ret
+	),
+
+	TP_ARGS(task, seq_xmit, ret),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(u32, seq_xmit)
+		__field(u32, seqno)
+		__field(bool, ret)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(task->tk_rqstp->rq_xid);
+		__entry->seq_xmit = seq_xmit;
+		__entry->seqno = task->tk_rqstp->rq_seqno;
+		__entry->ret = ret;
+	),
+
+	TP_printk("task:%u@%u xid=0x%08x rq_seqno=%u seq_xmit=%u reencode %sneeded",
+		__entry->task_id, __entry->client_id,
+		__entry->xid, __entry->seqno, __entry->seq_xmit,
+		__entry->ret ? "" : "un")
+);
+
+/**
+ ** gssd upcall related trace events
+ **/
+
+TRACE_EVENT(rpcgss_upcall_msg,
+	TP_PROTO(
+		const char *buf
+	),
+
+	TP_ARGS(buf),
+
+	TP_STRUCT__entry(
+		__string(msg, buf)
+	),
+
+	TP_fast_assign(
+		__assign_str(msg, buf)
+	),
+
+	TP_printk("msg='%s'", __get_str(msg))
+);
+
+TRACE_EVENT(rpcgss_upcall_result,
+	TP_PROTO(
+		u32 uid,
+		int result
+	),
+
+	TP_ARGS(uid, result),
+
+	TP_STRUCT__entry(
+		__field(u32, uid)
+		__field(int, result)
+
+	),
+
+	TP_fast_assign(
+		__entry->uid = uid;
+		__entry->result = result;
+	),
+
+	TP_printk("for uid %u, result=%d", __entry->uid, __entry->result)
+);
+
+TRACE_EVENT(rpcgss_context,
+	TP_PROTO(
+		unsigned long expiry,
+		unsigned long now,
+		unsigned int timeout,
+		unsigned int len,
+		const u8 *data
+	),
+
+	TP_ARGS(expiry, now, timeout, len, data),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, expiry)
+		__field(unsigned long, now)
+		__field(unsigned int, timeout)
+		__field(int, len)
+		__string(acceptor, data)
+	),
+
+	TP_fast_assign(
+		__entry->expiry = expiry;
+		__entry->now = now;
+		__entry->timeout = timeout;
+		__entry->len = len;
+		strncpy(__get_str(acceptor), data, len);
+	),
+
+	TP_printk("gc_expiry=%lu now=%lu timeout=%u acceptor=%.*s",
+		__entry->expiry, __entry->now, __entry->timeout,
+		__entry->len, __get_str(acceptor))
+);
+
+
+/**
+ ** Miscellaneous events
+ */
+
+TRACE_DEFINE_ENUM(RPC_AUTH_GSS_KRB5);
+TRACE_DEFINE_ENUM(RPC_AUTH_GSS_KRB5I);
+TRACE_DEFINE_ENUM(RPC_AUTH_GSS_KRB5P);
+
+#define show_pseudoflavor(x)						\
+	__print_symbolic(x,						\
+		{ RPC_AUTH_GSS_KRB5, "RPC_AUTH_GSS_KRB5" },		\
+		{ RPC_AUTH_GSS_KRB5I, "RPC_AUTH_GSS_KRB5I" },		\
+		{ RPC_AUTH_GSS_KRB5P, "RPC_AUTH_GSS_KRB5P" })
+
+
+TRACE_EVENT(rpcgss_createauth,
+	TP_PROTO(
+		unsigned int flavor,
+		int error
+	),
+
+	TP_ARGS(flavor, error),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, flavor)
+		__field(int, error)
+
+	),
+
+	TP_fast_assign(
+		__entry->flavor = flavor;
+		__entry->error = error;
+	),
+
+	TP_printk("flavor=%s error=%d",
+		show_pseudoflavor(__entry->flavor), __entry->error)
+);
+
+
+#endif	/* _TRACE_RPCGSS_H */
+
+#include <trace/define_trace.h>
diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 399b1ae..962975b 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -521,12 +521,18 @@
 
 	TP_STRUCT__entry(
 		__field(const void *, req)
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
 		__field(int, num_sge)
 		__field(int, signaled)
 		__field(int, status)
 	),
 
 	TP_fast_assign(
+		const struct rpc_rqst *rqst = &req->rl_slot;
+
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
 		__entry->req = req;
 		__entry->num_sge = req->rl_sendctx->sc_wr.num_sge;
 		__entry->signaled = req->rl_sendctx->sc_wr.send_flags &
@@ -534,9 +540,11 @@
 		__entry->status = status;
 	),
 
-	TP_printk("req=%p, %d SGEs%s, status=%d",
+	TP_printk("task:%u@%u req=%p (%d SGE%s) %sstatus=%d",
+		__entry->task_id, __entry->client_id,
 		__entry->req, __entry->num_sge,
-		(__entry->signaled ? ", signaled" : ""),
+		(__entry->num_sge == 1 ? "" : "s"),
+		(__entry->signaled ? "signaled " : ""),
 		__entry->status
 	)
 );
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 0531fc4..a267ced 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -655,9 +655,68 @@
 
 DEFINE_RPC_XPRT_EVENT(timer);
 DEFINE_RPC_XPRT_EVENT(lookup_rqst);
-DEFINE_RPC_XPRT_EVENT(transmit);
 DEFINE_RPC_XPRT_EVENT(complete_rqst);
 
+TRACE_EVENT(xprt_transmit,
+	TP_PROTO(
+		const struct rpc_rqst *rqst,
+		int status
+	),
+
+	TP_ARGS(rqst, status),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(u32, seqno)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->seqno = rqst->rq_seqno;
+		__entry->status = status;
+	),
+
+	TP_printk(
+		"task:%u@%u xid=0x%08x seqno=%u status=%d",
+		__entry->task_id, __entry->client_id, __entry->xid,
+		__entry->seqno, __entry->status)
+);
+
+TRACE_EVENT(xprt_enq_xmit,
+	TP_PROTO(
+		const struct rpc_task *task,
+		int stage
+	),
+
+	TP_ARGS(task, stage),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(u32, seqno)
+		__field(int, stage)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(task->tk_rqstp->rq_xid);
+		__entry->seqno = task->tk_rqstp->rq_seqno;
+		__entry->stage = stage;
+	),
+
+	TP_printk(
+		"task:%u@%u xid=0x%08x seqno=%u stage=%d",
+		__entry->task_id, __entry->client_id, __entry->xid,
+		__entry->seqno, __entry->stage)
+);
+
 TRACE_EVENT(xprt_ping,
 	TP_PROTO(const struct rpc_xprt *xprt, int status),
 
diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
index c374268..4a29f4c 100644
--- a/net/sunrpc/auth_gss/Makefile
+++ b/net/sunrpc/auth_gss/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_SUNRPC_GSS) += auth_rpcgss.o
 
 auth_rpcgss-y := auth_gss.o gss_generic_token.o \
 	gss_mech_switch.o svcauth_gss.o \
-	gss_rpc_upcall.o gss_rpc_xdr.o
+	gss_rpc_upcall.o gss_rpc_xdr.o trace.o
 
 obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 206788e..3d1fbd6 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -55,6 +55,8 @@
 
 #include "../netns.h"
 
+#include <trace/events/rpcgss.h>
+
 static const struct rpc_authops authgss_ops;
 
 static const struct rpc_credops gss_credops;
@@ -260,6 +262,7 @@ struct gss_auth {
 	}
 	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, NULL, GFP_NOFS);
 	if (ret < 0) {
+		trace_rpcgss_import_ctx(ret);
 		p = ERR_PTR(ret);
 		goto err;
 	}
@@ -275,12 +278,9 @@ struct gss_auth {
 	if (IS_ERR(p))
 		goto err;
 done:
-	dprintk("RPC:       %s Success. gc_expiry %lu now %lu timeout %u acceptor %.*s\n",
-		__func__, ctx->gc_expiry, now, timeout, ctx->gc_acceptor.len,
-		ctx->gc_acceptor.data);
-	return p;
+	trace_rpcgss_context(ctx->gc_expiry, now, timeout,
+			     ctx->gc_acceptor.len, ctx->gc_acceptor.data);
 err:
-	dprintk("RPC:       %s returns error %ld\n", __func__, -PTR_ERR(p));
 	return p;
 }
 
@@ -354,10 +354,8 @@ static void put_pipe_version(struct net *net)
 		if (auth && pos->auth->service != auth->service)
 			continue;
 		refcount_inc(&pos->count);
-		dprintk("RPC:       %s found msg %p\n", __func__, pos);
 		return pos;
 	}
-	dprintk("RPC:       %s found nothing\n", __func__);
 	return NULL;
 }
 
@@ -456,7 +454,7 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	size_t buflen = sizeof(gss_msg->databuf);
 	int len;
 
-	len = scnprintf(p, buflen, "mech=%s uid=%d ", mech->gm_name,
+	len = scnprintf(p, buflen, "mech=%s uid=%d", mech->gm_name,
 			from_kuid(&init_user_ns, gss_msg->uid));
 	buflen -= len;
 	p += len;
@@ -467,7 +465,7 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	 * identity that we are authenticating to.
 	 */
 	if (target_name) {
-		len = scnprintf(p, buflen, "target=%s ", target_name);
+		len = scnprintf(p, buflen, " target=%s", target_name);
 		buflen -= len;
 		p += len;
 		gss_msg->msg.len += len;
@@ -487,11 +485,11 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		char *c = strchr(service_name, '@');
 
 		if (!c)
-			len = scnprintf(p, buflen, "service=%s ",
+			len = scnprintf(p, buflen, " service=%s",
 					service_name);
 		else
 			len = scnprintf(p, buflen,
-					"service=%.*s srchost=%s ",
+					" service=%.*s srchost=%s",
 					(int)(c - service_name),
 					service_name, c + 1);
 		buflen -= len;
@@ -500,17 +498,17 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	}
 
 	if (mech->gm_upcall_enctypes) {
-		len = scnprintf(p, buflen, "enctypes=%s ",
+		len = scnprintf(p, buflen, " enctypes=%s",
 				mech->gm_upcall_enctypes);
 		buflen -= len;
 		p += len;
 		gss_msg->msg.len += len;
 	}
+	trace_rpcgss_upcall_msg(gss_msg->databuf);
 	len = scnprintf(p, buflen, "\n");
 	if (len == 0)
 		goto out_overflow;
 	gss_msg->msg.len += len;
-
 	gss_msg->msg.data = gss_msg->databuf;
 	return 0;
 out_overflow:
@@ -603,8 +601,6 @@ static void warn_gssd(void)
 	struct rpc_pipe *pipe;
 	int err = 0;
 
-	dprintk("RPC: %5u %s for uid %u\n",
-		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid));
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -612,7 +608,8 @@ static void warn_gssd(void)
 		warn_gssd();
 		task->tk_timeout = 15*HZ;
 		rpc_sleep_on(&pipe_version_rpc_waitqueue, task, NULL);
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto out;
 	}
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
@@ -635,9 +632,8 @@ static void warn_gssd(void)
 	spin_unlock(&pipe->lock);
 	gss_release_msg(gss_msg);
 out:
-	dprintk("RPC: %5u %s for uid %u result %d\n",
-		task->tk_pid, __func__,
-		from_kuid(&init_user_ns, cred->cr_cred->fsuid),	err);
+	trace_rpcgss_upcall_result(from_kuid(&init_user_ns,
+					     cred->cr_cred->fsuid), err);
 	return err;
 }
 
@@ -652,14 +648,13 @@ static void warn_gssd(void)
 	DEFINE_WAIT(wait);
 	int err;
 
-	dprintk("RPC:       %s for uid %u\n",
-		__func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid));
 retry:
 	err = 0;
 	/* if gssd is down, just skip upcalling altogether */
 	if (!gssd_running(net)) {
 		warn_gssd();
-		return -EACCES;
+		err = -EACCES;
+		goto out;
 	}
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
@@ -700,8 +695,8 @@ static void warn_gssd(void)
 	finish_wait(&gss_msg->waitqueue, &wait);
 	gss_release_msg(gss_msg);
 out:
-	dprintk("RPC:       %s for uid %u result %d\n",
-		__func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid), err);
+	trace_rpcgss_upcall_result(from_kuid(&init_user_ns,
+					     cred->cr_cred->fsuid), err);
 	return err;
 }
 
@@ -794,7 +789,6 @@ static void warn_gssd(void)
 err:
 	kfree(buf);
 out:
-	dprintk("RPC:       %s returning %zd\n", __func__, err);
 	return err;
 }
 
@@ -863,8 +857,6 @@ static int gss_pipe_open_v1(struct inode *inode)
 	struct gss_upcall_msg *gss_msg = container_of(msg, struct gss_upcall_msg, msg);
 
 	if (msg->errno < 0) {
-		dprintk("RPC:       %s releasing msg %p\n",
-			__func__, gss_msg);
 		refcount_inc(&gss_msg->count);
 		gss_unhash_msg(gss_msg);
 		if (msg->errno == -ETIMEDOUT)
@@ -1024,8 +1016,6 @@ static void gss_pipe_free(struct gss_pipe *p)
 	struct rpc_auth * auth;
 	int err = -ENOMEM; /* XXX? */
 
-	dprintk("RPC:       creating GSS authenticator for client %p\n", clnt);
-
 	if (!try_module_get(THIS_MODULE))
 		return ERR_PTR(err);
 	if (!(gss_auth = kmalloc(sizeof(*gss_auth), GFP_KERNEL)))
@@ -1041,10 +1031,8 @@ static void gss_pipe_free(struct gss_pipe *p)
 	gss_auth->net = get_net(rpc_net_ns(clnt));
 	err = -EINVAL;
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
-	if (!gss_auth->mech) {
-		dprintk("RPC:       Pseudoflavor %d not found!\n", flavor);
+	if (!gss_auth->mech)
 		goto err_put_net;
-	}
 	gss_auth->service = gss_pseudoflavor_to_service(gss_auth->mech, flavor);
 	if (gss_auth->service == 0)
 		goto err_put_mech;
@@ -1099,6 +1087,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 	kfree(gss_auth);
 out_dec:
 	module_put(THIS_MODULE);
+	trace_rpcgss_createauth(flavor, err);
 	return ERR_PTR(err);
 }
 
@@ -1135,9 +1124,6 @@ static void gss_pipe_free(struct gss_pipe *p)
 	struct gss_auth *gss_auth = container_of(auth,
 			struct gss_auth, rpc_auth);
 
-	dprintk("RPC:       destroying GSS authenticator %p flavor %d\n",
-			auth, auth->au_flavor);
-
 	if (hash_hashed(&gss_auth->hash)) {
 		spin_lock(&gss_auth_hash_lock);
 		hash_del(&gss_auth->hash);
@@ -1300,8 +1286,6 @@ static void gss_pipe_free(struct gss_pipe *p)
 static void
 gss_do_free_ctx(struct gss_cl_ctx *ctx)
 {
-	dprintk("RPC:       %s\n", __func__);
-
 	gss_delete_sec_context(&ctx->gc_gss_ctx);
 	kfree(ctx->gc_wire_ctx.data);
 	kfree(ctx->gc_acceptor.data);
@@ -1324,7 +1308,6 @@ static void gss_pipe_free(struct gss_pipe *p)
 static void
 gss_free_cred(struct gss_cred *gss_cred)
 {
-	dprintk("RPC:       %s cred=%p\n", __func__, gss_cred);
 	kfree(gss_cred);
 }
 
@@ -1381,10 +1364,6 @@ static void gss_pipe_free(struct gss_pipe *p)
 	struct gss_cred	*cred = NULL;
 	int err = -ENOMEM;
 
-	dprintk("RPC:       %s for uid %d, flavor %d\n",
-		__func__, from_kuid(&init_user_ns, acred->cred->fsuid),
-		auth->au_flavor);
-
 	if (!(cred = kzalloc(sizeof(*cred), gfp)))
 		goto out_err;
 
@@ -1400,7 +1379,6 @@ static void gss_pipe_free(struct gss_pipe *p)
 	return &cred->gc_base;
 
 out_err:
-	dprintk("RPC:       %s failed with error %d\n", __func__, err);
 	return ERR_PTR(err);
 }
 
@@ -1544,15 +1522,14 @@ static int gss_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 	struct xdr_netobj mic;
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
-
-	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
+	int status;
 
 	/* Credential */
 
 	p = xdr_reserve_space(xdr, 7 * sizeof(*p) +
 			      ctx->gc_wire_ctx.len);
 	if (!p)
-		goto out_put_ctx;
+		goto marshal_failed;
 	*p++ = rpc_auth_gss;
 	cred_len = p++;
 
@@ -1560,7 +1537,8 @@ static int gss_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 	req->rq_seqno = (ctx->gc_seq < MAXSEQ) ? ctx->gc_seq++ : MAXSEQ;
 	spin_unlock(&ctx->gc_seq_lock);
 	if (req->rq_seqno == MAXSEQ)
-		goto out_expired;
+		goto expired;
+	trace_rpcgss_seqno(task);
 
 	*p++ = cpu_to_be32(RPC_GSS_VERSION);
 	*p++ = cpu_to_be32(ctx->gc_proc);
@@ -1579,25 +1557,31 @@ static int gss_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 
 	p = xdr_reserve_space(xdr, sizeof(*p));
 	if (!p)
-		goto out_put_ctx;
+		goto marshal_failed;
 	*p++ = rpc_auth_gss;
 	mic.data = (u8 *)(p + 1);
 	maj_stat = gss_get_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
-		goto out_expired;
+		goto expired;
 	else if (maj_stat != 0)
-		goto out_put_ctx;
+		goto bad_mic;
 	if (xdr_stream_encode_opaque_inline(xdr, (void **)&p, mic.len) < 0)
-		goto out_put_ctx;
-	gss_put_ctx(ctx);
-	return 0;
-out_expired:
+		goto marshal_failed;
+	status = 0;
+out:
 	gss_put_ctx(ctx);
+	return status;
+expired:
 	clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
-	return -EKEYEXPIRED;
-out_put_ctx:
-	gss_put_ctx(ctx);
-	return -EMSGSIZE;
+	status = -EKEYEXPIRED;
+	goto out;
+marshal_failed:
+	status = -EMSGSIZE;
+	goto out;
+bad_mic:
+	trace_rpcgss_get_mic(task, maj_stat);
+	status = -EIO;
+	goto out;
 }
 
 static int gss_renew_cred(struct rpc_task *task)
@@ -1723,8 +1707,7 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	status = -EIO;
 	goto out;
 bad_mic:
-	dprintk("RPC: %5u %s: gss_verify_mic returned error 0x%08x\n",
-		task->tk_pid, __func__, maj_stat);
+	trace_rpcgss_verify_mic(task, maj_stat);
 	status = -EACCES;
 	goto out;
 }
@@ -1761,13 +1744,16 @@ static int gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	else if (maj_stat)
-		goto wrap_failed;
+		goto bad_mic;
 	/* Check that the trailing MIC fit in the buffer, after the fact */
 	if (xdr_stream_encode_opaque_inline(xdr, (void **)&p, mic.len) < 0)
 		goto wrap_failed;
 	return 0;
 wrap_failed:
 	return -EMSGSIZE;
+bad_mic:
+	trace_rpcgss_get_mic(task, maj_stat);
+	return -EIO;
 }
 
 static void
@@ -1860,7 +1846,6 @@ static int gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 		memcpy(tmp, snd_buf->tail[0].iov_base, snd_buf->tail[0].iov_len);
 		snd_buf->tail[0].iov_base = tmp;
 	}
-	status = -EIO;
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	maj_stat = gss_wrap(ctx->gc_gss_ctx, offset, snd_buf, inpages);
 	/* slack space should prevent this ever happening: */
@@ -1871,7 +1856,7 @@ static int gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	else if (maj_stat)
-		goto wrap_failed;
+		goto bad_wrap;
 
 	*opaque_len = cpu_to_be32(snd_buf->len - offset);
 	/* guess whether the pad goes into the head or the tail: */
@@ -1888,6 +1873,9 @@ static int gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	return 0;
 wrap_failed:
 	return status;
+bad_wrap:
+	trace_rpcgss_wrap(task, maj_stat);
+	return -EIO;
 }
 
 static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
@@ -1898,7 +1886,6 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
 	int status;
 
-	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 	status = -EIO;
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
 		/* The spec seems a little ambiguous here, but I think that not
@@ -1917,10 +1904,11 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	case RPC_GSS_SVC_PRIVACY:
 		status = gss_wrap_req_priv(cred, ctx, task, xdr);
 		break;
+	default:
+		status = -EIO;
 	}
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s returning %d\n", task->tk_pid, __func__, status);
 	return status;
 }
 
@@ -1932,8 +1920,9 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 }
 
 static int
-gss_unwrap_resp_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		      struct rpc_rqst *rqstp, struct xdr_stream *xdr)
+gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
+		      struct gss_cl_ctx *ctx, struct rpc_rqst *rqstp,
+		      struct xdr_stream *xdr)
 {
 	struct xdr_buf integ_buf, *rcv_buf = &rqstp->rq_rcv_buf;
 	u32 data_offset, mic_offset, integ_len, maj_stat;
@@ -1951,7 +1940,7 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	if (mic_offset > rcv_buf->len)
 		goto unwrap_failed;
 	if (be32_to_cpup(p) != rqstp->rq_seqno)
-		goto unwrap_failed;
+		goto bad_seqno;
 
 	if (xdr_buf_subsegment(rcv_buf, &integ_buf, data_offset, integ_len))
 		goto unwrap_failed;
@@ -1967,16 +1956,20 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 				   1 + XDR_QUADLEN(mic.len);
 	return 0;
 unwrap_failed:
+	trace_rpcgss_unwrap_failed(task);
+	return -EIO;
+bad_seqno:
+	trace_rpcgss_bad_seqno(task, rqstp->rq_seqno, be32_to_cpup(p));
 	return -EIO;
 bad_mic:
-	dprintk("RPC:       %s: gss_verify_mic returned error 0x%08x\n",
-		__func__, maj_stat);
+	trace_rpcgss_verify_mic(task, maj_stat);
 	return -EIO;
 }
 
 static int
-gss_unwrap_resp_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
-		     struct rpc_rqst *rqstp, struct xdr_stream *xdr)
+gss_unwrap_resp_priv(struct rpc_task *task, struct rpc_cred *cred,
+		     struct gss_cl_ctx *ctx, struct rpc_rqst *rqstp,
+		     struct xdr_stream *xdr)
 {
 	struct xdr_buf *rcv_buf = &rqstp->rq_rcv_buf;
 	struct kvec *head = rqstp->rq_rcv_buf.head;
@@ -2000,7 +1993,7 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 		goto bad_unwrap;
 	/* gss_unwrap decrypted the sequence number */
 	if (be32_to_cpup(p++) != rqstp->rq_seqno)
-		goto unwrap_failed;
+		goto bad_seqno;
 
 	/* gss_unwrap redacts the opaque blob from the head iovec.
 	 * rcv_buf has changed, thus the stream needs to be reset.
@@ -2011,10 +2004,13 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 				   XDR_QUADLEN(savedlen - rcv_buf->len);
 	return 0;
 unwrap_failed:
+	trace_rpcgss_unwrap_failed(task);
+	return -EIO;
+bad_seqno:
+	trace_rpcgss_bad_seqno(task, rqstp->rq_seqno, be32_to_cpup(--p));
 	return -EIO;
 bad_unwrap:
-	dprintk("RPC:       %s: gss_unwrap returned error 0x%08x\n",
-		__func__, maj_stat);
+	trace_rpcgss_unwrap(task, maj_stat);
 	return -EIO;
 }
 
@@ -2030,14 +2026,14 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_cred *cred = req->rq_cred;
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
-	u32 win, seq_xmit;
+	u32 win, seq_xmit = 0;
 	bool ret = true;
 
 	if (!ctx)
-		return true;
+		goto out;
 
 	if (gss_seq_is_newer(req->rq_seqno, READ_ONCE(ctx->gc_seq)))
-		goto out;
+		goto out_ctx;
 
 	seq_xmit = READ_ONCE(ctx->gc_seq_xmit);
 	while (gss_seq_is_newer(req->rq_seqno, seq_xmit)) {
@@ -2046,15 +2042,18 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 		seq_xmit = cmpxchg(&ctx->gc_seq_xmit, tmp, req->rq_seqno);
 		if (seq_xmit == tmp) {
 			ret = false;
-			goto out;
+			goto out_ctx;
 		}
 	}
 
 	win = ctx->gc_win;
 	if (win > 0)
 		ret = !gss_seq_is_newer(req->rq_seqno, seq_xmit - win);
-out:
+
+out_ctx:
 	gss_put_ctx(ctx);
+out:
+	trace_rpcgss_need_reencode(task, seq_xmit, ret);
 	return ret;
 }
 
@@ -2075,10 +2074,10 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 		status = gss_unwrap_resp_auth(cred);
 		break;
 	case RPC_GSS_SVC_INTEGRITY:
-		status = gss_unwrap_resp_integ(cred, ctx, rqstp, xdr);
+		status = gss_unwrap_resp_integ(task, cred, ctx, rqstp, xdr);
 		break;
 	case RPC_GSS_SVC_PRIVACY:
-		status = gss_unwrap_resp_priv(cred, ctx, rqstp, xdr);
+		status = gss_unwrap_resp_priv(task, cred, ctx, rqstp, xdr);
 		break;
 	}
 	if (status)
@@ -2088,8 +2087,6 @@ static int gss_wrap_req(struct rpc_task *task, struct xdr_stream *xdr)
 	status = rpcauth_unwrap_resp_decode(task, xdr);
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s returning %d\n",
-		task->tk_pid, __func__, status);
 	return status;
 }
 
diff --git a/net/sunrpc/auth_gss/trace.c b/net/sunrpc/auth_gss/trace.c
new file mode 100644
index 0000000..5576f1e
--- /dev/null
+++ b/net/sunrpc/auth_gss/trace.c
@@ -0,0 +1,11 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2018, 2019 Oracle. All rights reserved.
+ */
+
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/gss_err.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/rpcgss.h>
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f1ec211..bc7489f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1165,6 +1165,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 				/* Note: req is added _before_ pos */
 				list_add_tail(&req->rq_xmit, &pos->rq_xmit);
 				INIT_LIST_HEAD(&req->rq_xmit2);
+				trace_xprt_enq_xmit(task, 1);
 				goto out;
 			}
 		} else if (RPC_IS_SWAPPER(task)) {
@@ -1176,6 +1177,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 				/* Note: req is added _before_ pos */
 				list_add_tail(&req->rq_xmit, &pos->rq_xmit);
 				INIT_LIST_HEAD(&req->rq_xmit2);
+				trace_xprt_enq_xmit(task, 2);
 				goto out;
 			}
 		} else if (!req->rq_seqno) {
@@ -1184,11 +1186,13 @@ void xprt_request_wait_receive(struct rpc_task *task)
 					continue;
 				list_add_tail(&req->rq_xmit2, &pos->rq_xmit2);
 				INIT_LIST_HEAD(&req->rq_xmit);
+				trace_xprt_enq_xmit(task, 3);
 				goto out;
 			}
 		}
 		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
 		INIT_LIST_HEAD(&req->rq_xmit2);
+		trace_xprt_enq_xmit(task, 4);
 out:
 		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
 		spin_unlock(&xprt->queue_lock);
@@ -1313,8 +1317,6 @@ void xprt_end_transmit(struct rpc_task *task)
 	int is_retrans = RPC_WAS_SENT(task);
 	int status;
 
-	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
-
 	if (!req->rq_bytes_sent) {
 		if (xprt_request_data_received(task)) {
 			status = 0;
@@ -1336,9 +1338,9 @@ void xprt_end_transmit(struct rpc_task *task)
 
 	connect_cookie = xprt->connect_cookie;
 	status = xprt->ops->send_request(req);
-	trace_xprt_transmit(xprt, req->rq_xid, status);
 	if (status != 0) {
 		req->rq_ntrans--;
+		trace_xprt_transmit(req, status);
 		return status;
 	}
 
@@ -1347,7 +1349,6 @@ void xprt_end_transmit(struct rpc_task *task)
 
 	xprt_inject_disconnect(xprt);
 
-	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
 	task->tk_flags |= RPC_TASK_SENT;
 	spin_lock_bh(&xprt->transport_lock);
 
@@ -1360,6 +1361,7 @@ void xprt_end_transmit(struct rpc_task *task)
 
 	req->rq_connect_cookie = connect_cookie;
 out_dequeue:
+	trace_xprt_transmit(req, status);
 	xprt_request_dequeue_transmit(task);
 	rpc_wake_up_queued_task_set_status(&xprt->sending, task, status);
 	return status;

