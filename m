Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B830C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3B44320675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O2Xbpfap"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726117AbfBVV7X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:59:23 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:41232 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725811AbfBVV7X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:59:23 -0500
Received: by mail-io1-f65.google.com with SMTP id i5so2991804ioq.8
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:59:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ls6fCUTM8OmztX/B8symO/Y6xvSVuhS732vdLknYC4w=;
        b=O2XbpfaphZVNdt5i+dy9GwNINtP5gWKzAlaI9MONklNuFEZgQ5TzQTGrCc8lpm6inT
         Klvd1vmTtFABIrJszE7ewdJunqYQxRULLwDqelbB9Hgb+Uo6owgB33BMS81QdVHa9i2x
         GH25Oz7BbuBlX342IhU4MQIVAXA6V8zvmUC/dcEQWojduh4KuabzWxco061ykEE2YbYz
         csExiAEyvneLKlUdaOlZO6fBe+OAxiS+4aSCV1vaChB9I1YFjxQWt8CWG7SiD2o3IiRN
         GT3nN7k+wN36ZrcnF6wPlXTdDyGj2kuXpq5yIF4u+YYUrHdJ9FZJ7cEgvw5U/yGm5koJ
         GEcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=ls6fCUTM8OmztX/B8symO/Y6xvSVuhS732vdLknYC4w=;
        b=FxjzkKjVcchmZ4TSlCTAwJJ37vucyAjx8gWte4zJAXRkk2MrErahGvVpRJWWOJg1PP
         6C8YGk/OqsOjIX8raWtUFJyIrEu0Qm+bZCMscj07lvLWk4sQig2hPl0qmuf6wjLXVap/
         eDUSNOXn0RrphGk4OgVB2UosV/vXxvw4WwbnNR0zidkOJeqneYjyUA7LudpCVwPovJnZ
         3hCJ8CM50zJN793pms35MSWNoLTUpvIGEP1zi7MQNyB4Q3c40QsWckyJKChFd8rFGhCB
         nViNbYHILyPQva9r1j7cyInU0mJTUAtLQ+KcSAOiX+aHke3Fplgw/jUc0j2RfuswkuWx
         ZE6A==
X-Gm-Message-State: AHQUAuYRs1aXLRxE11KD94dBcEGVt3NmrEqoeC5B4KevZjIgcIxMcklY
        X8wa3/sflh+DbMj5cLnCYlw=
X-Google-Smtp-Source: AHgI3IaCdM2F/u9vuH04chaF9RrMrKiR2AJUR1m3OEJL6zF1VAlt2TgnT/QMU8vk1Z6pdwgPwJS0Bg==
X-Received: by 2002:a5d:9157:: with SMTP id y23mr3509463ioq.115.1550872762038;
        Fri, 22 Feb 2019 13:59:22 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id f13sm998171iol.82.2019.02.22.13.59.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:59:21 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 2/6] SUNRPC: Add the ability to expand holes in data pages
Date:   Fri, 22 Feb 2019 16:59:14 -0500
Message-Id: <20190222215918.20647-3-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
References: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This patch adds the ability to "read a hole" into a set of XDR data
pages by taking the following steps:

1) Shift all data after the current xdr->p to the right, possibly into
   the tail,
2) Zero the specified range, and
3) Update xdr->p to point beyond the hole.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           | 100 +++++++++++++++++++++++++++++++++++++
 2 files changed, 101 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 2ec128060239..47e2d1fff59a 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -243,6 +243,7 @@ extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
