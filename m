Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64213 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964989Ab2B2Xeh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 18:34:37 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1: Get rid of redundant NFS4CLNT_LAYOUTRECALL tests
Date: Wed, 29 Feb 2012 18:34:04 -0500
Message-Id: <1330558445-4583-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS4CLNT_LAYOUTRECALL tests in pnfs_layout_process and
pnfs_update_layout are redundant.

In the case of a bulk layout recall, we're always testing for
the NFS_LAYOUT_BULK_RECALL flay anyway.
In the case of a file or segment recall, the call to
pnfs_set_layout_stateid() updates the layout_header 'barrier'
sequence id, which triggers the test in pnfs_layoutgets_blocked()
and is less race-prone than NFS4CLNT_LAYOUTRECALL anyway.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a534216..9c19f92 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -966,8 +966,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* Do we even need to bother with this? */
-	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
 	}
@@ -1048,8 +1047,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 
 	spin_lock(&ino->i_lock);
-	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 		dprintk("%s forget reply due to recall\n", __func__);
 		goto out_forget_reply;
 	}
-- 
1.7.7.6

