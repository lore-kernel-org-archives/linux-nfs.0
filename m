From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/3] NFS: Don't clobber the attribute type in nfs_update_inode()
Date: Wed,  3 Feb 2010 15:14:39 -0500
Message-ID: <1265228079-9713-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1265228079-9713-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265228079-9713-2-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62009 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757842Ab0BCUPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 15:15:08 -0500
In-Reply-To: <1265228079-9713-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the NFS_ATTR_FATTR_TYPE field isn't set in fattr->valid, then we should
not set the S_IFMT part of inode->i_mode.

Reported-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..f141bde 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1261,8 +1261,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	if (fattr->valid & NFS_ATTR_FATTR_MODE) {
 		if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)) {
+			umode_t newmode = inode->i_mode & S_IFMT;
+			newmode |= fattr->mode & S_IALLUGO;
+			inode->i_mode = newmode;
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-			inode->i_mode = fattr->mode;
 		}
 	} else if (server->caps & NFS_CAP_MODE)
 		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
-- 
1.6.6

