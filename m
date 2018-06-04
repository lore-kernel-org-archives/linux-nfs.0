Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:38124 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbeFDWb4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:56 -0400
Received: by mail-it0-f67.google.com with SMTP id v83-v6so996861itc.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:56 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.54
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:54 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/11] NFSv4: Ignore NFS_INO_REVAL_FORCED in nfs4_proc_access
Date: Mon,  4 Jun 2018 18:31:23 -0400
Message-Id: <20180604223129.121477-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-4-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we hold a delegation, we don't need to care about whether or not
the inode attributes are up to date. We know we can cache the results
of this call regardless.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 544cdcb79b4f..f413d0c8c837 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4114,7 +4114,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	};
 	int status = 0;
 
-	if (!nfs_have_delegated_attributes(inode)) {
+	if (!nfs4_have_delegation(inode, FMODE_READ)) {
 		res.fattr = nfs_alloc_fattr();
 		if (res.fattr == NULL)
 			return -ENOMEM;
-- 
2.17.1

