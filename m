From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] NLM: Add expiry timeout helper
Date: Wed, 05 Nov 2008 16:52:20 -0500
Message-ID: <20081105215220.16549.71458.stgit@ingres.1015granger.net>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62563 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbYKEVwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:52:50 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: factor out logic to reset gc expiration timeout into a
simple helper.  Same treatment as the rebind timeout helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 665363a..753c831 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -49,6 +49,11 @@ static void nlm_reset_rebind_timeout(struct nlm_host *host)
 	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
 }
 
+static void nlm_reset_gc_timeout(struct nlm_host *host)
+{
+	host->h_expires = jiffies + NLM_HOST_EXPIRE;
+}
+
 /*
  * Hash function must work well on big- and little-endian platforms
  */
@@ -242,7 +247,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	host->h_rpcclnt    = NULL;
 	mutex_init(&host->h_mutex);
 	nlm_reset_rebind_timeout(host);
-	host->h_expires    = jiffies + NLM_HOST_EXPIRE;
+	nlm_reset_gc_timeout(host);
 	atomic_set(&host->h_count, 1);
 	init_waitqueue_head(&host->h_gracewait);
 	init_rwsem(&host->h_rwsem);
@@ -476,7 +481,7 @@ struct nlm_host * nlm_get_host(struct nlm_host *host)
 	if (host) {
 		dprintk("lockd: get host %s\n", host->h_name);
 		atomic_inc(&host->h_count);
-		host->h_expires = jiffies + NLM_HOST_EXPIRE;
+		nlm_reset_gc_timeout(host);
 	}
 	return host;
 }

