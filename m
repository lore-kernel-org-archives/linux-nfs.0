Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50767 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761Ab1FGRak (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:40 -0400
Date: Tue, 7 Jun 2011 13:30:38 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 39/88] pnfsblock: debugging dprintks for clist info
Message-ID: <993ea6b9602ce4fdc128ae2490277b9cb3023b9d.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/extents.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index a05ee2a..98452ca 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -349,6 +349,31 @@ int mark_written_sectors(struct pnfs_inval_markings *marks,
 	return status;
 }
 
+static void print_short_extent(struct pnfs_block_short_extent *be)
+{
+	dprintk("PRINT SHORT EXTENT extent %p\n", be);
+	if (be) {
+		dprintk("        be_f_offset %llu\n", (u64)be->bse_f_offset);
+		dprintk("        be_length   %llu\n", (u64)be->bse_length);
+	}
+}
+
+void print_clist(struct list_head *list, unsigned int count)
+{
+	struct pnfs_block_short_extent *be;
+	unsigned int i = 0;
+
+	dprintk("****************\n");
+	dprintk("Extent list looks like:\n");
+	list_for_each_entry(be, list, bse_node) {
+		i++;
+		print_short_extent(be);
+	}
+	if (i != count)
+		dprintk("\n\nExpected %u entries\n\n\n", count);
+	dprintk("****************\n");
+}
+
 /* Note: In theory, we should do more checking that devid's match between
  * old and new, but if they don't, the lists are too corrupt to salvage anyway.
  */
@@ -360,6 +385,9 @@ static void add_to_commitlist(struct pnfs_block_layout *bl,
 	struct pnfs_block_short_extent *old, *save;
 	sector_t end = new->bse_f_offset + new->bse_length;
 
+	dprintk("%s enter\n", __func__);
+	print_short_extent(new);
+	print_clist(clist, bl->bl_count);
 	bl->bl_count++;
 	/* Scan for proper place to insert, extending new to the left
 	 * as much as possible.
@@ -409,6 +437,8 @@ static void add_to_commitlist(struct pnfs_block_layout *bl,
 			kfree(old);
 		}
 	}
+	dprintk("%s: after merging\n", __func__);
+	print_clist(clist, bl->bl_count);
 }
 
 /* Note the range described by offset, length is guaranteed to be contained
-- 
1.7.4.1

