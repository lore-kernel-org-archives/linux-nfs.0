Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F0A8C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:09:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F37821855
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:09:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a5+5ftCa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726362AbfAYWJW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 17:09:22 -0500
Received: from mail-pg1-f196.google.com ([209.85.215.196]:38125 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726321AbfAYWJW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 17:09:22 -0500
Received: by mail-pg1-f196.google.com with SMTP id g189so4750328pgc.5
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2019 14:09:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=i22o3ksy7c0D+LS+PGtog5p4EJ4H8v6Pll4VIT9fBLU=;
        b=a5+5ftCaNER+K2hI1VmCjrmzQcNjlGBS3QbHpKuzngflr9LnEwcF1ZKwal09uAHL5v
         WaVPH2iX46grMvM7ZDvWiT+9/SE7qiWJ1BZSHJSPiF38N6FJVjkEpyqzJOS/QfioIYyg
         d0ik6NJIrzAcWtrZx7f4PFDP6h7O8TRTU7a8EoR3ffpMfset9TroZyO2G+KrzYE9ULuJ
         wTO5zMHPBKX4b5dLtW4iiwtVl1sfCPzQszVcesyFvScdZRI6tEFsu6drHE/gUos5TjVK
         5z3Fa/lTeyiul1wwMEw8j38S7xNA5m9R3LKkAPvJUh9qxf9LXFNBfI/HvIlF0+k0J64I
         3kFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=i22o3ksy7c0D+LS+PGtog5p4EJ4H8v6Pll4VIT9fBLU=;
        b=EmY5oGIVTBPgDqX8Z3Xit8rBzLQtWQZjYIAkYer31LQvswFbZThzDODY/oyqtB5/V6
         wu7Y1PDH8WLA2iHMqO8ckekgF9hY+xNmJEZwN5i/zidkqJP7aQr6s4KyDNTYvXjs+/cp
         2VWfIsoJBJUaZ6+d6dwwjFtRhB8/UP7L/Qaeu7No8hPH5tfNm8bKHFunEeh714jloH/b
         QbYuSQz70j/rScI7ERgijZ5RXCbL9nkBWmIXM8nymK/9MlD3G7t8bWOE7ymTxEU4/zQm
         HZ+VQuv5W6cfxLQc5jz2gNPo4sjz3Mayuvw0nCosAIzOdBhZxB2gTsmXLVmIQ5MRf/tc
         UapA==
X-Gm-Message-State: AJcUuketwVR238ImQRjgZaywSh4Wxn6y4AqbrYNzgtYMz/AZj7ueAfmq
        +e5F6d/wSEY2iwPzIPLjkQLsDKGE
X-Google-Smtp-Source: ALg8bN40cHjgnnJPNiPSfGIEz2OHLU0A/xvlUjEjOnT21rIaW3j1aZDONqYbNLh3J8w/+M8pkDWBHA==
X-Received: by 2002:a63:7f4f:: with SMTP id p15mr11647168pgn.296.1548454161013;
        Fri, 25 Jan 2019 14:09:21 -0800 (PST)
Received: from seurat.1015granger.net ([148.87.23.44])
        by smtp.gmail.com with ESMTPSA id m65sm62439288pfg.180.2019.01.25.14.09.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 14:09:20 -0800 (PST)
Subject: [PATCH RFC 2/5] SUNRPC: Add XDR overflow trace event
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 25 Jan 2019 17:08:59 -0500
Message-ID: <154845411975.70638.1963883055849267517.stgit@seurat.1015granger.net>
In-Reply-To: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
References: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
User-Agent: StGit/unknown-version
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
index f88b0f52aa7e..fbc41b8142d3 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -254,6 +254,73 @@ TRACE_EVENT(rpc_stats_latency,
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
index 345f08b634ee..6d0b615a02ae 100644
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
 

