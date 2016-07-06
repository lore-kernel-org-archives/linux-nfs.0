Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33174 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbcGFWao (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:44 -0400
Received: by mail-it0-f68.google.com with SMTP id y93so926041ita.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 08/28] pNFS/files: Fix layoutcommit after a commit to DS
Date: Wed,  6 Jul 2016 18:29:45 -0400
Message-Id: <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to the errata
https://www.rfc-editor.org/errata_search.php?rfc=5661&eid=2751
we should always send layout commit after a commit to DS.

Fixes: bc7d4b8fd091 ("nfs/filelayout: set layoutcommit...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index aa59757389dc..b4c1407e8fe4 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -375,8 +375,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
-	if (data->verf.committed == NFS_UNSTABLE)
-		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
+	pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
 	return 0;
 }
-- 
2.7.4

