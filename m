Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D0F1C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4274218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UWjY5nw5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728700AbfBKQYT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:19 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:36424 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728699AbfBKQYS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:18 -0500
Received: by mail-it1-f196.google.com with SMTP id c9so27702549itj.1;
        Mon, 11 Feb 2019 08:24:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=iFs5pcOp/J41ovxb5GvsjSrHLbi8rpX4+Bpm+F8aumw=;
        b=UWjY5nw5qZ/NA9pgjLoYpgvealZAA/K2CKi76QAZgp/ABPE+ZdHcijiA6BGajBZdGg
         xB944U97H849N+/s36CHmBFYdW2hg8mPCDXyYDVOwVoBriw/nA1ES17JHAEeK6HxUPkz
         aOOefaZXxxPfp0Sx492O2ydEqlWyV80rbb/DpuaVJSldiadwwgzfvp4Ms2N2bBuF09fY
         ZLp23EXdYJ7Qf6wxSKab/MyQ4uwwzBzKgRyU7Slm8AeSnnx9tWvb0q5eh+jLfEyL+Dby
         XPIgoS5JMaj8Q6SLgfYihYRUpAa+5av8SnIfNDrglJSjzZHt67+dKfrmhnZc8n4ps6xM
         XfBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=iFs5pcOp/J41ovxb5GvsjSrHLbi8rpX4+Bpm+F8aumw=;
        b=rdXP5ICxsFWy2ioUQ14FkhqjfBHoFPLEMT90+aksdbj+ITm6USQpO8rWCEy+Qj6xJc
         zkqZYBA5cszho1KGMrBhK/9GQeXL4NQ+Uc4fFHSRGDxFt8SXGQ2yz2KW9NWL9FgLJ7md
         7K1d6GzsYmmpfeR3qPdHTnisVQ451PJM/7A3NmBO9IpZ/K8bu1KRkBP/TZqu3XZQ8wsy
         lvl374TwtHjJxiNR8R9wJERZUvF7xHHLMdbn8SoEjz9aAq3v8Qk8h7FFVltSMyxL2Hc9
         6bcQAmpUQAlcbwxmOEGN+kXfoZVA0ypwgG59iGPO8bcEqXQW3w9toP0ye3vZ3tADDJr2
         hPTA==
X-Gm-Message-State: AHQUAubR5i4rbi5xT9TGAOSxil/J8ZTV4cp2st2Ka6kb+F8WnfyzAzE2
        VnJK+zpEG7Qt6JzD2xZDugY=
X-Google-Smtp-Source: AHgI3IY1ab/JWl1AJsWeMQLPtUhzmLwWUgAc5ndIcoctMmV1bdTNTa65mQSOMMcf0vm6YRcUKpeXRg==
X-Received: by 2002:a5e:de45:: with SMTP id e5mr14065880ioq.294.1549902257612;
        Mon, 11 Feb 2019 08:24:17 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id h123sm5339650itb.36.2019.02.11.08.24.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:16 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOGrA029973;
        Mon, 11 Feb 2019 16:24:16 GMT
Subject: [PATCH v1 07/23] SUNRPC: Add trace event that reports reply page
 vector alignment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:16 -0500
Message-ID: <20190211162416.2817.25507.stgit@manet.1015granger.net>
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
index fbc41b8..6276508 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -321,6 +321,65 @@
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
index 6d0b615..5f0aa53 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -347,13 +347,15 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
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
 
@@ -367,6 +369,7 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
 			copy = tail->iov_len - len;
 			memmove((char *)tail->iov_base + len,
 					tail->iov_base, copy);
+			result += copy;
 		}
 		/* Copy from the inlined pages into the tail */
 		copy = len;
@@ -377,11 +380,13 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
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
@@ -391,6 +396,7 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
 					(char *)head->iov_base +
 					head->iov_len - offs,
 					copy);
+			result += copy;
 		}
 	}
 	/* Now handle pages */
@@ -406,12 +412,15 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
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
@@ -423,14 +432,16 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
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
 
@@ -448,18 +459,22 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
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

