Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:49836 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbaLXHNz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:13:55 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so6631817igi.6
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:13:55 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 19/49] nfs/flexclient: export pnfs_layoutcommit_inode
Date: Tue, 23 Dec 2014 23:12:58 -0800
Message-Id: <1419405208-25975-20-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
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

