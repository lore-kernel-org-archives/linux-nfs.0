Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50595 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab1B1VbG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 16:31:06 -0500
Date: Mon, 28 Feb 2011 16:31:03 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] zero out delegation in the inode after it has been returned
Message-ID: <20110228213103.GA1256@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/delegation.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index bbbc6bf..5bc4f7e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -176,9 +176,11 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 
 static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
 {
+	struct nfs_inode *nfsi = NFS_I(inode);
 	int res = 0;
 
 	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid, issync);
+	rcu_assign_pointer(nfsi->delegation, NULL);
 	nfs_free_delegation(delegation);
 	return res;
 }
-- 
1.7.1

