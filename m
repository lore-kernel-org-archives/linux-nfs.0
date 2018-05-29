Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:42305 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936888AbeE2PtE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:49:04 -0400
Received: by mail-io0-f193.google.com with SMTP id a10-v6so18154308ioc.9
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:49:04 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id y14-v6sm16396515ioc.52.2018.05.29.08.49.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:49:03 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFS: Ensure we revalidate the inode correctly after setacl
Date: Tue, 29 May 2018 11:48:37 -0400
Message-Id: <20180529154838.12903-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20180529154838.12903-4-trond.myklebust@hammerspace.com>
References: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
 <20180529154838.12903-2-trond.myklebust@hammerspace.com>
 <20180529154838.12903-3-trond.myklebust@hammerspace.com>
 <20180529154838.12903-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 844eafbf1564..07a7f2d8f3e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5390,7 +5390,8 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	 */
 	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_CHANGE
-		| NFS_INO_INVALID_CTIME;
+		| NFS_INO_INVALID_CTIME
+		| NFS_INO_REVAL_FORCED;
 	spin_unlock(&inode->i_lock);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
-- 
2.17.0

