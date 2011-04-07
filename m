Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:37503 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569Ab1DGPiN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 11:38:13 -0400
Date: Thu, 7 Apr 2011 11:38:11 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: peter honeyman <honey@citi.umich.edu>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Updated the pNFS Developmental Repository
Message-ID: <20110407153811.GA13098@merit.edu>
References: <4D8E2B90.4030100@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D8E2B90.4030100@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  Hello,
  
  I've just updated the kernel and nfs-utils rpms in the pNFS development 
  repository to include:
      * The latest nfs-utils release (pnfs-nfs-utils-1-2-4-rc5)
      * The latest pNFS kernel bits (pnfs-all-2.6.38-2011-03-25)
  
  These latest bits are *only* in the Fedora 15 repo. The Fedora 13, 14 
  repos remained the same and the devel (or rawhide) repo was removed.

Do these builds include the following patch?  I sent it to the list on Feb
23 but don't see it in Benny's repo.

>From d7be3ca498142e1f50a7a4120ac890f2b2e4e2a2 Mon Sep 17 00:00:00 2001
From: Jim Rees <rees@umich.edu>
Date: Tue, 22 Feb 2011 18:13:20 -0500
Subject: [PATCH] fix stripe device size calculation for layouts not a multiple of stripe unit

If a complex layout has a stripe volume in it, and that volume has a size
that is not a multiple of the stripe unit, the total layout size will be
wrong because it is based on the truncated stripe volume size.  Fix this by
using the truncated size for making the mapped device, and the untruncated
size in the table for subsequent devices to use.

Also remove the warning for stripe volumes not a multiple of the stripe
width, since this is legal and apparently common.

While we're at it, use variable names consistent with the terminology in
rfc5661 section 13.2.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |   10 ++++------
 utils/blkmapd/dm-device.c      |   21 +++++----------------
 2 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 9a78457..79e596d 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -295,10 +295,10 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
 	case BLOCK_VOLUME_STRIPE:
 		BLK_READBUF(p, end, 8);
 		READ_SECTOR(vol->param.bv_stripe_unit);
-		off_t chunksize = vol->param.bv_stripe_unit;
+		off_t stripe_unit = vol->param.bv_stripe_unit;
 		/* Check limitations imposed by device-mapper */
-		if ((chunksize & (chunksize - 1)) != 0
-		    || chunksize < (off_t) (PAGE_SIZE >> 9))
+		if ((stripe_unit & (stripe_unit - 1)) != 0
+		    || stripe_unit < (off_t) (PAGE_SIZE >> 9))
 			return -EIO;
 		BLK_READBUF(p, end, 4);
 		READ32(vol->bv_vol_n);
@@ -306,7 +306,7 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
 			return -EIO;
 		*array_cnt = vol->bv_vol_n;
 		BL_LOG_INFO("%s: stripe %d nvols=%d unit=%ld\n", __func__, voln,
-			    vol->bv_vol_n, (long)chunksize);
+			    vol->bv_vol_n, (long)stripe_unit);
 		status = set_vol_array(&p, end, vols, voln);
 		if (status)
 			return status;
@@ -317,9 +317,7 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
 				return -EIO;
 			}
 		}
-		/* Truncate size to a stripe unit boundary */
 		vol->bv_size = vol->bv_vols[0]->bv_size * vol->bv_vol_n;
-		vol->bv_size &= ~(chunksize - 1);
 		break;
 	case BLOCK_VOLUME_CONCAT:
 		BLK_READBUF(p, end, 4);
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index c4fe4e9..0f4f148 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -369,7 +369,7 @@ static int dm_device_exists(char *dev_name)
 /* TODO: check the value for DM_DEV_NAME_LEN, DM_TYPE_LEN, DM_PARAMS_LEN */
 uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 {
-	uint64_t size, stripe_unit, stripe_size, nstripes, dev = 0;
+	uint64_t size, stripe_unit, dev = 0;
 	unsigned int count = dev_count;
 	int volnum, i, pos;
 	struct bl_volume *node;
@@ -414,21 +414,10 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 			if (!table)
 				goto out;
 			table->offset = 0;
-			stripe_unit = node->param.bv_stripe_unit << 9;
-			stripe_size = stripe_unit * node->bv_vol_n;
-			nstripes = node->bv_size * node->bv_vol_n / stripe_size;
-			/* Make sure total size is a multiple of stripe size */
-			size = node->bv_size;
-			if (size % stripe_size != 0) {
-				/* XXX Should this be an error? */
-				BL_LOG_WARNING(
-					"%s: %d units of %llu bytes is not a multiple of %lld stripe size\n",
-					__func__, node->bv_vol_n,
-					(long long unsigned) node->bv_size,
-					(long long unsigned) stripe_size);
-				size = nstripes * stripe_size;
-			}
-			table->size = size;
+			/* Truncate size to a stripe unit boundary */
+			stripe_unit = node->param.bv_stripe_unit;
+			table->size =
+			    node->bv_size - (node->bv_size % stripe_unit);
 			strcpy(table->target_type, "striped");
 			sprintf(table->params, "%d %llu %n", node->bv_vol_n,
 				(long long unsigned) stripe_unit, &pos);
-- 
1.7.1

