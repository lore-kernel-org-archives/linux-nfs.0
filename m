Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1960C43334
	for <linux-nfs@archiver.kernel.org>; Sun,  5 Jun 2022 19:58:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344478AbiFET6k (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 5 Jun 2022 15:58:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:32826 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1347132AbiFET6g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2022 15:58:36 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CEAD04D9C6
        for <linux-nfs@vger.kernel.org>; Sun,  5 Jun 2022 12:58:35 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 50798B80DCA
        for <linux-nfs@vger.kernel.org>; Sun,  5 Jun 2022 19:58:34 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E759FC385A5
        for <linux-nfs@vger.kernel.org>; Sun,  5 Jun 2022 19:58:32 +0000 (UTC)
Subject: [PATCH v1 2/5] SUNRPC: Optimize xdr_reserve_space()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 05 Jun 2022 15:58:31 -0400
Message-ID: <165445911199.1664.12318094116152634589.stgit@bazille.1015granger.net>
In-Reply-To: <165445865736.1664.4497130284832282034.stgit@bazille.1015granger.net>
References: <165445865736.1664.4497130284832282034.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The xdr_get_next_encode_buffer() function is called infrequently.
On a typical build/test workload, it's called about 1 time in 400
calls to xdr_reserve_space() (measured on NFSD).

Force the compiler to remove it from xdr_reserve_space(), which is
a hot path. This change reduces the size of xdr_reserve_space() from
10 cache lines to 4 on my test system.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xdr.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index b57cf9df4de8..08a85375b311 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -945,8 +945,13 @@ inline void xdr_commit_encode(struct xdr_stream *xdr)
 }
 EXPORT_SYMBOL_GPL(xdr_commit_encode);
 
-static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
-		size_t nbytes)
+/*
+ * The buffer space to be reserved crosses the boundary between
+ * xdr->buf->head and xdr->buf->pages, or between two pages
+ * in xdr->buf->pages.
+ */
+static noinline __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
+						   size_t nbytes)
 {
 	__be32 *p;
 	int space_left;


