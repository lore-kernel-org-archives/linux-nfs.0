Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44137 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394Ab2AJOcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2012 09:32:48 -0500
Received: by mail-iy0-f174.google.com with SMTP id z25so965522iab.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2012 06:32:48 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH RESEND 6/9] pnfsblock: clean up _add_entry
Date: Tue, 10 Jan 2012 22:30:32 +0800
Message-Id: <1326205835-2011-7-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
References: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
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

