Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33137 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbeCTUx6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:53:58 -0400
Received: by mail-io0-f194.google.com with SMTP id l3so4057745iog.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:53:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] NFS: Don't force a revalidation of all attributes if change is missing
Date: Tue, 20 Mar 2018 16:53:28 -0400
Message-Id: <20180320205332.94132-3-trond.myklebust@primarydata.com>
In-Reply-To: <20180320205332.94132-2-trond.myklebust@primarydata.com>
References: <20180320205332.94132-1-trond.myklebust@primarydata.com>
 <20180320205332.94132-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even if the change attribute is missing, it is still OK to mark the other
attributes as being up to date.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9da00b2e26a1..5a721c3f4eb0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1813,7 +1813,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			inode_set_iversion_raw(inode, fattr->change_attr);
 		}
 	} else {
-		nfsi->cache_validity |= save_cache_validity;
+		nfsi->cache_validity |= save_cache_validity &
+				(NFS_INO_INVALID_ATTR
+				| NFS_INO_REVAL_PAGECACHE
+				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
 
-- 
2.14.3

