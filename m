Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754289Ab1EWMwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2011 08:52:14 -0400
Subject: [PATCH] NFS: nfs_update_inode: print current and new inode size in
 debug output
From: Harshula Jayasuriya <harshula@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeffrey Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 May 2011 22:52:11 +1000
Message-ID: <1306155131.2871.41.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,

In nfs_update_inode debug output, print the current and new inode
size when the file size changes on the NFS server.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
--- 
fs/nfs/inode.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 57bb31a..2d54457 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1298,8 +1298,12 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				i_size_write(inode, new_isize);
 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 			}
-			dprintk("NFS: isize change on server for file %s/%ld\n",
-					inode->i_sb->s_id, inode->i_ino);
+			dprintk("NFS: isize change on server for file %s/%ld "
+					"(%Ld to %Ld)\n",
+					inode->i_sb->s_id,
+					inode->i_ino,
+					(long long)cur_isize,
+					(long long)new_isize);
 		}
 	} else
 		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
-- 
1.7.4.4

