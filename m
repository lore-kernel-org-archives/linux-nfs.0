From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/16] lockd: Combine __nsm_find() and nsm_find().
Date: Mon, 30 Jun 2008 18:59:34 -0400
Message-ID: <20080630225933.25407.78950.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51642 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764181AbYF3XAP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:15 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Having two separate functions doesn't add clarity, so
eliminate one of them.  Use contemporary kernel coding conventions
where appropriate.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   31 +++++++++++--------------------
 1 files changed, 11 insertions(+), 20 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index b10a6fe..808b67c 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -30,13 +30,11 @@ static unsigned long		next_gc;
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
+						const unsigned int hostname_len,
+						const int create);
 
 /*
  * Hash function must work well on big- and little-endian platforms
@@ -185,7 +183,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
-		nsm = nsm_find(sin, hostname, hostname_len);
+		nsm = nsm_find(sin, hostname, hostname_len, 1);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
@@ -419,8 +417,8 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 
 	dprintk("lockd: nlm_host_rebooted(%s)\n", hostname);
 
-	/* Find the NSM handle for this peer */
-	if (!(nsm = __nsm_find(sin, hostname, hostname_len, 0)))
+	nsm = nsm_find(sin, hostname, hostname_len, 0);
+	if (!nsm)
 		return;
 
 	/* When reclaiming locks on this peer, make sure that
@@ -553,10 +551,10 @@ nlm_gc_hosts(void)
 static LIST_HEAD(nsm_handles);
 static DEFINE_SPINLOCK(nsm_lock);
 
-static struct nsm_handle *
-__nsm_find(const struct sockaddr_in *sin,
-		const char *hostname, unsigned int hostname_len,
-		int create)
+static struct nsm_handle *nsm_find(const struct sockaddr_in *sin,
+				   const char *hostname,
+				   const unsigned int hostname_len,
+				   const int create)
 {
 	struct nsm_handle *nsm = NULL;
 	struct nsm_handle *pos;
@@ -614,13 +612,6 @@ found:
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

