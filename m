Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37913 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbeCTUyB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:54:01 -0400
Received: by mail-it0-f68.google.com with SMTP id 19-v6so4137442itw.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:54:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] NFSv4: Ignore change attribute invalidations if we hold a delegation
Date: Tue, 20 Mar 2018 16:53:32 -0400
Message-Id: <20180320205332.94132-7-trond.myklebust@primarydata.com>
In-Reply-To: <20180320205332.94132-6-trond.myklebust@primarydata.com>
References: <20180320205332.94132-1-trond.myklebust@primarydata.com>
 <20180320205332.94132-2-trond.myklebust@primarydata.com>
 <20180320205332.94132-3-trond.myklebust@primarydata.com>
 <20180320205332.94132-4-trond.myklebust@primarydata.com>
 <20180320205332.94132-5-trond.myklebust@primarydata.com>
 <20180320205332.94132-6-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't bother even recording an invalid change attribute if we hold a
delegation since we already know the state of our attribute cache.
We can rely on the fact that we will pick up a copy from the server
when we return the delegation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 23880f45c1e4..a2c5d4ad4535 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -200,7 +200,10 @@ bool nfs_check_cache_invalid(struct inode *inode, unsigned long flags)
 static void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	bool have_delegation = nfs_have_delegated_attributes(inode);
 
+	if (have_delegation)
+		flags &= ~(NFS_INO_INVALID_CHANGE|NFS_INO_REVAL_PAGECACHE);
 	if (inode->i_mapping->nrpages == 0)
 		flags &= ~NFS_INO_INVALID_DATA;
 	nfsi->cache_validity |= flags;
-- 
2.14.3

