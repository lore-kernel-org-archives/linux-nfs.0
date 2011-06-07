Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51078 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1FGRbd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:33 -0400
Date: Tue, 7 Jun 2011 13:31:31 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 46/88] SQUASHME: pnfsblock: Fix missing extent in commit list
Message-ID: <5f0b764a27be72fd2861ef4a5f7d1e13d9180635.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>

When offset is in the middle of a extent, we shouldn't step forward to
offset + extent->be_length, otherwise we may miss some extents in
commit list.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index b0ad836..cf306e9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -348,16 +348,13 @@ static void mark_extents_written(struct pnfs_block_layout *bl,
 	end = (offset + count + PAGE_CACHE_SIZE - 1) & (long)(PAGE_CACHE_MASK);
 	end >>= 9;
 	while (isect < end) {
+		sector_t len;
 		be = find_get_extent(bl, isect, NULL);
 		BUG_ON(!be); /* FIXME */
-		if (be->be_state != PNFS_BLOCK_INVALID_DATA)
-			isect += be->be_length;
-		else {
-			sector_t len;
-			len = min(end, be->be_f_offset + be->be_length) - isect;
+		len = min(end, be->be_f_offset + be->be_length) - isect;
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
 			mark_for_commit(be, isect, len); /* What if fails? */
-			isect += len;
-		}
+		isect += len;
 		put_extent(be);
 	}
 }
-- 
1.7.4.1

