Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab0EMVI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:26 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCP021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:25 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/15] SUNRPC: Dont run rpcauth_cache_shrinker() when gfp_mask is GFP_NOFS
Date: Thu, 13 May 2010 17:08:12 -0400
Message-Id: <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Under some circumstances, put_rpccred() can end up allocating memory, so
check the gfp_mask to prevent deadlocks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 95afe79..03ff9f9 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -270,6 +270,8 @@ rpcauth_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 	LIST_HEAD(free);
 	int res;
 
+	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		return -1;
 	if (list_empty(&cred_unused))
 		return 0;
 	spin_lock(&rpc_credcache_lock);
-- 
1.6.6.1

