Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33510 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab1JNRhZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:37:25 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Brent Welch <welch@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 6/6] ore: Enable RAID5 mounts
Date: Fri, 14 Oct 2011 19:37:16 +0200
Message-ID: <1318613836-3873-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
References: <4E98703E.7040605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we support raid5 Enable it at mount. Raid6 will come next
raid4 is not demanded for so it will probably not be enabled.
(Until some one wants it)

NOTE: That mkfs.exofs had support for raid5/6 since long time
ago. (Making an empty raidX FS is just as easy as raid0 ;-} )

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/ore.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 08ee454..fcfa86a 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -49,9 +49,17 @@ int ore_verify_layout(unsigned total_comps, struct ore_layout *layout)
 {
 	u64 stripe_length;
 
-/* FIXME: Only raid0 is supported for now. */
-	if (layout->raid_algorithm != PNFS_OSD_RAID_0) {
-		ORE_ERR("Only RAID_0 for now\n");
+	switch (layout->raid_algorithm) {
+	case PNFS_OSD_RAID_0:
+		layout->parity = 0;
+		break;
+	case PNFS_OSD_RAID_5:
+		layout->parity = 1;
+		break;
+	case PNFS_OSD_RAID_PQ:
+	case PNFS_OSD_RAID_4:
+	default:
+		ORE_ERR("Only RAID_0/5 for now\n");
 		return -EINVAL;
 	}
 	if (0 != (layout->stripe_unit & ~PAGE_MASK)) {
-- 
1.7.2.3

