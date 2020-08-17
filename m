Return-Path: <SRS0=jts/=B3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB82C433E4
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Aug 2020 17:33:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 462BA2063A
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Aug 2020 17:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d26zxZat"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388979AbgHQRdW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Aug 2020 13:33:22 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46856 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389126AbgHQQx6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2020 12:53:58 -0400
Received: from mail-il1-x142.google.com (mail-il1-x142.google.com [IPv6:2607:f8b0:4864:20::142])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 73FC0C061344
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2020 09:53:37 -0700 (PDT)
Received: by mail-il1-x142.google.com with SMTP id p13so15123597ilh.4
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2020 09:53:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=FfSVVvxhUmot5fhlVdNxRiIJLr9/EUy1AHdjap9t+i4=;
        b=d26zxZateQB2RVC312wHuitgCHtdQIPkcsIqNFxMnibbvAfezlJIyFhXNmZoZWg8so
         lhH/hc5yFxGe6uXz5UisRT3likZy8jU0vJ9pQrJ1w+tPNQ3Zrk9Ahaz6MamsY9Ecycua
         X4ymxA7cFfTWDZSuCb1V9jdHfhsaF/1zpsb+ycenkvNYqcK4OX9wGZVmCFqTV3WwAW1l
         BktyifZr35H0icq+Y6wSyZavbdLNmtAiWP2L1ZhT1CssZNTr4t3hdbAD/v2GhwX9cDWq
         sHcIsZWS7ErtYgi+8T3l6f5vHBIfhcu/mIDE75Pf9i1l6o01KsJPJ7A3uUxTmhZYIibV
         q+ew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=FfSVVvxhUmot5fhlVdNxRiIJLr9/EUy1AHdjap9t+i4=;
        b=Dm+OvozlRCE9Ayqqc+Qdfe5OXNsZE7CMoNj7rThCJH6fP986QbMxfeErbOcRKejPhg
         5qAc3wIT8X2zcIHS5TUmdb/AQVVjUnNjAjKhYm81+ClvFiaIQKO4veFdbMGE63QiN9/P
         SZw1Mj2nblQnANDJCKawqzyO7pBRMEMhKi8iWHDqMqftGGcpENz+Gg0OtpBWY9EriNsj
         hr+3FbVFeXY1XF/rFc5IIZ7qTtOXbEwKjNgnRSCWOY8xe3Mg/gJ+8uHsDQpsUcUFy4fo
         Npimo9nzmsv311pBFMBHq8nn+MuBo52A34JUh1mm6q65Zu7ED6ABuSmG/jfXxMc/6tOZ
         Mj8w==
X-Gm-Message-State: AOAM530QgW+tcx/DaEmlW82yGA18nq9jKpgdwwXg3RhrZLJrTd1Hv9FJ
        LWfg2O/hzfpoorW7CbdPGqzliSNBNyw=
X-Google-Smtp-Source: ABdhPJw4Jvy6sh2hXTXBpTlJ/ATPqKRfb/UivFSHk5QUMkMNnE2trxSrX9VdX1prPmBJQ/vLljVnQg==
X-Received: by 2002:a92:c90c:: with SMTP id t12mr14601679ilp.7.1597683216486;
        Mon, 17 Aug 2020 09:53:36 -0700 (PDT)
Received: from gouda.nowheycreamery.com (c-68-32-74-190.hsd1.mi.comcast.net. [68.32.74.190])
        by smtp.gmail.com with ESMTPSA id a16sm7413106ilc.7.2020.08.17.09.53.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2020 09:53:35 -0700 (PDT)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH v4 07/10] SUNRPC: Add the ability to expand holes in data pages
Date:   Mon, 17 Aug 2020 12:53:24 -0400
Message-Id: <20200817165327.354181-8-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20200817165327.354181-1-Anna.Schumaker@Netapp.com>
References: <20200817165327.354181-1-Anna.Schumaker@Netapp.com>
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
 include/linux/sunrpc/xdr.h |  1 +
 net/sunrpc/xdr.c           | 73 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 40318ff97c83..de1f301f4864 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -252,6 +252,7 @@ extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
+extern uint64_t xdr_expand_hole(struct xdr_stream *, uint64_t, uint64_t);
 
 /**
  * xdr_stream_remaining - Return the number of bytes remaining in the stream
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index d8c9555c6f2b..24baf052e6e6 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -390,6 +390,42 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 }
 EXPORT_SYMBOL_GPL(_copy_from_pages);
 
+/**
+ * _zero_pages
+ * @pages: array of pages
+ * @pgbase: beginning page vector address
+ * @len: length
+ */
+static void
+_zero_pages(struct page **pages, size_t pgbase, size_t len)
+{
+	struct page **page;
+	char *vpage;
+	size_t zero;
+
+	page = pages + (pgbase >> PAGE_SHIFT);
+	pgbase &= ~PAGE_MASK;
+
+	do {
+		zero = PAGE_SIZE - pgbase;
+		if (zero > len)
+			zero = len;
+
+		vpage = kmap_atomic(*page);
+		memset(vpage + pgbase, 0, zero);
+		kunmap_atomic(vpage);
+
+		pgbase += zero;
+		if (pgbase == PAGE_SIZE) {
+			flush_dcache_page(*page);
+			pgbase = 0;
+			page++;
+		}
+
+	} while ((len -= zero) != 0);
+	flush_dcache_page(*page);
+}
+
 /**
  * xdr_shrink_bufhead
  * @buf: xdr_buf
@@ -1141,6 +1177,43 @@ unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 }
 EXPORT_SYMBOL_GPL(xdr_read_pages);
 
+uint64_t xdr_expand_hole(struct xdr_stream *xdr, uint64_t offset, uint64_t length)
+{
+	struct xdr_buf *buf = xdr->buf;
+	unsigned int bytes;
+	unsigned int from;
+	unsigned int truncated = 0;
+
+	if ((offset + length) < offset ||
+	    (offset + length) > buf->page_len)
+		length = buf->page_len - offset;
+
+	xdr_realign_pages(xdr);
+	from = xdr_page_pos(xdr);
+	bytes = xdr->nwords << 2;
+
+	if (offset + length + bytes > buf->page_len) {
+		unsigned int shift = (offset + length + bytes) - buf->page_len;
+		unsigned int res = _shift_data_right_tail(buf, from + bytes - shift, shift);
+		truncated = shift - res;
+		xdr->nwords -= XDR_QUADLEN(truncated);
+		bytes -= shift;
+	}
+
+	/* Now move the page data over and zero pages */
+	if (bytes > 0)
+		_shift_data_right_pages(buf->pages,
+					buf->page_base + offset + length,
+					buf->page_base + from,
+					bytes);
+	_zero_pages(buf->pages, buf->page_base + offset, length);
+
+	buf->len += length - (from - offset) - truncated;
+	xdr_set_page(xdr, offset + length, PAGE_SIZE);
+	return length;
+}
+EXPORT_SYMBOL_GPL(xdr_expand_hole);
+
 /**
  * xdr_enter_page - decode data from the XDR page
  * @xdr: pointer to xdr_stream struct
-- 
2.28.0

