From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/18] NSM: Move nsm_addr() to fs/lockd/mon.c
Date: Wed, 05 Nov 2008 12:21:33 -0500
Message-ID: <20081105172133.6773.5155.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34503 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbYKERVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:52 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: nsm_addr_in() is no longer used, and nsm_addr() is used only in
fs/lockd/mon.c, so move it there.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c              |    5 +++++
 include/linux/lockd/lockd.h |   10 ----------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 8538180..b233b01 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -73,6 +73,11 @@ static struct rpc_clnt *nsm_create(void)
 	return rpc_create(&args);
 }
 
+static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
+{
+	return (struct sockaddr *)&nsm->sm_addr;
+}
+
 /*
  * Common procedure for NSMPROC_MON/NSMPROC_UNMON calls
  */
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ad1f848..6fc4f3e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -109,16 +109,6 @@ static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
 	return (struct sockaddr *)&host->h_srcaddr;
 }
 
-static inline struct sockaddr_in *nsm_addr_in(const struct nsm_handle *handle)
-{
-	return (struct sockaddr_in *)&handle->sm_addr;
-}
-
-static inline struct sockaddr *nsm_addr(const struct nsm_handle *handle)
-{
-	return (struct sockaddr *)&handle->sm_addr;
-}
-
 /*
  * Map an fl_owner_t into a unique 32-bit "pid"
  */

