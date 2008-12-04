From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/17] NLM: Move the public declaration of nsm_unmonitor() to
	lockd.h
Date: Thu, 04 Dec 2008 14:21:38 -0500
Message-ID: <20081204192138.8039.49521.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17773 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbYLDTWF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:22:05 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Make the nlm_host argument "const," and move the public declaration to
lockd.h.  Add a documenting comment.

Bruce observed that nsm_unmonitor()'s only caller doesn't care about
its return code, so make nsm_unmonitor() return void.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   15 +++++++++------
 include/linux/lockd/lockd.h    |    1 +
 include/linux/lockd/sm_inter.h |    1 -
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 15fab22..d61cdc6 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -107,15 +107,19 @@ int nsm_monitor(const struct nlm_host *host)
 	return status;
 }
 
-/*
- * Cease to monitor remote host
+/**
+ * nsm_unmonitor - Unregister peer notification
+ * @host: pointer to nlm_host of peer to stop monitoring
+ *
+ * If this peer is monitored, this function sends an upcall to
+ * tell the local rpc.statd not to send this peer a notification
+ * when we reboot.
  */
-int
-nsm_unmonitor(struct nlm_host *host)
+void nsm_unmonitor(const struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
-	int		status = 0;
+	int status;
 
 	if (atomic_read(&nsm->sm_count) == 1
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
@@ -128,7 +132,6 @@ nsm_unmonitor(struct nlm_host *host)
 		else
 			nsm->sm_monitored = 0;
 	}
-	return status;
 }
 
 /*
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 30a6a9c..38344bf 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -245,6 +245,7 @@ extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
  * Host monitoring
  */
 int		  nsm_monitor(const struct nlm_host *host);
+void		  nsm_unmonitor(const struct nlm_host *host);
 
 /*
  * This is used in garbage collection and resource reclaim
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 546b610..896a5e3 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -41,7 +41,6 @@ struct nsm_res {
 	u32		state;
 };
 
-int		nsm_unmonitor(struct nlm_host *);
 extern int	nsm_local_state;
 
 #endif /* LINUX_LOCKD_SM_INTER_H */

