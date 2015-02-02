Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:52281 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965219AbbBBWkK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:40:10 -0500
Received: by mail-pa0-f41.google.com with SMTP id kq14so87987379pab.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:40:09 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 19/53] nfs/flexclient: export pnfs_layoutcommit_inode
Date: Mon,  2 Feb 2015 14:38:33 -0800
Message-Id: <1422916747-86649-20-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

flexfiles needs to start layoutcommit when necessary

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0a5dda4..2d25670 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1966,6 +1966,7 @@ clear_layoutcommitting:
 	pnfs_clear_layoutcommitting(inode);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(pnfs_layoutcommit_inode);
 
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 {
-- 
1.9.3

