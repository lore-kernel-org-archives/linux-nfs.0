Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43667C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 12395218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fw95LyED"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727661AbfBKQYC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:02 -0500
Received: from mail-it1-f180.google.com ([209.85.166.180]:52294 "EHLO
        mail-it1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726892AbfBKQYC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:02 -0500
Received: by mail-it1-f180.google.com with SMTP id r11so22358953itc.2;
        Mon, 11 Feb 2019 08:24:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=cnAk4rX7dJgl4BhcP3XcR7Mgb0xjuxESk2AW6fa8VtI=;
        b=fw95LyEDETh854aalCN/jliam5eFCyt/8jXHVvvj2uc/RflzaBAAO3QbXNBVa3fr0b
         JLvepHupjtmkixCx0809vbkU7WHGKEqZ1e5IHWQBzEZw0TOh+eO4e32NcEvN2sSr9RRb
         TD55GVemqQBRvaHikNFQNCRgPGRkA1wycuCNQE0uBc5gWFHvPXjfHk7otuJUtZM8h8r2
         uOBE2oc2Ijn/C6XX+0QHVYnYp261w1Qdb3e9sI3/7pvmksEQd/rSLI7Y/jSIALVH8XS8
         voauvT4PvEpcOOXOMuaEHm8Un5iZSsfPxzW3Gg1zNbj3m9yNKwaR986CDLOkmccl63No
         qbhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=cnAk4rX7dJgl4BhcP3XcR7Mgb0xjuxESk2AW6fa8VtI=;
        b=rwtT5c6irPn4m4/KOqFAZ2HdqGZExP8WXjFfwFJA6cLxpxGTc6WBBeWylcooMfbvk8
         Gq82lDA1gMB2brdmJhXOfpzgpEJ93Ds9F5TzoTFDFD+wgneFkYzYN23hZmhapb2JejmS
         En9szz3tMb1W0M/1AW7+W3tbilRyMqUN/FaBb0TstUBaqhiJre6qb1AwUEbi38pv0gtp
         FwDJoGXcEjfp3Zgy0W+0XTh0cveeDbuDNUkhQdQP+f5dqwR1eWNCL0XB4Mt2fCRSglY9
         lHTbLMgxwtuMdYR6d+DXk/i4+diVAjV0bcyxVXuPEODfFXcTgt9uhG0RkWb6sQy1SHz5
         8d4A==
X-Gm-Message-State: AHQUAua25uKZKJgAbSccV7DIq6Zu+gaEe8K7YMTi0goacd2v2QzBfAck
        VSCN2dsRXi0iB3CTQR6JYKvY9owu
X-Google-Smtp-Source: AHgI3IbCpiUk3dEEVe5Y/RlfWmFIMbtuFTO8485IEZBSZk3Sxj+Z4CvxX45y5UO0lHW6v1le7cqOkQ==
X-Received: by 2002:a24:de87:: with SMTP id d129mr190484itg.110.1549902241541;
        Mon, 11 Feb 2019 08:24:01 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c15sm5000173ioi.66.2019.02.11.08.24.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:01 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGO0bI029964;
        Mon, 11 Feb 2019 16:24:00 GMT
Subject: [PATCH v1 04/23] SUNRPC: Display symbolic flag names in RPC trace
 events
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:00 -0500
Message-ID: <20190211162400.2817.53127.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Human-readable flags make it easier to observe RPC scheduling
decisions and other operational details.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   56 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 50 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 0d5d0d9..f88b0f5 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -77,6 +77,50 @@
 		)
 );
 
