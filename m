From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/17] NLM: Move the public declaration of nsm_monitor() to
	lockd.h
Date: Thu, 04 Dec 2008 14:21:24 -0500
Message-ID: <20081204192123.8039.60732.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:63837 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbYLDTWD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:22:03 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Make the nlm_host argument "const," and move the public declaration to
lockd.h with other NSM public function (nsm_release, eg) and global
variable declarations.

Add a documenting comment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   15 +++++++++++----
 include/linux/lockd/lockd.h    |    4 ++++
 include/linux/lockd/sm_inter.h |    1 -
 3 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 07e16b8..aaaa08e 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -69,11 +69,18 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
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
 	struct nsm_res	res;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index d3c7247..f15a4f5 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -242,6 +242,10 @@ extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
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
 

