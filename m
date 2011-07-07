Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:57674 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1GGQ0M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 12:26:12 -0400
Message-Id: <6d3e873bb170b69c38c4e9215a2eb8f523a4f18a.1310055433.git.rees@umich.edu>
In-Reply-To: <cover.1310055433.git.rees@umich.edu>
References: <cover.1310055433.git.rees@umich.edu>
Subject: [PATCH 2/6] SQUASHME: pnfs-block: skip sectors already initialized
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu,  7 Jul 2011 12:26:10 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

No need to test PageUptodate when checking for old pages.

Signed-off-by: Peng Tao <peng_tao@gmail.com>
---
 fs/nfs/blocklayout/blocklayout.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 331d687..804eee6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -596,11 +596,11 @@ fill_invalid_ext:
 
 			/* PageDirty: Other will write this out
 			 * PageWriteback: Other is writing this out
-			 * PageUptodate && sector_initialized: already written out
+			 * PageUptodate: It was read before
+			 * sector_initialized: already written out
 			 */
 			if (PageDirty(page) || PageWriteback(page) ||
-			    (PageUptodate(page) &&
-			     is_sector_initialized(be->be_inval, isect))) {
+			    is_sector_initialized(be->be_inval, isect)) {
 				dprintk
 				    ("page %lu is uptodate %d dirty %d writeback %d\n",
 				     page->index, PageUptodate(page),
@@ -612,7 +612,7 @@ fill_invalid_ext:
 				extent_length -= PAGE_CACHE_SIZE >> 9;
 				continue;
 			}
-			if (!PageUptodate(page) && cow_read) {
+			if (!PageUptodate(page)) {
 				/* New page, readin or zero it */
 				init_page_for_write(page, cow_read);
 			}
-- 
1.7.4.1

