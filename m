Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:39 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Uem008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:38 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] SQUASHME: pnfs_submit: remove inlines from *.c files
Date: Fri,  1 Oct 2010 12:02:46 -0400
Message-Id: <1285948971-2048-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 fs/nfs/pnfs.c              |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 5da6fec..e0edf93 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -559,7 +559,7 @@ nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
  * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
  * Then: ((res + fsi) % dsaddr->stripe_count)
  */
-static inline u32
+static u32
 _nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
 {
 	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 131602c..5ba2c45 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -336,7 +336,7 @@ EXPORT_SYMBOL_GPL(put_lseg);
  * READ		READ	true
  * READ		RW	false
  */
-static inline int
+static int
 should_free_lseg(struct pnfs_layout_segment *lseg,
 		   struct pnfs_layout_range *range)
 {
@@ -344,7 +344,7 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
 		lseg->range.iomode == range->iomode);
 }
 
-static inline bool
+static bool
 _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
 {
 	return atomic_read(&lseg->kref.refcount) == 1;
-- 
1.7.2.1

