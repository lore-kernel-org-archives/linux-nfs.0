From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 04/12] lockd: unmonitor only when last host goes away
Date: Wed,  5 Nov 2008 15:06:43 -0500
Message-ID: <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39489 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757500AbYKEUGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:55 -0500
In-Reply-To: <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sm_sticky logic seems racy; instead just unmonitor before
destruction of handle.

XXX: how to test?

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c             |   24 ++++++++++++++++++++----
 fs/lockd/mon.c              |   15 +--------------
 fs/lockd/svcsubs.c          |    6 ------
 include/linux/lockd/lockd.h |    3 +--
 4 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index e9069c2..1a1adb9 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -683,6 +683,10 @@ found:
 	return nsm;
 }
 
+
+/* XXX: */
+int nsm_mon_unmon(struct nsm_handle *, u32, struct nsm_res *);
+
 /*
  * Release an NSM handle
  */
@@ -691,9 +695,21 @@ nsm_release(struct nsm_handle *nsm)
 {
 	if (!nsm)
 		return;
-	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
-		list_del(&nsm->sm_link);
-		spin_unlock(&nsm_lock);
-		kfree(nsm);
+	if (!atomic_dec_and_lock(&nsm->sm_count, &nsm_lock))
+		return;
+	list_del(&nsm->sm_link);
+	spin_unlock(&nsm_lock);
+	if (nsm->sm_monitored) {
+		struct nsm_res res;
+		int status;
+
+		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
+		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
+		if (status < 0)
+			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
+					nsm->sm_name);
+		else
+			nsm->sm_monitored = 0;
 	}
+	kfree(nsm);
 }
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 480f197..8cc0e97 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -32,7 +32,7 @@ int				nsm_local_state;
 /*
  * Common procedure for SM_MON/SM_UNMON calls
  */
-static int
+int
 nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
@@ -100,24 +100,11 @@ nsm_monitor(struct nlm_host *host)
 void nsm_unmonitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
-	struct nsm_res	res;
-	int		status;
 
 	if (nsm == NULL)
 		return;
 	host->h_nsmhandle = NULL;
 
-	if (atomic_read(&nsm->sm_count) == 1
-	 && nsm->sm_monitored && !nsm->sm_sticky) {
-		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
-
-		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
-		if (status < 0)
-			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
-					host->h_name);
-		else
-			nsm->sm_monitored = 0;
-	}
 	nsm_release(nsm);
 }
 
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 9c186f0..0296904 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -336,12 +336,6 @@ nlmsvc_is_client(void *data, struct nlm_host *dummy)
 	struct nlm_host *host = data;
 
 	BUG_ON(!host->h_server);
-	/* we are destroying locks even though the client
-	 * hasn't asked us too, so don't unmonitor the
-	 * client
-	 */
-	if (host->h_nsmhandle)
-		host->h_nsmhandle->sm_sticky = 1;
 	return 1;
 
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index b56d5aa..e1c2690 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -75,8 +75,7 @@ struct nsm_handle {
 	char *			sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;
-	unsigned int		sm_monitored : 1,
-				sm_sticky : 1;	/* don't unmonitor */
+	unsigned int		sm_monitored : 1;
 	char			sm_addrbuf[48];	/* address eyecatcher */
 };
 
-- 
1.5.5.rc1

