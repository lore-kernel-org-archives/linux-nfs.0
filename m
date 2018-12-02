Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FCDFC04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 22:39:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E9F2020881
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 22:39:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BQi3OZnu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9F2020881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725786AbeLBWjT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 17:39:19 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52047 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725785AbeLBWjS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 17:39:18 -0500
Received: by mail-it1-f196.google.com with SMTP id x19so6448487itl.1
        for <linux-nfs@vger.kernel.org>; Sun, 02 Dec 2018 14:39:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=1NkZ7Tbw3Q5Q/w4Jq743PRe4Zw3xsFyeDzVajzhHdV4=;
        b=BQi3OZnu/QArXzl7PSMRvxBHZkQKtslknVBq3WC5VKXmNnknpPixLALZG0eMmFPvaR
         lGXYE45bo7OR0Xk8mOHcO+h5hXxQU0UXq4dvf/xb4kwlJ5VVPvsQY0379hak8LrRDMUV
         BxrKUDbf3DTghzKFMRPf9JKEWxZ+KvP6q08whvVngLxeQhVi7G4oAD8w0evF3nDgxA3O
         nPecTD1cLJiMQkusNqL2pG186A3yDMLL2iTGkCMHOvDeIEWOzZrr9HDZvJwME8Kjub4g
         ovDpCb3Gt802TVUfIhtd7XyyJg9ES2NgUVYWBTRAAE835aodXpm3CdgRx7+UpjbGSQt0
         ytrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=1NkZ7Tbw3Q5Q/w4Jq743PRe4Zw3xsFyeDzVajzhHdV4=;
        b=kLpBMmW6uxsVdwo64Y45HlOHqZpDEzYVnMaXa9K9UoSY6qvBPWFPNiLi8RAmqsCPSN
         d38F/gT3oePMQHqO4+MpBnom3/R/foaKJVIz9waLJAcIWLh9OqhaH5oSijfTycybx8+F
         DPV+Uzy/frMUkAohC5+cyLolPP0OwSPgwohc77qSxQmkkZjewMTs3AGN3NUiq3Ywd7Sc
         Tl3XYR5wf8ZSAoDP14aJBENCGyIq8RRvG0EQhQtyU+9dF+adhsVAbwKp9F/sFg8yK2Dw
         h/ljC7BZT1dnoHokIyosV2Twrw+TMMz473QqDbATF7fospGyykEQg36fGmbi9vRSDOnj
         O3Yw==
X-Gm-Message-State: AA+aEWY/xBST2nuvNly8vdDeDncBLftDaMIgrAfEZbtb8Jnkwa+LR065
        qTgdUmF63hKJiGn6ex2ECA==
X-Google-Smtp-Source: AFSGD/VfrWi5nBJiiEbVZPNr3qygLUD0+4kVOojSbOwpQKljqUiG54VvCrHbgDhyuKzT/hke3i7O5A==
X-Received: by 2002:a02:70d7:: with SMTP id f206mr12668869jac.118.1543790354479;
        Sun, 02 Dec 2018 14:39:14 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id b13sm4289183iot.70.2018.12.02.14.39.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Dec 2018 14:39:12 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix up handling of the XDRBUF_SPARSE_PAGES flag
Date:   Sun,  2 Dec 2018 17:38:05 -0500
Message-Id: <20181202223805.100675-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the allocator fails before it has reached the target number of pages,
then we need to recheck that we're not seeking past the page buffer.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ae77c71c1f64..36647bfbd683 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -330,19 +330,15 @@ xs_alloc_sparse_pages(struct xdr_buf *buf, size_t want, gfp_t gfp)
 {
 	size_t i,n;
 
-	if (!(buf->flags & XDRBUF_SPARSE_PAGES))
+	if (!want || !(buf->flags & XDRBUF_SPARSE_PAGES))
 		return want;
-	if (want > buf->page_len)
-		want = buf->page_len;
 	n = (buf->page_base + want + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < n; i++) {
 		if (buf->pages[i])
 			continue;
 		buf->bvec[i].bv_page = buf->pages[i] = alloc_page(gfp);
-		if (!buf->pages[i]) {
-			buf->page_len = (i * PAGE_SIZE) - buf->page_base;
-			return buf->page_len;
-		}
+		if (!buf->pages[i])
+			return (i * PAGE_SIZE) - buf->page_base;
 	}
 	return want;
 }
@@ -404,10 +400,11 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		seek -= buf->head[0].iov_len;
 		offset += buf->head[0].iov_len;
 	}
-	if (seek < buf->page_len) {
-		want = xs_alloc_sparse_pages(buf,
-				min_t(size_t, count - offset, buf->page_len),
-				GFP_NOWAIT);
+
+	want = xs_alloc_sparse_pages(buf,
+			min_t(size_t, count - offset, buf->page_len),
+			GFP_NOWAIT);
+	if (seek < want) {
 		ret = xs_read_bvec(sock, msg, flags, buf->bvec,
 				xdr_buf_pagecount(buf),
 				want + buf->page_base,
@@ -421,9 +418,10 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 			goto eagain;
 		seek = 0;
 	} else {
-		seek -= buf->page_len;
-		offset += buf->page_len;
+		seek -= want;
+		offset += want;
 	}
+
 	if (seek < buf->tail[0].iov_len) {
 		want = min_t(size_t, count - offset, buf->tail[0].iov_len);
 		ret = xs_read_kvec(sock, msg, flags, &buf->tail[0], want, seek);
-- 
2.19.2

