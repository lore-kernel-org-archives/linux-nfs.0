Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39378 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab0LNPFg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:05:36 -0500
Received: by mail-yx0-f174.google.com with SMTP id 3so384384yxt.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:05:36 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/11] lockd: Add nlm_destroy_host_locked()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:05:33 -0500
Message-ID: <20101214150533.2736.74362.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Refactor the tail of nlm_gc_hosts() into nlm_destroy_host() so that
this logic can be used separately from garbage collection.

Rename it _locked() to document that it must be called with the hosts
cache mutex held.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 1911f34..e58e142 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -231,16 +231,21 @@ out:
 }
 
 /*
- * Destroy a host
+ * Destroy an nlm_host and free associated resources
+ *
+ * Caller must hold nlm_host_mutex.
  */
-static void
-nlm_destroy_host(struct nlm_host *host)
+static void nlm_destroy_host_locked(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
 
+	dprintk("lockd: destroy host %s\n", host->h_name);
+
 	BUG_ON(!list_empty(&host->h_lockowners));
 	BUG_ON(atomic_read(&host->h_count));
 
+	hlist_del_init(&host->h_hash);
+
 	nsm_unmonitor(host);
 	nsm_release(host->h_nsmhandle);
 
@@ -248,6 +253,8 @@ nlm_destroy_host(struct nlm_host *host)
 	if (clnt != NULL)
 		rpc_shutdown_client(clnt);
 	kfree(host);
+
+	nrhosts--;
 }
 
 /**
@@ -589,11 +596,7 @@ nlm_gc_hosts(void)
 				host->h_inuse, host->h_expires);
 			continue;
 		}
-		dprintk("lockd: delete host %s\n", host->h_name);
-		hlist_del_init(&host->h_hash);
-
-		nlm_destroy_host(host);
-		nrhosts--;
+		nlm_destroy_host_locked(host);
 	}
 
 	next_gc = jiffies + NLM_HOST_COLLECT;

