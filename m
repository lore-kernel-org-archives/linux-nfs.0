Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1005CC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9EC82133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tC3c6RwA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388240AbeLQQlH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:07 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:54028 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:07 -0500
Received: by mail-it1-f195.google.com with SMTP id g85so19466044ita.3;
        Mon, 17 Dec 2018 08:41:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=/fajm+Q6Ev3B90pszxLhoKhMSyNLhkbB0DmCyy0qBQc=;
        b=tC3c6RwAWhhhoMnMOh95TdEYVdjwKyr3mDiDho3/GiKISaEGJ0sXKMVrtYAH/iRUZ0
         TXcSV1yoJBBULpqhg2KKCYGNem9wvjls1suQ+gKmgot/hLPqHCKW+0YYbltSjMveiUw+
         IjsQS+v4aOJB4M5S7n1dmGoh94PD7kKLLgJoyN7OnkW4jszkdxWt3wxkJZLW6CDBSUWS
         au7jkZSM2bJerMfxeAypOgYg2FKtmXkmifPa+S2vhRMTgGAKLR6FOLQKkyvMslGgf+uk
         DrATQ+6lvj8uLnFJieGmbvYYzNn4FaKI3fveuDfjUf+k4DHabHTdsSscdpKtdKnnZa6o
         ofmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/fajm+Q6Ev3B90pszxLhoKhMSyNLhkbB0DmCyy0qBQc=;
        b=Om6EBTrG6EIsMB4y37p9xiZxqU3Kpf8Eg+S8bnWPUhMX0V+9RuPLChk98i7gCSa1A1
         wdpB9Ra29kKrPfap+lZkIEBNQbnUmby/43T63kqiD7qHsmbj2fzqJLTe8qoKISgeBqtc
         p36Rkfvx0vU/99/Soi1I35sksa3dobnlRPLis3vSqMc+2bZ3WOkweTf71pGeb4KYRcFg
         koUUVskPzRhdDLKkd+4Wz4syyUTKhgGVKntz5FuiwLzRGdcSCbNcIxJPlPgtvZW6pmXM
         lFr0Cdc8eiqwsm1L2Kc3hwks7rDgJxKkba/DczYFiaW+IG3qkFaOXwK3NCG64KRFkOA1
         f8ow==
X-Gm-Message-State: AA+aEWZJ7H71pVhWrmUc8jDghc8sBXsL4Qq3rj4ciQ5lYLBZXJPOuAkA
        QH9BzypFmqibDsytgla9Q/Zym6fh
X-Google-Smtp-Source: AFSGD/XZWqGlSStXNgTHM71Hy8yWU5IAa5Bcc3VkKuOfVe8+wrq9KiXKvG/KKF8W73sAtlYwTfQegw==
X-Received: by 2002:a24:65c8:: with SMTP id u191mr13061612itb.7.1545064865315;
        Mon, 17 Dec 2018 08:41:05 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x99sm7369113ita.23.2018.12.17.08.41.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:03 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGf2Y1018636;
        Mon, 17 Dec 2018 16:41:02 GMT
Subject: [PATCH v4 19/30] xprtrdma: Clean up of xprtrdma chunk trace points
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:02 -0500
Message-ID: <20181217164102.24133.76850.stgit@manet.1015granger.net>
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

The chunk-related trace points capture nearly the same information
as the MR-related trace points.

