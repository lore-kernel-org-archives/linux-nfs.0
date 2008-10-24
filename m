From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/14] NLM: Change nlm_host_rebooted() to take a single
	nlm_reboot argument
Date: Fri, 24 Oct 2008 14:10:46 -0400
Message-ID: <20081024181046.23810.74867.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41453 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315AbYJXSLQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:16 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBDSx008968
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:13 -0500
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9NG5TAY014514
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:12 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIAkDQ023979
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:46 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass the nlm_reboot data structure directly from the NLM_SM_NOTIFY
XDR decoder to nlm_host_rebooted().  This eliminates some packing and
unpacking of the NLM_SM_NOTIFY results, and prepares for passing
NLM_SM_NOTIFY's "priv" argument directly to nsm_find().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   31 +++++++++++++++++--------------
 fs/lockd/svc4proc.c         |   11 +----------
 fs/lockd/svcproc.c          |   11 +----------
 include/linux/lockd/lockd.h |    3 +--
 4 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 0fb0910..91e26be 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -492,31 +492,34 @@ void nlm_release_host(struct nlm_host *host)
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
@@ -531,8 +534,8 @@ again:	mutex_lock(&nlm_host_mutex);
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
index 20a56e9..d271169 100644
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

