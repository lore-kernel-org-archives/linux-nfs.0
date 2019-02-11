Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8021C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 76F2D218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WpH3d83B"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728539AbfBKQYO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:14 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:35053 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728096AbfBKQYN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:13 -0500
Received: by mail-it1-f195.google.com with SMTP id v72so2762236itc.0;
        Mon, 11 Feb 2019 08:24:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=UzY2+bCRqn1Brv41PHmWOM9CfB1orMDzn3vzRPwOzWM=;
        b=WpH3d83BczZNh066kC6Lyh43F7IvInwtukoh7II9iuKi4qig0c9Qpwq4GWDrTkYlqB
         ezzDIhLux4uiEk/mOsNNN1JzYac/Jf6sD3965r356N/rpyqU16i5xo9gAGmxrPECyNxG
         dBWtm8UTxFmFUXHUM0pb8GSv+1TSBlsQe0+X5NLAn3mRVk/j5BJ9ws5eF4E2tBNiKRiX
         ltVzZ8/6Ctqz7GxmazX2C1i8Yf+9TZmUwFTX7aa6bAKB2edV/G9aIhui+jUkzvUQ9sz4
         RsZT7DS0m4LJhvwsa7ZqfSe+VqT3xpglVk4GJC5rBXKagdUTFzcydHg6cR8Y1PHWurGl
         SQyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=UzY2+bCRqn1Brv41PHmWOM9CfB1orMDzn3vzRPwOzWM=;
        b=uQG0XaOetpSrwOx7wfyXGw6uNnoablrF/+KsT9XEg8GkgXPCd3zSWACVfWO27oh7q0
         USkZM+2O40TUnRjLKEeOnStbzAUPi4+kk1FFCbaPiw+rdZ0870G0Zmz5V0hKHVnnizsP
         W92nqCrMfQgjPRpzIbQTlbh9XbAQxLobutz6QxumJGq8oiZlPx+oNQzUODzcntDA3xE0
         xGSC2CO5SVjkctyHbGZDkeoDij1WEUU1Isq6iam+6IjI7fZGh81UYxUpRRvnQEeVuSvx
         5MOUnqfkmitCflFzSAHxnsUutDerW8haq4y68c+k7LW9P6SV4notVgPbjexH452zh5pf
         C7xg==
X-Gm-Message-State: AHQUAuYVAto7kPq14DhWzYhqF+bV+26vCuKAhXRL4vLXmi+0WlEE4e6G
        bTVUgNvL144Ts4b33q3/2Q4=
X-Google-Smtp-Source: AHgI3IYZcm5iOyF8AahZNkbRPyjGVlFSZgSHWDfVeI2U4E+YD24pru7J6boTMBy1OqLp4pKnrM5DvA==
X-Received: by 2002:a02:9c16:: with SMTP id q22mr6559203jak.49.1549902252067;
        Mon, 11 Feb 2019 08:24:12 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u19sm5059518iog.17.2019.02.11.08.24.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:11 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOAx3029970;
        Mon, 11 Feb 2019 16:24:10 GMT
Subject: [PATCH v1 06/23] SUNRPC: Add XDR overflow trace event
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:10 -0500
Message-ID: <20190211162410.2817.88199.stgit@manet.1015granger.net>
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

This can help field troubleshooting without needing the overhead of
a full network capture (ie, tcpdump).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   67 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xdr.c              |   24 ++++++++++-----
 2 files changed, 84 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index f88b0f5..fbc41b8 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -254,6 +254,73 @@
 		__entry->backlog, __entry->rtt, __entry->execute)
 );
 
