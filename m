Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:46678 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932177Ab2AIQEf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 11:04:35 -0500
Received: by mail-tul01m020-f174.google.com with SMTP id wo16so4262986obc.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 08:04:35 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 6/9] pnfsblock: clean up _add_entry
Date: Tue, 10 Jan 2012 00:02:16 +0800
Message-Id: <1326124939-2152-7-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
References: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is wrong to kmalloc in _add_entry() as it is inside
spinlock. memory should be already allocated _add_entry() is called.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
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