+extern size_t xdr_expand_hole(struct xdr_stream *, size_t, uint64_t);
 
 /**
  * xdr_stream_remaining - Return the number of bytes remaining in the stream
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 0fb9bbd2f3c7..27dd3a507ef6 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -253,6 +253,40 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 	} while ((len -= copy) != 0);
 }
 
+static void
+_shift_data_right_tail(struct xdr_buf *buf, size_t pgfrom_base, size_t len)
+{
+	struct kvec *tail = buf->tail;
+
+	/* Make room for new data. */
+	if (tail->iov_len > 0)
+		memmove((char *)tail->iov_base + len, tail->iov_base, len);
+
+	_copy_from_pages((char *)tail->iov_base,
+			 buf->pages,
+			 buf->page_base + pgfrom_base,
+			 len);
+
+	tail->iov_len += len;
+}
+
+static void
+_shift_data_right(struct xdr_buf *buf, size_t to, size_t from, size_t len)
+{
+	size_t shift = len;
+
+	if ((to + len) > buf->page_len) {
+		shift = (to + len) - buf->page_len;
+		_shift_data_right_tail(buf, (from + len) - shift, shift);
+		shift = len - shift;
+	}
+
+	_shift_data_right_pages(buf->pages,
+				buf->page_base + to,
+				buf->page_base + from,
+				shift);
+}
+
 /**
  * _copy_to_pages
  * @pages: array of pages
@@ -337,6 +371,33 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 }
 EXPORT_SYMBOL_GPL(_copy_from_pages);
 
+/**
+ * _zero_data_pages
+ * @pages: array of pages
+ * @pgbase: beginning page vector address
+ * @len: length
+ */
+static void
+_zero_data_pages(struct page **pages, size_t pgbase, size_t len)
+{
+	struct page **page;
+	size_t zero;
+
+	page = pages + (pgbase >> PAGE_SHIFT);
+	pgbase &= ~PAGE_MASK;
+
+	do {
+		zero = len;
+		if (pgbase + zero > PAGE_SIZE)
+			zero = PAGE_SIZE - pgbase;
+
+		zero_user_segment(*page, pgbase, pgbase + zero);
+		page++;
+		pgbase = 0;
+
+	} while ((len -= zero) != 0);
+}
+
 /**
  * xdr_shrink_bufhead
  * @buf: xdr_buf
@@ -478,6 +539,24 @@ unsigned int xdr_stream_pos(const struct xdr_stream *xdr)
 }
 EXPORT_SYMBOL_GPL(xdr_stream_pos);
 
+/**
+ * xdr_page_pos - Return the current offset from the start of the xdr->buf->pages
+ * @xdr: pointer to struct xdr_stream
+ */
+static size_t xdr_page_pos(const struct xdr_stream *xdr)
+{
+	unsigned int offset;
+	unsigned int base = xdr->buf->page_len;
+	void *kaddr = xdr->buf->tail->iov_base;;
+
+	if (xdr->page_ptr) {
+		base   = (xdr->page_ptr - xdr->buf->pages) * PAGE_SIZE;
+		kaddr  = page_address(*xdr->page_ptr);
+	}
+	offset = xdr->p - (__be32 *)kaddr;
+	return base + (offset * sizeof(__be32));
+}
+
 /**
  * xdr_init_encode - Initialize a struct xdr_stream for sending data.
  * @xdr: pointer to xdr_stream struct
@@ -1014,6 +1093,27 @@ unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 }
 EXPORT_SYMBOL_GPL(xdr_read_pages);
 
+size_t xdr_expand_hole(struct xdr_stream *xdr, size_t offset, uint64_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+	size_t from = 0;
+
+	if ((offset + length) < offset ||
+	    (offset + length) > buf->page_len)
+		length = buf->page_len - offset;
+
+	if (offset == 0)
+		xdr_align_pages(xdr, xdr->nwords << 2);
+	else
+		from = xdr_page_pos(xdr);
+
+	_shift_data_right(buf, offset + length, from, xdr->nwords << 2);
+	_zero_data_pages(buf->pages, buf->page_base + offset, length);
+	xdr_set_page(xdr, offset + length);
+	return length;
+}
+EXPORT_SYMBOL_GPL(xdr_expand_hole);
+
 /**
  * xdr_enter_page - decode data from the XDR page
  * @xdr: pointer to xdr_stream struct
-- 
2.20.1

