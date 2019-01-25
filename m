Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0774C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:10:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 717EA21855
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:10:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ojTGJhtk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726321AbfAYWKK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 17:10:10 -0500
Received: from mail-pl1-f193.google.com ([209.85.214.193]:41741 "EHLO
        mail-pl1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726284AbfAYWKK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 17:10:10 -0500
Received: by mail-pl1-f193.google.com with SMTP id u6so5155040plm.8
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2019 14:10:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=up0okbHSGPL9FNXNzKZ/imEdDSLZPRgVundYrufTGtA=;
        b=ojTGJhtk6IRPYGee/CPK3q129QfqADZ7/sk8biwErKYXJhU3oxTMoq6vRbUFThNKVP
         MtkiyXkUWW7pwTyWRvdhtZpwijVfcMy4Hagm3UilMnCCnbrv4Pc47gOjP3Ipr2Y/ZnTh
         1sYF7GTAa7egrt07gzf6D6bVuWPsAnah43onmJgmjtPqg+DvozUKKY11ApBKiDtQLP0y
         6EoRSp5AW2GQ5HcyKwWW4UTdp8HldgQtiGHRFdnPkNdmg985IbasgXrCFPfI7UjmPCaE
         HIxiWl1e9zFzs3lgiPSbTP1ZHN7lVxmoO3QHKOn6GK9q5sBUuMYiEjyuAjVLuN+mXZ9v
         V8uQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=up0okbHSGPL9FNXNzKZ/imEdDSLZPRgVundYrufTGtA=;
        b=f+3m33y6ND3rf2EwSkDWVgY/qk9acBF9TwD4jlme8wsRFdUPfy4hQr4JKjuOKqPzWh
         tsoqwYRdZHOSm9fI1L6ZfNSGfP+uztWVp8DOIB7E+iJq+eAlTtxZmHEPO8QoMVbfXnOE
         eZnLOJIiysD4lDa1tzQWp86loM7/bKujgbHqAxhjxsmRO6mCvkCrMra2ApmWckjZtsFS
         8SNlkvvPGA1rHbTWUi+aQ35m17uV2FdWpvWQjws/joRQcZ/R8+/hg5kNinoGkqXYZOI7
         K29fr2x0YFo7XiqGuq1GpBmFb2OHFIPrK8pFMT8BoY9X7l/YgM8B8z33KJrrwkZQuQ2Q
         umxA==
X-Gm-Message-State: AJcUukd/6Zq0sRYPztA3VBaxf3iSjAajOygLzAxoLmoAHUNR70Xa5Z04
        DHHstzQ7HCeeGY3GmatyQu7OW/Lh
X-Google-Smtp-Source: ALg8bN7g/9QhjR/EqfrsnjQFVtTNb4HSx1MrEiFsrwabennQ7UFK5v+TVxNh30WDz/KTupZ2qzFnNQ==
X-Received: by 2002:a17:902:a5c3:: with SMTP id t3mr12551431plq.117.1548454209366;
        Fri, 25 Jan 2019 14:10:09 -0800 (PST)
Received: from seurat.1015granger.net ([148.87.23.44])
        by smtp.gmail.com with ESMTPSA id 125sm30572672pfx.159.2019.01.25.14.10.08
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 14:10:08 -0800 (PST)
Subject: [PATCH RFC 3/5] SUNRPC: Add trace event that reports reply page
 vector alignment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 25 Jan 2019 17:09:48 -0500
Message-ID: <154845416812.70638.16451351776177729009.stgit@seurat.1015granger.net>
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

We don't want READ payloads that are partially in the head iovec and
in the page buffer because this requires pull-up, which can be
expensive.

The NFS/RPC client tries hard to predict the size of the head iovec
so that the incoming READ data payload lands only in the page
vector, but it doesn't always get it right. To help diagnose such
problems, add a trace point in the logic that decodes READ-like
operations that reports whether pull-up is being done.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h |   59 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xdr.c              |   33 +++++++++++++++++++----
 2 files changed, 86 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index fbc41b8142d3..627650800676 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -321,6 +321,65 @@ TRACE_EVENT(rpc_xdr_overflow,
 	)
 );
 
