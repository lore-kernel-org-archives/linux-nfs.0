From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/11] NSM: Move nsm_addr() to fs/lockd/mon.c
Date: Thu, 11 Dec 2008 17:56:22 -0500
Message-ID: <20081211225621.21468.44600.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:22045 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759559AbYLKW4r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:47 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index acda46f..534d6de 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -55,6 +55,11 @@ static				DEFINE_SPINLOCK(nsm_lock);
  */
 int				nsm_local_state;
 
+static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
+{
+	return (struct sockaddr *)&nsm->sm_addr;
+}
+
 static void nsm_display_ipv4_address(const struct sockaddr *sap, char *buf,
 				     const size_t len)
 {
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 8b57467..6ab0449 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -112,16 +112,6 @@ static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
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

