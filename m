Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35903 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879AbcGFWap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:45 -0400
Received: by mail-it0-f68.google.com with SMTP id h190so900565ith.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 09/28] pNFS/flexfiles: Fix layoutcommit after a commit to DS
Date: Wed,  6 Jul 2016 18:29:46 -0400
Message-Id: <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should always do a layoutcommit after commit to DS, except if
the layout segment we're using has set FF_FLAGS_NO_LAYOUTCOMMIT.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0e8018bc9880..2689c9e9dc3c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1530,8 +1530,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
-	if (data->verf.committed == NFS_UNSTABLE
-	    && ff_layout_need_layoutcommit(data->lseg))
+	if (ff_layout_need_layoutcommit(data->lseg))
 		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
 	return 0;
-- 
2.7.4

