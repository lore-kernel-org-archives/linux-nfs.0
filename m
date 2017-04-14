Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38224 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751687AbdDNQ34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Apr 2017 12:29:56 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix missing pg_cleanup after nfs_pageio_cond_complete()
Date: Fri, 14 Apr 2017 12:29:54 -0400
Message-Id: <83814b669d9e092124acf1f74a496cce18011d32.1492187315.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit a7d42ddb3099727f58366fa006f850a219cce6c8 ("nfs: add mirroring
support to pgio layer") moved pg_cleanup out of the path when there was
non-sequental I/O that needed to be flushed.  The result is that for
layouts that have more than one layout segment per file, the pg_lseg is not
cleared, so we can end up hitting the WARN_ON_ONCE(req_start >= seg_end) in
pnfs_generic_pg_test since the pg_lseg will be pointing to that
previously-flushed layout segment.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6e629b856a00..3917268961d9 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1256,8 +1256,10 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
 		mirror = &desc->pg_mirrors[midx];
 		if (!list_empty(&mirror->pg_list)) {
 			prev = nfs_list_entry(mirror->pg_list.prev);
-			if (index != prev->wb_index + 1)
-				nfs_pageio_complete_mirror(desc, midx);
+			if (index != prev->wb_index + 1) {
+				nfs_pageio_complete(desc);
+				break;
+			}
 		}
 	}
 }
-- 
2.9.3

