Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab0EMVI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:27 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCR021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:26 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/15] SUNRPC: Ensure rpcauth_prune_expired() respects the nr_to_scan parameter
Date: Thu, 13 May 2010 17:08:14 -0400
Message-Id: <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2213dc5..5fb02ac 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -236,6 +236,8 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 
 	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
+		if (nr_to_scan-- == 0)
+			break;
 		/*
 		 * Enforce a 60 second garbage collection moratorium
 		 * Note that the cred_unused list must be time-ordered.
@@ -255,11 +257,8 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 			get_rpccred(cred);
 			list_add_tail(&cred->cr_lru, free);
 			rpcauth_unhash_cred_locked(cred);
-			nr_to_scan--;
 		}
 		spin_unlock(cache_lock);
-		if (nr_to_scan == 0)
-			break;
 	}
 	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
 }
-- 
1.6.6.1

