Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:49333 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaFDWzJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 18:55:09 -0400
Received: by mail-pd0-f179.google.com with SMTP id fp1so160409pdb.24
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 15:55:08 -0700 (PDT)
From: Thomas Haynes <thomas.haynes@primarydata.com>
To: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Cc: Tom Haynes <Thomas.Haynes@primarydata.com>
Subject: [PATCH] Fix typo in dprintk
Date: Wed,  4 Jun 2014 15:54:57 -0700
Message-Id: <1401922497-50046-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <Thomas.Haynes@primarydata.com>

In trond/testing

Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 7d479fd..4d1f99f 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -279,7 +279,7 @@ filelayout_set_layoutcommit(struct nfs_pgio_data *wdata)
 		return;
 
 	pnfs_set_layoutcommit(wdata);
-	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
+	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
 		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
 
-- 
1.9.3

