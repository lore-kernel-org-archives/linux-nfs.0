Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:52080 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbeFDWcC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:32:02 -0400
Received: by mail-it0-f65.google.com with SMTP id n7-v6so1020426itn.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:32:02 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.32.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:32:01 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] NFS: Filter cache invalidation when holding a delegation
Date: Mon,  4 Jun 2018 18:31:29 -0400
Message-Id: <20180604223129.121477-11-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-10-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
 <20180604223129.121477-5-trond.myklebust@hammerspace.com>
 <20180604223129.121477-6-trond.myklebust@hammerspace.com>
 <20180604223129.121477-7-trond.myklebust@hammerspace.com>
 <20180604223129.121477-8-trond.myklebust@hammerspace.com>
 <20180604223129.121477-9-trond.myklebust@hammerspace.com>
 <20180604223129.121477-10-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client holds a delegation, then ensure we filter out attempts
to invalidate the size, owner, group owner, or mode unless we made the
change, in which case, check that NFS_INO_REVAL_FORCED is set by the
caller.
Always filter out attempts to invalidate the change attribute and
size, since we are authoritative for those.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bc84ecaae886..73473d9bdfa4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -195,10 +195,16 @@ bool nfs_check_cache_invalid(struct inode *inode, unsigned long flags)
 static void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	bool have_delegation = nfs_have_delegated_attributes(inode);
+	bool have_delegation = NFS_PROTO(inode)->have_delegation(inode, FMODE_READ);
+
+	if (have_delegation) {
+		if (!(flags & NFS_INO_REVAL_FORCED))
+			flags &= ~NFS_INO_INVALID_OTHER;
+		flags &= ~(NFS_INO_INVALID_CHANGE
+				| NFS_INO_INVALID_SIZE
+				| NFS_INO_REVAL_PAGECACHE);
+	}
 
-	if (have_delegation)
-		flags &= ~(NFS_INO_INVALID_CHANGE|NFS_INO_REVAL_PAGECACHE);
 	if (inode->i_mapping->nrpages == 0)
 		flags &= ~NFS_INO_INVALID_DATA;
 	nfsi->cache_validity |= flags;
-- 
2.17.1

