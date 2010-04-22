From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/5] SUNRPC: Fix a bug in rpcauth_prune_expired
Date: Thu, 22 Apr 2010 16:50:17 -0400
Message-ID: <1271969421-7443-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56493 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab0DVUuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 16:50:24 -0400
Received: from localhost.localdomain (kmanoj02-lxp.hq.netapp.com [10.58.60.82] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3MKoMJ6026155
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 13:50:23 -0700 (PDT)
In-Reply-To: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't want to evict a credential if cred->cr_expire == jiffies, since that
means that it was just placed on the cred_unused list. We therefore need to
use time_in_range() rather than time_in_range_open().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index f394fc1..95afe79 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -237,7 +237,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
 		/* Enforce a 60 second garbage collection moratorium */
-		if (time_in_range_open(cred->cr_expire, expired, jiffies) &&
+		if (time_in_range(cred->cr_expire, expired, jiffies) &&
 		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
 			continue;
 
-- 
1.6.6.1