+TRACE_DEFINE_ENUM(RPC_TASK_ASYNC);
+TRACE_DEFINE_ENUM(RPC_TASK_SWAPPER);
+TRACE_DEFINE_ENUM(RPC_CALL_MAJORSEEN);
+TRACE_DEFINE_ENUM(RPC_TASK_ROOTCREDS);
+TRACE_DEFINE_ENUM(RPC_TASK_DYNAMIC);
+TRACE_DEFINE_ENUM(RPC_TASK_KILLED);
+TRACE_DEFINE_ENUM(RPC_TASK_SOFT);
+TRACE_DEFINE_ENUM(RPC_TASK_SOFTCONN);
+TRACE_DEFINE_ENUM(RPC_TASK_SENT);
+TRACE_DEFINE_ENUM(RPC_TASK_TIMEOUT);
+TRACE_DEFINE_ENUM(RPC_TASK_NOCONNECT);
+TRACE_DEFINE_ENUM(RPC_TASK_NO_RETRANS_TIMEOUT);
+
+#define rpc_show_task_flags(flags)					\
+	__print_flags(flags, "|",					\
+		{ RPC_TASK_ASYNC, "ASYNC" },				\
+		{ RPC_TASK_SWAPPER, "SWAPPER" },			\
+		{ RPC_CALL_MAJORSEEN, "MAJORSEEN" },			\
+		{ RPC_TASK_ROOTCREDS, "ROOTCREDS" },			\
+		{ RPC_TASK_DYNAMIC, "DYNAMIC" },			\
+		{ RPC_TASK_KILLED, "KILLED" },				\
+		{ RPC_TASK_SOFT, "SOFT" },				\
+		{ RPC_TASK_SOFTCONN, "SOFTCONN" },			\
+		{ RPC_TASK_SENT, "SENT" },				\
+		{ RPC_TASK_TIMEOUT, "TIMEOUT" },			\
+		{ RPC_TASK_NOCONNECT, "NOCONNECT" },			\
+		{ RPC_TASK_NO_RETRANS_TIMEOUT, "NORTO" })
+
+TRACE_DEFINE_ENUM(RPC_TASK_RUNNING);
+TRACE_DEFINE_ENUM(RPC_TASK_QUEUED);
+TRACE_DEFINE_ENUM(RPC_TASK_ACTIVE);
+TRACE_DEFINE_ENUM(RPC_TASK_NEED_XMIT);
+TRACE_DEFINE_ENUM(RPC_TASK_NEED_RECV);
+TRACE_DEFINE_ENUM(RPC_TASK_MSG_PIN_WAIT);
+
+#define rpc_show_runstate(flags)					\
+	__print_flags(flags, "|",					\
+		{ (1UL << RPC_TASK_RUNNING), "RUNNING" },		\
+		{ (1UL << RPC_TASK_QUEUED), "QUEUED" },			\
+		{ (1UL << RPC_TASK_ACTIVE), "ACTIVE" },			\
+		{ (1UL << RPC_TASK_NEED_XMIT), "NEED_XMIT" },		\
+		{ (1UL << RPC_TASK_NEED_RECV), "NEED_RECV" },		\
+		{ (1UL << RPC_TASK_MSG_PIN_WAIT), "MSG_PIN_WAIT" })
+
 DECLARE_EVENT_CLASS(rpc_task_running,
 
 	TP_PROTO(const struct rpc_task *task, const void *action),
@@ -102,10 +146,10 @@
 		__entry->flags = task->tk_flags;
 		),
 
-	TP_printk("task:%u@%d flags=%4.4x state=%4.4lx status=%d action=%pf",
+	TP_printk("task:%u@%d flags=%s runstate=%s status=%d action=%pf",
 		__entry->task_id, __entry->client_id,
-		__entry->flags,
-		__entry->runstate,
+		rpc_show_task_flags(__entry->flags),
+		rpc_show_runstate(__entry->runstate),
 		__entry->status,
 		__entry->action
 		)
@@ -149,10 +193,10 @@
 		__assign_str(q_name, rpc_qname(q));
 		),
 
-	TP_printk("task:%u@%d flags=%4.4x state=%4.4lx status=%d timeout=%lu queue=%s",
+	TP_printk("task:%u@%d flags=%s runstate=%s status=%d timeout=%lu queue=%s",
 		__entry->task_id, __entry->client_id,
-		__entry->flags,
-		__entry->runstate,
+		rpc_show_task_flags(__entry->flags),
+		rpc_show_runstate(__entry->runstate),
 		__entry->status,
 		__entry->timeout,
 		__get_str(q_name)

