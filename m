From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/16] lockd: Update nsm_find() to support non-AF_INET
	addresses
Date: Mon, 30 Jun 2008 18:59:42 -0400
Message-ID: <20080630225941.25407.35943.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51614 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763054AbYF3XAN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:13 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 808b67c..0e749e6 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -31,9 +31,10 @@ static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
-static struct nsm_handle	*nsm_find(const struct sockaddr_in *sin,
+static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
+						const size_t salen,
 						const char *hostname,
-						const unsigned int hostname_len,
+						const size_t hostname_len,
 						const int create);
 
 /*
@@ -183,7 +184,8 @@ static struct nlm_host *nlm_lookup_host(int server,
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
 
 	dprintk("lockd: nlm_host_rebooted(%s)\n", hostname);
 
-	nsm = nsm_find(sin, hostname, hostname_len, 0);
+	nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
+			hostname, hostname_len, 0);
 	if (!nsm)
 		return;
 
@@ -551,22 +554,23 @@ nlm_gc_hosts(void)
 static LIST_HEAD(nsm_handles);
 static DEFINE_SPINLOCK(nsm_lock);
 
-static struct nsm_handle *nsm_find(const struct sockaddr_in *sin,
+static struct nsm_handle *nsm_find(const struct sockaddr *sap,
+				   const size_t salen,
 				   const char *hostname,
-				   const unsigned int hostname_len,
+				   const size_t hostname_len,
 				   const int create)
 {
 	struct nsm_handle *nsm = NULL;
 	struct nsm_handle *pos;
 
-	if (!sin)
+	if (!sap)
 		return NULL;
 
 	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
 		if (printk_ratelimit()) {
 			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
 					    "in NFS lock request\n",
-				hostname_len, hostname);
+						(int)hostname_len, hostname);
 		}
 		return NULL;
 	}
@@ -579,7 +583,7 @@ retry:
 			if (strlen(pos->sm_name) != hostname_len
 			 || memcmp(pos->sm_name, hostname, hostname_len))
 				continue;
-		} else if (!nlm_cmp_addr(nsm_addr(pos), (struct sockaddr *)sin))
+		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
 			continue;
 		atomic_inc(&pos->sm_count);
 		kfree(nsm);
@@ -599,8 +603,8 @@ retry:
 	if (nsm == NULL)
 		return NULL;
 
-	memcpy(nsm_addr(nsm), sin, sizeof(*sin));
-	nsm->sm_addrlen = sizeof(*sin);
+	memcpy(nsm_addr(nsm), sap, salen);
+	nsm->sm_addrlen = salen;
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';

