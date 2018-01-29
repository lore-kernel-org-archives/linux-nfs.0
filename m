Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50286 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbeA2C61 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 21:58:27 -0500
Received: by mail-it0-f65.google.com with SMTP id x128so6548559ite.0
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jan 2018 18:58:27 -0800 (PST)
Received: from localhost.localdomain (50-36-85-67.alma.mi.frontiernet.net. [50.36.85.67])
        by smtp.gmail.com with ESMTPSA id w125sm5265667itb.31.2018.01.28.18.58.25
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jan 2018 18:58:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Remove a redundant call to unmap_mapping_range()
Date: Sun, 28 Jan 2018 21:58:21 -0500
Message-Id: <20180129025822.5116-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need to call unmap_mapping_range() prior to calling
nfs_sync_mapping().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index deeb7d1097d0..49fba9ea5872 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1170,7 +1170,6 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 
 	if (mapping->nrpages != 0) {
 		if (S_ISREG(inode->i_mode)) {
-			unmap_mapping_range(mapping, 0, 0, 0);
 			ret = nfs_sync_mapping(mapping);
 			if (ret < 0)
 				return ret;
-- 
2.14.3

