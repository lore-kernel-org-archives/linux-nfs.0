Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85772C63798
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Nov 2020 13:50:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3624420897
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Nov 2020 13:50:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AUVGcOmO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388582AbgKXNu3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Nov 2020 08:50:29 -0500
Received: from mail.kernel.org ([198.145.29.99]:44666 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388575AbgKXNu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Nov 2020 08:50:28 -0500
Received: from leira.hammer.space (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1BBFD20888
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2020 13:50:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1606225828;
        bh=A2MtDuZ1NZ5rfhyFyzg3U6eJcSxZ9+2Hp5BMK2OFL8U=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=AUVGcOmOUjlIDsvLAttfC/hcC4DuUctB6+BNpNYvY+xiU8Gl1XSlwxyf0C4qA5qqT
         AdCFBuWYa1UfhgXfwVuCHsY0KrDgQe35qxwFH4y86TgW+8AhgG3xaX0n0z5gDe4ye/
         eH2fl50Ou3uw13uGc6Dms6aeO6Co3fHmnxBKNYm0=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/9] SUNRPC: Fix up typo in xdr_init_decode()
Date:   Tue, 24 Nov 2020 08:50:18 -0500
Message-Id: <20201124135025.1097571-3-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201124135025.1097571-2-trondmy@kernel.org>
References: <20201124135025.1097571-1-trondmy@kernel.org>
 <20201124135025.1097571-2-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We already know that the head buffer and page are empty, so if there is
any data, it is in the tail.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index b1cda6d85ded..bc7a622016ee 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1060,7 +1060,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p,
 	else if (buf->page_len != 0)
 		xdr_set_page_base(xdr, 0, buf->len);
 	else
-		xdr_set_iov(xdr, buf->head, buf->len);
+		xdr_set_iov(xdr, buf->tail, buf->len);
 	if (p != NULL && p > xdr->p && xdr->end >= p) {
 		xdr->nwords -= p - xdr->p;
 		xdr->p = p;
-- 
2.28.0

