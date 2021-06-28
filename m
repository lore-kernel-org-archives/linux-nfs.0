Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BAB3C49EA3
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jun 2021 17:15:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 09BE761C47
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jun 2021 17:15:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233865AbhF1RRo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jun 2021 13:17:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:37720 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233709AbhF1RRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jun 2021 13:17:41 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id CD9AE61C49;
        Mon, 28 Jun 2021 17:15:15 +0000 (UTC)
Subject: [PATCH] mm/page_alloc: Return nr_populated when the array is full
From:   Chuck Lever <chuck.lever@oracle.com>
To:     mgorman@techsingularity.net
Cc:     linux-nfs@vger.kernel.org, linux-mm@kvack.org
Date:   Mon, 28 Jun 2021 13:15:15 -0400
Message-ID: <162490051493.1165.8122675403341013520.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The SUNRPC consumer of __alloc_bulk_pages() legitimately calls it
with a full array sometimes. In that case, the correct return code,
according to the API contract, is to return the number of requested
pages.

Fixes: b3b64ebd3822 ("mm/page_alloc: do bulk array bounds check after checking populated elements")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ef2265f86b91..79f88c4ae372 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5058,7 +5058,7 @@ unsigned long __alloc_pages_bulk(gfp_t gfp, int preferred_nid,
 
 	/* Already populated array? */
 	if (unlikely(page_array && nr_pages - nr_populated == 0))
-		return 0;
+		return nr_pages;
 
 	/* Use the single page allocator for one page. */
 	if (nr_pages - nr_populated == 1)


