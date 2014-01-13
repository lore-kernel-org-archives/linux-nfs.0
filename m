Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.nrchpc.ac.cn ([211.103.180.228]:37993 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751526AbaAMIDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jan 2014 03:03:21 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH] nfs: don't update isize when NFS_INO_LAYOUTCOMMITTING in nfs_update_inode
Date: Mon, 13 Jan 2014 15:55:59 +0800
Message-Id: <1389599759-2711-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <n>
References: <n>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a file is in NFS_INO_LAYOUTCOMMITING status, its isize perhaps has not been 
transferred to the metadate server. So the isize getting from the metadata server
perhaps is out of date and cannot be used to update the isize of the client.

Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
---
 fs/nfs/inode.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ebeb94c..caf50a1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1402,7 +1402,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (new_isize != cur_isize) {
 			/* Do we perhaps have any outstanding writes, or has
 			 * the file grown beyond our last write? */
-			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) ||
+			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags) &&
+			     !test_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) ||
 			     new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
-- 
1.7.4.2

