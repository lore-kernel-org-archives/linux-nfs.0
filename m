Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49837 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNta (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:49:30 -0500
Received: by eeaq14 with SMTP id q14so1496904eea.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:49:29 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/13] pnfsd-block: allow positive fiemap rval
Date: Sun,  4 Dec 2011 15:49:23 +0200
Message-Id: <1323006563-13760-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_ops.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 52ac073..0c3a536 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -1302,7 +1302,7 @@ struct list_head *
 	    (1 << i->i_sb->s_blocksize_bits) - 1);
 	set_fs(old_fs);
 	
-	if (rval || !fei->fi_extents_mapped) {
+	if (rval < 0 || !fei->fi_extents_mapped) {
 		dprintk("    No extents. Wanted %d, got %d: rval=%d\n",
 			fei->fi_extents_max, fei->fi_extents_mapped, rval);
 		kfree(fe);
-- 
1.7.6

