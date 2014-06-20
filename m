Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:58394 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757071AbaFTRl2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 13:41:28 -0400
Received: by mail-ie0-f172.google.com with SMTP id lx4so3530262iec.31
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 10:41:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFS: Clear NFS_INO_REVAL_PAGECACHE when we update the file size
Date: Fri, 20 Jun 2014 13:41:21 -0400
Message-Id: <1403286083-14345-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
References: <20140620125140.GH4510@tonberry.usersys.redhat.com>
 <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs_update_inode(), if the change attribute is seen to change on
the server, then we set NFS_INO_REVAL_PAGECACHE in order to make
sure that we check the file size.
However, if we also update the file size in the same function, we
don't need to check it again. So make sure that we clear the
NFS_INO_REVAL_PAGECACHE that was set earlier.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c496f8a74639..51dda21ebc4e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1601,6 +1601,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			if ((nfsi->npages == 0) || new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+				invalid &= ~NFS_INO_REVAL_PAGECACHE;
 			}
 			dprintk("NFS: isize change on server for file %s/%ld "
 					"(%Ld to %Ld)\n",
-- 
1.9.3

