From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] lockd: Update nsm_find() to support non-AF_INET addresses
Date: Wed, 03 Sep 2008 14:36:23 -0400
Message-ID: <20080903183623.16867.21356.stgit@ingres.1015granger.net>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56839 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbYICSgg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 14:36:36 -0400
In-Reply-To: <20080903183411.16867.33715.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index b9eeafe..be8f19d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -32,7 +32,8 @@ static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
-static struct nsm_handle	*nsm_find(const struct sockaddr_in *sin,
+static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
+						const size_t salen,
 						const char *hostname,
 						const size_t hostname_len,
 						const int create);
@@ -185,7 +186,8 @@ static struct nlm_host *nlm_lookup_host(int server,
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
-		nsm = nsm_find(sin, hostname, hostname_len, 1);
+		nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
+				hostname, hostname_len, 1);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
@@ -417,7 +419,8 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
-	nsm = nsm_find(sin, hostname, hostname_len, 0);
+	nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
+			hostname, hostname_len, 0);
 	if (nsm == NULL) {
 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
 				hostname_len, hostname);
@@ -557,7 +560,8 @@ nlm_gc_hosts(void)
 static LIST_HEAD(nsm_handles);
 static DEFINE_SPINLOCK(nsm_lock);
 
-static struct nsm_handle *nsm_find(const struct sockaddr_in *sin,
+static struct nsm_handle *nsm_find(const struct sockaddr *sap,
+				   const size_t salen,
 				   const char *hostname,
 				   const size_t hostname_len,
 				   const int create)
@@ -565,7 +569,7 @@ static struct nsm_handle *nsm_find(const struct sockaddr_in *sin,
 	struct nsm_handle *nsm = NULL;
 	struct nsm_handle *pos;
 
-	if (!sin)
+	if (!sap)
 		return NULL;
 
 	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
@@ -585,7 +589,7 @@ retry:
 			if (strlen(pos->sm_name) != hostname_len
 			 || memcmp(pos->sm_name, hostname, hostname_len))
 				continue;
-		} else if (!nlm_cmp_addr(nsm_addr(pos), (struct sockaddr *)sin))
+		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
 			continue;
 		atomic_inc(&pos->sm_count);
 		kfree(nsm);
@@ -605,8 +609,8 @@ retry:
 	if (nsm == NULL)
 		return NULL;
 
-	memcpy(nsm_addr(nsm), sin, sizeof(*sin));
-	nsm->sm_addrlen = sizeof(*sin);
+	memcpy(nsm_addr(nsm), sap, salen);
+	nsm->sm_addrlen = salen;
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';