Also, rename them so globbing can be used to enable or disable
these trace points more easily.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   42 +++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/rpc_rdma.c |    6 +++---
 2 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 2efe2d7..e9fbf7d 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -97,7 +97,6 @@
 	TP_STRUCT__entry(
 		__field(unsigned int, task_id)
 		__field(unsigned int, client_id)
-		__field(const void *, mr)
 		__field(unsigned int, pos)
 		__field(int, nents)
 		__field(u32, handle)
@@ -109,7 +108,6 @@
 	TP_fast_assign(
 		__entry->task_id = task->tk_pid;
 		__entry->client_id = task->tk_client->cl_clid;
-		__entry->mr = mr;
 		__entry->pos = pos;
 		__entry->nents = mr->mr_nents;
 		__entry->handle = mr->mr_handle;
@@ -118,8 +116,8 @@
 		__entry->nsegs = nsegs;
 	),
 
-	TP_printk("task:%u@%u mr=%p pos=%u %u@0x%016llx:0x%08x (%s)",
-		__entry->task_id, __entry->client_id, __entry->mr,
+	TP_printk("task:%u@%u pos=%u %u@0x%016llx:0x%08x (%s)",
+		__entry->task_id, __entry->client_id,
 		__entry->pos, __entry->length,
 		(unsigned long long)__entry->offset, __entry->handle,
 		__entry->nents < __entry->nsegs ? "more" : "last"
@@ -127,7 +125,7 @@
 );
 
 #define DEFINE_RDCH_EVENT(name)						\
-		DEFINE_EVENT(xprtrdma_rdch_event, name,			\
+		DEFINE_EVENT(xprtrdma_rdch_event, xprtrdma_chunk_##name,\
 				TP_PROTO(				\
 					const struct rpc_task *task,	\
 					unsigned int pos,		\
@@ -148,7 +146,6 @@
 	TP_STRUCT__entry(
 		__field(unsigned int, task_id)
 		__field(unsigned int, client_id)
-		__field(const void *, mr)
 		__field(int, nents)
 		__field(u32, handle)
 		__field(u32, length)
@@ -159,7 +156,6 @@
 	TP_fast_assign(
 		__entry->task_id = task->tk_pid;
 		__entry->client_id = task->tk_client->cl_clid;
-		__entry->mr = mr;
 		__entry->nents = mr->mr_nents;
 		__entry->handle = mr->mr_handle;
 		__entry->length = mr->mr_length;
@@ -167,8 +163,8 @@
 		__entry->nsegs = nsegs;
 	),
 
-	TP_printk("task:%u@%u mr=%p %u@0x%016llx:0x%08x (%s)",
-		__entry->task_id, __entry->client_id, __entry->mr,
+	TP_printk("task:%u@%u %u@0x%016llx:0x%08x (%s)",
+		__entry->task_id, __entry->client_id,
 		__entry->length, (unsigned long long)__entry->offset,
 		__entry->handle,
 		__entry->nents < __entry->nsegs ? "more" : "last"
@@ -176,7 +172,7 @@
 );
 
 #define DEFINE_WRCH_EVENT(name)						\
-		DEFINE_EVENT(xprtrdma_wrch_event, name,			\
+		DEFINE_EVENT(xprtrdma_wrch_event, xprtrdma_chunk_##name,\
 				TP_PROTO(				\
 					const struct rpc_task *task,	\
 					struct rpcrdma_mr *mr,		\
@@ -234,6 +230,18 @@
 				),					\
 				TP_ARGS(wc, frwr))
 
+TRACE_DEFINE_ENUM(DMA_BIDIRECTIONAL);
+TRACE_DEFINE_ENUM(DMA_TO_DEVICE);
+TRACE_DEFINE_ENUM(DMA_FROM_DEVICE);
+TRACE_DEFINE_ENUM(DMA_NONE);
+
+#define xprtrdma_show_direction(x)					\
+		__print_symbolic(x,					\
+				{ DMA_BIDIRECTIONAL, "BIDIR" },		\
+				{ DMA_TO_DEVICE, "TO_DEVICE" },		\
+				{ DMA_FROM_DEVICE, "FROM_DEVICE" },	\
+				{ DMA_NONE, "NONE" })
+
 DECLARE_EVENT_CLASS(xprtrdma_mr,
 	TP_PROTO(
 		const struct rpcrdma_mr *mr
@@ -246,6 +254,7 @@
 		__field(u32, handle)
 		__field(u32, length)
 		__field(u64, offset)
+		__field(u32, dir)
 	),
 
 	TP_fast_assign(
@@ -253,12 +262,13 @@
 		__entry->handle = mr->mr_handle;
 		__entry->length = mr->mr_length;
 		__entry->offset = mr->mr_offset;
+		__entry->dir    = mr->mr_dir;
 	),
 
-	TP_printk("mr=%p %u@0x%016llx:0x%08x",
+	TP_printk("mr=%p %u@0x%016llx:0x%08x (%s)",
 		__entry->mr, __entry->length,
-		(unsigned long long)__entry->offset,
-		__entry->handle
+		(unsigned long long)__entry->offset, __entry->handle,
+		xprtrdma_show_direction(__entry->dir)
 	)
 );
 
@@ -437,9 +447,9 @@
 
 DEFINE_RXPRT_EVENT(xprtrdma_nomrs);
 
-DEFINE_RDCH_EVENT(xprtrdma_read_chunk);
-DEFINE_WRCH_EVENT(xprtrdma_write_chunk);
-DEFINE_WRCH_EVENT(xprtrdma_reply_chunk);
+DEFINE_RDCH_EVENT(read);
+DEFINE_WRCH_EVENT(write);
+DEFINE_WRCH_EVENT(reply);
 
 TRACE_DEFINE_ENUM(rpcrdma_noch);
 TRACE_DEFINE_ENUM(rpcrdma_readch);
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 5a58769..54fbd70 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -365,7 +365,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		if (encode_read_segment(xdr, mr, pos) < 0)
 			return -EMSGSIZE;
 
-		trace_xprtrdma_read_chunk(rqst->rq_task, pos, mr, nsegs);
+		trace_xprtrdma_chunk_read(rqst->rq_task, pos, mr, nsegs);
 		r_xprt->rx_stats.read_chunk_count++;
 		nsegs -= mr->mr_nents;
 	} while (nsegs);
@@ -422,7 +422,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		if (encode_rdma_segment(xdr, mr) < 0)
 			return -EMSGSIZE;
 
-		trace_xprtrdma_write_chunk(rqst->rq_task, mr, nsegs);
+		trace_xprtrdma_chunk_write(rqst->rq_task, mr, nsegs);
 		r_xprt->rx_stats.write_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += mr->mr_length;
 		nchunks++;
@@ -479,7 +479,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		if (encode_rdma_segment(xdr, mr) < 0)
 			return -EMSGSIZE;
 
-		trace_xprtrdma_reply_chunk(rqst->rq_task, mr, nsegs);
+		trace_xprtrdma_chunk_reply(rqst->rq_task, mr, nsegs);
 		r_xprt->rx_stats.reply_chunk_count++;
 		r_xprt->rx_stats.total_rdma_request += mr->mr_length;
 		nchunks++;

