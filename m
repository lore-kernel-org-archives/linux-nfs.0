Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:47717 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab1BNTce (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 14:32:34 -0500
Date: Mon, 14 Feb 2011 14:32:33 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] nfs-utils: calculate stripe device size during process
 phase
Message-ID: <20110214193233.GA3555@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If a device has stripe device components, the total size will be wrong.
Calculate the stripe device size earlier, during the process phase, so that
later devices will have the correct size.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |    3 ++-
 utils/blkmapd/dm-device.c      |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index b709b48..9a78457 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -318,7 +318,8 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
 			}
 		}
 		/* Truncate size to a stripe unit boundary */
-		vol->bv_size = vol->bv_vols[0]->bv_size & ~(chunksize - 1);
+		vol->bv_size = vol->bv_vols[0]->bv_size * vol->bv_vol_n;
+		vol->bv_size &= ~(chunksize - 1);
 		break;
 	case BLOCK_VOLUME_CONCAT:
 		BLK_READBUF(p, end, 4);
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index 2e87db8..c4fe4e9 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -418,7 +418,7 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 			stripe_size = stripe_unit * node->bv_vol_n;
 			nstripes = node->bv_size * node->bv_vol_n / stripe_size;
 			/* Make sure total size is a multiple of stripe size */
-			size = node->bv_size * node->bv_vol_n;
+			size = node->bv_size;
 			if (size % stripe_size != 0) {
 				/* XXX Should this be an error? */
 				BL_LOG_WARNING(
-- 
1.7.1
