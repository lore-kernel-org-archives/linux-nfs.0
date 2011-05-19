Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48156 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933727Ab1ESTLH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 15:11:07 -0400
Received: by fxm17 with SMTP id 17so2213417fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2011 12:11:06 -0700 (PDT)
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs41: Correct offset for LAYOUTCOMMIT
Date: Thu, 19 May 2011 23:10:45 +0400
Message-Id: <1305832245-17318-1-git-send-email-gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A client sends offset to MDS as it was seen by DS. As result,
file size after copy is only half of original file size in case
of 2 DS.

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/nfs4filelayout.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index be79dc9..790eb1d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -167,6 +167,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 	    wdata->res.verf->committed == NFS_FILE_SYNC)
 		return;
 
+	wdata->args.offset = wdata->mds_offset;
 	pnfs_set_layoutcommit(wdata);
 	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
 		(unsigned long) wdata->lseg->pls_end_pos);
-- 
1.7.4.1

