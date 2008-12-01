From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] NSM: Serialize SM_MON and SM_UNMON upcalls
Date: Mon, 01 Dec 2008 13:58:13 -0500
Message-ID: <20081201185812.10600.92501.stgit@ingres.1015granger.net>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29733 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbYLAS7H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:59:07 -0500
In-Reply-To: <20081201185108.10600.21700.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux NSM implementation currently does nothing to prevent
concurrent SM_MON and SM_UNMON upcalls regarding the same peer.  Races
could cause duplicate SM_MON upcalls for the same peer, or locking
activity during server shutdown might cause SM_MON and SM_UNMON upcalls
to occur in an arbitrary order.

To avoid confusing rpc.statd, add a per-nsm_handle mutex to serialize
the upcalls.  To prevent duplicate upcalls, the mutex is held while the
upcall is outstanding, and is not released until we can tell if the
upcall succeeded.

The nsm_monitor() function is called frequently.  The extra inline
function mitigates the overhead of taking the mutex.  It is only taken
if the nsm_handle is not already monitored.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    1 +
 fs/lockd/mon.c              |   23 ++++++++++++++++-------
 include/linux/lockd/lockd.h |   12 +++++++++++-
 3 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 8d26d0c..bf705d0 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -697,6 +697,7 @@ retry:
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';
+	mutex_init(&nsm->sm_mutex);
 	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
 				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
 	atomic_set(&nsm->sm_count, 1);
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index b76d9b2..301aeb7 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -70,8 +70,8 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 }
 
 /**
- * nsm_monitor - Notify a peer in case we reboot
- * @host: pointer to nlm_host of peer to notify
+ * __nsm_monitor - Notify a peer in case we reboot
+ * @nsm: pointer to nsm_handle of peer to notify
  *
  * If this peer is not already monitored, this function sends an
  * upcall to the local rpc.statd to record the name/address of
@@ -80,16 +80,17 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
  * Returns zero if the peer is monitored by the local rpc.statd;
  * otherwise a negative errno value is returned.
  */
-int nsm_monitor(const struct nlm_host *host)
+int __nsm_monitor(struct nsm_handle *nsm)
 {
-	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res res;
-	int status;
+	int status = 0;
 
 	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
 
+	mutex_lock(&nsm->sm_mutex);
+
 	if (nsm->sm_monitored)
-		return 0;
+		goto out;
 
 	/*
 	 * Choose whether to record the caller_name or IP address of
@@ -104,6 +105,9 @@ int nsm_monitor(const struct nlm_host *host)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
 	else
 		nsm->sm_monitored = 1;
+
+out:
+	mutex_unlock(&nsm->sm_mutex);
 	return status;
 }
 
@@ -121,8 +125,10 @@ void nsm_unmonitor(struct nsm_handle *nsm)
 
 	dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
 
+	mutex_lock(&nsm->sm_mutex);
+
 	if (!nsm->sm_monitored)
-		return;
+		goto out;
 
 	if (atomic_read(&nsm->sm_count) == 1 && !nsm->sm_sticky) {
 		if (nsm_mon_unmon(nsm, SM_UNMON, &res) < 0)
@@ -131,6 +137,9 @@ void nsm_unmonitor(struct nsm_handle *nsm)
 		else
 			nsm->sm_monitored = 0;
 	}
+
+out:
+	mutex_unlock(&nsm->sm_mutex);
 }
 
 /*
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index e2fa968..bf6c1c1 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -76,6 +76,7 @@ struct nsm_handle {
 	char *			sm_mon_name;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
+	struct mutex		sm_mutex;
 	char			sm_addrbuf[63];	/* presentation address */
 };
 
@@ -236,9 +237,18 @@ void		  nsm_release(struct nsm_handle *);
 /*
  * Host monitoring
  */
-int		  nsm_monitor(const struct nlm_host *host);
+int		  __nsm_monitor(struct nsm_handle *nsm);
 void		  nsm_unmonitor(struct nsm_handle *nsm);
 
+static inline int nsm_monitor(const struct nlm_host *host)
+{
+	struct nsm_handle *nsm = host->h_nsmhandle;
+
+	if (likely(nsm->sm_monitored))
+		return 0;
+	return __nsm_monitor(nsm);
+}
+
 /*
  * This is used in garbage collection and resource reclaim
  * A return value != 0 means destroy the lock/block/share

