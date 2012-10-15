Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39243 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVc7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:59 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/13] lockd: Remove BUG_ON()s in fs/lockd/host.c
Date: Mon, 15 Oct 2012 17:31:06 -0400
Message-Id: <1350336667-18770-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-11-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-12-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Convert the non-trivial ones into WARN_ON_ONCE().
- Remove the trivial refcounting BUGs

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/lockd/host.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index f9b22e5..0e17090 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -177,9 +177,6 @@ static void nlm_destroy_host_locked(struct nlm_host *host)
 
 	dprintk("lockd: destroy host %s\n", host->h_name);
 
-	BUG_ON(!list_empty(&host->h_lockowners));
-	BUG_ON(atomic_read(&host->h_count));
-
 	hlist_del_init(&host->h_hash);
 
 	nsm_unmonitor(host);
@@ -289,13 +286,12 @@ void nlmclnt_release_host(struct nlm_host *host)
 
 	dprintk("lockd: release client host %s\n", host->h_name);
 
-	BUG_ON(atomic_read(&host->h_count) < 0);
-	BUG_ON(host->h_server);
+	WARN_ON_ONCE(host->h_server);
 
 	if (atomic_dec_and_test(&host->h_count)) {
-		BUG_ON(!list_empty(&host->h_lockowners));
-		BUG_ON(!list_empty(&host->h_granted));
-		BUG_ON(!list_empty(&host->h_reclaim));
+		WARN_ON_ONCE(!list_empty(&host->h_lockowners));
+		WARN_ON_ONCE(!list_empty(&host->h_granted));
+		WARN_ON_ONCE(!list_empty(&host->h_reclaim));
 
 		mutex_lock(&nlm_host_mutex);
 		nlm_destroy_host_locked(host);
@@ -412,8 +408,7 @@ void nlmsvc_release_host(struct nlm_host *host)
 
 	dprintk("lockd: release server host %s\n", host->h_name);
 
-	BUG_ON(atomic_read(&host->h_count) < 0);
-	BUG_ON(!host->h_server);
+	WARN_ON_ONCE(!host->h_server);
 	atomic_dec(&host->h_count);
 }
 
-- 
1.7.11.7

