From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] NLM: Clean up nsm_monitor() call
Date: Mon, 01 Dec 2008 13:57:58 -0500
Message-ID: <20081201185757.10600.38854.stgit@ingres.1015granger.net>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:34033 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbYLAS7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:59:47 -0500
In-Reply-To: <20081201185108.10600.21700.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: A few minor clean-ups for nsm_monitor():

 o  Make sure to return an error if the SM_MON call result is not zero.

 o  Remove the BUG_ON() -- the code will die anyway if nsm is NULL.

 o  Use nsm->sm_name instead of host->h_name to be consistent with
    other functions in fs/lockd/mon.c.

 o  Collect the public declaration of nsm_monitor() in lockd.h with
    other NSM public function declarations (eg. nsm_release).

 o  Add documenting comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   29 ++++++++++++++++++-----------
 include/linux/lockd/lockd.h    |    4 ++++
 include/linux/lockd/sm_inter.h |    1 -
 3 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index a606fbb..78d5f59 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -69,18 +69,24 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	return status;
 }
 
-/*
- * Set up monitoring of a remote host
+/**
+ * nsm_monitor - Notify a peer in case we reboot
+ * @host: pointer to nlm_host of peer to notify
+ *
+ * If this peer is not already monitored, this function sends an
+ * upcall to the local rpc.statd to record the name/address of
+ * the peer to notify in case we reboot.
+ *
+ * Returns zero if the peer is monitored by the local rpc.statd;
+ * otherwise a negative errno value is returned.
  */
-int
-nsm_monitor(struct nlm_host *host)
+int nsm_monitor(const struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
-	struct nsm_res	res;
-	int		status;
+	struct nsm_res res;
+	int status;
 
-	dprintk("lockd: nsm_monitor(%s)\n", host->h_name);
-	BUG_ON(nsm == NULL);
+	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
 
 	if (nsm->sm_monitored)
 		return 0;
@@ -92,9 +98,10 @@ nsm_monitor(struct nlm_host *host)
 	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
 
 	status = nsm_mon_unmon(nsm, SM_MON, &res);
-
-	if (status < 0 || res.status != 0)
-		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
+	if (res.status != 0)
+		status = -EIO;
+	if (status < 0)
+		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
 	else
 		nsm->sm_monitored = 1;
 	return status;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index de9ea7b..4ca6f39 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -233,6 +233,10 @@ extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
 					unsigned int, u32);
 void		  nsm_release(struct nsm_handle *);
 
+/*
+ * Host monitoring
+ */
+int		  nsm_monitor(const struct nlm_host *host);
 
 /*
  * This is used in garbage collection and resource reclaim
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 5a5448b..546b610 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -41,7 +41,6 @@ struct nsm_res {
 	u32		state;
 };
 
-int		nsm_monitor(struct nlm_host *);
 int		nsm_unmonitor(struct nlm_host *);
 extern int	nsm_local_state;
 

