Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6816AC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A98720675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HnmrPu82"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726237AbfBVV7Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:59:25 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:33331 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726116AbfBVV7Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:59:24 -0500
Received: by mail-io1-f66.google.com with SMTP id e186so3029569ioa.0
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:59:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LP2hmCdYU9qGVvtw/7cjfUxsP7LOVY3WvPuMkrzMq+Y=;
        b=HnmrPu8271roe/fxC1e39/xpzgyomO2/7a4h3f3HEdvFiMeGr9wuzl3c1igD4Pu97G
         7HOQv0pTjglGdwO2NO6rTRl8xGnRX6LBDAP2U1bA6NR6FfVzyiK0YoG07QZybrNj3l5o
         jxgljTyhogkjFXzdtJH38jkAfrrDbVZpQ3wpbRv+2moCa5Qiq//DhMsIrodsz7sQnqq3
         9pvK630Z3C6pNQro/sM7JC3oAfIl2m6samkMeijyU9n8hcz0Tf4dN0jFJNvr5sYzKWlH
         Ji+jWB/c54KzhpONP/jWOrdbyPpfEtXV17ChAJNdyGIb1E2Siagtw+EYDGE/km/q7lhu
         ttPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=LP2hmCdYU9qGVvtw/7cjfUxsP7LOVY3WvPuMkrzMq+Y=;
        b=m8kNGa+NVyjzkrSoKm11YznA2MRQYXa1KDbCuJyeCmk8YDlKte8wStfKhoUCpvzRP7
         8T0yxtEOsm/b63IVvoZDq2KnuBGeXVOVMt54krGo085NGCqnH0TWoI+b8i3ynrgcz9ne
         H0Cmi4nGO7tXNoLiXZW3vToN/N4fL+lzzFh4pa22vStPRcZjmqwBTmMqHV9tNw14sAvY
         q8hZiIhUJW4BchV3LpbfvyD8SiPZ7RLZ+NG2X/cWI6UWzhYcNv11ExgqyqlVFoqPyDyn
         SvqoS8sRxy8reIaStW/FH+ByfexsePynmYoJPBWlCTyW7g0fT5lz+t6S9V5TV02r9oQw
         fSpg==
X-Gm-Message-State: AHQUAuZOcGcSVbdqu2UNLh5X5LaBZF5yTSs0B7+ybNg3NsDfucaaLvdn
        6ilWpUbR9G7Xb3u8gVP11dI=
X-Google-Smtp-Source: AHgI3IZn10uf4VH2PtpEN1MwVOwoeaNa5iVKr8jHQUisZHX+rhcbv0qe67Jvkp3hdlNZTWAKZO0olw==
X-Received: by 2002:a5d:8494:: with SMTP id t20mr3685312iom.232.1550872763074;
        Fri, 22 Feb 2019 13:59:23 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id f13sm998171iol.82.2019.02.22.13.59.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:59:22 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 3/6] SUNRPC: Add the ability to shift data to a specific offset
Date:   Fri, 22 Feb 2019 16:59:15 -0500
Message-Id: <20190222215918.20647-4-Anna.Schumaker@Netapp.com>
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

Expanding holes tends to put the data content a few bytes to the right
of where we want it.  This patch implements a left-shift operation to
line everything up properly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           | 135 +++++++++++++++++++++++++++++++++++++
 2 files changed, 136 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 47e2d1fff59a..c7e49dc06b0b 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -244,6 +244,7 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 extern size_t xdr_expand_hole(struct xdr_stream *, size_t, uint64_t);
+extern uint64_t xdr_align_data(struct xdr_stream *, uint64_t, uint64_t);
 
 /**
  * xdr_stream_remaining - Return the number of bytes remaining in the stream
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 27dd3a507ef6..f85f83da663c 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -17,6 +17,9 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/bvec.h>
 
+static void _copy_to_pages(struct page **, size_t, const char *, size_t);
+
+
 /*
  * XDR functions for basic NFS types
  */
@@ -287,6 +290,117 @@ _shift_data_right(struct xdr_buf *buf, size_t to, size_t from, size_t len)
 				shift);
 }
 
