From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/33] SUNRPC: Protect creds against early garbage
	collection
Date: Sat, 19 Apr 2008 16:40:53 -0400
Message-ID: <20080419204053.14124.66402.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39914 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756347AbYDSUub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:31 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoVL0026094
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:31 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 0632cd0..6bfea9e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -220,6 +220,9 @@ rpcauth_destroy_credcache(struct rpc_auth *auth)
 }
 EXPORT_SYMBOL_GPL(rpcauth_destroy_credcache);
 
+
+#define RPC_AUTH_EXPIRY_MORATORIUM (60 * HZ)
+
 /*
  * Remove stale credentials. Avoid sleeping inside the loop.
  */
@@ -228,6 +231,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 {
 	spinlock_t *cache_lock;
 	struct rpc_cred *cred;
+	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
 
 	while (!list_empty(&cred_unused)) {
 		cred = list_entry(cred_unused.next, struct rpc_cred, cr_lru);
@@ -235,6 +239,10 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 		number_cred_unused--;
 		if (atomic_read(&cred->cr_count) != 0)
 			continue;
+		/* Enforce a 5 second garbage collection moratorium */
+		if (time_in_range(cred->cr_expire, expired, jiffies) &&
+		    test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0)
+			continue;
 		cache_lock = &cred->cr_auth->au_credcache->lock;
 		spin_lock(cache_lock);
 		if (atomic_read(&cred->cr_count) == 0) {

