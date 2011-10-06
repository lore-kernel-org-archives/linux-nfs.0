Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54407 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929Ab1JFM2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 08:28:01 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 3/5] SQUASHME: pnfsd-exofs: Fix export of only one group layout
Date: Thu, 6 Oct 2011 14:27:52 +0200
Message-ID: <1317904072-17353-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8D9D56.6020803@panasas.com>
References: <4E8D9D56.6020803@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid the 32 bit -1 group_depth problem by using the
group_width=0 case

This is a bug introduced by the previous patch "Convert to ORE 3.1"
Where the data_map member was removed from exofs_sb_info

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 5f5e9d9..42d21c0 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -76,13 +76,22 @@ err:
 void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
 			      const struct ore_layout *ol)
 {
-	pl->olo_map.odm_num_comps = ol->group_width * ol->mirrors_p1 *
-				    ol->group_count;
 	pl->olo_map.odm_stripe_unit = ol->stripe_unit;
-	pl->olo_map.odm_group_width = ol->group_width;
-	pl->olo_map.odm_group_depth = ol->group_depth;
 	pl->olo_map.odm_mirror_cnt = ol->mirrors_p1 - 1;
 	pl->olo_map.odm_raid_algorithm = ol->raid_algorithm;
+	if (ol->group_count > 1) {
+		pl->olo_map.odm_num_comps = ol->group_width * ol->mirrors_p1 *
+				    ol->group_count;
+		pl->olo_map.odm_group_width = ol->group_width;
+		pl->olo_map.odm_group_depth = ol->group_depth;
+	} else {
+		/* If we don't do this here group_depth will not be correct
+		 * because it is 32 bit only in pNFS
+		 */
+		pl->olo_map.odm_num_comps = ol->group_width * ol->mirrors_p1;
+		pl->olo_map.odm_group_width = 0;
+		pl->olo_map.odm_group_depth = 0;
+	}
 }
 
 static enum nfsstat4 exofs_layout_get(
-- 
1.7.2.3

