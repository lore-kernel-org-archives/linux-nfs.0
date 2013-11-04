Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:37667 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760Ab3KDUvU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 15:51:20 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
CC: J Bruce Fields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 2/5] NFS: __nfs_revalidate_inode() - use the nfs4_label to update file security info
Date: Mon, 4 Nov 2013 15:51:09 -0500
Message-ID: <1383598272-17737-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we just discard the nfs4_label information, instead of using it
to update the file LSM security info.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 471ba59c42f9..09d4df5f588a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -920,6 +920,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto err_out;
 	}
 
+	nfs_setsecurity(inode, fattr, label);
 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
 		nfs_zap_acl_cache(inode);
 
-- 
1.8.3.1

