Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:56655 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbbAGA3b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 19:29:31 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so1067436pdi.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 16:29:31 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 19/49] nfs/flexclient: export pnfs_layoutcommit_inode
Date: Tue,  6 Jan 2015 16:28:24 -0800
Message-Id: <1420590534-84063-20-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
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

