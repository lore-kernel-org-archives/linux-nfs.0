Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067Ab0EMVI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:26 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCQ021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:26 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/15] SUNRPC: Ensure memory shrinker doesn't waste time in rpcauth_prune_expired()
Date: Thu, 13 May 2010 17:08:13 -0400
Message-Id: <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The 'cred_unused' list, that is traversed by rpcauth_cache_shrinker is
ordered by time. If we hit a credential that is under the 60 second garbage
collection moratorium, we should exit because we know at that point that
all successive credentials are subject to the same moratorium...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 03ff9f9..2213dc5 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -236,10 +236,13 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 
 	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
-		/* Enforce a 60 second garbage collection moratorium */
+		/*
+		 * Enforce a 60 second garbage collection moratorium
+		 * Note that the cred_unused list must be time-ordered.
+		 */
 		if (time_in_range(cred->cr_expire, expired, jiffies) &&
 		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
-			continue;
+			return 0;
 
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
@@ -258,7 +261,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 		if (nr_to_scan == 0)
 			break;
 	}
-	return nr_to_scan;
+	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
 /*
@@ -275,8 +278,7 @@ rpcauth_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 	if (list_empty(&cred_unused))
 		return 0;
 	spin_lock(&rpc_credcache_lock);
-	nr_to_scan = rpcauth_prune_expired(&free, nr_to_scan);
-	res = (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
+	res = rpcauth_prune_expired(&free, nr_to_scan);
 	spin_unlock(&rpc_credcache_lock);
 	rpcauth_destroy_credlist(&free);
 	return res;
-- 
1.6.6.1

