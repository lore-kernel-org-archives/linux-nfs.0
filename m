Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:52925 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbaLPTCl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:41 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so14384164pdb.19
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:41 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 19/50] nfs/flexclient: export pnfs_layoutcommit_inode
Date: Tue, 16 Dec 2014 11:01:22 -0800
Message-Id: <1418756513-95187-20-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
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

