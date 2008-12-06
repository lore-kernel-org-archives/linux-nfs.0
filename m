From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/27] NSM: Move nsm_addr() to fs/lockd/mon.c
Date: Fri, 05 Dec 2008 19:04:40 -0500
Message-ID: <20081206000439.24075.51755.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:25931 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbYLFAJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:09:43 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 97011ee..2e0ec9f 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -53,6 +53,11 @@ static				DEFINE_SPINLOCK(nsm_lock);
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

