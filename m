From: andros@netapp.com
Subject: [PATCH 10/16] SQUASHME pnfs-submit: reference the layout when inserted into segs list
Date: Wed,  7 Jul 2010 18:34:17 -0400
Message-ID: <1278542063-4009-11-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
 <1278542063-4009-7-git-send-email-andros@netapp.com>
 <1278542063-4009-8-git-send-email-andros@netapp.com>
 <1278542063-4009-9-git-send-email-andros@netapp.com>
 <1278542063-4009-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757653Ab0GGWe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:29 -0400
In-Reply-To: <1278542063-4009-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We take a reference on the pnfs_layout_type structure at allocation, so we
don't need to take another reference when adding it to the nfs_client cl_layouts
list.

We do need to take a referece when an lseg is inserted into the layout->segs
list to keep the pnfs_layout_type around while the layout segment is in the
list.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d4ffd1c..1372ae1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -411,6 +411,7 @@ destroy_lseg(struct kref *kref)
 		container_of(kref, struct pnfs_layout_segment, kref);
 
 	dprintk("--> %s\n", __func__);
+	/* Matched by get_layout in pnfs_insert_layout */
 	put_layout(lseg->layout);
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
@@ -876,7 +877,6 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 		BUG_ON(!list_empty(&lo->lo_layouts));
 		list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
 		spin_unlock(&clp->cl_lock);
-		get_layout(lo);
 	}
 	list_for_each_entry (lp, &lo->segs, fi_list) {
 		if (cmp_layout(&lp->range, &lseg->range) > 0)
@@ -899,6 +899,7 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 			__func__, lseg, lseg->range.iomode,
 			lseg->range.offset, lseg->range.length);
 	}
+	get_layout(lo);
 
 	dprintk("%s:Return\n", __func__);
 }
-- 
1.6.6

