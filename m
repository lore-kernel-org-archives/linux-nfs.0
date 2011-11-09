Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f42.google.com ([209.85.210.42]:62512 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab1KIPRz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2011 10:17:55 -0500
Received: by pzk2 with SMTP id 2so1947446pzk.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 07:17:54 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH 6/8] pnfsblock: clean up _add_entry
Date: Wed,  9 Nov 2011 07:16:04 -0800
Message-Id: <1320851766-1834-7-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is wrong to kmalloc in _add_entry() as it is inside
spinlock. memory should be already allocated _add_entry() is called.
So BUG instead if we fail to find a match and no memory preallocated.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/extents.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index f383524..952ea8a 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -110,13 +110,8 @@ static int _add_entry(struct my_tree *tree, u64 s, int32_t tag,
 		return 0;
 	} else {
 		struct pnfs_inval_tracking *new;
-		if (storage)
-			new = storage;
-		else {
-			new = kmalloc(sizeof(*new), GFP_NOFS);
-			if (!new)
-				return -ENOMEM;
-		}
+		BUG_ON(!storage);
+		new = storage;
 		new->it_sector = s;
 		new->it_tags = (1 << tag);
 		list_add(&new->it_link, &pos->it_link);
-- 
1.7.1.262.g5ef3d