+TRACE_EVENT(rpc_xdr_alignment,
+	TP_PROTO(
+		const struct xdr_stream *xdr,
+		size_t offset,
+		unsigned int copied
+	),
+
+	TP_ARGS(xdr, offset, copied),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(int, version)
+		__field(size_t, offset)
+		__field(unsigned int, copied)
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
+		const struct rpc_task *task = xdr->rqst->rq_task;
+
+		__entry->task_id = task->tk_pid;
+		__entry->client_id = task->tk_client->cl_clid;
+		__assign_str(progname,
+			     task->tk_client->cl_program->name)
+		__entry->version = task->tk_client->cl_vers;
+		__assign_str(procedure, task->tk_msg.rpc_proc->p_name)
+
+		__entry->offset = offset;
+		__entry->copied = copied;
+		__entry->head_base = xdr->buf->head[0].iov_base,
+		__entry->head_len = xdr->buf->head[0].iov_len,
+		__entry->page_len = xdr->buf->page_len,
+		__entry->tail_base = xdr->buf->tail[0].iov_base,
+		__entry->tail_len = xdr->buf->tail[0].iov_len,
+		__entry->len = xdr->buf->len;
+	),
+
+	TP_printk(
+		"task:%u@%u %sv%d %s offset=%zu copied=%u xdr=[%p,%zu]/%u/[%p,%zu]/%u\n",
+		__entry->task_id, __entry->client_id,
+		__get_str(progname), __entry->version, __get_str(procedure),
+		__entry->offset, __entry->copied,
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
index 6d0b615a02ae..5f0aa53fa4ae 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -347,13 +347,15 @@ EXPORT_SYMBOL_GPL(_copy_from_pages);
  * 'len' bytes. The extra data is not lost, but is instead
  * moved into the inlined pages and/or the tail.
  */
-static void
+static unsigned int
 xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 {
 	struct kvec *head, *tail;
 	size_t copy, offs;
 	unsigned int pglen = buf->page_len;
+	unsigned int result;
 
+	result = 0;
 	tail = buf->tail;
 	head = buf->head;
 
@@ -367,6 +369,7 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 			copy = tail->iov_len - len;
 			memmove((char *)tail->iov_base + len,
 					tail->iov_base, copy);
+			result += copy;
 		}
 		/* Copy from the inlined pages into the tail */
 		copy = len;
@@ -377,11 +380,13 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 			copy = 0;
 		else if (copy > tail->iov_len - offs)
 			copy = tail->iov_len - offs;
-		if (copy != 0)
+		if (copy != 0) {
 			_copy_from_pages((char *)tail->iov_base + offs,
 					buf->pages,
 					buf->page_base + pglen + offs - len,
 					copy);
+			result += copy;
+		}
 		/* Do we also need to copy data from the head into the tail ? */
 		if (len > pglen) {
 			offs = copy = len - pglen;
@@ -391,6 +396,7 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 					(char *)head->iov_base +
 					head->iov_len - offs,
 					copy);
+			result += copy;
 		}
 	}
 	/* Now handle pages */
@@ -406,12 +412,15 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 		_copy_to_pages(buf->pages, buf->page_base,
 				(char *)head->iov_base + head->iov_len - len,
 				copy);
+		result += copy;
 	}
 	head->iov_len -= len;
 	buf->buflen -= len;
 	/* Have we truncated the message? */
 	if (buf->len > buf->buflen)
 		buf->len = buf->buflen;
+
+	return result;
 }
 
 /**
@@ -423,14 +432,16 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
  * 'len' bytes. The extra data is not lost, but is instead
  * moved into the tail.
  */
-static void
+static unsigned int
 xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 {
 	struct kvec *tail;
 	size_t copy;
 	unsigned int pglen = buf->page_len;
 	unsigned int tailbuf_len;
+	unsigned int result;
 
+	result = 0;
 	tail = buf->tail;
 	BUG_ON (len > pglen);
 
@@ -448,18 +459,22 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 		if (tail->iov_len > len) {
 			char *p = (char *)tail->iov_base + len;
 			memmove(p, tail->iov_base, tail->iov_len - len);
+			result += tail->iov_len - len;
 		} else
 			copy = tail->iov_len;
 		/* Copy from the inlined pages into the tail */
 		_copy_from_pages((char *)tail->iov_base,
 				buf->pages, buf->page_base + pglen - len,
 				copy);
+		result += copy;
 	}
 	buf->page_len -= len;
 	buf->buflen -= len;
 	/* Have we truncated the message? */
 	if (buf->len > buf->buflen)
 		buf->len = buf->buflen;
+
+	return result;
 }
 
 void
@@ -959,13 +974,17 @@ static unsigned int xdr_align_pages(struct xdr_stream *xdr, unsigned int len)
 	struct kvec *iov;
 	unsigned int nwords = XDR_QUADLEN(len);
 	unsigned int cur = xdr_stream_pos(xdr);
+	unsigned int copied, offset;
 
 	if (xdr->nwords == 0)
 		return 0;
+
 	/* Realign pages to current pointer position */
-	iov  = buf->head;
+	iov = buf->head;
 	if (iov->iov_len > cur) {
-		xdr_shrink_bufhead(buf, iov->iov_len - cur);
+		offset = iov->iov_len - cur;
+		copied = xdr_shrink_bufhead(buf, offset);
+		trace_rpc_xdr_alignment(xdr, offset, copied);
 		xdr->nwords = XDR_QUADLEN(buf->len - cur);
 	}
 
@@ -977,7 +996,9 @@ static unsigned int xdr_align_pages(struct xdr_stream *xdr, unsigned int len)
 		len = buf->page_len;
 	else if (nwords < xdr->nwords) {
 		/* Truncate page data and move it into the tail */
-		xdr_shrink_pagelen(buf, buf->page_len - len);
+		offset = buf->page_len - len;
+		copied = xdr_shrink_pagelen(buf, offset);
+		trace_rpc_xdr_alignment(xdr, offset, copied);
 		xdr->nwords = XDR_QUADLEN(buf->len - cur);
 	}
 	return len;

