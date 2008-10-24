From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/14] NSM: Move NSM-related function and variable
	declarations to lockd.h
Date: Fri, 24 Oct 2008 14:10:17 -0400
Message-ID: <20081024181016.23810.69413.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41765 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbYJXSL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:26 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBKbh009829
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:20 -0500
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9OECxtZ022218
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:19 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIAH8B023923
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:17 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 1c058b1..d48ae14 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -159,11 +159,12 @@ void nsm_release(struct nsm_handle *nsm)
 	}
 }
 
-/*
- * Set up monitoring of a remote host
+/**
+ * nsm_monitor - Set up monitoring of a remote host
+ * @host: pointer to nlm_host representing remote peer to monitor
+ *
  */
-int
-nsm_monitor(struct nlm_host *host)
+int nsm_monitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
@@ -184,11 +185,12 @@ nsm_monitor(struct nlm_host *host)
 	return status;
 }
 
-/*
- * Cease to monitor remote host
+/**
+ * nsm_unmonitor - Cease to monitor remote host
+ * @host: pointer to nlm_host representing remote peer to stop monitoring
+ *
  */
-int
-nsm_unmonitor(struct nlm_host *host)
+int nsm_unmonitor(struct nlm_host *host)
 {
 	struct nsm_handle *nsm = host->h_nsmhandle;
 	struct nsm_res	res;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a45be5d..6dc1043 100644
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

