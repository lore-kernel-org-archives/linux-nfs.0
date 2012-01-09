Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58925 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426Ab2AIKjJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 05:39:09 -0500
Message-ID: <4F0AC3C1.5040303@panasas.com>
Date: Mon, 9 Jan 2012 12:38:57 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] SQUASHME: pnfsd-exofs: Fix the RAID5 export
References: <4EC13EEA.3030404@tonian.com> <4EDBACDD.3010609@tonian.com> <4F0A9F00.4020308@tonian.com>
In-Reply-To: <4F0A9F00.4020308@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


BAD RAID Math in layout_get.

TODO: ore_calc_stripe_info, which is already called, as all
the needed information calculated by _align_io. Only that
first_stripe_start is only set in case of RAID, but lo_get
always needs it. Move the set of first_stripe_start inside
ore_calc_stripe_info, to the generic part.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 8a0e510..621bd11 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -96,7 +96,8 @@ void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
 
 static void _align_io(struct ore_layout *layout, u64 *offset, u64 *length)
 {
-	u64 stripe_size = layout->group_width * layout->stripe_unit;
+	u64 stripe_size = (layout->group_width - layout->parity) *
+							layout->stripe_unit;
 	u64 group_size = stripe_size * layout->group_depth;
 
 	*offset = div64_u64(*offset, group_size) * group_size;
-- 
1.7.2.3


