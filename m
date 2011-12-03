Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:65230 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967Ab1K2QEb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 11:04:31 -0500
Received: by mail-qw0-f46.google.com with SMTP id c14so2131121qad.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 08:04:31 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH 6/9] pnfsblock: clean up _add_entry
Date: Fri,  2 Dec 2011 20:46:20 -0800
Message-Id: <1322887583-2719-7-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
References: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is wrong to kmalloc in _add_entry() as it is inside
spinlock. memory should be already allocated _add_entry() is called.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/extents.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index f383524..d0f52ed 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -110,13 +110,7 @@ static int _add_entry(struct my_tree *tree, u64 s, int32_t tag,
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
+		new = storage;
 		new->it_sector = s;
 		new->it_tags = (1 << tag);
 		list_add(&new->it_link, &pos->it_link);
-- 
1.7.1.262.g5ef3d

