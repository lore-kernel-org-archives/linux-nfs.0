Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:40067 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110Ab1GQUVT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 16:21:19 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] blkmapd: remove unused variable
Date: Sun, 17 Jul 2011 16:21:15 -0400
Message-Id: <1310934075-9459-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 79e596d..27ff374 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -204,7 +204,6 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 {
 	int mapped = 0;
 	struct bl_disk *disk;
-	char *filepath = 0;
 
 	/* scan disk list to find out match device */
 	for (disk = visible_disk_list; disk; disk = disk->next) {
@@ -212,7 +211,6 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
 		mapped = verify_sig(disk, sig);
 		if (mapped) {
 			vol->param.bv_dev = disk->dev;
-			filepath = disk->valid_path->full_path;
 			vol->bv_size = disk->size;
 			break;
 		}
-- 
1.7.4.1

