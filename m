Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34160 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbcDZL4Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 07:56:25 -0400
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Dave Chinner <david@fromorbit.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>,
        ceph-devel@vger.kernel.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: [PATCH 2/2] mm, debug: report when GFP_NO{FS,IO} is used explicitly from memalloc_no{fs,io}_{save,restore} context
Date: Tue, 26 Apr 2016 13:56:12 +0200
Message-Id: <1461671772-1269-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Michal Hocko <mhocko@suse.com>

THIS PATCH IS FOR TESTING ONLY AND NOT MEANT TO HIT LINUS TREE

It is desirable to reduce the direct GFP_NO{FS,IO} usage at minimum and
prefer scope usage defined by memalloc_no{fs,io}_{save,restore} API.

Let's help this process and add a debugging tool to catch when an
explicit allocation request for GFP_NO{FS,IO} is done from the scope
context. The printed stacktrace should help to identify the caller
and evaluate whether it can be changed to use a wider context or whether
it is called from another potentially dangerous context which needs
a scope protection as well.

The checks have to be enabled explicitly by debug_scope_gfp kernel
command line parameter.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 86bb5d6ddd7d..085d00280496 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3750,6 +3750,61 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
+static bool debug_scope_gfp;
+
+static int __init enable_debug_scope_gfp(char *unused)
+{
+	debug_scope_gfp = true;
+	return 0;
+}
+
+/*
+ * spit the stack trace if the given gfp_mask clears flags which are context
+ * wide cleared. Such a caller can remove special flags clearing and rely on
+ * the context wide mask.
+ */
+static inline void debug_scope_gfp_context(gfp_t gfp_mask)
+{
+	gfp_t restrict_mask;
+
+	if (likely(!debug_scope_gfp))
+		return;
+
+	/* both NOFS, NOIO are irrelevant when direct reclaim is disabled */
+	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
+		return;
+
+	if (current->flags & PF_MEMALLOC_NOIO)
+		restrict_mask = __GFP_IO;
+	else if ((current->flags & PF_MEMALLOC_NOFS) && (gfp_mask & __GFP_IO))
+		restrict_mask = __GFP_FS;
+	else
+		return;
+
+	if ((gfp_mask & restrict_mask) != restrict_mask) {
+		/*
+		 * If you see this this warning then the code does:
+		 * memalloc_no{fs,io}_save()
+		 * ...
+		 *    foo()
+		 *      alloc_page(GFP_NO{FS,IO})
+		 * ...
+		 * memalloc_no{fs,io}_restore()
+		 *
+		 * allocation which is unnecessary because the scope gfp
+		 * context will do that for all allocation requests already.
+		 * If foo() is called from multiple contexts then make sure other
+		 * contexts are safe wrt. GFP_NO{FS,IO} semantic and either add
+		 * scope protection into particular paths or change the gfp mask
+		 * to GFP_KERNEL.
+		 */
+		pr_info("Unnecesarily specific gfp mask:%#x(%pGg) for the %s task wide context\n", gfp_mask, &gfp_mask,
+				(current->flags & PF_MEMALLOC_NOIO)?"NOIO":"NOFS");
+		dump_stack();
+	}
+}
+early_param("debug_scope_gfp", enable_debug_scope_gfp);
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3796,6 +3851,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 				ac.nodemask);
 
 	/* First allocation attempt */
+	debug_scope_gfp_context(gfp_mask);
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
-- 
2.8.0.rc3

