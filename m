From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 42/69] NFS: Use delegations to optimise ACCESS calls
Date: Tue, 23 Dec 2008 18:23:38 -0500
Message-ID: <20081223230217.13743.76526.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46961 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbYLWX1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:27:55 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNRg7c006949
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:27:46 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ff167aa..ed7024c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1797,7 +1797,8 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 	cache = nfs_access_search_rbtree(inode, cred);
 	if (cache == NULL)
 		goto out;
-	if (!time_in_range(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
+	if (!nfs_have_delegation(inode, FMODE_READ) &&
+	    !time_in_range(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
 		goto out_stale;
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;

