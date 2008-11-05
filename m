From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/18] NSM: Move NSM-related function and variable
	declarations to lockd.h
Date: Wed, 05 Nov 2008 12:20:05 -0500
Message-ID: <20081105172005.6773.74231.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34378 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbYKERVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:31 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Keep the NSM function declarations together with the
declarations already in lockd.h, and modernize the documenting
comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   18 ++++++++++--------
 include/linux/lockd/lockd.h    |    4 ++++
 include/linux/lockd/sm_inter.h |    4 ----
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 9c9406d..4ffd556 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -93,11 +93,12 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	return status;
 }
 
-/*
- * Set up monitoring of a remote host
+/**
+ * nsm_monitor - Set up monitoring of a remote host
+ * @host: pointer to nlm_host of peer to start monitoring
+ *
  */
-int
-nsm_monitor(struct nlm_host *host)
+int nsm_monitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
@@ -118,11 +119,12 @@ nsm_monitor(struct nlm_host *host)
 	return status;
 }
 
-/*
- * Cease to monitor remote host
+/**
+ * nsm_unmonitor - Cease to monitor remote host
+ * @host: pointer to nlm_host of peer to stop monitoring
+ *
  */
-int
-nsm_unmonitor(struct nlm_host *host)
+int nsm_unmonitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 34f0101..d8fa8d3 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -200,7 +200,9 @@ extern struct svc_procedure	nlmsvc_procedures4[];
 #endif
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
+
 extern int			nsm_use_hostnames;
+extern int			nsm_local_state;
 
 /*
  * Lockd client functions
@@ -247,6 +249,8 @@ struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
 					const size_t hostname_len,
 					const int create);
 void		  nsm_release(struct nsm_handle *nsm);
+int		  nsm_monitor(struct nlm_host *host);
+int		  nsm_unmonitor(struct nlm_host *host);
 
 /*
  * This is used in garbage collection and resource reclaim
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 5a5448b..f75d3ea 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -41,8 +41,4 @@ struct nsm_res {
 	u32		state;
 };
 
-int		nsm_monitor(struct nlm_host *);
-int		nsm_unmonitor(struct nlm_host *);
-extern int	nsm_local_state;
-
 #endif /* LINUX_LOCKD_SM_INTER_H */

