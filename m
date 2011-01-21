Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:52024 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486Ab1AUQx5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jan 2011 11:53:57 -0500
Date: Fri, 21 Jan 2011 11:53:53 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 2/3] Fix calculation of stripe device and unit sizes
Message-ID: <6eae3b83b619dc3965e1c0fd1110df2db76b9183.1295627825.git.rees@umich.edu>
References: <cover.1295627825.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1295627825.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

- Total size is size of each individual device times number of devices
- Stripe unit is in bytes, not sectors
- Round total device size down to a muliple of the stripe size

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/dm-device.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index d720086..ee7d787 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -371,7 +371,7 @@ static int dm_device_exists(char *dev_name)
 /* TODO: check the value for DM_DEV_NAME_LEN, DM_TYPE_LEN, DM_PARAMS_LEN */
 uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 {
-	uint64_t size, dev = 0;
+	uint64_t size, stripe_unit, stripe_size, nstripes, dev = 0;
 	unsigned int count = dev_count;
 	int volnum, i, pos;
 	struct bl_volume *node;
@@ -416,11 +416,25 @@ uint64_t dm_device_create(struct bl_volume *vols, int num_vols)
 			if (!table)
 				goto out;
 			table->offset = 0;
-			table->size = node->bv_size;
+			stripe_unit = node->param.bv_stripe_unit << 9;
+			stripe_size = stripe_unit * node->bv_vol_n;
+			nstripes = node->bv_size * node->bv_vol_n / stripe_size;
+			/* Make sure total size is a multiple of stripe size */
+			size = node->bv_size * node->bv_vol_n;
+			if (size % stripe_size != 0) {
+				/* XXX Should this be an error? */
+				BL_LOG_WARNING(
+					"%s: %d units of %llu bytes is not a multiple of %lld stripe size\n",
+					__func__, node->bv_vol_n,
+					(long long unsigned) node->bv_size,
+					(long long unsigned) stripe_size);
+				size = nstripes * stripe_size;
+			}
+			table->size = size;
 			strcpy(table->target_type, "striped");
-			sprintf(table->params, "%d %lu %n", node->bv_vol_n,
-				node->param.bv_stripe_unit, &pos);
-			/* Repeatedly copy subdev to params */
+			sprintf(table->params, "%d %llu %n", node->bv_vol_n,
+				(long long unsigned) stripe_unit, &pos);
+			/* Copy subdev major:minor to params */
 			tmp = table->params + pos;
 			len = DM_PARAMS_LEN - pos;
 			for (i = 0; i < node->bv_vol_n; i++) {
-- 
1.7.1

