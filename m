Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:55407 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbeFDWb5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:57 -0400
Received: by mail-it0-f47.google.com with SMTP id 144-v6so983941iti.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:57 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.55
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:55 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/11] NFSv4: Ensure the inode is clean when we set a delegation
Date: Mon,  4 Jun 2018 18:31:24 -0400
Message-Id: <20180604223129.121477-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-5-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
 <20180604223129.121477-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

If there are attributes that are still invalid when we set a delegation,
then we need to set the NFS_INO_REVAL_FORCED flag.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 105b0f39a5b2..91c3737d69df 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -404,6 +404,10 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred,
 
 	trace_nfs4_set_delegation(inode, type);
 
+	spin_lock(&inode->i_lock);
+	if (NFS_I(inode)->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME))
+		NFS_I(inode)->cache_validity |= NFS_INO_REVAL_FORCED;
+	spin_unlock(&inode->i_lock);
 out:
 	spin_unlock(&clp->cl_lock);
 	if (delegation != NULL)
-- 
2.17.1

