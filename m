From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/18] NLM: Change nlm_host_rebooted() to take a single
	nlm_reboot argument
Date: Wed, 05 Nov 2008 12:20:34 -0500
Message-ID: <20081105172034.6773.64880.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34178 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbYKERVK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:10 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass the nlm_reboot data structure directly from the NLMPROC_SM_NOTIFY
XDR decoders to nlm_host_rebooted().  This eliminates some packing and
unpacking of the NLMPROC_SM_NOTIFY results, and prepares for passing
NLMPROC_SM_NOTIFY's "priv" argument directly to nsm_find().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   31 +++++++++++++++++--------------
 fs/lockd/svc4proc.c         |   11 +----------
 fs/lockd/svcproc.c          |   11 +----------
 include/linux/lockd/lockd.h |    3 +--
 4 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 50dcf79..7071acb 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -489,31 +489,34 @@ void nlm_release_host(struct nlm_host *host)
 	}
 }
 
-/*
- * We were notified that the host indicated by address &sin
- * has rebooted.
- * Release all resources held by that peer.
+/**
+ * nlm_host_rebooted - Release all resources held by rebooted host
+ * @info: pointer to decoded results of NLM_SM_NOTIFY call
+ *
+ * We were notified that the specified host has rebooted.  Release
+ * all resources held by that peer.
  */
-void nlm_host_rebooted(const struct sockaddr_in *sin,
-				const char *hostname,
-				unsigned int hostname_len,
-				u32 new_state)
+void nlm_host_rebooted(struct nlm_reboot *info)
 {
+	const struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= info->addr,
+	};
 	struct hlist_head *chain;
 	struct hlist_node *pos;
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
-	nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
-			hostname, hostname_len, 0);
+	nsm = nsm_find((struct sockaddr *)&sin, sizeof(sin),
+			info->mon, info->len, 0);
 	if (nsm == NULL) {
 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
-				hostname_len, hostname);
+				info->len, info->mon);
 		return;
 	}
 
 	dprintk("lockd: nlm_host_rebooted(%.*s, %s)\n",
-			hostname_len, hostname, nsm->sm_addrbuf);
+			info->len, info->mon, nsm->sm_addrbuf);
 
 	/* When reclaiming locks on this peer, make sure that
 	 * we set up a new notification */
@@ -528,8 +531,8 @@ again:	mutex_lock(&nlm_host_mutex);
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
 		hlist_for_each_entry(host, pos, chain, h_hash) {
 			if (host->h_nsmhandle == nsm
-			 && host->h_nsmstate != new_state) {
-				host->h_nsmstate = new_state;
+			 && host->h_nsmstate != info->state) {
+				host->h_nsmstate = info->state;
 				host->h_state++;
 
 				nlm_get_host(host);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 4dfdcbc..bb79a53 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -419,8 +419,6 @@ static __be32
 nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr;
-
 	dprintk("lockd: SM_NOTIFY     called\n");
 
 	if (!nlm_privileged_requester(rqstp)) {
@@ -430,14 +428,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 		return rpc_system_err;
 	}
 
-	/* Obtain the host pointer for this NFS server and try to
-	 * reclaim all locks we hold on this server.
-	 */
-	memset(&saddr, 0, sizeof(saddr));
-	saddr.sin_family = AF_INET;
-	saddr.sin_addr.s_addr = argp->addr;
-	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
-
+	nlm_host_rebooted(argp);
 	return rpc_success;
 }
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 3ca89e2..e44310c 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -451,8 +451,6 @@ static __be32
 nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr;
-
 	dprintk("lockd: SM_NOTIFY     called\n");
 
 	if (!nlm_privileged_requester(rqstp)) {
@@ -462,14 +460,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 		return rpc_system_err;
 	}
 
-	/* Obtain the host pointer for this NFS server and try to
-	 * reclaim all locks we hold on this server.
-	 */
-	memset(&saddr, 0, sizeof(saddr));
-	saddr.sin_family = AF_INET;
-	saddr.sin_addr.s_addr = argp->addr;
-	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
-
+	nlm_host_rebooted(argp);
 	return rpc_success;
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 6178fcc..8f6369d 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -239,8 +239,7 @@ void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
 void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
-extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
-					unsigned int, u32);
+void		  nlm_host_rebooted(struct nlm_reboot *);
 
 /*
  * Host monitoring

