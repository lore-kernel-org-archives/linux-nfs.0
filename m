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
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFBC4C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:05:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7C1442070D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:05:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F2R6t+sK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729390AbfACOFz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 09:05:55 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:33819 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727650AbfACOFz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 09:05:55 -0500
Received: by mail-it1-f196.google.com with SMTP id x124so41274152itd.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2019 06:05:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ZRekI0C04B5ge6IcTWIv+thi9Ze6j6jOEDtPfN0EoXY=;
        b=F2R6t+sKXE5O8tFch1w4kgJCGRHqVCVuM42dZVpdOTTz4U8Zvmf8i9fcP9etuLlw8s
         riZzVejjISEjBHdjo4M9cQQU469/L/zOwMOPWqaT3+0yC752Gpa8wdOh9EJGtvslbhRk
         cB+o7riaVZb6cHnehWJUgYNXP1kDwydwL6UFDTr1/+FjHw57o3UwPLNCva+/BKHJzHfL
         tyq2jtHi36lixu1ofweZJdZQjAtH1HUAvXrEndoDBxNudNL3XeH0jqjO7Zw4sBQ8+FaS
         VYEJU/cvi0ejZyA1bVx7UtnpLrRLy02PQ9t7y5oLUZKzNxBo5nnrcVwmOvGZJ1c+YoSE
         ua/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ZRekI0C04B5ge6IcTWIv+thi9Ze6j6jOEDtPfN0EoXY=;
        b=V1GF9lhBcSP7/ykJXT+fv6Lm7hGelipPSy4KtmszeRDIKeqJM8IAvUNZVehUBwfjAA
         1YKACoAsaDTyv82xA84sr+OCXE9jY4ctrRm5S3Wdou5RT7dCXu4uJ3YMEADrSbPEFgsD
         YWc1UGpq7uT/nrecJdOiHKg51Pf2SzRc5US0mN8cRfSsF2NB6zNjZF3d+Ds3VT0+imH/
         zYhBFHg5xqF4vRr864f7Gs1GHnCje1opc0Z9ZBgJn40/6Low+ro2qCbbgVPzLwSGCerT
         nvTZbC1H0yunfHwzRdoTolygfRIAKIPzGp+R6d319RrVRQ9b4XfKITDDmXCqPbyoUsPp
         KHjQ==
X-Gm-Message-State: AA+aEWZNXVZfTYPuXW7gHrBN7UrWTT+Szk8ElRCdGRHhkTKRP1OFEX+6
        m/TSJt3VT0CZVQBeXqbI2w==
X-Google-Smtp-Source: ALg8bN7O2hS2LyS6qaPxq9AuOwxk9Vtj55D2NCo4ErU+SowoVOWz1KIvUUkovDyG8s2MyK21oR8Czg==
X-Received: by 2002:a24:570a:: with SMTP id u10mr31739438ita.11.1546524354178;
        Thu, 03 Jan 2019 06:05:54 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id g12sm24378300iok.38.2019.01.03.06.05.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 06:05:53 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc:     Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3] SUNRPC: Fix TCP receive code on archs with flush_dcache_page()
Date:   Thu,  3 Jan 2019 09:04:45 -0500
Message-Id: <20190103140445.22627-1-trond.myklebust@hammerspace.com>
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
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 v2: fix the argument to flush_dcache_page()
 v3: Simplify variable initialisation in xs_flush_bvec()

 net/sunrpc/xprtsock.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f0b3700cec95..9cdbb6d6e7f5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -48,6 +48,7 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 #include <linux/bvec.h>
+#include <linux/highmem.h>
 #include <linux/uio.h>
 
 #include <trace/events/sunrpc.h>
@@ -380,6 +381,26 @@ xs_read_discard(struct socket *sock, struct msghdr *msg, int flags,
 	return sock_recvmsg(sock, msg, flags);
 }
 
+#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
+static void
+xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
+{
+	struct bvec_iter bi = {
+		.bi_size = count,
+	};
+	struct bio_vec bv;
+
+	bvec_iter_advance(bvec, &bi, seek & PAGE_MASK);
+	for_each_bvec(bv, bvec, bi, bi)
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
@@ -413,6 +434,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 				seek + buf->page_base);
 		if (ret <= 0)
 			goto sock_err;
+		xs_flush_bvec(buf->bvec, ret, seek + buf->page_base);
 		offset += ret - buf->page_base;
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
-- 
2.20.1

