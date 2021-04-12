Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9EF9C433B4
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Apr 2021 11:03:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7044961074
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Apr 2021 11:03:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239969AbhDLLDR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Apr 2021 07:03:17 -0400
Received: from outbound-smtp55.blacknight.com ([46.22.136.239]:57579 "EHLO
        outbound-smtp55.blacknight.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S239943AbhDLLDQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2021 07:03:16 -0400
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
        by outbound-smtp55.blacknight.com (Postfix) with ESMTPS id 6530CFB875
        for <linux-nfs@vger.kernel.org>; Mon, 12 Apr 2021 12:02:57 +0100 (IST)
Received: (qmail 19040 invoked from network); 12 Apr 2021 11:02:57 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.22.4])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 12 Apr 2021 11:02:57 -0000
Date:   Mon, 12 Apr 2021 12:02:55 +0100
From:   Mel Gorman <mgorman@techsingularity.net>
To:     Andrew Morton <akpm@linux-foundation.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Vlastimil Babka <vbabka@suse.cz>,
        Matthew Wilcox <willy@infradead.org>,
        Ilias Apalodimas <ilias.apalodimas@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux-Net <netdev@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] mm/page_alloc: Add a bulk page allocator -fix -fix -fix
Message-ID: <20210412110255.GV3697@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Vlastimil Babka noted that a comment is wrong, fix it. This is the third
fix to the mmotm patch mm-page_alloc-add-a-bulk-page-allocator.patch.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1c67c99603a3..c62862071e6a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5067,7 +5067,7 @@ unsigned long __alloc_pages_bulk(gfp_t gfp, int preferred_nid,
 		return 0;
 	gfp = alloc_gfp;
 
-	/* Find an allowed local zone that meets the high watermark. */
+	/* Find an allowed local zone that meets the low watermark. */
 	for_each_zone_zonelist_nodemask(zone, z, ac.zonelist, ac.highest_zoneidx, ac.nodemask) {
 		unsigned long mark;
 
