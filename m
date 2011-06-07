Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:44245 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432Ab1FGRgQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:36:16 -0400
Date: Tue, 7 Jun 2011 13:36:14 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 88/88] NFS41: do not update isize if inode needs layoutcommit
Message-ID: <8d4549ecda23f5ada0c88677c9505cba2830dad5.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Layout commit is supposed to set server file size similiar to nfs pages.
We should not update client file size for the same reason.
Otherwise we will lose what we have at hand.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
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
1.7.4.1

