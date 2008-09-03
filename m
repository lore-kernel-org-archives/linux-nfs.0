From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] lockd: Combine __nsm_find() and nsm_find().
Date: Wed, 03 Sep 2008 14:36:16 -0400
Message-ID: <20080903183615.16867.58815.stgit@ingres.1015granger.net>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56711 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563AbYICSg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 14:36:29 -0400
In-Reply-To: <20080903183411.16867.33715.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Having two separate functions doesn't add clarity, so
eliminate one of them.  Use contemporary kernel coding conventions
where appropriate.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   32 +++++++++++---------------------
 1 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 1f9d72a..b9eeafe 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -31,13 +31,11 @@ static unsigned long		next_gc;
 static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
-
 static void			nlm_gc_hosts(void);
-static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
-					const char *, unsigned int, int);
-static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
-					 const char *hostname,
-					 unsigned int hostname_len);
+static struct nsm_handle	*nsm_find(const struct sockaddr_in *sin,
+						const char *hostname,
+						const size_t hostname_len,
+						const int create);
 
 /*
  * Hash function must work well on big- and little-endian platforms
@@ -187,7 +185,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
-		nsm = nsm_find(sin, hostname, hostname_len);
+		nsm = nsm_find(sin, hostname, hostname_len, 1);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
@@ -419,8 +417,7 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
-	/* Find the NSM handle for this peer */
-	nsm = __nsm_find(sin, hostname, hostname_len, 0);
+	nsm = nsm_find(sin, hostname, hostname_len, 0);
 	if (nsm == NULL) {
 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
 				hostname_len, hostname);
@@ -560,10 +557,10 @@ nlm_gc_hosts(void)
 static LIST_HEAD(nsm_handles);
 static DEFINE_SPINLOCK(nsm_lock);
 
-static struct nsm_handle *
-__nsm_find(const struct sockaddr_in *sin,
-		const char *hostname, unsigned int hostname_len,
-		int create)
+static struct nsm_handle *nsm_find(const struct sockaddr_in *sin,
+				   const char *hostname,
+				   const size_t hostname_len,
+				   const int create)
 {
 	struct nsm_handle *nsm = NULL;
 	struct nsm_handle *pos;
@@ -575,7 +572,7 @@ __nsm_find(const struct sockaddr_in *sin,
 		if (printk_ratelimit()) {
 			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
 					    "in NFS lock request\n",
-				hostname_len, hostname);
+				(int)hostname_len, hostname);
 		}
 		return NULL;
 	}
@@ -623,13 +620,6 @@ found:
 	return nsm;
 }
 
-static struct nsm_handle *
-nsm_find(const struct sockaddr_in *sin, const char *hostname,
-	 unsigned int hostname_len)
-{
-	return __nsm_find(sin, hostname, hostname_len, 1);
-}
-
 /*
  * Release an NSM handle
  */

