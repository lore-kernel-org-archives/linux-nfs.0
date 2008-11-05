From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] NLM: Add rebind timeout helper
Date: Wed, 05 Nov 2008 16:52:13 -0500
Message-ID: <20081105215213.16549.32032.stgit@ingres.1015granger.net>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62501 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbYKEVwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:52:42 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: factor out logic to reset rebind timeout into a simple helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 45a6d01..665363a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -44,6 +44,11 @@ struct nlm_lookup_host_info {
 	const size_t		src_len;	/* it's length */
 };
 
+static void nlm_reset_rebind_timeout(struct nlm_host *host)
+{
+	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
+}
+
 /*
  * Hash function must work well on big- and little-endian platforms
  */
@@ -236,7 +241,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	host->h_proto      = ni->protocol;
 	host->h_rpcclnt    = NULL;
 	mutex_init(&host->h_mutex);
-	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
+	nlm_reset_rebind_timeout(host);
 	host->h_expires    = jiffies + NLM_HOST_EXPIRE;
 	atomic_set(&host->h_count, 1);
 	init_waitqueue_head(&host->h_gracewait);
@@ -403,7 +408,7 @@ nlm_bind_host(struct nlm_host *host)
 	if ((clnt = host->h_rpcclnt) != NULL) {
 		if (time_after_eq(jiffies, host->h_nextrebind)) {
 			rpc_force_rebind(clnt);
-			host->h_nextrebind = jiffies + NLM_HOST_REBIND;
+			nlm_reset_rebind_timeout(host);
 			dprintk("lockd: next rebind in %lu jiffies\n",
 					host->h_nextrebind - jiffies);
 		}
@@ -459,7 +464,7 @@ nlm_rebind_host(struct nlm_host *host)
 	dprintk("lockd: rebind host %s\n", host->h_name);
 	if (host->h_rpcclnt && time_after_eq(jiffies, host->h_nextrebind)) {
 		rpc_force_rebind(host->h_rpcclnt);
-		host->h_nextrebind = jiffies + NLM_HOST_REBIND;
+		nlm_reset_rebind_timeout(host);
 	}
 }
 

