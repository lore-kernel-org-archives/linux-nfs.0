Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:55795 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbeA2C62 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 21:58:28 -0500
Received: by mail-it0-f67.google.com with SMTP id c16so6542481itc.5
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jan 2018 18:58:28 -0800 (PST)
Received: from localhost.localdomain (50-36-85-67.alma.mi.frontiernet.net. [50.36.85.67])
        by smtp.gmail.com with ESMTPSA id w125sm5265667itb.31.2018.01.28.18.58.26
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jan 2018 18:58:26 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Fix a race between mmap() and O_DIRECT
Date: Sun, 28 Jan 2018 21:58:22 -0500
Message-Id: <20180129025822.5116-2-trond.myklebust@primarydata.com>
In-Reply-To: <20180129025822.5116-1-trond.myklebust@primarydata.com>
References: <20180129025822.5116-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When locking the file in order to do O_DIRECT on it, we must unmap
any mmapped ranges on the pagecache so that we can flush out the
dirty data.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.8+
---
 fs/nfs/io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/io.c b/fs/nfs/io.c
index 20fef85d2bb1..9034b4926909 100644
--- a/fs/nfs/io.c
+++ b/fs/nfs/io.c
@@ -99,7 +99,7 @@ static void nfs_block_buffered(struct nfs_inode *nfsi, struct inode *inode)
 {
 	if (!test_bit(NFS_INO_ODIRECT, &nfsi->flags)) {
 		set_bit(NFS_INO_ODIRECT, &nfsi->flags);
-		nfs_wb_all(inode);
+		nfs_sync_mapping(inode->i_mapping);
 	}
 }
 
-- 
2.14.3

