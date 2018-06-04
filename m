Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:38131 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbeFDWcB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:32:01 -0400
Received: by mail-it0-f65.google.com with SMTP id v83-v6so997117itc.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:32:01 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.32.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:32:00 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/11] NFS: Ignore NFS_INO_REVAL_FORCED in nfs_check_inode_attributes()
Date: Mon,  4 Jun 2018 18:31:28 -0400
Message-Id: <20180604223129.121477-10-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-9-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
 <20180604223129.121477-5-trond.myklebust@hammerspace.com>
 <20180604223129.121477-6-trond.myklebust@hammerspace.com>
 <20180604223129.121477-7-trond.myklebust@hammerspace.com>
 <20180604223129.121477-8-trond.myklebust@hammerspace.com>
 <20180604223129.121477-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we hold a delegation, we should not need to call
nfs_check_inode_attributes() since we already know which attributes
are valid, and which ones may still need revalidation. The state
of the NFS_INO_REVAL_FORCED flag is therefore irrelevant.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 90d9fbfd82db..bc84ecaae886 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1390,8 +1390,9 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	unsigned long invalid = 0;
 
 
-	if (nfs_have_delegated_attributes(inode))
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
 		return 0;
+
 	/* Has the inode gone and changed behind our back? */
 	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
 		return -ESTALE;
@@ -1441,7 +1442,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 		invalid |= NFS_INO_INVALID_ATIME;
 
 	if (invalid != 0)
-		nfs_set_cache_invalid(inode, invalid | NFS_INO_REVAL_FORCED);
+		nfs_set_cache_invalid(inode, invalid);
 
 	nfsi->read_cache_jiffies = fattr->time_start;
 	return 0;
-- 
2.17.1

