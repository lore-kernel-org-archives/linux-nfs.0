From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 21/32] SUNRPC: Ensure we initialise the cache_detail before
 creating procfs files
Date: Wed, 19 Aug 2009 19:38:44 -0400
Message-ID: <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138AbZHSXlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:03 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe90d028534
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:51 -0700 (PDT)
In-Reply-To: <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also ensure that we destroy those files before we destroy the cache_detail.
Otherwise, user processes might attempt to write into uninitialised caches.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/cache.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8ede4a6..062d4f4 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -347,13 +347,8 @@ static int create_cache_proc_entries(struct cache_detail *cd)
 }
 #endif
 
-int cache_register(struct cache_detail *cd)
+static void sunrpc_init_cache_detail(struct cache_detail *cd)
 {
-	int ret;
-
-	ret = create_cache_proc_entries(cd);
-	if (ret)
-		return ret;
 	rwlock_init(&cd->hash_lock);
 	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
@@ -367,11 +362,9 @@ int cache_register(struct cache_detail *cd)
 
 	/* start the cleaning process */
 	schedule_delayed_work(&cache_cleaner, 0);
-	return 0;
 }
-EXPORT_SYMBOL_GPL(cache_register);
 
-void cache_unregister(struct cache_detail *cd)
+static void sunrpc_destroy_cache_detail(struct cache_detail *cd)
 {
 	cache_purge(cd);
 	spin_lock(&cache_list_lock);
@@ -386,7 +379,6 @@ void cache_unregister(struct cache_detail *cd)
 	list_del_init(&cd->others);
 	write_unlock(&cd->hash_lock);
 	spin_unlock(&cache_list_lock);
-	remove_cache_proc_entries(cd);
 	if (list_empty(&cache_list)) {
 		/* module must be being unloaded so its safe to kill the worker */
 		cancel_delayed_work_sync(&cache_cleaner);
@@ -395,6 +387,24 @@ void cache_unregister(struct cache_detail *cd)
 out:
 	printk(KERN_ERR "nfsd: failed to unregister %s cache\n", cd->name);
 }
+
+int cache_register(struct cache_detail *cd)
+{
+	int ret;
+
+	sunrpc_init_cache_detail(cd);
+	ret = create_cache_proc_entries(cd);
+	if (ret)
+		sunrpc_destroy_cache_detail(cd);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cache_register);
+
+void cache_unregister(struct cache_detail *cd)
+{
+	remove_cache_proc_entries(cd);
+	sunrpc_destroy_cache_detail(cd);
+}
 EXPORT_SYMBOL_GPL(cache_unregister);
 
 /* clean cache tries to find something to clean
-- 
1.6.0.4
