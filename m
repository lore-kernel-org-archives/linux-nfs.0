Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:44731 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935213AbeE2PtF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:49:05 -0400
Received: by mail-io0-f172.google.com with SMTP id y2-v6so12843048iob.11
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:49:05 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id y14-v6sm16396515ioc.52.2018.05.29.08.49.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:49:04 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: Fix up nfs_post_op_update_inode() to force ctime updates
Date: Tue, 29 May 2018 11:48:38 -0400
Message-Id: <20180529154838.12903-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180529154838.12903-5-trond.myklebust@hammerspace.com>
References: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
 <20180529154838.12903-2-trond.myklebust@hammerspace.com>
 <20180529154838.12903-3-trond.myklebust@hammerspace.com>
 <20180529154838.12903-4-trond.myklebust@hammerspace.com>
 <20180529154838.12903-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We do not want to ignore ctime updates that originate from functions
such as link().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 40a6cf6db4e8..5de724b1b90c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1633,7 +1633,8 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	nfs_fattr_set_barrier(fattr);
 	status = nfs_post_op_update_inode_locked(inode, fattr,
 			NFS_INO_INVALID_CHANGE
-			| NFS_INO_INVALID_CTIME);
+			| NFS_INO_INVALID_CTIME
+			| NFS_INO_REVAL_FORCED);
 	spin_unlock(&inode->i_lock);
 
 	return status;
-- 
2.17.0

