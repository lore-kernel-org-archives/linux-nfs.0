Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389Ab0EMVI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:27 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCS021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:27 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/15] NFS: Don't run nfs_access_cache_shrinker() when the mask is GFP_NOFS
Date: Thu, 13 May 2010 17:08:15 -0400
Message-Id: <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Both iput() and put_rpccred() might allocate memory under certain
circumstances, so make sure that we don't recurse and deadlock...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 18da8ab..bc136ef 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1703,6 +1703,8 @@ int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 	struct nfs_inode *nfsi;
 	struct nfs_access_entry *cache;
 
+	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		return -1;
 restart:
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry(nfsi, &nfs_access_lru_list, access_cache_inode_lru) {
-- 
1.6.6.1

