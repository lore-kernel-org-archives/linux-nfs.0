From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] NLM: Always set host->h_rpcclnt to NULL after shutting
	down RPC client
Date: Wed, 05 Nov 2008 16:52:06 -0500
Message-ID: <20081105215205.16549.66126.stgit@ingres.1015granger.net>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62365 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbYKEVwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:52:20 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're about to introduce an nlm_host SLAB.  We can initialize the
h_rpcclnt field in an init_once callback if we always make sure to set
h_rpcclnt to NULL after invoking rpc_shutdown_client().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index bda5f9e..45a6d01 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -98,6 +98,14 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
+static void nlm_host_rpc_shutdown(struct nlm_host *host)
+{
+	if (host->h_rpcclnt) {
+		rpc_shutdown_client(host->h_rpcclnt);
+		host->h_rpcclnt = NULL;
+	}
+}
+
 static void nlm_display_ipv4_address(const struct sockaddr *sap, char *buf,
 				     const size_t len)
 {
@@ -264,8 +272,6 @@ out:
 static void
 nlm_destroy_host(struct nlm_host *host)
 {
-	struct rpc_clnt	*clnt;
-
 	BUG_ON(!list_empty(&host->h_lockowners));
 	BUG_ON(atomic_read(&host->h_count));
 
@@ -274,9 +280,7 @@ nlm_destroy_host(struct nlm_host *host)
 	 */
 	nsm_unmonitor(host);
 
-	clnt = host->h_rpcclnt;
-	if (clnt != NULL)
-		rpc_shutdown_client(clnt);
+	nlm_host_rpc_shutdown(host);
 	kfree(host);
 }
 
@@ -569,10 +573,7 @@ nlm_shutdown_hosts(void)
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
 		hlist_for_each_entry(host, pos, chain, h_hash) {
 			host->h_expires = jiffies - 1;
-			if (host->h_rpcclnt) {
-				rpc_shutdown_client(host->h_rpcclnt);
-				host->h_rpcclnt = NULL;
-			}
+			nlm_host_rpc_shutdown(host);
 		}
 	}
 

