Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:47628 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126Ab1FFE1t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 00:27:49 -0400
Received: by pzk9 with SMTP id 9so1670644pzk.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Jun 2011 21:27:49 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: NFS41: do not update isize if inode needs layoutcommit
Date: Sat, 16 Oct 2010 22:07:46 -0700
Message-Id: <1287292066-23254-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nfs_update_inode will update isize if there is no queued pages. For pNFS,
layoutcommit is supposed to change file size on server, the same effect as queued
pages. nfs_update_inode may be called when dirty pages are written back (nfsi->npages==0)
but layoutcommit is not sent, and it will change client file size according to server
file size. Then client ends up losing what it just writes back in pNFS path.
So we should skip updating client file size if file needs layoutcommit.

Signed-off-by: Peng Tao <peng_tao@emc.com>

---
 fs/nfs/inode.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 144f2a3..3f1eb81 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1294,7 +1294,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (new_isize != cur_isize) {
 			/* Do we perhaps have any outstanding writes, or has
 			 * the file grown beyond our last write? */
-			if (nfsi->npages == 0 || new_isize > cur_isize) {
+			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) ||
+			     new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 			}
-- 
1.7.4.2