+
+/**
+ * _shift_data_left_pages
+ * @pages: vector of pages containing both the source and dest memory area.
+ * @pgto_base: page vector address of destination
+ * @pgfrom_base: page vector address of source
+ * @len: number of bytes to copy
+ *
+ * Note: the addresses pgto_base and pgfrom_base are both calculated in
+ *       the same way:
+ *            if a memory area starts at byte 'base' in page 'pages[i]',
+ *            then its address is given as (i << PAGE_CACHE_SHIFT) + base
+ * Alse note: pgto_base must be < pgfrom_base, but the memory areas
+ * 	they point to may overlap.
+ */
+static void
+_shift_data_left_pages(struct page **pages, size_t pgto_base,
+			size_t pgfrom_base, size_t len)
+{
+	struct page **pgfrom, **pgto;
+	char *vfrom, *vto;
+	size_t copy;
+
+	BUG_ON(pgfrom_base <= pgto_base);
+
+	pgto = pages + (pgto_base >> PAGE_SHIFT);
+	pgfrom = pages + (pgfrom_base >> PAGE_SHIFT);
+
+	pgto_base = pgto_base % PAGE_SIZE;
+	pgfrom_base = pgfrom_base % PAGE_SIZE;
+
+	do {
+		if (pgto_base >= PAGE_SIZE) {
+			pgto_base = 0;
+			pgto++;
+		}
+		if (pgfrom_base >= PAGE_SIZE){
+			pgfrom_base = 0;
+			pgfrom++;
+		}
+
+		copy = len;
+		if (copy > (PAGE_SIZE - pgto_base))
+			copy = PAGE_SIZE - pgto_base;
+		if (copy > (PAGE_SIZE - pgfrom_base))
+			copy = PAGE_SIZE - pgfrom_base;
+
+		if (pgto_base == 131056)
+			break;
+
+		vto = kmap_atomic(*pgto);
+		if (*pgto != *pgfrom) {
+			vfrom = kmap_atomic(*pgfrom);
+			memcpy(vto + pgto_base, vfrom + pgfrom_base, copy);
+			kunmap_atomic(vfrom);
+		} else
+			memmove(vto + pgto_base, vto + pgfrom_base, copy);
+		flush_dcache_page(*pgto);
+		kunmap_atomic(vto);
+
+		pgto_base += copy;
+		pgfrom_base += copy;
+
+	} while ((len -= copy) != 0);
+}
+
+static void
+_shift_data_left_tail(struct xdr_buf *buf, size_t pgto_base,
+		      size_t tail_from, size_t len)
+{
+	struct kvec *tail = buf->tail;
+	size_t shift = len;
+
+	if (len == 0)
+		return;
+	if (pgto_base + len > buf->page_len)
+		shift = buf->page_len - pgto_base;
+
+	_copy_to_pages(buf->pages,
+			buf->page_base + pgto_base,
+			(char *)(tail->iov_base + tail_from),
+			shift);
+
+	memmove((char *)tail->iov_base, tail->iov_base + tail_from + shift, shift);
+	tail->iov_len -= (tail_from + shift);
+}
+
+static void
+_shift_data_left(struct xdr_buf *buf, size_t to, size_t from, size_t len)
+{
+	size_t shift = len;
+
+	if (from < buf->page_len) {
+		shift = min(len, buf->page_len - from);
+		_shift_data_left_pages(buf->pages,
+					buf->page_base + to,
+					buf->page_base + from,
+					shift);
+		to += shift;
+		from += shift;
+		shift = len - shift;
+	}
+
+	if (shift == 0)
+		return;
+	if (from >= buf->page_len)
+		from -= buf->page_len;
+
+	_shift_data_left_tail(buf, to, from, shift);
+}
+
 /**
  * _copy_to_pages
  * @pages: array of pages
@@ -1114,6 +1228,27 @@ size_t xdr_expand_hole(struct xdr_stream *xdr, size_t offset, uint64_t length)
 }
 EXPORT_SYMBOL_GPL(xdr_expand_hole);
 
+uint64_t xdr_align_data(struct xdr_stream *xdr, uint64_t offset, uint64_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+	size_t from = offset;
+
+	if (offset + length > buf->page_len)
+		length = buf->page_len - offset;
+
+	if (offset == 0)
+		xdr_align_pages(xdr, xdr->nwords << 2);
+	else {
+		from = xdr_page_pos(xdr);
+		_shift_data_left(buf, offset, from, length);
+	}
+
+	xdr->nwords -= XDR_QUADLEN(length);
+	xdr_set_page(xdr, from + length);
+	return length;
+}
+EXPORT_SYMBOL_GPL(xdr_align_data);
+
 /**
  * xdr_enter_page - decode data from the XDR page
  * @xdr: pointer to xdr_stream struct
-- 
2.20.1

