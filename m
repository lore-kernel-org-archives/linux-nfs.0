Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from juliette.telenet-ops.be ([195.130.137.74]:52059 "EHLO
	juliette.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1JBR0u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Oct 2011 13:26:50 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH] blkmapd: Use getconf(_SC_PAGE_SIZE)
Date: Sun,  2 Oct 2011 19:27:30 +0200
Message-Id: <1317576450-26056-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

PAGE_SIZE is not exported by all architectures as it is not fixed: it can depend on the model of the machine. So it's better to query the system configuration for the actual page size on the machine.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/blkmapd/device-process.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 27ff374..652a7a8 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -296,7 +296,7 @@ decode_blk_volume(uint32_t **pp, uint32_t *end, struct bl_volume *vols, int voln
 		off_t stripe_unit = vol->param.bv_stripe_unit;
 		/* Check limitations imposed by device-mapper */
 		if ((stripe_unit & (stripe_unit - 1)) != 0
-		    || stripe_unit < (off_t) (PAGE_SIZE >> 9))
+		    || stripe_unit < (off_t) (sysconf(_SC_PAGE_SIZE) >> 9))
 			return -EIO;
 		BLK_READBUF(p, end, 4);
 		READ32(vol->bv_vol_n);
-- 
1.7.6.3

