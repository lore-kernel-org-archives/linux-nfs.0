From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/11] lockd: Refactor nlm_host_rebooted()
Date: Thu, 01 Apr 2010 15:03:25 -0400
Message-ID: <20100401190324.6395.84601.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:62450 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044Ab0DATD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:03:26 -0400
Received: by mail-qy0-f173.google.com with SMTP id 4so1698690qyk.24
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:03:26 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to be able to call the lock recovery logic directly with an
nsm_handle.  Factor that piece out of nlm_host_rebooted().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   35 ++++++++++++++++++++++++-----------
 include/linux/lockd/lockd.h |    2 ++
 2 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 0a62d8d..001d05b 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -669,26 +669,39 @@ void nlm_release_host(struct nlm_host *host)
  */
 void nlm_host_rebooted(const struct nlm_reboot *info)
 {
-	struct hlist_head *chain;
-	struct hlist_node *pos;
 	struct nsm_handle *nsm;
-	struct nlm_host	*host;
 
 	nsm = nsm_reboot_lookup(info);
 	if (unlikely(nsm == NULL))
 		return;
 
-	/* Mark all hosts tied to this NSM state as having rebooted.
-	 * We run the loop repeatedly, because we drop the host table
-	 * lock for this.
-	 * To avoid processing a host several times, we match the nsmstate.
-	 */
-again:	mutex_lock(&nlm_host_mutex);
+	nlm_host_rebooted_nsm(nsm, info->state);
+}
+
+/**
+ * nlm_host_rebooted_nsm - start reboot recovery on remote peer
+ * @nsm: pointer to NSM handle for rebooting peer
+ * @nsmstate: new NSM state number of rebooting peer
+ *
+ * Mark all hosts tied to this NSM state as having rebooted.  We run
+ * the loop repeatedly, because we drop the host table lock for this.
+ *
+ * To avoid processing a host several times, we match the nsmstate.
+ */
+void nlm_host_rebooted_nsm(const struct nsm_handle *nsm, const int nsmstate)
+{
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+	struct nlm_host	*host;
+
+again:
+	mutex_lock(&nlm_host_mutex);
+
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
 		hlist_for_each_entry(host, pos, chain, h_hash) {
 			if (host->h_nsmhandle == nsm
-			 && host->h_nsmstate != info->state) {
-				host->h_nsmstate = info->state;
+			 && host->h_nsmstate != nsmstate) {
+				host->h_nsmstate = nsmstate;
 				host->h_state++;
 
 				nlm_get_host(host);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 3d1c594..3c20114 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -235,6 +235,8 @@ void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
+void		  nlm_host_rebooted_nsm(const struct nsm_handle *nsm,
+					const int nsmstate);
 void		  nlm_host_rebooted(const struct nlm_reboot *);
 
 /*