+TRACE_EVENT(rpc_xdr_overflow,
+	TP_PROTO(
+		const struct xdr_stream *xdr,
+		size_t requested
+	),
+
+	TP_ARGS(xdr, requested),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(int, version)
+		__field(size_t, requested)
+		__field(const void *, end)
+		__field(const void *, p)
+		__field(const void *, head_base)
+		__field(size_t, head_len)
+		__field(const void *, tail_base)
+		__field(size_t, tail_len)
+		__field(unsigned int, page_len)
+		__field(unsigned int, len)
+		__string(progname,
+			 xdr->rqst->rq_task->tk_client->cl_program->name)
+		__string(procedure,
+			 xdr->rqst->rq_task->tk_msg.rpc_proc->p_name)
+	),
+
+	TP_fast_assign(
+		if (xdr->rqst) {
+			const struct rpc_task *task = xdr->rqst->rq_task;
+
+			__entry->task_id = task->tk_pid;
+			__entry->client_id = task->tk_client->cl_clid;
+			__assign_str(progname,
+				     task->tk_client->cl_program->name)
+			__entry->version = task->tk_client->cl_vers;
+			__assign_str(procedure, task->tk_msg.rpc_proc->p_name)
+		} else {
+			__entry->task_id = 0;
+			__entry->client_id = 0;
+			__assign_str(progname, "unknown")
+			__entry->version = 0;
+			__assign_str(procedure, "unknown")
+		}
+		__entry->requested = requested;
+		__entry->end = xdr->end;
+		__entry->p = xdr->p;
+		__entry->head_base = xdr->buf->head[0].iov_base,
+		__entry->head_len = xdr->buf->head[0].iov_len,
+		__entry->page_len = xdr->buf->page_len,
+		__entry->tail_base = xdr->buf->tail[0].iov_base,
+		__entry->tail_len = xdr->buf->tail[0].iov_len,
+		__entry->len = xdr->buf->len;
+	),
+
+	TP_printk(
+		"task:%u@%u %sv%d %s requested=%zu p=%p end=%p xdr=[%p,%zu]/%u/[%p,%zu]/%u\n",
+		__entry->task_id, __entry->client_id,
+		__get_str(progname), __entry->version, __get_str(procedure),
+		__entry->requested, __entry->p, __entry->end,
+		__entry->head_base, __entry->head_len,
+		__entry->page_len,
+		__entry->tail_base, __entry->tail_len,
+		__entry->len
+	)
+);
+
 /*
  * First define the enums in the below macros to be exported to userspace
  * via TRACE_DEFINE_ENUM().
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 345f08b..6d0b615 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/bvec.h>
+#include <trace/events/sunrpc.h>
 
 /*
  * XDR functions for basic NFS types
@@ -554,9 +555,9 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
 	int frag1bytes, frag2bytes;
 
 	if (nbytes > PAGE_SIZE)
-		return NULL; /* Bigger buffers require special handling */
+		goto out_overflow; /* Bigger buffers require special handling */
 	if (xdr->buf->len + nbytes > xdr->buf->buflen)
-		return NULL; /* Sorry, we're totally out of space */
+		goto out_overflow; /* Sorry, we're totally out of space */
 	frag1bytes = (xdr->end - xdr->p) << 2;
 	frag2bytes = nbytes - frag1bytes;
 	if (xdr->iov)
@@ -585,6 +586,9 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
 	xdr->buf->page_len += frag2bytes;
 	xdr->buf->len += nbytes;
 	return p;
+out_overflow:
+	trace_rpc_xdr_overflow(xdr, nbytes);
+	return NULL;
 }
 
 /**
@@ -902,20 +906,23 @@ static __be32 *xdr_copy_to_scratch(struct xdr_stream *xdr, size_t nbytes)
 	size_t cplen = (char *)xdr->end - (char *)xdr->p;
 
 	if (nbytes > xdr->scratch.iov_len)
-		return NULL;
+		goto out_overflow;
 	p = __xdr_inline_decode(xdr, cplen);
 	if (p == NULL)
 		return NULL;
 	memcpy(cpdest, p, cplen);
+	if (!xdr_set_next_buffer(xdr))
+		goto out_overflow;
 	cpdest += cplen;
 	nbytes -= cplen;
-	if (!xdr_set_next_buffer(xdr))
-		return NULL;
 	p = __xdr_inline_decode(xdr, nbytes);
 	if (p == NULL)
 		return NULL;
 	memcpy(cpdest, p, nbytes);
 	return xdr->scratch.iov_base;
+out_overflow:
+	trace_rpc_xdr_overflow(xdr, nbytes);
+	return NULL;
 }
 
 /**
@@ -932,14 +939,17 @@ __be32 * xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
 {
 	__be32 *p;
 
-	if (nbytes == 0)
+	if (unlikely(nbytes == 0))
 		return xdr->p;
 	if (xdr->p == xdr->end && !xdr_set_next_buffer(xdr))
-		return NULL;
+		goto out_overflow;
 	p = __xdr_inline_decode(xdr, nbytes);
 	if (p != NULL)
 		return p;
 	return xdr_copy_to_scratch(xdr, nbytes);
+out_overflow:
+	trace_rpc_xdr_overflow(xdr, nbytes);
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(xdr_inline_decode);
 

