Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50967 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab1FGRbN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:13 -0400
Date: Tue, 7 Jun 2011 13:31:12 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 44/88] SQUASHME: pnfsblock: Wrong extent refcount in block
 extents list
Message-ID: <41a3a9eeeac246e94bfcc17f3464e10b01a19866.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>

_prep_new_extent called kref_init to initialize extent's refcount to 1.
After that, we shouldn't call kref_get to increase its refcount, because
this extent is only referenced by the list.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Acked-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/extents.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 288a38a..4722899 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -868,7 +868,6 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 				 offset - be->be_f_offset,
 				 PNFS_BLOCK_INVALID_DATA);
 		children[i++] = e1;
-		kref_get(&e1->be_refcnt);
 		print_bl_extent(e1);
 	} else
 		merge1 = e1;
@@ -876,7 +875,6 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 			 min(length, be->be_f_offset + be->be_length - offset),
 			 PNFS_BLOCK_READWRITE_DATA);
 	children[i++] = e2;
-	kref_get(&e2->be_refcnt);
 	print_bl_extent(e2);
 	if (offset + length < be->be_f_offset + be->be_length) {
 		_prep_new_extent(e3, be, e2->be_f_offset + e2->be_length,
@@ -884,7 +882,6 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 				 offset - length,
 				 PNFS_BLOCK_INVALID_DATA);
 		children[i++] = e3;
-		kref_get(&e3->be_refcnt);
 		print_bl_extent(e3);
 	} else
 		merge2 = e3;
-- 
1.7.4.1

