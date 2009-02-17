From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] NFS: Minor __nfs_revalidate_inode cleanup
Date: Tue, 17 Feb 2009 15:29:54 +0530
Message-ID: <499A8A9A.7040304@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:49638 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbZBQKAB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 05:00:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove redundant NFS_STALE() check, a leftover due to the commit
691beb13cdc88358334ef0ba867c080a247a760f

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---

 fs/nfs/inode.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0c38168..acaaa7c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -670,9 +670,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	if (NFS_STALE(inode))
 		goto out;
 
-	if (NFS_STALE(inode))
-		goto out;
-
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
 	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), &fattr);
 	if (status != 0) {

