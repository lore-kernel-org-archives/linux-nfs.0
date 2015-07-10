Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:36842 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932615AbbGJT6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 15:58:51 -0400
Received: by ykey15 with SMTP id y15so75361793yke.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 12:58:50 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: plug memory leak when ->prepare_layoutcommit fails
Date: Fri, 10 Jul 2015 15:58:42 -0400
Message-Id: <1436558322-23672-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"data" is currently leaked when the prepare_layoutcommit operation
returns an error. Put the cred before taking the spinlock in that
case, take the lock and then goto out_unlock which will drop the
lock and then free "data".

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0ba9a02c9566..5c9581419ec9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2207,13 +2207,12 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	if (ld->prepare_layoutcommit) {
 		status = ld->prepare_layoutcommit(&data->args);
 		if (status) {
+			put_rpccred(data->cred);
 			spin_lock(&inode->i_lock);
 			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
 			if (end_pos > nfsi->layout->plh_lwb)
 				nfsi->layout->plh_lwb = end_pos;
-			spin_unlock(&inode->i_lock);
-			put_rpccred(data->cred);
-			goto clear_layoutcommitting;
+			goto out_unlock;
 		}
 	}
 
-- 
2.4.3

