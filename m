Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A97BC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 00:43:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3E65720815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 00:43:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V2aHh0Xg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729032AbfACAnU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 19:43:20 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52364 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727021AbfACAnU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 19:43:20 -0500
Received: by mail-it1-f196.google.com with SMTP id g76so43298397itg.2
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 16:43:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Z8AUwXE2cI8igJDsZx9ElproD/SPGREjPanh852XR34=;
        b=V2aHh0Xg1ZTGHNwB0lZCdb88zILgJrlr5TbgqQQqL+fGC6J25zQLwjls44dZ3GC/Ln
         uKaEsA8/ontzHonfIf74hf2nGQ54/0BT7+rOHd4D1rVKCHdPqqn3ea6UX4gTY5ypwYH8
         TF2t9y466xQxN9Xoar4jAgGtJnO1uT60OcFU+FVBaKpBLirdp7xxUG4qLJx3KuYXMU+t
         +h6NpRAzEVw27jwRsA7GN3M7DMgSz6M8hC+PfwBwPzDuWAnsEuZ/m3TaDe6bIkxhRDhE
         2T5UjHfI8yM9BjWzOt8OzQemZJqrtOH4UUQR0Tu2CBcKTNm6jN4L4ewoQlfrKL1d80kP
         SlAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Z8AUwXE2cI8igJDsZx9ElproD/SPGREjPanh852XR34=;
        b=Sv0yKrHp5LzRSM08q8qg86rtCyhfyOMpVKHPg31BluZcmZeOmFbfH2MfpD/uXVDnD1
         bUfIG3tn5ZvTKbu1PCX/da9tgF9o7ZicdDEyn7toyb6ilZKOUDkfF3RdX50hlbEzTzKc
         9W3Y5adeUf44XMAFqYKs3uDIePK1+HGY3yvP1IxQVSW49S9vgsFW55iM9zbAQyP/SNW7
         t6feoo2KUP6n0n5he9vo61HCIC0K/UxNmIsupzqv67nEfecp50AlBt1mD1UOsNx+gcXK
         dXx26oI/3ba+aCXo8wlK3f9WZDrw0rIozKaUjTeLuqkTBjh+kD78NlpvMn4+JHnQDGZP
         x0Jg==
X-Gm-Message-State: AJcUukdbb/r2I20ncK0WFHJSCmnCzX2X8jvRYBVCUQANR+W/boXvi8WG
        37AyubTYUyv59rwbxts4QHezouEq9w==
X-Google-Smtp-Source: ALg8bN754WdDF4KjmbhSq2fduj/mLpMyuCxvS3nfS56mKW6CnkYq1d+/g5LFcO/33vDscAt+gv5+Jg==
X-Received: by 2002:a24:7c58:: with SMTP id a85mr30279482itd.9.1546476198866;
        Wed, 02 Jan 2019 16:43:18 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r16sm23771421ioa.16.2019.01.02.16.43.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 16:43:18 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Geert Uytterhoeven <geert@linux-m68k.org>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix TCP receive code on archs with flush_dcache_page()
Date:   Wed,  2 Jan 2019 19:42:11 -0500
Message-Id: <20190103004211.12404-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After receiving data into the page cache, we need to call flush_dcache_page()
for the architectures that define it.

Fixes: 277e4ab7d530b ("SUNRPC: Simplify TCP receive code by switching...")
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.20
---
 net/sunrpc/xprtsock.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f0b3700cec95..ec239b02b86e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -48,6 +48,7 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 #include <linux/bvec.h>
+#include <linux/highmem.h>
 #include <linux/uio.h>
 
 #include <trace/events/sunrpc.h>
@@ -380,6 +381,27 @@ xs_read_discard(struct socket *sock, struct msghdr *msg, int flags,
 	return sock_recvmsg(sock, msg, flags);
 }
 
+#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
+static void
+xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
+{
+	struct bvec_iter bi, __start = {
+		.bi_size = count,
+	};
+	struct bio_vec bv;
+
+	bvec_iter_advance(bvec, &__start, seek & PAGE_MASK);
+
+	for_each_bvec(bv, bvec, bi, __start)
+		flush_dcache_page(bv.page);
+}
+#else
+static inline void
+xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
+{
+}
+#endif
+
 static ssize_t
 xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		struct xdr_buf *buf, size_t count, size_t seek, size_t *read)
@@ -413,6 +435,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 				seek + buf->page_base);
 		if (ret <= 0)
 			goto sock_err;
+		xs_flush_bvec(buf->bvec, ret, seek + buf->page_base);
 		offset += ret - buf->page_base;
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
-- 
2.20.1

