Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624Ab1LDNtR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:49:17 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3592866eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:49:17 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/13] pnfsd-block: dprint fiemap rval
Date: Sun,  4 Dec 2011 15:49:11 +0200
Message-Id: <1323006551-13721-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_ops.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 5f20b90..52ac073 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -1303,8 +1303,8 @@ struct list_head *
 	set_fs(old_fs);
 	
 	if (rval || !fei->fi_extents_mapped) {
-		dprintk("    No extents. Wanted %d, got %d\n",
-			fei->fi_extents_max, fei->fi_extents_mapped);
+		dprintk("    No extents. Wanted %d, got %d: rval=%d\n",
+			fei->fi_extents_max, fei->fi_extents_mapped, rval);
 		kfree(fe);
 		fei->fi_extents_start = NULL;
 		return False;
-- 
1.7.6

