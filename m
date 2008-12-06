From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/27] NLM: Call nsm_reboot_lookup() instead of nsm_find()
Date: Fri, 05 Dec 2008 19:03:54 -0500
Message-ID: <20081206000354.24075.8981.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:57051 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223AbYLFAEc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:32 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Invoke the newly introduced nsm_reboot_lookup() function in
nlm_host_rebooted() instead of nsm_find().

This introduces just one behavioral change: debugging messages
produced during reboot notification will now appear when the
NLMDBG_MONITOR flag is set, but not when the NLMDBG_HOSTCACHE flag
is set.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   20 ++------------------
 1 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index dc41e46..230de93 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -453,30 +453,14 @@ void nlm_release_host(struct nlm_host *host)
  */
 void nlm_host_rebooted(const struct nlm_reboot *info)
 {
-	__be32 *p = (__be32 *)&info->priv.data;
-	const struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= *p,
-	};
 	struct hlist_head *chain;
 	struct hlist_node *pos;
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
-	nsm = nsm_find((struct sockaddr *)&sin, sizeof(sin),
-			info->mon, info->len, 0);
-	if (nsm == NULL) {
-		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
-				info->len, info->mon);
+	nsm = nsm_reboot_lookup(info);
+	if (unlikely(nsm == NULL))
 		return;
-	}
-
-	dprintk("lockd: nlm_host_rebooted(%.*s, %s)\n",
-			info->len, info->mon, nsm->sm_addrbuf);
-
-	/* When reclaiming locks on this peer, make sure that
-	 * we set up a new notification */
-	nsm->sm_monitored = 0;
 
 	/* Mark all hosts tied to this NSM state as having rebooted.
 	 * We run the loop repeatedly, because we drop the host table

