Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:26011 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752114Ab3HEOrr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Aug 2013 10:47:47 -0400
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: kernel-janitors@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] fs/nfs/inode.c: adjust code alignment
Date: Mon,  5 Aug 2013 16:47:36 +0200
Message-Id: <1375714059-29567-2-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

This patch adjusts the code so that the alignment matches the current
semantics.  I have no idea if it is the intended semantics, though.  Should
the call to nfs_setsecurity also be under the else?

 fs/nfs/inode.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..d8ad685 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -463,7 +463,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		unlock_new_inode(inode);
 	} else
 		nfs_refresh_inode(inode, fattr);
-		nfs_setsecurity(inode, fattr, label);
+	nfs_setsecurity(inode, fattr, label);
 	dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),

