From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/30] NFS: Minor __nfs_revalidate_inode cleanup
Date: Wed, 11 Mar 2009 14:41:06 -0400
Message-ID: <20090311184106.5578.761.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200AbZCKSoI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:08 -0400
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Suresh Jayaraman <sjayaraman@suse.de>

Remove redundant NFS_STALE() check, a leftover due to the commit
691beb13cdc88358334ef0ba867c080a247a760f

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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

