Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33960 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933309Ab3HGVQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 17:16:15 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: Julia Lawall <Julia.Lawall@lip6.fr>, Steve Dickson <SteveD@redhat.com>,
        Dave Quigley <dpquigl@davequigley.com>
Subject: [PATCH] NFS: Remove unnecessary call to nfs_setsecurity in nfs_fhget()
Date: Wed, 7 Aug 2013 17:16:10 -0400
Message-ID: <1375910170-23872-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only need to call it on the creation of the inode.

Reported-by: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: Steve Dickson <SteveD@redhat.com>
Cc: Dave Quigley <dpquigl@davequigley.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3ea4f64..941246f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -463,7 +463,6 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		unlock_new_inode(inode);
 	} else
 		nfs_refresh_inode(inode, fattr);
-		nfs_setsecurity(inode, fattr, label);
 	dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
-- 
1.8.3.1

