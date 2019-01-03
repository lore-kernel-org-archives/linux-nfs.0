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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35E3EC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 06:14:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EAAFF2070C
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 06:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k9yHlL1c"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726724AbfACGOd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 01:14:33 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:54234 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726222AbfACGOd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 01:14:33 -0500
Received: by mail-it1-f195.google.com with SMTP id g85so43981100ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 22:14:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=5CmVMl6YpUZzW6zeCM99+9Ou4hMjAX3z7X+0zLO0Hqo=;
        b=k9yHlL1c8zHCmR6xJIJ3Y3wwvqraK5IKzbG8SaGthL6/2unPED+5/tKfBQgP7bWJk0
         kCYBt9UbuqU4wjH0dVlJs87URS50nwX0kogqvwO8DVBrgHIUcdCDScMNiBAuPTZrcUbX
         +qfps56708R/eMfL6amSIIHOJFa704Dxb10ZPo2txGOSroHAa9FBoUjPQNvKAqQwfz++
         E3/9IHcoJDyY+HGNV0cIvnbIfjENQogTEQ9fcSbj1GuwVd/isWsMHP6Px+wDJi0S/2aI
         WKquMt4q+gHMYuDjD+EYp15+3LMKHHRDcabx+6nEbLe8fbA/RJN0yZ/t70xXuLfk0a7E
         /XaA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=5CmVMl6YpUZzW6zeCM99+9Ou4hMjAX3z7X+0zLO0Hqo=;
        b=pFz+4mqsxfmwqANNcCOJTBvkDXDL0cAqT7SMqJqjmq0SDDT2RULbBWPNegSl8rnIN4
         DGntasXrDou4vHTNbwffhOVUfBurpmRr1aEIKH8G1r5KfgLLI1CoRnX96T2ZU1kXx1MD
         nMyqSSbn0ZMnTGmwSih+5TMLXjcfqWHLF1yEQ6dM+QHVtSdTx/Tg2LgZYi0J+CV6FqO6
         KQKlxG+Q2ROxnIUtpGFtK8Tym1dXDIp2OvltorCQilQZq3P/VE36cJgBTqBA5R133OkD
         dktOhqL++f/uy2W7MXsnY63H/pWAVNuJvObGa7sXQwPp5YxOggu9cA09IyjZx9VYWxpX
         RL7Q==
X-Gm-Message-State: AA+aEWaBeL4yEJooaLfI8/Y6ZpZOvd1Zgb37dgYsRcEvqWdtxry+fB7M
        2zM8yPz6wVZAPA16nb4aqBk5cyptNA==
X-Google-Smtp-Source: AFSGD/VlRto4FeWgxKjRehFEjXries1vmSI9befNQWVIR8Z0h1h/z/6+upGqtBuuBADmO06gdxvWBw==
X-Received: by 2002:a24:1d4a:: with SMTP id 71mr27864976itj.62.1546496072827;
        Wed, 02 Jan 2019 22:14:32 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id u3sm8186977iog.67.2019.01.02.22.14.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 22:14:31 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Geert Uytterhoeven <geert@linux-m68k.org>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Fix TCP receive code on archs with flush_dcache_page()
Date:   Thu,  3 Jan 2019 01:13:24 -0500
Message-Id: <20190103061324.16607-1-trond.myklebust@hammerspace.com>
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
 v2: fix the argument to flush_dcache_page()

 net/sunrpc/xprtsock.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f0b3700cec95..a72207af45d4 100644
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
+		flush_dcache_page(bv.bv_page);
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

